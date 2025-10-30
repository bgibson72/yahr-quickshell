pragma Singleton
import QtQuick
import Quickshell

Singleton {
    property var pickerWindow: null
    
    function toggle() {
        if (pickerWindow === null) {
            console.log("WallpaperPickerManager: Creating picker window")
            pickerWindow = Qt.createQmlObject('
                import QtQuick
                import "."
                WallpaperPicker {}
            ', Singleton, "wallpaperPickerInstance")
        }
        
        if (pickerWindow.visible) {
            pickerWindow.hide()
        } else {
            pickerWindow.show()
        }
    }
    
    function show() {
        if (pickerWindow === null) {
            console.log("WallpaperPickerManager: Creating picker window")
            pickerWindow = Qt.createQmlObject('
                import QtQuick
                import "."
                WallpaperPicker {}
            ', Singleton, "wallpaperPickerInstance")
        }
        
        pickerWindow.show()
    }
}
