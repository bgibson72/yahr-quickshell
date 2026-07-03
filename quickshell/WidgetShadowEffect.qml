import QtQuick
import QtQuick.Effects

// Reusable glow/shadow effect for floating Quickshell widgets, mirroring
// Hyprland's window shadow settings (see SettingsWidget.qml's Shadows
// section). Apply to a widget's root item via:
//   layer.enabled: true
//   layer.effect: WidgetShadowEffect {}
// Intentionally NOT applied to Bar.qml or Dock.qml.
//
// Hyprland's compositor-rendered shadow (at typical range/render_power
// values) reads as a fairly dense, saturated band close to the window edge
// rather than a soft, spread-out blur. Qt's MultiEffect shadow is a gaussian
// blur by nature, so to look consistent with Hyprland's windows at the same
// settings we boost the color's perceived density a bit rather than mapping
// alpha 1:1. shadowScale is intentionally left at its default (1.0) — scaling
// the silhouette up before blurring produces a hard-edged enlarged outline
// (looks like a solid thick border) instead of a soft gradient fading outward
// from the widget's actual edge.
MultiEffect {
    shadowEnabled: true
    shadowColor: Qt.rgba(
        ThemeManager.hyprShadowUseAccent ? ThemeManager.accentBlue.r : 0,
        ThemeManager.hyprShadowUseAccent ? ThemeManager.accentBlue.g : 0,
        ThemeManager.hyprShadowUseAccent ? ThemeManager.accentBlue.b : 0,
        Math.min(1, ThemeManager.hyprShadowAlpha / 100 * 1.15))
    shadowBlur: Math.min(1, 0.55 + ThemeManager.hyprShadowRange / 70)
    shadowHorizontalOffset: 0
    shadowVerticalOffset: 0
}
