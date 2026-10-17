// MediaWidget.qml
import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects

Item {
    id: root
    implicitWidth: flow.implicitWidth
    implicitHeight: flow.implicitHeight

    readonly property var player: {
        const ps = Mpris.players.values;
        if (!ps || ps.length === 0)
            return null;
        for (let p of ps)
            if (p.playbackState === MprisPlaybackState.Playing)
                return p;
        return ps[0];
    }
    readonly property bool hasPlayer: player !== null
    readonly property string artUrl: hasPlayer && player.trackArtUrl ? player.trackArtUrl : ""
    readonly property string title: hasPlayer && player.trackTitle ? player.trackTitle : ""
    readonly property string artist: hasPlayer && player.trackArtist ? player.trackArtist : ""
    readonly property string combo: {
        if (!title && !artist)
            return "";
        const t = title.length > Config.mediaTitleMax ? title.substring(0, Config.mediaTitleMax) + "…" : title;
        if (!artist)
            return t;
        if (!title)
            return artist;
        return artist + " - " + t;
    }
    readonly property bool isOpen: BarState.activePanel === "media"

    visible: hasPlayer || isOpen

    Flow {
        id: flow
        flow: (Config.barPosition === "left" || Config.barPosition === "right") ? Flow.TopToBottom : Flow.LeftToRight
        spacing: 8

        Item {
            width: 20
            height: 20
            Image {
                id: art
                anchors.fill: parent
                source: root.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: false
            }
            Rectangle {
                id: mask
                anchors.fill: parent
                radius: 6
                visible: false
            }
            OpacityMask {
                anchors.fill: parent
                source: art
                maskSource: mask
                visible: art.status === Image.Ready && root.artUrl !== ""
            }
            Text {
                anchors.centerIn: parent
                visible: art.status !== Image.Ready || root.artUrl === ""
                text: "󰎈"
                color: Config.fgColor
                font.family: Config.fontFamily
                font.pixelSize: 26
            }
        }

        Text {
            visible: !root.isOpen && root.combo !== ""
            text: root.combo
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: 14
            elide: Text.ElideRight
        }

        Text {
            visible: root.isOpen
            text: "󰅃"
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: 22
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            const p = root.mapToItem(null, root.width / 2, root.height / 2);
            BarState.toggle("media", p.x, p.y);
        }
    }
}
