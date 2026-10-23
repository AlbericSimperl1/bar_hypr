// VolumePanel.qml - volume slider for the current sink + list of sinks to switch to
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

Item {
    id: root

    property color fgColor: "#fff7e5"
    property color accentColor: "#ebd9b9"
    property color dimColor: Qt.rgba(fgColor.r, fgColor.g, fgColor.b, 0.6)
    property color lineColor: "#20ffffff"
    property string fontFamily: "mononoki"

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null
    readonly property real vol: audio ? (audio.volume || 0) : 0
    readonly property bool muted: audio ? audio.muted : false
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio)

    readonly property real neededHeight: col.implicitHeight + 32

    function nameOf(n) {
        return n ? (n.description || n.nickname || n.name) : "No output";
    }
    function setVol(v) {
        if (!audio)
            return;
        audio.muted = false;
        audio.volume = Math.max(0, Math.min(1, v));
    }

    // audio props are only valid on bound nodes
    PwObjectTracker {
        objects: root.sinks
    }

    ColumnLayout {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 16
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: root.muted || root.vol === 0 ? "󰖁" : root.vol < 0.33 ? "󰕿" : root.vol < 0.66 ? "󰖀" : "󰕾"
                color: root.muted ? root.dimColor : root.accentColor
                font.family: root.fontFamily
                font.pixelSize: 22
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (root.audio)
                        root.audio.muted = !root.audio.muted
                }
            }
            Text {
                text: root.nameOf(root.sink)
                color: root.fgColor
                font.family: root.fontFamily
                font.pixelSize: 15
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            Text {
                text: Math.round(root.vol * 100) + "%"
                color: root.dimColor
                font.family: root.fontFamily
                font.pixelSize: 14
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 8
            color: "#15ffffff"
            border.color: root.lineColor
            border.width: 1

            Rectangle {
                width: parent.width * Math.min(1, root.vol)
                height: parent.height
                    color: root.muted ? root.dimColor : root.accentColor
            }

            MouseArea {
                anchors.fill: parent
                anchors.topMargin: -6
                anchors.bottomMargin: -6
                cursorShape: Qt.PointingHandCursor
                onPressed: m => root.setVol(m.x / width)
                onPositionChanged: m => {
                    if (pressed)
                        root.setVol(m.x / width);
                }
                onWheel: w => root.setVol(root.vol + (w.angleDelta.y > 0 ? 0.05 : -0.05))
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: root.lineColor
        }

        Text {
            text: "Output"
            color: root.dimColor
            font.family: root.fontFamily
            font.pixelSize: 12
        }

        Repeater {
            model: root.sinks

            delegate: Rectangle {
                required property var modelData
                readonly property bool current: modelData === root.sink
                Layout.fillWidth: true
                implicitHeight: 36
                color: current ? "#22ffffff" : rowMa.containsMouse ? "#12ffffff" : "transparent"
                border.color: current ? root.accentColor : "transparent"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10

                    Text {
                        text: current ? "󰓃" : "󰓄"
                        color: current ? root.accentColor : root.dimColor
                        font.family: root.fontFamily
                        font.pixelSize: 16
                    }
                    Text {
                        text: root.nameOf(modelData)
                        color: current ? root.accentColor : root.fgColor
                        font.family: root.fontFamily
                        font.pixelSize: 13
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                MouseArea {
                    id: rowMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Pipewire.preferredDefaultAudioSink = modelData
                }
            }
        }
    }
}
