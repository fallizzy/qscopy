import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import QtQuick.Effects

Rectangle {
    id: rootItem
    width: parent ? parent.width : 400

    property string type: "text"
    property string content: ""
    property int timestamp: 0
    property var pinned: 0
    readonly property bool isPinned: pinned ? true : false

    property color fgColor: "black"
    property color cardColor: "white"
    property color cardHover: "#f5f5f5"
    property color accentColor: "#0067c0"
    property bool isDarkMode: false

    signal pinToggled(bool value)
    signal deleteRequested()
    signal copyRequested()
    signal hovered(bool isHovered)

    property bool isCurrent: ListView.isCurrentItem
    readonly property bool isActive: itemMouse.containsMouse || isCurrent

    height: 70
    radius: 12
    
    color: isActive ? rootItem.accentColor : rootItem.cardColor
    opacity: isActive ? 1.0 : 0.8
    
    Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutQuart } }
    Behavior on opacity { NumberAnimation { duration: 250 } }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // Icon Box (Artık resimse Thumbnail gösterir)
        Rectangle {
            width: 46; height: 46
            radius: 10
            color: isActive ? "white" : Qt.rgba(rootItem.fgColor.r, rootItem.fgColor.g, rootItem.fgColor.b, 0.1)
            clip: true
            
            // Eğer resimse Thumbnail göster
            Image {
                anchors.fill: parent
                visible: rootItem.type === "image"
                source: rootItem.type === "image" ? ("file://" + rootItem.content) : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            // Eğer resim değilse Ikon göster
            Text {
                anchors.centerIn: parent
                visible: rootItem.type !== "image"
                font.family: "Material Symbols Rounded"
                font.pixelSize: 24
                color: isActive ? rootItem.accentColor : rootItem.fgColor
                text: {
                    if (rootItem.content.trim().startsWith("http")) return "link";
                    return "content_paste";
                }
            }
        }

        // Text Column
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            
            Text {
                Layout.fillWidth: true
                // DOSYA İSMİNİ GÖSTER: Yolun son kısmını al
                text: {
                    if (rootItem.type === "image") {
                        let parts = rootItem.content.split('/');
                        return parts[parts.length - 1];
                    }
                    return rootItem.content.replace(/\n/g, " ");
                }
                color: isActive ? "white" : rootItem.fgColor
                font.pixelSize: 14
                font.bold: true
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                Layout.fillWidth: true
                text: {
                    if (rootItem.type === "image") return "PNG • Image File";
                    let c = rootItem.content;
                    if (c.length > 50) return "Uzun metin";
                    return c.length + " characters, " + c.split(/\s+/).length + " words";
                }
                color: isActive ? "white" : rootItem.fgColor
                opacity: 0.6
                font.pixelSize: 12
            }
        }

        // Delete button
        Rectangle {
            width: 32; height: 32; radius: 16
            color: deleteMouse.containsMouse ? "#ff4444" : "transparent"
            visible: isActive
            Text { 
                anchors.centerIn: parent; text: "delete"; 
                font.family: "Material Symbols Rounded"; 
                color: "white"; 
                font.pixelSize: 18 
            }
            MouseArea { id: deleteMouse; anchors.fill: parent; hoverEnabled: true; onClicked: deleteRequested() }
        }
    }

    MouseArea {
        id: itemMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: hovered(true)
        onExited: hovered(false)
        onClicked: {
            rootItem.ListView.view.currentIndex = index
            copyRequested()
        }
    }
}
