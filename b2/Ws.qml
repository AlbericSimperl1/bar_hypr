// Ws.qml - workspace indicator, Config.workspaceStyle:
//   pills     - bars, active longest
//   numbers   - numbers on translucent squares
//   box       - active number inverted in a full-thickness square
//   underline - numbers, active one underlined
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Item {
    id: root
    implicitWidth: flow.implicitWidth
    implicitHeight: numbered && !vertical ? Config.barHeight : flow.implicitHeight

    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"
    readonly property string style: Config.workspaceStyle
    readonly property bool numbered: style !== "pills"
    // box / underline: one px below the clock & date text
    readonly property int textPx: Math.min(Config.fontPx("clock", 19), Config.fontPx("date", 17))

    function fg(a) {
        return Qt.rgba(Config.fgColor.r, Config.fgColor.g, Config.fgColor.b, a);
    }

    Process {
        id: dispatch
    }

    function run(expr) {
        dispatch.command = ["hyprctl", "dispatch", expr];
        dispatch.running = true;
    }

    Flow {
        id: flow
        anchors.verticalCenter: parent.verticalCenter
        flow: root.vertical ? Flow.TopToBottom : Flow.LeftToRight
        spacing: root.style === "box" ? 2 : 5.5

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

                readonly property real len: {
                    switch (root.style) {
                    case "pills":
                        return (isActive ? 80 : (hasWindows ? 40 : 20)) * Config.widgetScale("ws");
                    case "box":
                        return Config.barHeight;
                    case "underline":
                        return Math.round(root.textPx * 1.4);
                    default:
                        return Config.barHeight - 2;
                    }
                }
                readonly property real thick: root.style === "pills" ? 7 * Config.widgetScale("ws") : (root.style === "box" ? Config.barHeight : Config.barHeight - 2)

                width: root.vertical ? thick : len
                height: root.vertical ? len : thick
                radius: root.style === "box" ? 0 : (root.style === "numbers" ? 4 : 3)
                color: {
                    switch (root.style) {
                    case "pills":
                        return isActive ? "#fff7e5" : (hovered ? "#99fff7e5" : "#55fff7e5");
                    case "numbers":
                        return Qt.rgba(1, 1, 1, isActive ? 0.35 : (hasWindows ? 0.15 : (hovered ? 0.08 : 0)));
                    case "box":
                        return isActive ? Config.fgColor : (hovered ? root.fg(0.1) : "transparent");
                    default:
                        return hovered ? root.fg(0.08) : "transparent";
                    }
                }

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
                    visible: root.numbered
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: pill.wsId === 10 ? "0" : pill.wsId.toString()
                    color: {
                        if (root.style === "numbers")
                            return Qt.rgba(1, 1, 1, pill.isActive ? 1 : (pill.hasWindows ? 0.7 : 0.4));
                        if (root.style === "box" && pill.isActive)
                            return Qt.rgba(Config.barBg.r, Config.barBg.g, Config.barBg.b, 1);
                        return root.fg(pill.isActive || pill.hasWindows ? 1 : 0.45);
                    }
                    font.bold: pill.isActive || root.style !== "numbers"
                    font.family: Config.fontFamily
                    font.pixelSize: root.style === "numbers" ? Math.round(14 * Config.widgetScale("ws")) : root.textPx
                }

                // underline style: rounded bar under the active number
                Rectangle {
                    visible: root.style === "underline" && pill.isActive
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: Math.max(2, Math.round(2 * Config.widgetScale("ws")))
                    radius: height / 2
                    color: Config.fgColor
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
