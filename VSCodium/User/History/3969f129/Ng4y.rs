use anyhow::{Context, Result};
use color_thief::{ColorFormat, get_palette};
use image::DynamicImage;
use std::path::Path;

#[derive(Debug, Clone)]
pub struct Color {
    pub r: u8,
    pub g: u8,
    pub b: u8,
}

impl Color {
    pub fn new(r: u8, g: u8, b: u8) -> Self {
        Self { r, g, b }
    }

    pub fn to_hex(&self) -> String {
        format!("#{:02X}{:02X}{:02X}", self.r, self.g, self.b)
    }

    pub fn to_rgb_string(&self) -> String {
        format!("rgb({}, {}, {})", self.r, self.g, self.b)
    }
}

pub struct ColorExtractor;

impl ColorExtractor {
    /// Extract color palette from an image file
    pub fn extract_from_path(path: &Path, color_count: u8) -> Result<Vec<Color>> {
        let img = image::open(path)
            .context("Failed to open image")?;
        
        Self::extract_from_image(&img, color_count)
    }

    /// Extract color palette from a DynamicImage
    pub fn extract_from_image(img: &DynamicImage, color_count: u8) -> Result<Vec<Color>> {
        let img_rgb = img.to_rgb8();
        let pixels = img_rgb.as_raw();
        
        // Note: color-thief's get_palette returns (color_count - 1) colors
        // So we add 1 to get the requested number of colors
        let palette = get_palette(
            pixels,
            ColorFormat::Rgb,
            10, // quality - lower is faster but less accurate
            color_count + 1,
        )
        .context("Failed to extract palette")?;

        let colors = palette
            .into_iter()
            .map(|c| Color::new(c.r, c.g, c.b))
            .collect();

        Ok(colors)
    }
}
