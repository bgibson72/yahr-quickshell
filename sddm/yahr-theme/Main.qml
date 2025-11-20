import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import SddmComponents 2.0
import "Components"

Rectangle {
    id: root
    
    width: 1920
    height: 1080
    
    // SDDM Components
    TextConstants { id: textConstants }
    
    // Theme configuration - use proper config API
    property string background: config.stringValue("Background") || ""
    property int backgroundBlur: config.intValue("BackgroundBlur") || 20
    property color themeColor: config.stringValue("ThemeColor") || "#82aaff"
    property color accentColor: config.stringValue("AccentColor") || "#c792ea"
    property color bgBase: config.stringValue("BgBase") || "#292d3e"
    property color bgSurface: config.stringValue("BgSurface") || "#1e2030"
    property color fgPrimary: config.stringValue("FgPrimary") || "#d9d7ce"
    property color fgSecondary: config.stringValue("FgSecondary") || "#7d83a1"
    property string fontFamily: config.stringValue("Font") || "MapleMono NF"
    property int fontSize: config.intValue("FontSize") || 11
    property int titleFontSize: config.intValue("TitleFontSize") || 32
    property bool enableAvatars: config.boolValue("EnableAvatars")
    property bool showHostname: config.boolValue("ShowHostname") !== false
    property bool showSessionButton: config.boolValue("ShowSessionButton") !== false
    property bool showPowerButtons: config.boolValue("ShowPowerButtons") !== false
    property string timeFormat: config.stringValue("TimeFormat") || "hh:mm"
    property string dateFormat: config.stringValue("DateFormat") || "dddd, MMMM d"
    
    // Translations
    property string translateLogin: config.stringValue("TranslateLogin") || textConstants.login
    property string translateLoginFailed: config.stringValue("TranslateLoginFailed") || textConstants.loginFailed
    property string translateUsername: config.stringValue("TranslateUsername") || textConstants.userName
    property string translatePassword: config.stringValue("TranslatePassword") || textConstants.password
    property string translateSession: config.stringValue("TranslateSession") || textConstants.session
    property string translateSuspend: config.stringValue("TranslateSuspend") || textConstants.suspend
    property string translateReboot: config.stringValue("TranslateReboot") || textConstants.reboot
    property string translateShutdown: config.stringValue("TranslateShutdown") || textConstants.shutdown
    
    // Background
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: background
        fillMode: Image.PreserveAspectCrop
        visible: background !== ""
        
        layer.enabled: backgroundBlur > 0
        layer.effect: FastBlur {
            radius: backgroundBlur
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: bgBase
        opacity: background !== "" ? 0.3 : 1.0
    }
    
    // Main container
    Item {
        anchors.fill: parent
        
        // Clock and date - top left
        Column {
            anchors {
                left: parent.left
                top: parent.top
                margins: 48
            }
            spacing: 8
            
            Text {
                id: timeText
                text: Qt.formatTime(timeSource.currentDateTime, timeFormat)
                font.family: fontFamily
                font.pixelSize: titleFontSize * 2
                font.weight: Font.Light
                color: fgPrimary
            }
            
            Text {
                id: dateText
                text: Qt.formatDate(timeSource.currentDateTime, dateFormat)
                font.family: fontFamily
                font.pixelSize: fontSize + 6
                font.weight: Font.Normal
                color: fgSecondary
            }
            
            Text {
                id: hostnameText
                text: sddm.hostName
                font.family: fontFamily
                font.pixelSize: fontSize + 2
                font.weight: Font.Normal
                color: fgSecondary
                visible: showHostname
            }
        }
        
        // Login card - center
        Rectangle {
            id: loginCard
            anchors.centerIn: parent
            width: 420
            height: column.height + 80
            radius: 28
            color: bgSurface
            opacity: 0.97
            
            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 12
                radius: 32
                samples: 65
                color: "#60000000"
                spread: 0.1
            }
            
            Column {
                id: column
                anchors {
                    centerIn: parent
                    margins: 40
                }
                width: parent.width - 80
                spacing: 20
                
                // Avatar
                Rectangle {
                    id: avatarContainer
                    width: 112
                    height: 112
                    radius: 56
                    color: bgBase
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: enableAvatars
                    
                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 0
                        verticalOffset: 4
                        radius: 16
                        samples: 33
                        color: "#30000000"
                    }
                    
                    Image {
                        id: avatar
                        anchors.fill: parent
                        anchors.margins: 3
                        source: userModel.lastUser !== "" ? userModel.icon : ""
                        fillMode: Image.PreserveAspectCrop
                        
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: avatar.width
                                height: avatar.height
                                radius: width / 2
                            }
                        }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: userModel.lastUser !== "" ? userModel.lastUser.charAt(0).toUpperCase() : ""
                        font.family: fontFamily
                        font.pixelSize: 56
                        font.weight: Font.Medium
                        color: themeColor
                        visible: avatar.status !== Image.Ready
                    }
                }
                
                // Username field
                Rectangle {
                    width: parent.width
                    height: 52
                    radius: 14
                    color: bgBase
                    border.width: usernameField.activeFocus ? 2 : 1
                    border.color: usernameField.activeFocus ? themeColor : Qt.rgba(fgSecondary.r, fgSecondary.g, fgSecondary.b, 0.2)
                    
                    Behavior on border.width {
                        NumberAnimation { duration: 150 }
                    }
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 150 }
                    }
                    
                    TextField {
                        id: usernameField
                        anchors.fill: parent
                        anchors.margins: 1
                        leftPadding: 16
                        rightPadding: 16
                        placeholderText: translateUsername
                        text: userModel.lastUser
                        font.family: fontFamily
                        font.pixelSize: fontSize + 1
                        color: fgPrimary
                        selectionColor: themeColor
                        selectedTextColor: bgBase
                        background: Rectangle { color: "transparent" }
                        
                        Keys.onReturnPressed: passwordField.forceActiveFocus()
                        Keys.onTabPressed: passwordField.forceActiveFocus()
                    }
                }
                
                // Password field
                Rectangle {
                    width: parent.width
                    height: 52
                    radius: 14
                    color: bgBase
                    border.width: passwordField.activeFocus ? 2 : 1
                    border.color: passwordField.activeFocus ? themeColor : Qt.rgba(fgSecondary.r, fgSecondary.g, fgSecondary.b, 0.2)
                    
                    Behavior on border.width {
                        NumberAnimation { duration: 150 }
                    }
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 150 }
                    }
                    
                    TextField {
                        id: passwordField
                        anchors.fill: parent
                        anchors.margins: 1
                        leftPadding: 16
                        rightPadding: 16
                        placeholderText: translatePassword
                        font.family: fontFamily
                        font.pixelSize: fontSize + 1
                        color: fgPrimary
                        echoMode: TextInput.Password
                        focus: true
                        selectionColor: themeColor
                        selectedTextColor: bgBase
                        background: Rectangle { color: "transparent" }
                        
                        Keys.onReturnPressed: loginButton.clicked()
                        Keys.onEscapePressed: passwordField.text = ""
                        
                        onTextChanged: {
                            if (loginFailedText.visible) {
                                loginFailedText.visible = false
                            }
                        }
                    }
                }
                
                // Login failed message
                Text {
                    id: loginFailedText
                    width: parent.width
                    text: translateLoginFailed
                    font.family: fontFamily
                    font.pixelSize: fontSize - 1
                    color: "#ff5370"
                    horizontalAlignment: Text.AlignHCenter
                    visible: false
                    
                    Connections {
                        target: sddm
                        function onLoginFailed() {
                            loginFailedText.visible = true
                            passwordField.selectAll()
                        }
                    }
                }
                
                // Login button
                Rectangle {
                    width: parent.width
                    height: 52
                    radius: 14
                    color: loginMouseArea.containsPress ? Qt.darker(themeColor, 1.2) : 
                           loginMouseArea.containsMouse ? Qt.lighter(themeColor, 1.15) : themeColor
                    
                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 0
                        verticalOffset: 4
                        radius: 12
                        samples: 25
                        color: Qt.rgba(themeColor.r, themeColor.g, themeColor.b, 0.4)
                    }
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: translateLogin
                        font.family: fontFamily
                        font.pixelSize: fontSize + 3
                        font.weight: Font.Medium
                        font.capitalization: Font.AllUppercase
                        color: bgBase
                    }
                    
                    MouseArea {
                        id: loginMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sddm.login(usernameField.text, passwordField.text, sessionCombo.currentIndex)
                    }
                }
                
                // Session selector
                Row {
                    width: parent.width
                    spacing: 12
                    visible: showSessionButton
                    
                    Text {
                        text: translateSession + ":"
                        font.family: fontFamily
                        font.pixelSize: fontSize
                        color: fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    ComboBox {
                        id: sessionCombo
                        width: parent.width - parent.spacing - 80
                        model: sessionModel
                        index: sessionModel.lastIndex
                        textColor: fgPrimary
                        color: bgBase
                        borderColor: themeColor
                        hoverColor: Qt.lighter(bgBase, 1.1)
                        font.family: fontFamily
                        font.pixelSize: fontSize
                        arrowIcon: ""
                    }
                }
            }
        }
        
        // Power buttons - bottom right
        Row {
            anchors {
                right: parent.right
                bottom: parent.bottom
                margins: 48
            }
            spacing: 16
            visible: showPowerButtons
            
            PowerButton {
                icon: "suspend"
                text: translateSuspend
                onClicked: sddm.suspend()
            }
            
            PowerButton {
                icon: "reboot"
                text: translateReboot
                onClicked: sddm.reboot()
            }
            
            PowerButton {
                icon: "shutdown"
                text: translateShutdown
                onClicked: sddm.powerOff()
            }
        }
    }
    
    // Time source
    Timer {
        id: timeSource
        property var currentDateTime: new Date()
        interval: 1000
        repeat: true
        running: true
        onTriggered: currentDateTime = new Date()
    }
    
    // Components from SDDM
    Component.onCompleted: {
        if (usernameField.text === "") {
            usernameField.forceActiveFocus()
        } else {
            passwordField.forceActiveFocus()
        }
    }
}
