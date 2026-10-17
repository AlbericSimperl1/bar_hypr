// Ws.qml
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Item {
    id: root
    implicitWidth:  flow.implicitWidth
    implicitHeight: flow.implicitHeight

    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"

    Flow {
        id: flow
        flow: root.vertical ? Flow.TopToBottom : Flow.LeftToRight
        spacing: 5

        Repeater {
            model: Config.workspaceCount
            delegate: Rectangle {
                id: pill
                required property int index
                property int wsId: index + 1

                readonly property bool isActive:
                    Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === wsId
                readonly property bool hasWindows: {
                    if (!Hyprland.toplevels) return false;
                    return Hyprland.toplevels.values.some(
                        t => t.workspace && t.workspace.id === wsId);
                }
                property bool hovered: false

                width:  root.vertical ? 22 : (Config.workspaceShowNumbers ? 22 : (isActive ? 26 : (hasWindows ? 20 : 16)))
                height: root.vertical ? (Config.workspaceShowNumbers ? 22 : (isActive ? 26 : (hasWindows ? 20 : 16))) : 8
                radius: Config.workspaceShowNumbers ? 4 : 2
                color: isActive ? "#99ffffff" : (hovered ? Qt.rgba(1,1,1,0.55) : Qt.rgba(1,1,1,0.25))

                Behavior on width  { NumberAnimation { duration: 100 } }
                Behavior on height { NumberAnimation { duration: 100 } }

                Text {
                    visible: Config.workspaceShowNumbers
                    anchors.centerIn: parent
                    text: pill.wsId === 10 ? "0" : pill.wsId.toString()
                    color: pill.isActive ? Config.fgColor : Qt.rgba(1,1,1,0.6)
                    font.family: Config.fontFamily
                    font.pixelSize: 12
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: pill.hovered = true
                    onExited:  pill.hovered = false
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: mouse => {
                        dispatchProcess.command = ["hyprctl", "dispatch",
                            (mouse.button === Qt.LeftButton ? "hl.dsp.focus" : "hl.dsp.window.move") +
                            "({workspace = " + pill.wsId + "})"];
                        dispatchProcess.running = true;
                    }
                }
                Process { id: dispatchProcess }
            }
        }
    }
}