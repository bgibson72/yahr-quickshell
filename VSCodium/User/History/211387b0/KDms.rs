use gtk::prelude::*;
use gtk::{glib, Align, ApplicationWindow, FileDialog, Orientation};
use relm4::{ComponentParts, ComponentSender, SimpleComponent, RelmWidgetExt};
use std::path::PathBuf;

use crate::color_extractor::{Color, ColorExtractor};

pub struct App {
    current_image: Option<PathBuf>,
    image_texture: Option<gtk::gdk::Texture>,
    placeholder_texture: Option<gtk::gdk::Texture>,
    colors: Vec<Color>,
    status_message: String,
    color_count: u8,
    color_grid_widget: Option<gtk::FlowBox>,
    image_preview_widget: Option<gtk::Picture>,
}

#[derive(Debug)]
pub enum AppMsg {
    OpenImage,
    ImageSelected(Option<PathBuf>),
    ExtractColors,
    ColorCountChanged(u8),
    CopyColor(String),
}

#[relm4::component(pub)]
impl SimpleComponent for App {
    type Init = ();
    type Input = AppMsg;
    type Output = ();

    view! {
        ApplicationWindow {
            set_title: Some("Pluck - Color Palette Extractor"),
            set_default_width: 1000,
            set_default_height: 700,

            gtk::Box {
                set_orientation: Orientation::Vertical,
                set_spacing: 0,

                gtk::HeaderBar {
                    #[wrap(Some)]
                    set_title_widget = &gtk::Box {
                        set_orientation: Orientation::Vertical,
                        set_valign: Align::Center,

                        gtk::Label {
                            set_label: "Pluck",
                            add_css_class: "title",
                        },
                    },
                },

                gtk::Box {
                    set_orientation: Orientation::Vertical,
                    set_vexpand: true,
                    set_margin_all: 16,
                    set_spacing: 16,

                    // Top control bar: Image preview + controls
                    gtk::Box {
                        set_orientation: Orientation::Horizontal,
                        set_spacing: 20,
                        set_margin_bottom: 8,

                        // Image preview (leftmost)
                        gtk::Frame {
                            set_hexpand: false,
                            add_css_class: "image-preview-frame",
                            
                            #[wrap(Some)]
                            set_child: image_preview = &gtk::Picture {
                                set_width_request: 200,
                                set_height_request: 200,
                                set_can_shrink: true,
                                set_content_fit: gtk::ContentFit::Contain,
                                #[watch]
                                set_paintable: model.image_texture.as_ref()
                                    .map(|t| t.upcast_ref::<gtk::gdk::Paintable>())
                                    .or_else(|| model.placeholder_texture.as_ref()
                                        .map(|t| t.upcast_ref::<gtk::gdk::Paintable>())),
                            },
                        },

                        // Controls column
                        gtk::Box {
                            set_orientation: Orientation::Vertical,
                            set_spacing: 16,
                            set_hexpand: true,
                            set_valign: Align::Start,

                            // Select Image button
                            gtk::Button {
                                set_label: "Select An Image",
                                add_css_class: "suggested-action",
                                set_height_request: 48,
                                set_halign: Align::Start,
                                connect_clicked => AppMsg::OpenImage,
                            },

                            // Selected filename
                            gtk::Label {
                                #[watch]
                                set_label: &if let Some(ref path) = model.current_image {
                                    format!("📁 {}", path.file_name()
                                        .and_then(|n| n.to_str())
                                        .unwrap_or("Unknown"))
                                } else {
                                    String::new()
                                },
                                set_wrap: true,
                                set_xalign: 0.0,
                                set_halign: Align::Start,
                                add_css_class: "dim-label",
                                #[watch]
                                set_visible: model.current_image.is_some(),
                            },

                            // Number of colors control
                            gtk::Box {
                                set_orientation: Orientation::Horizontal,
                                set_spacing: 12,
                                set_halign: Align::Start,

                                gtk::Label {
                                    set_label: "Number of Colors:",
                                },

                                gtk::SpinButton::with_range(2.0, 20.0, 1.0) {
                                    set_value: model.color_count as f64,
                                    set_tooltip_text: Some("Number of colors to extract"),
                                    connect_value_changed[sender] => move |spin| {
                                        sender.input(AppMsg::ColorCountChanged(spin.value() as u8));
                                    },
                                },
                            },

                            // Status message (only shown when there's a real message)
                            gtk::Label {
                                #[watch]
                                set_label: &model.status_message,
                                set_wrap: true,
                                set_xalign: 0.0,
                                set_halign: Align::Start,
                                add_css_class: "status-label",
                                #[watch]
                                set_visible: !model.status_message.is_empty() && model.current_image.is_some(),
                            },
                        },
                    },

                    gtk::Separator {
                        set_orientation: Orientation::Horizontal,
                    },

                    // Color palette display - grid layout
                    gtk::ScrolledWindow {
                        set_vexpand: true,
                        set_hexpand: true,
                        set_min_content_height: 300,

                        #[wrap(Some)]
                        set_child: color_grid = &gtk::FlowBox {
                            set_selection_mode: gtk::SelectionMode::None,
                            set_max_children_per_line: 4,
                            set_min_children_per_line: 1,
                            set_row_spacing: 16,
                            set_column_spacing: 16,
                            set_margin_start: 16,
                            set_margin_end: 16,
                            set_margin_top: 16,
                            set_margin_bottom: 16,
                            set_halign: Align::Start,
                            set_valign: Align::Start,
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
        // Create a placeholder image
        let placeholder_texture = create_placeholder_image();
        
        let mut model = App {
            current_image: None,
            image_texture: None,
            placeholder_texture: Some(placeholder_texture),
            colors: Vec::new(),
            status_message: String::new(),
            color_count: 8,
            color_grid_widget: None,
            image_preview_widget: None,
        };

        let widgets = view_output!();
        
        // Store the color grid widget reference
        model.color_grid_widget = Some(widgets.color_grid.clone());
        model.image_preview_widget = Some(widgets.image_preview.clone());

        // Add initial placeholder color cards
        if let Some(ref grid) = model.color_grid_widget {
            for _ in 0..model.color_count {
                let placeholder = create_placeholder_color_card();
                grid.insert(&placeholder, -1);
            }
        }

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
                    // Load the image as a texture for preview
                    match gtk::gdk::Texture::from_filename(&path) {
                        Ok(texture) => {
                            self.image_texture = Some(texture);
                            self.status_message = format!("Loaded: {}", 
                                path.file_name()
                                    .and_then(|n| n.to_str())
                                    .unwrap_or("image")
                            );
                        }
                        Err(e) => {
                            self.status_message = format!("Failed to load image: {}", e);
                            self.image_texture = None;
                        }
                    }
                    
                    self.current_image = Some(path);
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
                            
                            // Update the color grid
                            if let Some(ref grid) = self.color_grid_widget {
                                while let Some(child) = grid.first_child() {
                                    grid.remove(&child);
                                }
                                
                                for color in &self.colors {
                                    let card = create_color_card(color, &sender);
                                    grid.insert(&card, -1);
                                }
                            }
                        }
                        Err(e) => {
                            self.status_message = format!("Error: {}", e);
                            self.colors.clear();
                            
                            // Clear the grid
                            if let Some(ref grid) = self.color_grid_widget {
                                while let Some(child) = grid.first_child() {
                                    grid.remove(&child);
                                }
                            }
                        }
                    }
                }
            }

            AppMsg::ColorCountChanged(count) => {
                self.color_count = count;
                if self.current_image.is_some() {
                    sender.input(AppMsg::ExtractColors);
                }
            }

            AppMsg::CopyColor(text) => {
                if let Some(display) = gtk::gdk::Display::default() {
                    display.clipboard().set_text(&text);
                    self.status_message = format!("Copied: {}", text);
                }
            }
        }
    }
}

