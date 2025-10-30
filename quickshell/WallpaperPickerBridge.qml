pragma Singleton
import QtQuick

QtObject {
    property var pickerWindow: null
    
    function show() {
        if (pickerWindow) {
            pickerWindow.show()
        }
    }
}
