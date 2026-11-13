// MediaWidget.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects

Item {
    id: root

    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"
    readonly property real s: Config.widgetScale("media")

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
    readonly property bool wantVisible: hasPlayer || isOpen

    // first half of cava's 12 bars (the low end), 0..100
    property var bars: [0, 0, 0, 0, 0, 0]

    Process {
        running: Config.mediaCava && root.hasPlayer
        command: ["cava", "-p", Qt.resolvedUrl("cava.conf").toString().replace("file://", "")]
        stdout: SplitParser {
            onRead: line => root.bars = line.split(";").slice(0, 6).map(Number)
        }
        onRunningChanged: if (!running)
            root.bars = [0, 0, 0, 0, 0, 0]
    }

    visible: wantVisible
    implicitWidth: grid.implicitWidth
    implicitHeight: grid.implicitHeight

    GridLayout {
        id: grid
        columns: root.vertical ? 1 : 3
        columnSpacing: 8
        rowSpacing: 8

        Item {
            visible: Config.mediaArt
            Layout.row: root.vertical ? 1 : 0
            Layout.column: 0
            Layout.preferredWidth: Math.round(20 * root.s)
            Layout.preferredHeight: Math.round(20 * root.s)
            Layout.alignment: Qt.AlignVCenter

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
                font.family: Config.iconFont
                font.pixelSize: Math.round(26 * root.s)
            }
        }

        Item {
            visible: Config.mediaCava
            // vertical: bars above the art; horizontal: art, bars, title
            Layout.row: 0
            Layout.column: root.vertical ? 0 : 1
            Layout.preferredWidth: Math.round(20 * root.s)
            Layout.preferredHeight: Math.round(20 * root.s)
            Layout.alignment: Qt.AlignVCenter

            Row {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 1.6 * root.s
                Repeater {
                    model: 6
                    delegate: Rectangle {
                        required property int index
                        anchors.bottom: parent.bottom
                        width: 2 * root.s
                        height: Math.max(2, (root.bars[index] || 0) / 100 * 20 * root.s)
                        radius: 1
                        color: Config.fgColor
                    }
                }
            }
        }

        Text {
            visible: !root.vertical && root.combo !== ""
            Layout.row: 0
            Layout.column: 2
            Layout.alignment: Qt.AlignVCenter
            text: root.combo
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: Config.fontPx("media", 14)
            elide: Text.ElideRight
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