fn create_color_card(color: &Color, sender: &ComponentSender<App>) -> gtk::Box {
    let card = gtk::Box::builder()
        .orientation(Orientation::Vertical)
        .spacing(8)
        .css_classes(vec!["color-card"])
        .build();
    
    card.set_margin_all(8);

    let preview = gtk::Box::builder()
        .orientation(Orientation::Vertical)
        .width_request(140)
        .height_request(140)
        .css_classes(vec!["color-preview"])
        .build();
    
    preview.inline_css(&format!(
        "background-color: rgb({}, {}, {});",
        color.r, color.g, color.b
    ));
    
    card.append(&preview);

    let hex_label = gtk::Label::builder()
        .label(&color.to_hex())
        .selectable(true)
        .css_classes(vec!["color-hex"])
        .build();
    card.append(&hex_label);

    let rgb_label = gtk::Label::builder()
        .label(&color.to_rgb_string())
        .selectable(true)
        .css_classes(vec!["color-rgb"])
        .build();
    card.append(&rgb_label);

    let button_box = gtk::Box::builder()
        .orientation(Orientation::Horizontal)
        .spacing(4)
        .homogeneous(true)
        .build();

    let hex_btn = gtk::Button::builder()
        .label("Copy HEX")
        .css_classes(vec!["flat"])
        .build();
    let hex_value = color.to_hex();
    hex_btn.connect_clicked(glib::clone!(
        #[strong]
        sender,
        move |_| {
            sender.input(AppMsg::CopyColor(hex_value.clone()));
        }
    ));
    button_box.append(&hex_btn);

    let rgb_btn = gtk::Button::builder()
        .label("Copy RGB")
        .css_classes(vec!["flat"])
        .build();
    let rgb_value = color.to_rgb_string();
    rgb_btn.connect_clicked(glib::clone!(
        #[strong]
        sender,
        move |_| {
            sender.input(AppMsg::CopyColor(rgb_value.clone()));
        }
    ));
    button_box.append(&rgb_btn);

    card.append(&button_box);

    card
}
