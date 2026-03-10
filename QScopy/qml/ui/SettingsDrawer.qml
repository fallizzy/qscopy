import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: drawerRoot
    
    property bool opened: false
    visible: opacity > 0
    
    property bool isDarkMode: true
    property bool isAutoDelete: false
    property bool isPasteRightAway: false
    property bool closeOnCopy: true
    property real glassOpacity: 0.6
    
    property color fgColor: "white"
    property color bgColor: "#1a1b26"
    property color accentColor: "#0067c0"
    
    signal requestClose()
    signal requestDarkMode(bool val)
    signal requestAutoDelete(bool val)
    signal requestPasteRightAway(bool val)
    signal requestCloseOnCopy(bool val)
    signal requestGlassOpacity(real val)
    signal requestClearHistory()

    anchors.fill: parent
    color: bgColor
    radius: 32
    
    opacity: opened ? 1.0 : 0.0
    property real slideOffset: opened ? 0 : 50
    
    Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.OutQuint } }
    Behavior on slideOffset { NumberAnimation { duration: 800; easing.type: Easing.OutBack } }

    border.color: isDarkMode ? "#333" : "#ddd"
    border.width: 1
    z: 10

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        anchors.topMargin: 32 + drawerRoot.slideOffset
        spacing: 24

        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            Text {
                text: "settings"
                font.family: "Material Symbols Rounded"
                font.pixelSize: 28
                color: drawerRoot.accentColor
            }
            Text { text: "Settings"; color: fgColor; font.pixelSize: 22; font.bold: true; Layout.fillWidth: true }
            
            Rectangle {
                width: 36; height: 36; radius: 18
                color: closeMouse.containsMouse ? Qt.rgba(drawerRoot.fgColor.r, drawerRoot.fgColor.g, drawerRoot.fgColor.b, 0.1) : "transparent"
                Text { anchors.centerIn: parent; text: "close"; font.family: "Material Symbols Rounded"; color: drawerRoot.fgColor; font.pixelSize: 24 }
                MouseArea { id: closeMouse; anchors.fill: parent; hoverEnabled: true; onClicked: requestClose() }
            }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: optionsList.implicitHeight
            clip: true

            ColumnLayout {
                id: optionsList
                width: parent.width
                spacing: 20

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "opacity"; font.family: "Material Symbols Rounded"; font.pixelSize: 24; color: drawerRoot.fgColor; opacity: 0.7 }
                        Text { text: "Glass Transparency"; color: fgColor; font.pixelSize: 17; Layout.fillWidth: true }
                        Text { text: Math.round(drawerRoot.glassOpacity * 100) + "%"; color: fgColor; opacity: 0.6 }
                    }
                    Slider {
                        Layout.fillWidth: true
                        from: 0.1; to: 1.0
                        value: drawerRoot.glassOpacity
                        onMoved: requestGlassOpacity(value)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "dark_mode"; font.family: "Material Symbols Rounded"; font.pixelSize: 24; color: drawerRoot.fgColor; opacity: 0.7 }
                    Text { text: "Dark Mode"; color: fgColor; font.pixelSize: 17; Layout.fillWidth: true }
                    Switch {
                        checked: drawerRoot.isDarkMode
                        onToggled: requestDarkMode(checked)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "exit_to_app"; font.family: "Material Symbols Rounded"; font.pixelSize: 24; color: drawerRoot.fgColor; opacity: 0.7 }
                    Text { text: "Close on Copy"; color: fgColor; font.pixelSize: 17; Layout.fillWidth: true }
                    Switch {
                        checked: drawerRoot.closeOnCopy
                        onToggled: requestCloseOnCopy(checked)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "delete_sweep"; font.family: "Material Symbols Rounded"; font.pixelSize: 24; color: drawerRoot.fgColor; opacity: 0.7 }
                    Text { text: "Auto Delete on Reboot"; color: fgColor; font.pixelSize: 17; Layout.fillWidth: true }
                    Switch {
                        checked: drawerRoot.isAutoDelete
                        onToggled: requestAutoDelete(checked)
                    }
                }

                Item { Layout.preferredHeight: 20 }
                Button {
                    text: "Clear History"
                    Layout.fillWidth: true
                    onClicked: requestClearHistory()
                    background: Rectangle { radius: 16; color: "#e81123"; opacity: parent.hovered ? 0.9 : 1.0; implicitHeight: 48 }
                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                }
            }
        }
    }
    MouseArea { anchors.fill: parent; z: -1; preventStealing: true }
}
