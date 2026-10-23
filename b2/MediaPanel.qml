// MediaPanel.qml - album art left; title, artist and controls centred right; thin progress line along the bottom
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

Item {
    id: root

    property color fgColor: "#fff7e5"
    property color accentColor: "#ebd9b9"
    property color dimColor: Qt.rgba(fgColor.r, fgColor.g, fgColor.b, 0.6)
    property string fontFamily: "mononoki"

    readonly property int artSize: 170
    implicitHeight: artSize + 40

    readonly property var ignoredPlayers: ["zen-browser", "firefox", "youtube"]

    readonly property var activePlayer: {
        const players = Mpris.players.values || [];
        let fallback = null;
        for (let i = 0; i < players.length; i++) {
            const p = players[i];
            if (!p)
                continue;
            const id = ((p.identity || "") + " " + (p.desktopEntry || "") + " " + (p.dbusName || "")).toLowerCase();
            if (ignoredPlayers.some(name => id.includes(name)))
                continue;
            if (p.isPlaying)
                return p;
            if (!fallback && p.playbackState !== MprisPlaybackState.Stopped)
                fallback = p;
        }
        return fallback;
    }

    readonly property bool hasPlayer: activePlayer !== null
    readonly property bool isPlaying: hasPlayer && activePlayer.isPlaying
    readonly property bool canControl: hasPlayer && activePlayer.canControl
    readonly property string trackTitle: hasPlayer && activePlayer.trackTitle ? activePlayer.trackTitle : "No media playing"
    readonly property string trackArtist: hasPlayer && activePlayer.trackArtist ? activePlayer.trackArtist : ""
    readonly property string artUrl: hasPlayer && activePlayer.trackArtUrl ? activePlayer.trackArtUrl : ""
    readonly property real trackLength: hasPlayer && activePlayer.lengthSupported ? Math.max(0, activePlayer.length) : 0
    readonly property bool canSeek: hasPlayer && activePlayer.canSeek && trackLength > 0
    property real trackPosition: 0

    function formatTime(s) {
        s = Math.max(0, Math.floor(s));
        const m = Math.floor(s / 60);
        const r = s % 60;
        return m + ":" + (r < 10 ? "0" : "") + r;
    }

    function syncPosition() {
        if (!activePlayer || !activePlayer.positionSupported) {
            trackPosition = 0;
            return;
        }
        trackPosition = Math.max(0, activePlayer.position);
    }

    Timer {
        interval: 500
        repeat: true
        running: root.hasPlayer && root.visible
        onTriggered: {
            if (root.isPlaying && root.trackLength > 0)
                root.trackPosition = Math.min(root.trackLength, root.trackPosition + 0.5);
            else
                root.syncPosition();
        }
    }

    Connections {
        target: root.activePlayer
        enabled: root.activePlayer !== null
        function onPositionChanged() {
            root.syncPosition();
        }
        function onTrackTitleChanged() {
            root.syncPosition();
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // album cover
        Item {
            Layout.preferredWidth: root.artSize
            Layout.preferredHeight: root.artSize
            Layout.alignment: Qt.AlignVCenter

            Image {
                id: albumArt
                anchors.fill: parent
                source: root.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: status === Image.Ready && root.artUrl !== ""
            }
            Rectangle {
                anchors.fill: parent
                color: "#15ffffff"
                border.color: "#20ffffff"
                border.width: 1
                visible: albumArt.status !== Image.Ready || root.artUrl === ""
                Text {
                    anchors.centerIn: parent
                    text: "󰎈"
                    color: root.dimColor
                    font.family: root.fontFamily
                    font.pixelSize: 48
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            Text {
                text: root.trackTitle
                color: root.fgColor
                font.family: root.fontFamily
                font.pixelSize: 23
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            Text {
                text: root.trackArtist
                visible: text !== ""
                color: Qt.rgba(root.fgColor.r, root.fgColor.g, root.fgColor.b, 0.7)
                font.family: root.fontFamily
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 14
                spacing: 18

                MediaBtn {
                    player: root
                    text: ""
                    font.pixelSize: 28
                    active: root.hasPlayer && root.activePlayer.shuffle
                    enabledBtn: root.canControl && root.activePlayer.shuffleSupported
                    opacity: enabledBtn ? (active ? 1 : 0.55) : 0.25
                    onClicked: root.activePlayer.shuffle = !root.activePlayer.shuffle
                }
                MediaBtn {
                    player: root
                    text: ""
                    font.pixelSize: 36
                    onClicked: root.activePlayer.previous()
                }
                // primary action: filled circle
                Rectangle {
                    implicitWidth: 50
                    implicitHeight: 50
                    radius: 25
                    color: root.fgColor
                    opacity: root.canControl ? 1 : 0.35
                    MediaBtn {
                        player: root
                        anchors.centerIn: parent
                        text: root.isPlaying ? "" : ""
                        font.pixelSize: 40
                        color: "#0b0d12"
                        onClicked: root.activePlayer.togglePlaying()
                    }
                }
                MediaBtn {
                    player: root
                    text: ""
                    font.pixelSize: 36
                    onClicked: root.activePlayer.next()
                }
                MediaBtn {
                    player: root
                    text: ""
                    font.pixelSize: 28
                    active: root.hasPlayer && root.activePlayer.loopState !== MprisLoopState.None
                    enabledBtn: root.canControl && root.activePlayer.loopSupported
                    opacity: enabledBtn ? (active ? 1 : 0.55) : 0.25
                    onClicked: {
                        const p = root.activePlayer;
                        p.loopState = p.loopState === MprisLoopState.None ? MprisLoopState.Playlist : p.loopState === MprisLoopState.Playlist ? MprisLoopState.Track : MprisLoopState.None;
                    }
                    Text {
                        text: "1"
                        visible: root.hasPlayer && root.activePlayer.loopState === MprisLoopState.Track
                        color: root.accentColor
                        font.family: root.fontFamily
                        font.pixelSize: 9
                        font.bold: true
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: -5
                    }
                }
            }
        }
    }

    Text {
        anchors.right: parent.right
        anchors.bottom: progressBar.top
        anchors.margins: 8
        text: root.formatTime(root.trackPosition) + " / " + root.formatTime(root.trackLength)
        visible: root.trackLength > 0
        color: root.dimColor
        font.family: root.fontFamily
        font.pixelSize: 11
    }

    // thin progress line along the bottom edge
    Rectangle {
        id: progressBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        implicitHeight: seekArea.containsMouse ? 5 : 3
        color: "#1fffffff"

        Rectangle {
            height: parent.height
            width: root.trackLength > 0 ? parent.width * Math.min(1, root.trackPosition / root.trackLength) : 0
            color: root.fgColor
        }

        MouseArea {
            id: seekArea
            anchors.fill: parent
            anchors.topMargin: -10
            enabled: root.canSeek
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: mouse => {
                root.activePlayer.position = (mouse.x / width) * root.trackLength;
                root.syncPosition();
            }
        }
    }
}
