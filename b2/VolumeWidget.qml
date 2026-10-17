// VolumeWidget.qml
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Item {
    id: root
    implicitWidth:  flow.implicitWidth
    implicitHeight: flow.implicitHeight

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null
    readonly property bool muted: audio ? audio.muted : false
    readonly property real vol: audio ? (audio.volume || 0) : 0
    readonly property int pct: Math.round(vol * 100)

    readonly property string icon: {
        if (muted || pct === 0) return "󰖁";
        if (pct < 33) return "󰕿";
        if (pct < 66) return "󰖀";
        return "󰕾";
    }

    Flow {
        id: flow
        flow: (Config.barPosition === "left" || Config.barPosition === "right") ? Flow.TopToBottom : Flow.LeftToRight
        spacing: 4

        Text {
            text: root.icon
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: 24
        }
        Text {
            visible: Config.volumeIconMode !== "icon"
            text: Config.volumeIconMode === "both" ? " " + root.pct + "%" : root.pct + "%"
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: 16
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (!root.audio) return;
            if (mouse.button === Qt.RightButton)
                root.audio.muted = !root.audio.muted;
        }
        onWheel: wheel => {
            if (!root.audio) return;
            const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
            root.audio.volume = Math.max(0, Math.min(1.5, root.audio.volume + step));
        }
    }
}