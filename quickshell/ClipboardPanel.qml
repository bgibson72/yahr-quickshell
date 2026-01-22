import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    
    width: 500
    height: 600
    color: ThemeManager.bgBase
    radius: 16
    border.width: 3
    border.color: ThemeManager.accentPurple
    
    property bool isVisible: false
    signal requestClose()
    
    focus: true
    
    Keys.onEscapePressed: {
        root.requestClose()
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16
        
        // Header with title and close button
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            
            Row {
                spacing: 12
                Layout.alignment: Qt.AlignVCenter
                
                Text {
                    text: "📋"
                    font.pixelSize: 24
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Text {
                    text: "Clipboard History"
                    font.family: "MapleMono NF"
                    font.pixelSize: 20
                    font.weight: Font.Bold
                    color: ThemeManager.fgPrimary
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            
            Item {
                Layout.fillWidth: true  // Fill remaining space
            }
            
            // Close button
            Rectangle {
                width: 36
                height: 36
                radius: 8
                color: closeMouseArea.containsMouse ? ThemeManager.surface1 : "transparent"
                Layout.alignment: Qt.AlignVCenter
                
                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.requestClose()
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    font.pixelSize: 18
                    color: ThemeManager.fgPrimary
                }
            }
        }
        
        // Search field
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            color: ThemeManager.surface1
            radius: 10
            border.width: searchInput.activeFocus ? 2 : 0
            border.color: ThemeManager.accentPurple
            
            Row {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10
                
                Text {
                    text: "🔍"
                    font.pixelSize: 18
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                TextInput {
                    id: searchInput
                    width: parent.width - 40
                    height: parent.height
                    font.family: "MapleMono NF"
                    font.pixelSize: 14
                    color: ThemeManager.fgPrimary
                    verticalAlignment: TextInput.AlignVCenter
                    clip: true
                    
                    Text {
                        visible: searchInput.text === ""
                        text: "Search clipboard history..."
                        font.family: searchInput.font.family
                        font.pixelSize: searchInput.font.pixelSize
                        color: ThemeManager.fgTertiary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    onTextChanged: {
                        clipboardModel.filterText = text
                    }
                }
            }
        }
        
        // Clipboard items list
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true  // Take all remaining space
            color: ThemeManager.surface0
            radius: 12
            
            ListView {
                id: clipboardListView
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8
                clip: true
                
                model: clipboardModel.filteredItems
                
                delegate: Rectangle {
                    width: clipboardListView.width
                    height: Math.min(contentText.contentHeight + 32, 120)
                    color: delegateMouseArea.containsMouse ? ThemeManager.surface1 : ThemeManager.surface0
                    radius: 8
                    border.width: 1
                    border.color: delegateMouseArea.containsMouse ? ThemeManager.accentPurple : ThemeManager.surface2
                    
                    MouseArea {
                        id: delegateMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: {
                            console.log("Copying clipboard item:", index)
                            clipboardModel.copyItem(index)
                            root.requestClose()
                        }
                    }
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 6
                        
                        Row {
                            width: parent.width
                            spacing: 8
                            
                            Text {
                                text: "📄"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            
                            Text {
                                text: modelData.timestamp || "Unknown"
                                font.family: "MapleMono NF"
                                font.pixelSize: 11
                                color: ThemeManager.fgSecondary
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        
                        Text {
                            id: contentText
                            width: parent.width
                            text: modelData.content || ""
                            font.family: "MapleMono NF"
                            font.pixelSize: 13
                            color: ThemeManager.fgPrimary
                            wrapMode: Text.Wrap
                            maximumLineCount: 4
                            elide: Text.ElideRight
                        }
                    }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: clipboardModel.items.length === 0 ? "No clipboard history" : "No results found"
                    font.family: "MapleMono NF"
                    font.pixelSize: 14
                    color: ThemeManager.fgTertiary
                    visible: clipboardListView.count === 0
                }
            }
        }
        
        // Footer with item count
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 20  // Fixed height for footer
            
            Text {
                anchors.fill: parent
                text: `${clipboardListView.count} item${clipboardListView.count !== 1 ? 's' : ''}`
                font.family: "MapleMono NF"
                font.pixelSize: 12
                color: ThemeManager.fgSecondary
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
    
    QtObject {
        id: clipboardModel
        
        property var items: []
        property var filteredItems: []
        property string filterText: ""
        
        onFilterTextChanged: updateFilter()
        
        function updateFilter() {
            if (filterText === "") {
                filteredItems = items
            } else {
                let filtered = []
                for (let i = 0; i < items.length; i++) {
                    if (items[i].content.toLowerCase().includes(filterText.toLowerCase())) {
                        filtered.push(items[i])
                    }
                }
                filteredItems = filtered
            }
        }
        
        function loadHistory() {
            cliphistLoader.running = true
        }
        
        function copyItem(index) {
            if (index >= 0 && index < filteredItems.length) {
                let item = filteredItems[index]
                copyProcess.command = ["sh", "-c", `printf '%s' "${item.content}" | wl-copy`]
                copyProcess.running = true
            }
        }
    }
    
    // Load clipboard history from cliphist
    Process {
        id: cliphistLoader
        running: false
        command: ["sh", "-c", "cliphist list"]
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => { cliphistLoader.buffer += data }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                let lines = buffer.trim().split('\n')
                let historyItems = []
                
                for (let i = 0; i < Math.min(lines.length, 50); i++) {
                    if (lines[i].trim() !== "") {
                        historyItems.push({
                            content: lines[i].trim(),
                            timestamp: new Date().toLocaleString()
                        })
                    }
                }
                
                clipboardModel.items = historyItems
                clipboardModel.updateFilter()
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    // Copy selected item to clipboard
    Process {
        id: copyProcess
        running: false
    }
    
    // Load history when panel becomes visible
    onIsVisibleChanged: {
        if (isVisible) {
            searchInput.text = ""
            clipboardModel.loadHistory()
            searchInput.forceActiveFocus()
        }
    }
}
