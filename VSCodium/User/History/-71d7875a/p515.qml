import QtQuick
import Quickshell

ShellRoot {
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            property var modelData
            screen: modelData
            
            anchors {
                top: true
                left: true
                right: true
            }
            
            implicitHeight: 42
            color: "red"
            exclusiveZone: height
            
            MouseArea {
                anchors.fill: parent
                onClicked: console.log("TEST CLICK WORKED!")
                
                Rectangle {
                    anchors.centerIn: parent
                    width: 100
                    height: 30
                    color: "blue"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "CLICK ME"
                        color: "white"
                    }
                }
            }
        }
    }
}