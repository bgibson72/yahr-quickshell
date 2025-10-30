mod app;
mod color_extractor;

use relm4::RelmApp;
use app::App;

fn main() {
    let app = RelmApp::new("com.github.pluck");
    app.run::<App>(());
}
