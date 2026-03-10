import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: backendRoot

    property bool isDarkMode: false
    property bool isAutoDelete: false
    property bool isPasteRightAway: false
    property bool closeOnCopy: true 
    property real glassOpacity: 0.7
    property string typeFilter: "all"
    property string searchInputText: ""
    
    property ListModel targetModel: null

    function getDaemonPath() {
        return "/home/ryuma/Downloads/QScopy/bin/qscopy-daemon"; // Changed for export
    }

    Process {
        id: listProc
        command: [getDaemonPath(), "list", "--search", backendRoot.searchInputText, "--type-filter", backendRoot.typeFilter === "color" || backendRoot.typeFilter === "link" ? "text" : backendRoot.typeFilter]
        stdout: SplitParser {
            onRead: data => {
                if (!targetModel) return;
                let items = [];
                try { items = JSON.parse(data); } catch (e) { return; }
                for (let i = targetModel.count - 1; i >= 0; i--) {
                    let oldId = targetModel.get(i).id;
                    if (!items.some(n => n.id === oldId)) targetModel.remove(i);
                }
                for (let i = 0; i < items.length; i++) {
                    let newItem = items[i];
                    let existingIndex = -1;
                    for (let j = i; j < targetModel.count; j++) {
                        if (targetModel.get(j).id === newItem.id) { existingIndex = j; break; }
                    }
                    if (existingIndex === i) {
                        let m = targetModel.get(i);
                        if (m.timestamp !== newItem.timestamp) targetModel.setProperty(i, "timestamp", newItem.timestamp);
                        if (m.pinned !== newItem.pinned) targetModel.setProperty(i, "pinned", newItem.pinned);
                        if (m.content !== newItem.content) targetModel.setProperty(i, "content", newItem.content);
                    } else if (existingIndex !== -1) {
                        targetModel.move(existingIndex, i, 1);
                        let m = targetModel.get(i);
                        if (m.timestamp !== newItem.timestamp) targetModel.setProperty(i, "timestamp", newItem.timestamp);
                        if (m.pinned !== newItem.pinned) targetModel.setProperty(i, "pinned", newItem.pinned);
                        if (m.content !== newItem.content) targetModel.setProperty(i, "content", newItem.content);
                    } else {
                        targetModel.insert(i, newItem);
                    }
                }
            }
        }
    }

    Process { id: actionProc; onExited: loadData() }
    Process { id: copyProc; onExited: { if (backendRoot.closeOnCopy) Quickshell.exit(0); } }
    Process { id: silentProc }
    Process { id: notifyProc; command: ["notify-send", "QScopy", "Copied to clipboard", "-t", "2000"] }

    Process { id: loadDarkProc; command: [getDaemonPath(), "config", "get", "dark_mode"]; stdout: SplitParser { onRead: data => backendRoot.isDarkMode = (data.trim() === "true") } }
    Process { id: loadAutoProc; command: [getDaemonPath(), "config", "get", "auto_delete"]; stdout: SplitParser { onRead: data => backendRoot.isAutoDelete = (data.trim() === "true") } }
    Process { id: loadPasteProc; command: [getDaemonPath(), "config", "get", "paste_right_away"]; stdout: SplitParser { onRead: data => backendRoot.isPasteRightAway = (data.trim() === "true") } }
    Process { id: loadGlassProc; command: [getDaemonPath(), "config", "get", "glass_opacity"]; stdout: SplitParser { onRead: data => { let v = parseFloat(data.trim()); if (!isNaN(v)) backendRoot.glassOpacity = v; } } }
    Process { id: loadCloseProc; command: [getDaemonPath(), "config", "get", "close_on_copy"]; stdout: SplitParser { onRead: data => backendRoot.closeOnCopy = (data.trim() !== "false") } }

    function loadData() { listProc.running = false; listProc.running = true; }
    function search(text) { backendRoot.searchInputText = text; loadData(); }
    
    function copyItem(id) {
        notifyProc.running = false; notifyProc.running = true;
        copyProc.command = [getDaemonPath(), "get", id.toString()];
        copyProc.running = false; copyProc.running = true;
        if (backendRoot.closeOnCopy) {
            let t = Qt.createQmlObject('import QtQuick; Timer { interval: 500; onTriggered: Quickshell.exit(0) }', backendRoot);
            t.start();
        }
    }
    
    function deleteItem(id) { actionProc.command = [getDaemonPath(), "delete", id.toString()]; actionProc.running = false; actionProc.running = true; }
    function pinItem(id, isPinned) { actionProc.command = [getDaemonPath(), isPinned ? "pin" : "unpin", id.toString()]; actionProc.running = false; actionProc.running = true; }
    function clearHistory() { actionProc.command = [getDaemonPath(), "clear"]; actionProc.running = false; actionProc.running = true; }
    
    function setDarkMode(val) { backendRoot.isDarkMode = val; silentProc.command = [getDaemonPath(), "config", "set", "dark_mode", val ? "true" : "false"]; silentProc.running = false; silentProc.running = true; }
    function setAutoDelete(val) { backendRoot.isAutoDelete = val; silentProc.command = [getDaemonPath(), "config", "set", "auto_delete", val ? "true" : "false"]; silentProc.running = false; silentProc.running = true; }
    function setPasteRightAway(val) { backendRoot.isPasteRightAway = val; silentProc.command = [getDaemonPath(), "config", "set", "paste_right_away", val ? "true" : "false"]; silentProc.running = false; silentProc.running = true; }
    function setGlassOpacity(val) { backendRoot.glassOpacity = val; silentProc.command = [getDaemonPath(), "config", "set", "glass_opacity", val.toString()]; silentProc.running = false; silentProc.running = true; }
    function setCloseOnCopy(val) { backendRoot.closeOnCopy = val; silentProc.command = [getDaemonPath(), "config", "set", "close_on_copy", val ? "true" : "false"]; silentProc.running = false; silentProc.running = true; }

    Timer { interval: 2000; repeat: true; running: true; onTriggered: loadData() }
    function init() { loadDarkProc.running = true; loadAutoProc.running = true; loadPasteProc.running = true; loadGlassProc.running = true; loadCloseProc.running = true; loadData(); }
}
