use gtk::prelude::*;
use gtk::{glib, Align, Application, ApplicationWindow, Button, FileDialog, Label, Orientation, ScrolledWindow};
use relm4::{ComponentParts, ComponentSender, SimpleComponent, Component, Controller};
use std::path::PathBuf;

use crate::color_extractor::{Color, ColorExtractor};
use crate::widgets::color_card::{ColorCard, ColorCardOutput};

#[derive(Debug)]
pub struct App {
    current_image: Option<PathBuf>,
    colors: Vec<Color>,
    status_message: String,
    color_count: u8,
    color_cards: Vec<Controller<ColorCard>>,
}

#[derive(Debug)]
pub enum AppMsg {
    OpenImage,
    ImageSelected(Option<PathBuf>),
    ExtractColors,
    ColorCountChanged(u8),
    ColorCopied(String),
}

#[relm4::component(pub)]
impl SimpleComponent for App {
    type Init = ();
    type Input = AppMsg;
    type Output = ();

    view! {
        ApplicationWindow {
            set_title: Some("Pluck - Color Palette Extractor"),
            set_default_width: 800,
            set_default_height: 600,

            gtk::Box {
                set_orientation: Orientation::Vertical,
                set_spacing: 0,

                // Header bar
                gtk::HeaderBar {
                    pack_start = &gtk::Button {
                        set_label: "Open Image",
                        set_icon_name: "document-open",
                        connect_clicked => AppMsg::OpenImage,
                    },

                    #[wrap(Some)]
                    set_title_widget = &gtk::Box {
                        set_orientation: Orientation::Vertical,
                        set_valign: Align::Center,

                        gtk::Label {
                            set_label: "Pluck",
                            add_css_class: "title",
                        },
                    },

                    pack_end = &gtk::SpinButton::with_range(2.0, 20.0, 1.0) {
                        set_value: model.color_count as f64,
                        set_tooltip_text: Some("Number of colors to extract"),
                        connect_value_changed[sender] => move |spin| {
                            sender.input(AppMsg::ColorCountChanged(spin.value() as u8));
                        },
                    },
                },

                // Main content area
                gtk::Box {
                    set_orientation: Orientation::Vertical,
                    set_vexpand: true,
                    set_margin_all: 16,
                    set_spacing: 16,

                    // Status bar
                    gtk::Box {
                        set_orientation: Orientation::Horizontal,
                        set_spacing: 8,
                        add_css_class: "status-bar",

                        gtk::Label {
                            #[watch]
                            set_label: &model.status_message,
                            set_hexpand: true,
                            set_xalign: 0.0,
                        },

                        gtk::Button {
                            set_label: "Extract Colors",
                            add_css_class: "suggested-action",
                            #[watch]
                            set_sensitive: model.current_image.is_some(),
                            connect_clicked => AppMsg::ExtractColors,
                        },
                    },

                    // Color palette display
                    gtk::ScrolledWindow {
                        set_vexpand: true,
                        set_hexpand: true,

                        #[wrap(Some)]
                        set_child = &gtk::FlowBox {
                            set_selection_mode: gtk::SelectionMode::None,
                            set_homogeneous: true,
                            set_row_spacing: 8,
                            set_column_spacing: 8,
                            set_margin_all: 8,

                            #[local_ref]
                            color_grid -> gtk::Box {
                                set_orientation: Orientation::Horizontal,
                                set_spacing: 8,
                                set_homogeneous: false,
                            },
                        },
                    },
                },
            },
        }
    }

    fn init(
        _init: Self::Init,
        root: Self::Root,
        sender: ComponentSender<Self>,
    ) -> ComponentParts<Self> {
        let model = App {
            current_image: None,
            colors: Vec::new(),
            status_message: "Open an image to extract colors".to_string(),
            color_count: 8,
            color_cards: Vec::new(),
        };

        let color_grid = gtk::Box::new(Orientation::Horizontal, 8);
        let widgets = view_output!();

        ComponentParts { model, widgets }
    }

    fn update(&mut self, msg: Self::Input, sender: ComponentSender<Self>) {
        match msg {
            AppMsg::OpenImage => {
                let sender = sender.clone();
                glib::spawn_future_local(async move {
                    let dialog = FileDialog::builder()
                        .title("Select an Image")
                        .modal(true)
                        .build();

                    // Add image filters
                    let filter = gtk::FileFilter::new();
                    filter.set_name(Some("Images"));
                    filter.add_mime_type("image/png");
                    filter.add_mime_type("image/jpeg");
                    filter.add_mime_type("image/jpg");
                    filter.add_mime_type("image/webp");
                    filter.add_mime_type("image/gif");
                    filter.add_pattern("*.png");
                    filter.add_pattern("*.jpg");
                    filter.add_pattern("*.jpeg");
                    filter.add_pattern("*.webp");
                    filter.add_pattern("*.gif");

                    let filters = gtk::gio::ListStore::new::<gtk::FileFilter>();
                    filters.append(&filter);
                    dialog.set_filters(Some(&filters));

                    let file = dialog.open_future(None::<&ApplicationWindow>).await;
                    
                    if let Ok(file) = file {
                        let path = file.path().map(|p| p.to_path_buf());
                        sender.input(AppMsg::ImageSelected(path));
                    }
                });
            }

            AppMsg::ImageSelected(path) => {
                if let Some(path) = path {
                    self.status_message = format!("Selected: {}", path.display());
                    self.current_image = Some(path);
                    // Automatically extract colors when image is selected
                    sender.input(AppMsg::ExtractColors);
                }
            }

            AppMsg::ExtractColors => {
                if let Some(ref path) = self.current_image {
                    self.status_message = "Extracting colors...".to_string();
                    
                    match ColorExtractor::extract_from_path(path, self.color_count) {
                        Ok(colors) => {
                            self.colors = colors;
                            self.status_message = format!(
                                "Extracted {} colors from {}",
                                self.colors.len(),
                                path.file_name()
                                    .and_then(|n| n.to_str())
                                    .unwrap_or("image")
                            );
                            
                            // Clear existing color cards
                            self.color_cards.clear();
                            
                            // Create new color cards
                            for color in &self.colors {
                                let color_card = ColorCard::builder()
                                    .launch(color.clone())
                                    .forward(sender.input_sender(), |msg| match msg {
                                        ColorCardOutput::ColorCopied(text) => AppMsg::ColorCopied(text),
                                    });
                                self.color_cards.push(color_card);
                            }
                        }
                        Err(e) => {
                            self.status_message = format!("Error: {}", e);
                            self.colors.clear();
                            self.color_cards.clear();
                        }
                    }
                }
            }

            AppMsg::ColorCountChanged(count) => {
                self.color_count = count;
                // Re-extract if we have an image
                if self.current_image.is_some() {
                    sender.input(AppMsg::ExtractColors);
                }
            }

            AppMsg::ColorCopied(message) => {
                self.status_message = message;
            }
        }
    }
}
