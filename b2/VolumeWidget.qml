// VolumeWidget.qml
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris

Item {
    id: root
    implicitWidth:  flow.implicitWidth
    implicitHeight: flow.implicitHeight

    // same rule as MediaWidget: only shown while a player exists (or the panel is open)
    readonly property bool isOpen: BarState.activePanel === "volume"
    visible: Mpris.players.values.length > 0 || isOpen

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

    // volume/mute are only readable and writable on bound nodes
    PwObjectTracker {
        objects: [root.sink]
    }

    Flow {
        id: flow
        flow: (Config.barPosition === "left" || Config.barPosition === "right") ? Flow.TopToBottom : Flow.LeftToRight
        spacing: 4

        // fixed 24px cells, centered, so icon and percent share one baseline like the other widgets
        Text {
            visible: Config.volumeIconMode === "icon" || Config.volumeIconMode === "both"
            height: Math.round(24 * Config.widgetScale("volume"))
            verticalAlignment: Text.AlignVCenter
            text: root.icon
            color: Config.fgColor
            font.family: Config.iconFont
            font.pixelSize: Config.iconPx("volume", 24)
        }
        Text {
            visible: Config.volumeIconMode === "percent" || Config.volumeIconMode === "both"
            height: Math.round(24 * Config.widgetScale("volume"))
            verticalAlignment: Text.AlignVCenter
            text: root.pct + "%"
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: Config.fontPx("volume", 15)
        }
        // 24px across the bar so the thin pill stays easy to click and scroll on
        Item {
            visible: Config.volumeIconMode === "bar"
            width: Config.vertical ? Math.max(24, volBar.implicitWidth) : volBar.implicitWidth
            height: Config.vertical ? volBar.implicitHeight : Math.max(24, volBar.implicitHeight)
            FillBar {
                id: volBar
                anchors.centerIn: parent
                sizeScale: Config.widgetScale("volume")
                value: root.muted ? 0 : root.vol
                fillColor: !root.muted && root.pct > 100 ? "#e6c641" : Qt.rgba(1, 1, 1, 0.55)
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                if (root.audio)
                    root.audio.muted = !root.audio.muted;
            } else {
                const p = root.mapToItem(null, root.width / 2, root.height / 2);
                BarState.toggle("volume", p.x, p.y);
            }
        }
        onWheel: wheel => {
            if (!root.audio) return;
            const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
            root.audio.volume = Math.max(0, Math.min(1.5, root.audio.volume + step));
        }
    }
}