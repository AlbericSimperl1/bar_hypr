// Ws.qml
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Item {
    id: root
    implicitWidth: flow.implicitWidth
    implicitHeight: flow.implicitHeight

    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"

    Process {
        id: dispatch
    }

    function run(expr) {
        dispatch.command = ["hyprctl", "dispatch", expr];
        dispatch.running = true;
    }

    Flow {
        id: flow
        flow: root.vertical ? Flow.TopToBottom : Flow.LeftToRight
        spacing: 5

        Repeater {
            model: Config.workspaceCount

            delegate: Rectangle {
                id: pill
                required property int index
                readonly property int wsId: index + 1

                readonly property bool isActive: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === wsId
                readonly property bool hasWindows: {
                    if (!Hyprland.toplevels)
                        return false;
                    return Hyprland.toplevels.values.some(t => t.workspace && t.workspace.id === wsId);
                }
                property bool hovered: false

                readonly property real len: Config.workspaceShowNumbers ? 22 : (isActive ? 80 : (hasWindows ? 40 : 20))
                readonly property real thick: Config.workspaceShowNumbers ? 22 : 8

                width: root.vertical ? thick : len
                height: root.vertical ? len : thick
                radius: Config.workspaceShowNumbers ? 4 : 2
                color: isActive ? "#99ffffff" : (hovered ? Qt.rgba(1, 1, 1, 0.55) : Qt.rgba(1, 1, 1, 0.25))

                Behavior on width {
                    NumberAnimation {
                        duration: 100
                    }
                }
                Behavior on height {
                    NumberAnimation {
                        duration: 100
                    }
                }

                Text {
                    visible: Config.workspaceShowNumbers
                    anchors.centerIn: parent
                    text: pill.wsId === 10 ? "0" : pill.wsId.toString()
                    color: pill.isActive ? Config.fgColor : Qt.rgba(1, 1, 1, 0.6)
                    font.family: Config.fontFamily
                    font.pixelSize: 12
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -2
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onEntered: pill.hovered = true
                    onExited: pill.hovered = false
                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton)
                            root.run("hl.dsp.focus({workspace = " + pill.wsId + "})");
                        else
                            root.run("hl.dsp.window.move({workspace = " + pill.wsId + "})");
                    }
                }
            }
        }
    }
}
