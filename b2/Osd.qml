// Osd.qml — on-screen toasts voor volume, microfoon, audio-output, brightness en muziek,
// in dezelfde stijl als de notificatie-toasts (via Notifications.osd).
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris

Singleton {
    id: root

    // bij het opstarten melden pipewire en mpris hun beginwaarden als wijziging: die tonen we niet
    property bool ready: false
    Timer {
        interval: 2500
        running: true
        onTriggered: root.ready = true
    }

    // ---- audio --------------------------------------------------------
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    property real _sinkSwitchedAt: 0

    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    function volumeGlyph(pct, muted) {
        if (muted || pct === 0)
            return "󰖁";
        if (pct < 33)
            return "󰕿";
        if (pct < 66)
            return "󰖀";
        return "󰕾";
    }

    function showVolume() {
        // een nieuwe output meldt meteen zijn volume; dan alleen de output-toast tonen
        if (!ready || !sink || !sink.audio || Date.now() - _sinkSwitchedAt < 600)
            return;
        const vol = sink.audio.volume || 0;
        const pct = Math.round(vol * 100);
        const muted = sink.audio.muted;
        Notifications.osd("volume", volumeGlyph(pct, muted), "", muted ? "Muted" : pct + "%", muted ? 0 : Math.min(1, vol), "");
    }

    // bluetooth-sinks hebben geen icon-name op de node, dus op naam herkennen
    function sinkGlyph(n) {
        const id = n ? ((n.name || "") + " " + (n.properties["device.icon-name"] || "")).toLowerCase() : "";
        return id.includes("bluez") || id.includes("headset") || id.includes("headphone") ? "󰋋" : "󰓃";
    }

    onSinkChanged: {
        _sinkSwitchedAt = Date.now();
        if (ready && sink)
            Notifications.osd("output", sinkGlyph(sink), "Audio output", sink.description || sink.nickname || sink.name, -1, "");
    }

    Connections {
        target: root.sink ? root.sink.audio : null
        function onVolumeChanged() {
            root.showVolume();
        }
        function onMutedChanged() {
            root.showVolume();
        }
    }

    Connections {
        target: root.source ? root.source.audio : null
        function onMutedChanged() {
            if (!root.ready)
                return;
            const muted = root.source.audio.muted;
            Notifications.osd("mic", muted ? "󰍭" : "󰍬", "Microphone", muted ? "Muted" : "On", -1, "");
        }
    }

    // ---- brightness (DDC/CI: het externe scherm heeft geen backlight) ---
    property int brightness: -1
    property int _target: -1

    Process {
        id: readBrightness
        command: ["ddcutil", "--brief", "getvcp", "10"]
        running: true
        // uitvoer: "VCP 10 C <huidig> <max>"
        stdout: StdioCollector {
            onStreamFinished: {
                const v = parseInt(this.text.trim().split(/\s+/)[3]);
                if (!isNaN(v))
                    root.brightness = v;
            }
        }
    }

    // ddcutil duurt ~0.4s per aanroep: snelle toetsaanslagen schrijven alleen de laatste waarde
    Process {
        id: writeBrightness
        onExited: if (root._target >= 0)
            root._flushBrightness()
    }

    function _flushBrightness() {
        writeBrightness.command = ["ddcutil", "--noverify", "setvcp", "10", String(_target)];
        _target = -1;
        writeBrightness.running = true;
    }

    function setBrightness(v) {
        if (brightness < 0) {
            readBrightness.running = true;
            return;
        }
        brightness = Math.max(0, Math.min(100, Math.round(v)));
        const glyph = ["󰃞", "󰃟", "󰃝", "󰃠"][Math.min(3, Math.floor(brightness / 25.01))];
        Notifications.osd("brightness", glyph, "", brightness + "%", brightness / 100, "");
        _target = brightness;
        if (!writeBrightness.running)
            _flushBrightness();
    }

    // ---- muziek -------------------------------------------------------
    property string _lastTrack: ""

    Instantiator {
        model: Mpris.players
        delegate: Connections {
            required property var modelData
            target: modelData
            function onTrackTitleChanged() {
                root._track(modelData);
            }
            function onTrackArtistChanged() {
                root._track(modelData);
            }
            function onTrackArtUrlChanged() {
                root._track(modelData);
            }
        }
    }

    function _track(p) {
        if (!ready || !p.isPlaying || !p.trackTitle)
            return;
        // de cover komt vaak net na de titel binnen: dan werkt dezelfde toast bij
        const id = p.trackTitle + "|" + (p.trackArtist || "") + "|" + (p.trackArtUrl || "");
        if (id === _lastTrack)
            return;
        _lastTrack = id;
        Notifications.osd("music", "󰝚", p.trackTitle, p.trackArtist || p.identity || "", -1, p.trackArtUrl || "");
    }

    // ---- IPC (Hyprland-binds) ------------------------------------------
    // qs -p ~/bar_hypr/b2 ipc call osd brightness 5
    IpcHandler {
        target: "osd"
        function brightness(delta: int): void {
            root.setBrightness(root.brightness + delta);
        }
    }
}
