// bar/horizontaal/BluetoothPanel.qml
// Native Quickshell.Bluetooth (BlueZ) - no Rust backend needed
import QtQuick
import QtQuick.Layouts
import QtQml
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth

TuiPanel {
    id: root

    mode: "bt"
    total: powered ? deviceCount : 0

    // ------------------------------------------------------------------
    // State
    // ------------------------------------------------------------------
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool powered: adapter ? adapter.enabled : false

    property var entries: []          // [{ title, kind, devs, base }], één pane per groep
    property int deviceCount: 0
    property string _sig: ""

    property string connectingAddr: ""
    property string failedAddr: ""
    property bool sawConnecting: false
    property int retries: 0

    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------
    function labelOf(d) {
        return String(d.name || d.deviceName || "").trim();
    }

    function isNamed(d) {
        const n = labelOf(d);
        if (n === "")
            return false;
        return !/^([0-9a-f]{2}[-:]){5}[0-9a-f]{2}$/i.test(n);
    }

    function scheduleRebuild() {
        Qt.callLater(root.rebuild);
    }

    function rebuild() {
        const devs = adapter ? adapter.devices.values : [];
        const conn = [], known = [], avail = [];

        for (let i = 0; i < devs.length; i++) {
            const d = devs[i];
            if (!d)
                continue;
            if (d.connected) {
                conn.push(d);
            } else if (isNamed(d)) {
                if (d.paired || d.trusted)
                    known.push(d);
                else
                    avail.push(d);
            }
        }

        const byName = (a, b) => labelOf(a).toLowerCase().localeCompare(labelOf(b).toLowerCase());
        conn.sort(byName);
        known.sort(byName);
        avail.sort(byName);

        const out = [];
        if (powered) {
            let base = 0;
            const add = (title, kind, list) => {
                out.push({
                    title,
                    kind,
                    devs: list,
                    base
                });
                base += list.length;
            };
            if (conn.length)
                add("connected", "connected", conn);
            if (known.length)
                add("paired", "known", known);
            add("available", "available", avail);
            deviceCount = base;
        }

        const sig = out.map(e => e.kind + e.devs.map(d => d.address).join(",")).join("|");
        if (sig !== _sig) {
            _sig = sig;
            entries = out;
        }
    }

    // ------------------------------------------------------------------
    // Scanning — altijd aan zolang het paneel zichtbaar is
    // ------------------------------------------------------------------
    function startScan() {
        if (adapter && powered)
            adapter.discovering = true;
    }

    function stopScan() {
        if (adapter && adapter.discovering)
            adapter.discovering = false;
    }

    function togglePower() {
        if (!adapter)
            return;
        adapter.enabled = !adapter.enabled;
    }

    function connectDevice(d) {
        if (!d || d.connected)
            return;
        failedAddr = "";
        retries = 0;
        sawConnecting = false;
        connectingAddr = d.address;
        connectTimeout.restart();
        if (!d.paired) {
            d.trusted = true;
            d.pair();
        } else {
            if (!d.trusted)
                d.trusted = true;
            d.connect();
        }
    }

    function disconnectDevice(d) {
        if (d)
            d.disconnect();
    }

    function forgetDevice(d) {
        if (d)
            d.forget();
    }

    // ------------------------------------------------------------------
    // Wiring
    // ------------------------------------------------------------------
    Component.onCompleted: {
        rebuild();
        startScan();
    }

    onAdapterChanged: {
        scheduleRebuild();
        startScan();
    }

    onPoweredChanged: {
        scheduleRebuild();
        if (powered)
            startScan();
    }

    onVisibleChanged: {
        if (visible)
            startScan();
        else
            stopScan();
    }

    Connections {
        target: root.adapter ? root.adapter.devices : null
        function onValuesChanged() {
            root.scheduleRebuild();
        }
    }

    Instantiator {
        model: root.adapter ? root.adapter.devices : null
        delegate: Connections {
            required property var modelData
            target: modelData

            function onConnectedChanged() {
                if (modelData.connected && root.connectingAddr === modelData.address) {
                    root.connectingAddr = "";
                    connectTimeout.stop();
                }
                root.scheduleRebuild();
            }

            function onPairedChanged() {
                if (modelData.paired && root.connectingAddr === modelData.address && !modelData.connected) {
                    modelData.trusted = true;
                    modelData.connect();
                }
                root.scheduleRebuild();
            }

            function onStateChanged() {
                if (root.connectingAddr !== modelData.address)
                    return;
                if (modelData.state === BluetoothDeviceState.Connecting) {
                    root.sawConnecting = true;
                } else if (modelData.state === BluetoothDeviceState.Disconnected && root.sawConnecting && !modelData.connected) {
                    root.sawConnecting = false;
                    if (root.retries < 1) {
                        root.retries++;
                        Qt.callLater(function () {
                            modelData.connect();
                        });
                    } else {
                        root.failedAddr = modelData.address;
                        root.connectingAddr = "";
                        connectTimeout.stop();
                        failTimer.restart();
                    }
                }
            }

            function onTrustedChanged() {
                root.scheduleRebuild();
            }
            function onNameChanged() {
                root.scheduleRebuild();
            }
            function onDeviceNameChanged() {
                root.scheduleRebuild();
            }
        }
        onObjectAdded: root.scheduleRebuild()
        onObjectRemoved: root.scheduleRebuild()
    }

    Timer {
        id: connectTimeout
        interval: 20000
        repeat: false
        onTriggered: {
            if (root.connectingAddr !== "") {
                root.failedAddr = root.connectingAddr;
                root.connectingAddr = "";
                failTimer.restart();
            }
        }
    }

    Timer {
        id: failTimer
        interval: 4000
        repeat: false
        onTriggered: root.failedAddr = ""
    }

    // ------------------------------------------------------------------
    // UI
    // ------------------------------------------------------------------
    TuiPane {
        title: "bluetooth"

        TuiLine {
            text: (root.powered ? "[x]" : "[ ]") + " powered"
            detail: root.powered ? "on" : "off"
            detailColor: root.powered ? Tui.on : Tui.dim
            hint: "toggle"
            onClicked: root.togglePower()
        }
        TuiLine {
            visible: !root.powered
            selectable: false
            text: root.adapter ? "bluetooth is off" : "no adapter found"
            textColor: Tui.dim
        }
    }

    Repeater {
        model: root.entries

        delegate: TuiPane {
            id: group
            required property var modelData
            title: modelData.title

            Repeater {
                model: group.modelData.devs

                delegate: TuiLine {
                    id: device
                    required property var modelData
                    required property int index
                    readonly property var d: modelData
                    readonly property string kind: group.modelData.kind
                    // d wordt null zodra BlueZ het apparaat weghaalt, nog voor de lijst is herbouwd
                    readonly property bool busy: d ? (root.connectingAddr === d.address || d.state === BluetoothDeviceState.Connecting || d.pairing === true) : false
                    readonly property bool failed: d ? root.failedAddr === d.address : false

                    number: String(group.modelData.base + index + 1)
                    text: d ? root.labelOf(d) : ""
                    hint: kind === "connected" || busy ? "" : (kind === "available" ? "pair" : "connect")
                    detail: busy ? "connecting…" : failed ? "failed" : d && d.batteryAvailable ? Math.round(d.battery * 100) + "%" : ""
                    detailColor: failed && !busy ? Tui.danger : Tui.dim
                    onClicked: {
                        if (d && !d.connected && !busy)
                            root.connectDevice(d);
                    }

                    TuiAction {
                        visible: device.kind === "connected"
                        text: "disconnect"
                        onClicked: root.disconnectDevice(device.d)
                    }
                    TuiAction {
                        visible: device.kind !== "connected" && !device.busy
                        text: device.kind === "available" ? "pair" : "connect"
                        onClicked: root.connectDevice(device.d)
                    }
                    TuiAction {
                        visible: device.kind === "known"
                        text: "forget"
                        onClicked: root.forgetDevice(device.d)
                    }
                }
            }

            TuiLine {
                visible: group.modelData.kind === "available" && root.adapter && root.adapter.discovering
                selectable: false
                text: "searching for devices…"
                textColor: Tui.dim
            }
        }
    }
}
