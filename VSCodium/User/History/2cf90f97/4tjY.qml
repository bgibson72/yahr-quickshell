pragma Singleton
import QtQuick

QtObject {
    id: root
    property bool isVisible: false
    
    function toggle() {
        isVisible = !isVisible
    }
    
    function show() {
        isVisible = true
    }
    
    function hide() {
        isVisible = false
    }
}
