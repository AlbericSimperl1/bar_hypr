// VolumePanel.qml - volume meter for the current sink + list of sinks to switch to
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

TuiPanel {
    id: root

    mode: "vol"
    total: sinks.length

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null
    readonly property real vol: audio ? (audio.volume || 0) : 0
    readonly property bool muted: audio ? audio.muted : false
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio)

    function nameOf(n) {
        return n ? (n.description || n.nickname || n.name) : "No output";
    }
    function setVol(v) {
        if (!audio)
            return;
        audio.muted = false;
        audio.volume = Math.max(0, Math.min(1.5, v));
    }

    // audio props are only valid on bound nodes
    PwObjectTracker {
        objects: root.sinks
    }

    TuiPane {
        title: "volume"

        TuiMeter {
            Layout.leftMargin: 40
            from: 0
            to: 1.5
            tick: 1
            value: root.vol
            muted: root.muted
            wheelStep: 0.05
            label: Math.round(root.vol * 100) + "%"
            onMoved: v => root.setVol(v)
        }
        TuiLine {
            text: (root.muted ? "[x]" : "[ ]") + " mute"
            hint: "toggle"
            onClicked: if (root.audio)
                root.audio.muted = !root.audio.muted
        }
    }

    TuiPane {
        title: "output"

        Repeater {
            model: root.sinks

            delegate: TuiLine {
                required property var modelData
                required property int index
                number: String(index + 1)
                text: root.nameOf(modelData)
                current: modelData === root.sink
                hint: "switch output"
                onClicked: Pipewire.preferredDefaultAudioSink = modelData
            }
        }
    }
}
