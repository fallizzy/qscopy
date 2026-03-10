import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import QtQuick.Window
import "backend"
import "ui"

ShellRoot {
    id: root

    ListModel { id: listModel }

    QScopyBackend {
        id: backend
        targetModel: listModel
    }
    
    property var scheme: ({})
    property string lastRawConfig: ""
    property var hoveredItem: null
    property real previewOpacity: hoveredItem ? 1.0 : 0.0

    Timer {
        id: configTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            // Updated to fallback gracefully if Caelestia/Hyprland theme doesn't exist
            var process = Quickshell.exec(["cat", "/home/ryuma/.config/hypr/scheme/current.conf"]);
            process.finished.connect(function() {
                var data = process.stdout;
                if (data && data !== lastRawConfig) {
                    lastRawConfig = data;
                    parseHyprConfig(data);
                }
            });
        }
    }

    function parseHyprConfig(rawText) {
        var lines = rawText.split("\n");
        var newScheme = {};
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();
            if (line.startsWith("$")) {
                var parts = line.substring(1).split("=");
                if (parts.length === 2) {
                    newScheme[parts[0].trim()] = parts[1].trim();
                }
            }
        }
        if (Object.keys(newScheme).length > 0) root.scheme = newScheme;
    }

    Component.onCompleted: backend.init()

    FloatingWindow {
        id: mainWindow
        width: 870; height: 700
        visible: true; color: "transparent"

        property color bgColor: root.scheme.background ? ("#" + root.scheme.background) : (backend.isDarkMode ? "#121212" : "#f0f2f5")
        property color fgColor: root.scheme.onBackground ? ("#" + root.scheme.onBackground) : (backend.isDarkMode ? "#e8eaed" : "#202124")
        property color cardColor: root.scheme.surface ? ("#" + root.scheme.surface) : (backend.isDarkMode ? "#1e1e1e" : "#ffffff")
        property color cardHover: root.scheme.surfaceVariant ? ("#" + root.scheme.surfaceVariant) : (backend.isDarkMode ? "#2c2c2c" : "#f8f9fa")
        property color accentColor: root.scheme.primary ? ("#" + root.scheme.primary) : (backend.isDarkMode ? "#8ab4f8" : "#1a73e8")
        property color outlineColor: root.scheme.outline ? ("#" + root.scheme.outline) : (backend.isDarkMode ? "#333" : "#ddd")
        property color shadowColor: "#80000000"

        Behavior on bgColor { ColorAnimation { duration: 1000; easing.type: Easing.OutQuint } }

        Item {
            anchors.fill: parent

            // LEFT PANEL
            Rectangle {
                id: mainRect
                width: 450; height: 650
                anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                color: Qt.rgba(mainWindow.bgColor.r, mainWindow.bgColor.g, mainWindow.bgColor.b, backend.glassOpacity)
                radius: 32; border.color: mainWindow.outlineColor; border.width: 1; clip: true
                layer.enabled: true
                layer.effect: MultiEffect { shadowEnabled: true; shadowColor: mainWindow.shadowColor; shadowBlur: 0.7; shadowVerticalOffset: 6 }

                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 20; spacing: 16
                    TitleBar {
                        Layout.fillWidth: true
                        isDarkMode: backend.isDarkMode; fgColor: mainWindow.fgColor
                        cardColor: mainWindow.cardColor; accentColor: mainWindow.accentColor
                        onSearchChanged: text => backend.search(text)
                        onSettingsClicked: settingsDrawer.opened = true
                        onSearchFinished: listView.forceActiveFocus()
                    }
                    ListView {
                        id: listView
                        Layout.fillWidth: true; Layout.fillHeight: true; spacing: 10; clip: true; focus: true
                        model: listModel
                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Up || event.key === Qt.Key_K) { listView.decrementCurrentIndex(); event.accepted = true }
                            else if (event.key === Qt.Key_Down || event.key === Qt.Key_J) { listView.incrementCurrentIndex(); event.accepted = true }
                            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { if (listView.currentIndex >= 0) backend.copyItem(listModel.get(listView.currentIndex).id) }
                            else if (event.key === Qt.Key_Escape) Quickshell.exit(0)
                        }
                        onCurrentIndexChanged: if (currentIndex >= 0 && currentIndex < model.count) root.hoveredItem = model.get(currentIndex)
                        delegate: ClipboardItem {
                            width: listView.width - 4; type: model.type; content: model.content
                            timestamp: model.timestamp; pinned: model.pinned; isCurrent: ListView.isCurrentItem
                            fgColor: mainWindow.fgColor; cardColor: mainWindow.cardColor
                            cardHover: mainWindow.cardHover; accentColor: mainWindow.accentColor; isDarkMode: backend.isDarkMode
                            onHovered: (isHovered) => { if (isHovered) root.hoveredItem = model; else if (root.hoveredItem === model) root.hoveredItem = null; }
                            onCopyRequested: backend.copyItem(model.id)
                            onDeleteRequested: backend.deleteItem(model.id)
                        }
                    }
                }
            }

            // RIGHT PANEL
            Rectangle {
                id: previewIsland
                x: mainRect.width + 20 + (1.0 - root.previewOpacity) * 30; y: (parent.height - height) / 2
                width: 400; height: Math.min(650, Math.max(200, contentColumn.implicitHeight + 80))
                color: Qt.rgba(mainWindow.bgColor.r, mainWindow.bgColor.g, mainWindow.bgColor.b, backend.glassOpacity)
                radius: 32; border.color: mainWindow.outlineColor; border.width: 1; clip: true
                opacity: root.previewOpacity; visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: 800; easing.type: Easing.OutQuint } }
                Behavior on x { NumberAnimation { duration: 1000; easing.type: Easing.OutExpo } }
                Behavior on height { NumberAnimation { duration: 800; easing.type: Easing.OutQuint } }
                layer.enabled: true
                layer.effect: MultiEffect { shadowEnabled: true; shadowColor: mainWindow.shadowColor; shadowBlur: 0.8; shadowVerticalOffset: 8 }

                ColumnLayout {
                    id: contentColumn
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 28; spacing: 20
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: (root.hoveredItem && root.hoveredItem.type === "image") ? 350 : Math.min(480, previewText.implicitHeight + 40)
                        color: Qt.rgba(mainWindow.cardColor.r, mainWindow.cardColor.g, mainWindow.cardColor.b, 0.3); radius: 20; clip: true
                        Flickable {
                            anchors.fill: parent; contentWidth: parent.width; contentHeight: previewText.implicitHeight; clip: true
                            Text {
                                id: previewText; width: parent.width - 40; anchors.horizontalCenter: parent.horizontalCenter; anchors.top: parent.top; anchors.topMargin: 20
                                text: (root.hoveredItem && root.hoveredItem.type !== "image") ? root.hoveredItem.content : ""; color: mainWindow.fgColor
                                font.pixelSize: 16; lineHeight: 1.5; wrapMode: Text.Wrap; visible: root.hoveredItem && root.hoveredItem.type !== "image"
                            }
                        }
                        Image {
                            anchors.fill: parent; anchors.margins: 15; fillMode: Image.PreserveAspectFit; visible: root.hoveredItem && root.hoveredItem.type === "image"
                            source: root.hoveredItem && root.hoveredItem.type === "image" ? ("file://" + root.hoveredItem.content) : ""
                        }
                    }
                    Text {
                        text: { if (!root.hoveredItem) return ""; if (root.hoveredItem.type === "image") return "IMAGE PREVIEW"; let c = root.hoveredItem.content; return (c ? c.length : 0) + " CHARS  •  " + (c ? c.split(/\s+/).length : 0) + " WORDS"; }
                        color: mainWindow.fgColor; opacity: 0.5; font.pixelSize: 11; font.bold: true; font.letterSpacing: 2
                    }
                }
            }
        }

        SettingsDrawer {
            id: settingsDrawer; opened: false; isDarkMode: backend.isDarkMode; isAutoDelete: backend.isAutoDelete
            isPasteRightAway: backend.isPasteRightAway; closeOnCopy: backend.closeOnCopy; glassOpacity: backend.glassOpacity
            fgColor: mainWindow.fgColor; bgColor: mainWindow.cardColor; accentColor: mainWindow.accentColor
            onRequestClose: opened = false; onRequestDarkMode: val => backend.setDarkMode(val); onRequestAutoDelete: val => backend.setAutoDelete(val)
            onRequestPasteRightAway: val => backend.setPasteRightAway(val); onRequestCloseOnCopy: val => backend.setCloseOnCopy(val)
            onRequestGlassOpacity: val => backend.setGlassOpacity(val); onRequestClearHistory: { backend.clearHistory(); opened = false }
        }
    }
}
