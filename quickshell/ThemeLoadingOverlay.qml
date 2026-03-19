import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

Scope {
    id: loadingScope
    
    property bool isVisible: false
    property string themeName: ""
    
    onIsVisibleChanged: {
        console.log("ThemeLoadingOverlay: isVisible changed to:", isVisible)
    }
    
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            id: loadingWindow
            property var modelData
            screen: modelData
            
            visible: loadingScope.isVisible
            
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            
            color: "transparent"
            
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            exclusiveZone: 0
            
            Rectangle {
                id: overlayRect
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.7)
                
                // Prevent any clicks from going through
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    preventStealing: true
                    propagateComposedEvents: false
                }
                
                Column {
                    anchors.centerIn: parent
                    spacing: 24
                    
                    // Spinner
                    Item {
                        width: 80
                        height: 80
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Rectangle {
                            id: spinner
                            anchors.centerIn: parent
                            width: 60
                            height: 60
                            radius: 30
                            color: "transparent"
                            border.width: 6
                            border.color: ThemeManager.accentBlue
                            opacity: 0.3
                        }
                        
                        Rectangle {
                            id: spinnerArc
                            anchors.centerIn: parent
                            width: 60
                            height: 60
                            radius: 30
                            color: "transparent"
                            border.width: 6
                            border.color: ThemeManager.accentBlue
                            
                            // Create arc effect by masking
                            clip: true
                            
                            Rectangle {
                                width: parent.width
                                height: parent.height / 2
                                anchors.top: parent.top
                                color: "transparent"
                            }
                            
                            RotationAnimation on rotation {
                                loops: Animation.Infinite
                                from: 0
                                to: 360
                                duration: 1200
                                running: loadingScope.isVisible
                            }
                        }
                    }
                    
                    // Loading text
                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Applying Theme"
                            font.family: "Sen"
                            font.pixelSize: 20
                            font.weight: Font.Bold
                            color: ThemeManager.fgPrimary
                        }
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: loadingScope.themeName
                            font.family: "Sen"
                            font.pixelSize: 16
                            color: ThemeManager.accentBlue
                        }
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Please wait..."
                            font.family: "Sen"
                            font.pixelSize: 14
                            color: ThemeManager.fgSecondary
                            opacity: 0.8
                        }
                    }
                }
                
                // Auto-hide after timeout
                Timer {
                    id: hideTimer
                    interval: 5000  // 5 seconds max
                    running: loadingScope.isVisible
                    repeat: false
                    onTriggered: {
                        loadingScope.isVisible = false
                    }
                }
            }
        }
    }
    
    function show(theme) {
        console.log("ThemeLoadingOverlay: Showing overlay for theme:", theme)
        themeName = theme
        isVisible = true
    }
    
    function hide() {
        console.log("ThemeLoadingOverlay: Hiding overlay")
        isVisible = false
    }
}
