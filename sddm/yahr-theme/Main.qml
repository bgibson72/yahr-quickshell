import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import SddmComponents 2.0
import "Components"

Rectangle {
    id: root
    
    width: 1920
    height: 1080
    
    // Theme configuration
    property string background: config.Background || ""
    property int backgroundBlur: config.BackgroundBlur || 20
    property color themeColor: config.ThemeColor || "#82aaff"
    property color accentColor: config.AccentColor || "#c792ea"
    property color bgBase: config.BgBase || "#292d3e"
    property color bgSurface: config.BgSurface || "#1e2030"
    property color fgPrimary: config.FgPrimary || "#d9d7ce"
    property color fgSecondary: config.FgSecondary || "#7d83a1"
    property string fontFamily: config.Font || "MapleMono NF"
    property int fontSize: config.FontSize || 11
    property int titleFontSize: config.TitleFontSize || 32
    property bool enableAvatars: config.EnableAvatars === "true"
    property bool showHostname: config.ShowHostname !== "false"
    property bool showSessionButton: config.ShowSessionButton !== "false"
    property bool showPowerButtons: config.ShowPowerButtons !== "false"
    property string timeFormat: config.TimeFormat || "hh:mm"
    property string dateFormat: config.DateFormat || "dddd, MMMM d"
    
    // Translations
    property string translateLogin: config.TranslateLogin || "Login"
    property string translateLoginFailed: config.TranslateLoginFailed || "Login Failed"
    property string translateUsername: config.TranslateUsername || "Username"
    property string translatePassword: config.TranslatePassword || "Password"
    property string translateSession: config.TranslateSession || "Session"
    property string translateSuspend: config.TranslateSuspend || "Suspend"
    property string translateReboot: config.TranslateReboot || "Reboot"
    property string translateShutdown: config.TranslateShutdown || "Shutdown"
    
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
            width: 400
            height: column.height + 64
            radius: 24
            color: bgSurface
            opacity: 0.95
            
            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 8
                radius: 24
                samples: 49
                color: "#40000000"
            }
            
            Column {
                id: column
                anchors {
                    centerIn: parent
                    margins: 32
                }
                width: parent.width - 64
                spacing: 24
                
                // Avatar
                Rectangle {
                    id: avatarContainer
                    width: 96
                    height: 96
                    radius: 48
                    color: bgBase
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: enableAvatars
                    
                    Image {
                        id: avatar
                        anchors.fill: parent
                        anchors.margins: 2
                        source: usersList.currentItem ? usersList.currentItem.icon : ""
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
                        text: usersList.currentItem ? usersList.currentItem.name.charAt(0).toUpperCase() : ""
                        font.family: fontFamily
                        font.pixelSize: 48
                        font.weight: Font.Medium
                        color: themeColor
                        visible: avatar.status !== Image.Ready
                    }
                }
                
                // Username field
                TextField {
                    id: usernameField
                    width: parent.width
                    height: 48
                    placeholderText: translateUsername
                    text: usersList.currentItem ? usersList.currentItem.name : ""
                    font.family: fontFamily
                    font.pixelSize: fontSize
                    color: fgPrimary
                    
                    background: Rectangle {
                        radius: 12
                        color: bgBase
                        border.width: usernameField.activeFocus ? 2 : 0
                        border.color: themeColor
                    }
                    
                    Keys.onReturnPressed: passwordField.forceActiveFocus()
                    Keys.onTabPressed: passwordField.forceActiveFocus()
                }
                
                // Password field
                TextField {
                    id: passwordField
                    width: parent.width
                    height: 48
                    placeholderText: translatePassword
                    font.family: fontFamily
                    font.pixelSize: fontSize
                    color: fgPrimary
                    echoMode: TextInput.Password
                    focus: true
                    
                    background: Rectangle {
                        radius: 12
                        color: bgBase
                        border.width: passwordField.activeFocus ? 2 : 0
                        border.color: themeColor
                    }
                    
                    Keys.onReturnPressed: loginButton.clicked()
                    Keys.onEscapePressed: passwordField.text = ""
                    
                    onTextChanged: {
                        if (loginFailedText.visible) {
                            loginFailedText.visible = false
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
                }
                
                // Login button
                Button {
                    id: loginButton
                    width: parent.width
                    height: 48
                    text: translateLogin
                    
                    contentItem: Text {
                        text: loginButton.text
                        font.family: fontFamily
                        font.pixelSize: fontSize + 2
                        font.weight: Font.Medium
                        color: bgBase
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    background: Rectangle {
                        radius: 12
                        color: loginButton.down ? Qt.darker(themeColor, 1.2) : 
                               loginButton.hovered ? Qt.lighter(themeColor, 1.1) : themeColor
                        
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }
                    
                    onClicked: sddm.login(usernameField.text, passwordField.text, sessionCombo.currentIndex)
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
                        currentIndex: sessionModel.lastIndex
                        textRole: "name"
                        
                        delegate: ItemDelegate {
                            width: sessionCombo.width
                            text: model.name
                            font.family: fontFamily
                            font.pixelSize: fontSize
                            highlighted: sessionCombo.highlightedIndex === index
                        }
                        
                        background: Rectangle {
                            radius: 8
                            color: bgBase
                            border.width: sessionCombo.down ? 2 : 0
                            border.color: themeColor
                        }
                        
                        contentItem: Text {
                            text: sessionCombo.displayText
                            font.family: fontFamily
                            font.pixelSize: fontSize
                            color: fgPrimary
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 12
                        }
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
    
    // User list model
    UsersList {
        id: usersList
    }
    
    // Session model
    SessionModel {
        id: sessionModel
    }
    
    // Connection to handle login result
    Connections {
        target: sddm
        function onLoginFailed() {
            loginFailedText.visible = true
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }
    }
    
    Component.onCompleted: {
        if (usernameField.text === "") {
            usernameField.forceActiveFocus()
        } else {
            passwordField.forceActiveFocus()
        }
    }
}
