// BarState.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property bool panelOpen: false
    property string activePanel: "none"
    property real clickX: 0
    property real clickY: 0

    function toggle(panel, x, y) {
        if (panelOpen && activePanel === panel) {
            panelOpen = false;
            activePanel = "none";
        } else {
            clickX = x !== undefined ? x : 0;
            clickY = y !== undefined ? y : 0;
            activePanel = panel;
            panelOpen = true;
        }
    }

    // qs -p ~/bar_hypr/b2 ipc call bar toggle settings
    IpcHandler {
        target: "bar"
        function toggle(panel: string): void {
            const s = Quickshell.screens[0];
            root.toggle(panel, s.width / 2, s.height / 2);
        }
    }

    function close() {
        panelOpen = false;
        activePanel = "none";
    }
}
