// MediaPanel.qml - album art and track info, a seek meter, and the controls as a row of words
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

TuiPanel {
    id: root

    mode: "media"
    hint: !hasPlayer ? "" : isPlaying ? "playing" : "paused"

    readonly property int artSize: 96

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
        triggeredOnStart: true // direct juiste positie bij openen van het panel
        onTriggered: root.syncPosition()
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

    TuiPane {
        title: root.hasPlayer && root.activePlayer.identity ? root.activePlayer.identity : "media"

        TuiLine {
            visible: !root.hasPlayer
            numbered: false
            selectable: false
            text: "no player"
            textColor: Tui.dim
        }

        ColumnLayout {
            visible: root.hasPlayer
            Layout.fillWidth: true
            Layout.margins: 4
            spacing: 6

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // album cover
                Item {
                    Layout.preferredWidth: root.artSize
                    Layout.preferredHeight: root.artSize

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
                        color: "transparent"
                        border.color: Tui.rule
                        border.width: 1
                        visible: !albumArt.visible
                        Text {
                            anchors.centerIn: parent
                            text: "art"
                            color: Tui.dim
                            font.family: Tui.family
                            font.pixelSize: Tui.size
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    spacing: 0

                    Repeater {
                        model: root.hasPlayer ? [root.activePlayer.trackTitle || "No media playing", root.activePlayer.trackArtist || "", root.activePlayer.trackAlbum || ""] : []
                        delegate: Text {
                            required property string modelData
                            required property int index
                            visible: modelData !== ""
                            Layout.fillWidth: true
                            Layout.preferredHeight: Tui.lineH
                            verticalAlignment: Text.AlignVCenter
                            text: modelData
                            elide: Text.ElideRight
                            color: index === 0 ? Tui.text : Tui.dim
                            font.family: Tui.family
                            font.pixelSize: Tui.size
                            font.bold: index === 0
                        }
                    }
                }
            }

            RowLayout {
                visible: root.trackLength > 0
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: root.formatTime(root.trackPosition)
                    color: Tui.dim
                    font.family: Tui.family
                    font.pixelSize: Tui.size
                }
                TuiMeter {
                    from: 0
                    to: root.trackLength
                    value: root.trackPosition
                    interactive: root.canSeek
                    onMoved: v => {
                        root.activePlayer.position = v;
                        root.syncPosition();
                    }
                }
                Text {
                    text: root.formatTime(root.trackLength)
                    color: Tui.dim
                    font.family: Tui.family
                    font.pixelSize: Tui.size
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                SChip {
                    Layout.fillWidth: true
                    label: "shuf"
                    on: root.hasPlayer && root.activePlayer.shuffle
                    enabled: root.canControl && root.activePlayer.shuffleSupported
                    onActivated: root.activePlayer.shuffle = !root.activePlayer.shuffle
                }
                SChip {
                    Layout.fillWidth: true
                    label: "prev"
                    enabled: root.canControl
                    onActivated: root.activePlayer.previous()
                }
                SChip {
                    Layout.fillWidth: true
                    label: root.isPlaying ? "pause" : "play"
                    sel: true
                    enabled: root.canControl
                    onActivated: root.activePlayer.togglePlaying()
                }
                SChip {
                    Layout.fillWidth: true
                    label: "next"
                    enabled: root.canControl
                    onActivated: root.activePlayer.next()
                }
                SChip {
                    Layout.fillWidth: true
                    label: root.hasPlayer && root.activePlayer.loopState === MprisLoopState.Track ? "loop 1" : "loop"
                    on: root.hasPlayer && root.activePlayer.loopState !== MprisLoopState.None
                    enabled: root.canControl && root.activePlayer.loopSupported
                    onActivated: {
                        const p = root.activePlayer;
                        p.loopState = p.loopState === MprisLoopState.None ? MprisLoopState.Playlist : p.loopState === MprisLoopState.Playlist ? MprisLoopState.Track : MprisLoopState.None;
                    }
                }
            }
        }
    }
}
