use gtk::prelude::*;
use gtk::Orientation;
use relm4::{ComponentParts, ComponentSender, SimpleComponent, RelmWidgetExt};

use crate::color_extractor::Color;

#[derive(Debug)]
pub struct ColorCard {
    color: Color,
}

#[derive(Debug)]
pub enum ColorCardInput {
    CopyHex,
    CopyRgb,
}

#[derive(Debug)]
pub enum ColorCardOutput {
    ColorCopied(String),
}

#[relm4::component(pub)]
impl SimpleComponent for ColorCard {
    type Init = Color;
    type Input = ColorCardInput;
    type Output = ColorCardOutput;

    view! {
        gtk::Box {
            set_orientation: Orientation::Vertical,
            set_spacing: 8,
            set_margin_all: 8,
            add_css_class: "color-card",

            gtk::Box {
                set_orientation: Orientation::Vertical,
                set_size_request: (120, 120),
                set_hexpand: false,
                add_css_class: "color-preview",
                
                inline_css: &format!(
                    "background-color: rgb({}, {}, {});",
                    model.color.r, model.color.g, model.color.b
                ),
            },

            gtk::Label {
                set_label: &model.color.to_hex(),
                add_css_class: "color-hex",
                set_selectable: true,
            },

            gtk::Label {
                set_label: &model.color.to_rgb_string(),
                add_css_class: "color-rgb",
                set_selectable: true,
            },

            gtk::Box {
                set_orientation: Orientation::Horizontal,
                set_spacing: 4,
                set_homogeneous: true,

                gtk::Button {
                    set_label: "Copy HEX",
                    add_css_class: "flat",
                    connect_clicked => ColorCardInput::CopyHex,
                },

                gtk::Button {
                    set_label: "Copy RGB",
                    add_css_class: "flat",
                    connect_clicked => ColorCardInput::CopyRgb,
                },
            },
        }
    }

    fn init(
        color: Self::Init,
        root: Self::Root,
        sender: ComponentSender<Self>,
    ) -> ComponentParts<Self> {
        let model = ColorCard { color };
        let widgets = view_output!();
        ComponentParts { model, widgets }
    }

    fn update(&mut self, msg: Self::Input, sender: ComponentSender<Self>) {
        match msg {
            ColorCardInput::CopyHex => {
                let hex = self.color.to_hex();
                if let Some(display) = gtk::gdk::Display::default() {
                    display.clipboard().set_text(&hex);
                    let _ = sender.output(ColorCardOutput::ColorCopied(format!("Copied: {}", hex)));
                }
            }
            ColorCardInput::CopyRgb => {
                let rgb = self.color.to_rgb_string();
                if let Some(display) = gtk::gdk::Display::default() {
                    display.clipboard().set_text(&rgb);
                    let _ = sender.output(ColorCardOutput::ColorCopied(format!("Copied: {}", rgb)));
                }
            }
        }
    }
}
