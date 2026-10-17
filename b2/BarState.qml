// BarState.qml
pragma Singleton
import QtQuick
import Quickshell     

Singleton {
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

    function close() {
        panelOpen = false;
        activePanel = "none";
    }
}
