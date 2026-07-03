import QtQuick
import QtQuick.Effects

// Reusable glow/shadow effect for floating Quickshell widgets, mirroring
// Hyprland's window shadow settings (see SettingsWidget.qml's Shadows
// section). Apply to a widget's root item via:
//   layer.enabled: true
//   layer.effect: WidgetShadowEffect {}
// Intentionally NOT applied to Bar.qml or Dock.qml.
MultiEffect {
    shadowEnabled: true
    shadowColor: Qt.rgba(
        ThemeManager.hyprShadowUseAccent ? ThemeManager.accentBlue.r : 0,
        ThemeManager.hyprShadowUseAccent ? ThemeManager.accentBlue.g : 0,
        ThemeManager.hyprShadowUseAccent ? ThemeManager.accentBlue.b : 0,
        ThemeManager.hyprShadowAlpha / 100)
    shadowBlur: Math.min(1, ThemeManager.hyprShadowRange / 60)
    shadowHorizontalOffset: 0
    shadowVerticalOffset: 0
}
