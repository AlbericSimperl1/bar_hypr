// quickshell/modules/panels/WifiPanel.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import "./Model.js" as Model

TuiPanel {
    id: wifiPanelRoot

    mode: passwordSsid !== "" ? "pass" : "net"
    total: wifiStationAvailable ? wifiNetworks.length : 0

    onEscaped: cancelPasswordPrompt()
    // de prompt verdwijnt met de focus erin: haal hem terug zodat de pijltjes blijven werken
    onPasswordSsidChanged: if (passwordSsid === "")
        forceActiveFocus()

    buttons: [
        TuiAction {
            visible: wifiPanelRoot.passwordSsid === ""
            text: "refresh"
            font.pixelSize: Tui.statusSize
            onClicked: wifiPanelRoot.refresh(true)
        },
        TuiAction {
            visible: wifiPanelRoot.passwordSsid !== ""
            text: "connect"
            font.pixelSize: Tui.statusSize
            onClicked: wifiPanelRoot.submitPassword()
        },
        TuiAction {
            visible: wifiPanelRoot.passwordSsid !== ""
            text: "cancel"
            font.pixelSize: Tui.statusSize
            onClicked: wifiPanelRoot.cancelPasswordPrompt()
        }
    ]

    // State & Networking
    readonly property bool networkManagerAvailable: Networking.backend === NetworkBackendType.NetworkManager
    readonly property var networkDevices: Networking.devices ? Networking.devices.values : []
    readonly property var wifiDevice: findDevice(DeviceType.Wifi)
    readonly property var wifiNetworkObjects: wifiDevice && wifiDevice.networks ? wifiDevice.networks.values : []
    readonly property var connectedWifiNetwork: findConnectedWifiNetwork()
    readonly property var wiredDevice: findDevice(DeviceType.Wired)

    property var wifiNetworks: []
    property bool scanning: false
    property bool wifiStationAvailable: false

    property string dnsProvider: "DHCP"
    property string actionSsid: ""
    property string actionKind: ""
    property string failureSsid: ""
    property string failureReason: ""
    property string passwordSsid: ""
    property string passwordText: ""
    property string identityText: ""

    readonly property bool busy: actionKind !== ""

    readonly property string kind: {
        if (wiredDevice && wiredDevice.connected)
            return "ethernet";
        if (connectedWifiNetwork)
            return "wifi";
        return "disconnected";
    }

    readonly property int signalStrength: connectedWifiNetwork ? Math.round((connectedWifiNetwork.signalStrength || 0) * 100) : -1

    // Functies
    function cancelPasswordPrompt() {
        passwordSsid = "";
        passwordText = "";
        identityText = "";
    }

    function toggleNetwork() {
        if (!networkManagerAvailable)
            return;
        Networking.wifiEnabled = !Networking.wifiEnabled;
        Qt.callLater(function () {
            wifiPanelRoot.refresh(true);
        });
    }

    function findDevice(type) {
        var devices = networkDevices || [];
        var fallback = null;
        for (var i = 0; i < devices.length; i++) {
            var device = devices[i];
            if (!device || device.type !== type)
                continue;
            if (device.connected)
                return device;
            if (!fallback)
                fallback = device;
        }
        return fallback;
    }

    function findConnectedWifiNetwork() {
        var networks = wifiNetworkObjects || [];
        for (var i = 0; i < networks.length; i++) {
            if (networks[i] && networks[i].connected)
                return networks[i];
        }
        return null;
    }

    function syncWifiNetworks() {
        var nets = [];
        var networks = wifiNetworkObjects || [];

        for (var i = 0; i < networks.length; i++) {
            var network = networks[i];
            if (!network)
                continue;
            checkActionCompletion(network);
            var row = Model.wifiRow(network);
            if (row)
                nets.push(row);
        }
        wifiNetworks = Model.sortWifiRows(nets);
        wifiStationAvailable = !!wifiDevice;
        scanning = false;
    }

    function refresh(scanWifi) {
        if (scanWifi === undefined)
            scanWifi = false;
        if (wifiDevice) {
            if (scanWifi) {
                scanning = true;
                setScannerEnabled(false);
                scanRestart.start();
            } else {
                setScannerEnabled(true);
            }
        }
        syncWifiNetworks();
    }

    property var scannerDevice: null
    function setScannerEnabled(enabled) {
        var nextDevice = wifiDevice;
        if (scannerDevice && scannerDevice !== nextDevice)
            scannerDevice.scannerEnabled = false;
        scannerDevice = nextDevice;
        if (scannerDevice)
            scannerDevice.scannerEnabled = enabled;
    }

    Component.onCompleted: refresh(true)
    Component.onDestruction: {
        if (scannerDevice)
            scannerDevice.scannerEnabled = false;
    }

    onWifiDeviceChanged: {
        setScannerEnabled(true);
        syncWifiNetworks();
    }
    onWifiNetworkObjectsChanged: syncWifiNetworks()

    function requiresCredentials(security) {
        return Model.requiresCredentials(security, WifiSecurityType.Open, WifiSecurityType.Owe);
    }

    function openPasswordPrompt(ssid) {
        if (passwordSsid !== ssid) {
            passwordText = "";
            identityText = "";
        }
        passwordSsid = ssid;
    }

    function isEnterprise(security) {
        return security === WifiSecurityType.Wpa2Eap || security === WifiSecurityType.WpaEap;
    }

    function submitPassword() {
        const net = wifiNetworks.find(n => n.ssid === passwordSsid);
        if (!net || passwordText.length === 0)
            return;
        if (!isEnterprise(net.security))
            connectWithPassphrase(passwordSsid, passwordText);
        else if (identityText.length > 0)
            connectEnterprise(passwordSsid, identityText, passwordText);
    }

    function networkForSsid(ssid) {
        var networks = wifiNetworkObjects || [];
        for (var i = 0; i < networks.length; i++) {
            if (networks[i] && networks[i].name === ssid)
                return networks[i];
        }
        return null;
    }

    function runNetworkAction(kind, network, callback) {
        if (actionKind !== "" || !network)
            return;
        var ssid = network.name || "";
        actionSsid = ssid;
        actionKind = kind;
        failureSsid = "";
        failureReason = "";
        callback(network);
        actionTimeout.restart();
    }

    function clearNetworkAction() {
        actionTimeout.stop();
        if (actionKind === "connect")
            passwordSsid = "";
        failureSsid = "";
        failureReason = "";
        actionSsid = "";
        actionKind = "";
        refresh();
    }

    function checkActionCompletion(network) {
        if (!network || actionKind === "" || actionSsid !== (network.name || ""))
            return;
        if (actionKind === "connect" && network.connected)
            clearNetworkAction();
        else if (actionKind === "disconnect" && !network.connected && !network.stateChanging)
            clearNetworkAction();
        else if (actionKind === "forget" && !network.known && !network.stateChanging)
            clearNetworkAction();
    }

    function connectDirectly(ssid) {
        runNetworkAction("connect", networkForSsid(ssid), function (network) {
            network.connect();
        });
    }

    function connectWithPassphrase(ssid, passphrase) {
        runNetworkAction("connect", networkForSsid(ssid), function (network) {
            network.connectWithPsk(passphrase);
        });
    }

    function connectEnterprise(ssid, identity, passphrase) {
        runNetworkAction("connect", networkForSsid(ssid), function (network) {
            enterpriseConnect.secret = passphrase;
            enterpriseConnect.command = ["bash", "-c", Model.enterpriseConnectScript, "nmcli-eap", ssid, identity];
            enterpriseConnect.running = true;
        });
    }

    // stats for the active connection (wifi or ethernet); polled only while the panel is open
    property var linkStats: Model.connectionStats({})
    property var throughput: ({})

    Process {
        id: statsProc
        command: ["bash", "-c", Model.connectionStatsScript, "stats", wifiPanelRoot.kind]
        stdout: StdioCollector {
            onStreamFinished: {
                const kv = Model.parseKeyValue(text);
                wifiPanelRoot.linkStats = Model.connectionStats(kv);
                wifiPanelRoot.throughput = Model.throughputState(wifiPanelRoot.throughput, kv, Date.now() / 1000);
            }
        }
    }

    Timer {
        interval: 2000
        repeat: true
        triggeredOnStart: true
        running: wifiPanelRoot.visible && wifiPanelRoot.kind !== "disconnected"
        onTriggered: statsProc.running = true
        // a stale sample would show a huge spike on reopen
        onRunningChanged: if (!running)
            wifiPanelRoot.throughput = {}
    }

    // last speed test result: ping (ms), down / up (bytes/s), at (Date) or error; kept until the next run
    property var speedTest: ({})

    Process {
        id: speedTestProc
        command: ["bash", "-c", Model.speedTestScript]
        stdout: SplitParser {
            onRead: line => {
                const kv = Model.parseKeyValue(line);
                wifiPanelRoot.speedTest = Object.assign({}, wifiPanelRoot.speedTest, kv);
            }
        }
        onExited: exitCode => {
            if (exitCode === 0)
                wifiPanelRoot.speedTest = Object.assign({}, wifiPanelRoot.speedTest, {
                    at: new Date()
                });
            else if (!wifiPanelRoot.speedTest.error)
                wifiPanelRoot.speedTest = Object.assign({}, wifiPanelRoot.speedTest, {
                    error: "failed"
                });
        }
    }

    Process {
        id: enterpriseConnect
        property string secret: ""
        stdinEnabled: true
        onStarted: {
            write(secret + "\n");
            secret = "";
        }
    }

    function disconnectRow(ssid) {
        var network = networkForSsid(ssid);
        if (network)
            runNetworkAction("disconnect", network, function (net) {
                net.disconnect();
            });
    }

    function forget(net) {
        var network = net ? networkForSsid(net.ssid) : null;
        if (network)
            runNetworkAction("forget", network, function (n) {
                n.forget();
            });
    }

    Timer {
        id: scanRestart
        interval: 100
        repeat: false
        onTriggered: {
            if (wifiPanelRoot.wifiDevice) {
                wifiPanelRoot.setScannerEnabled(true);
                scanDone.start();
            }
        }
    }

    Timer {
        id: scanDone
        interval: 1500
        repeat: false
        onTriggered: wifiPanelRoot.syncWifiNetworks()
    }

    Timer {
        id: actionTimeout
        interval: 30000
        repeat: false
        onTriggered: {
            if (!wifiPanelRoot.actionKind)
                return;
            wifiPanelRoot.failureSsid = wifiPanelRoot.actionSsid;
            wifiPanelRoot.failureReason = "Timing out";
            wifiPanelRoot.actionSsid = "";
            wifiPanelRoot.actionKind = "";
            wifiPanelRoot.refresh();
        }
    }

    // UI Layout
    TuiPane {
        title: "network"

        TuiLine {
            text: (Networking.wifiEnabled ? "[x]" : "[ ]") + " wi-fi"
            detail: Networking.wifiEnabled ? "on" : "off"
            detailColor: Networking.wifiEnabled ? Tui.on : Tui.dim
            hint: "toggle"
            onClicked: wifiPanelRoot.toggleNetwork()
        }
    }

    TuiPane {
        title: "connection"

        TuiLine {
            visible: wifiPanelRoot.kind === "disconnected"
            numbered: false
            selectable: false
            text: "disconnected"
            textColor: Tui.dim
        }

        ColumnLayout {
            visible: wifiPanelRoot.kind !== "disconnected"
            Layout.fillWidth: true
            spacing: 0

            TuiLine {
                numbered: false
                selectable: wifiPanelRoot.kind === "wifi"
                text: wifiPanelRoot.kind === "ethernet" ? "Ethernet" : (wifiPanelRoot.connectedWifiNetwork ? wifiPanelRoot.connectedWifiNetwork.name : "Wi-Fi")
                current: true
                detail: "connected"
                detailColor: Tui.on

                TuiAction {
                    text: "disconnect"
                    onClicked: {
                        if (wifiPanelRoot.connectedWifiNetwork)
                            wifiPanelRoot.disconnectRow(wifiPanelRoot.connectedWifiNetwork.name);
                    }
                }
            }
            // wifi strength, also while ethernet is active (then it's the standby network's)
            TuiLine {
                visible: wifiPanelRoot.signalStrength >= 0
                numbered: false
                selectable: false
                text: wifiPanelRoot.kind === "wifi" ? "signal" : "wi-fi signal"
                textColor: Tui.dim
                detail: wifiPanelRoot.signalStrength + "%"
                detailColor: Tui.text
                trailing: TuiBars {
                    pct: wifiPanelRoot.signalStrength
                }
            }
            TuiLine {
                numbered: false
                selectable: false
                text: "link speed"
                textColor: Tui.dim
                detail: wifiPanelRoot.linkStats.link || "—"
                detailColor: Tui.text
            }
            TuiLine {
                numbered: false
                selectable: false
                text: "traffic"
                textColor: Tui.dim
                detail: wifiPanelRoot.throughput.prevSampleTime ? "↓ " + Model.formatBits(wifiPanelRoot.throughput.downloadRate) + "  ↑ " + Model.formatBits(wifiPanelRoot.throughput.uploadRate) : "—"
                detailColor: Tui.text
            }
            TuiLine {
                numbered: false
                selectable: false
                text: "ip address"
                textColor: Tui.dim
                detail: wifiPanelRoot.linkStats.ip || "—"
                detailColor: Tui.text
            }
            // Speed test (on demand)
            TuiLine {
                numbered: false
                selectable: false
                text: "speed test"
                textColor: Tui.dim
                trailing: TuiAction {
                    enabled: !speedTestProc.running
                    text: speedTestProc.running ? "testing…" : (wifiPanelRoot.speedTest.at ? "run again" : "run")
                    color: speedTestProc.running ? Tui.dim : Tui.text
                    onClicked: {
                        wifiPanelRoot.speedTest = {};
                        speedTestProc.running = true;
                    }
                }
            }
            TuiLine {
                readonly property string progress: {
                    const t = wifiPanelRoot.speedTest;
                    if (speedTestProc.running)
                        return !t.ping ? "measuring ping…" : !t.down ? "measuring download…" : "measuring upload…";
                    return t.error ? "couldn't reach Cloudflare" : "";
                }
                visible: text !== ""
                numbered: false
                selectable: false
                text: Model.speedTestSummary(wifiPanelRoot.speedTest) || progress
                textColor: wifiPanelRoot.speedTest.error ? Tui.danger : Tui.text
            }
        }
    }

    // // --- SECTION 2: DNS PROVIDER ---
    // ColumnLayout {
    //     Layout.fillWidth: true
    //     spacing: 0

    //     Text {
    //         text: "DNS Provider"
    //         color: wifiPanelRoot.dimColor
    //         font.family: wifiPanelRoot.fontFamily
    //         font.pixelSize: 13
    //         font.capitalization: Font.AllUppercase
    //         Layout.fillWidth: true
    //         Layout.topMargin: 6
    //         Layout.bottomMargin: 12
    //     }

    //     RowLayout {
    //         Layout.fillWidth: true
    //         Layout.bottomMargin: 12
    //         spacing: 12

    //         Repeater {
    //             model: ["DHCP", "Cloudflare", "Google", "Custom"]

    //             delegate: Text {
    //                 required property string modelData
    //                 text: modelData
    //                 color: dnsMa.containsMouse ? wifiPanelRoot.fgColor : (wifiPanelRoot.dnsProvider === modelData ? wifiPanelRoot.accentColor : wifiPanelRoot.dimColor)
    //                 font.family: wifiPanelRoot.fontFamily
    //                 font.pixelSize: 13
    //                 font.bold: wifiPanelRoot.dnsProvider === modelData

    //                 MouseArea {
    //                     id: dnsMa
    //                     anchors.fill: parent
    //                     cursorShape: Qt.PointingHandCursor
    //                     hoverEnabled: true
    //                     onClicked: wifiPanelRoot.dnsProvider = parent.modelData
    //                 }
    //             }
    //         }

    //         Item {
    //             Layout.fillWidth: true
    //         }
    //     }

    //     // Trace line
    //     Rectangle {
    //         Layout.fillWidth: true
    //         height: 1
    //         color: wifiPanelRoot.lineColor
    //     }
    // }

    TuiPane {
        title: wifiPanelRoot.scanning ? "scanning…" : "wi-fi networks"

        Repeater {
            model: wifiPanelRoot.wifiStationAvailable ? wifiPanelRoot.wifiNetworks : []

            delegate: ColumnLayout {
                id: net
                required property var modelData
                required property int index

                readonly property bool isConnected: modelData && modelData.connected
                readonly property bool isKnown: modelData && modelData.known
                readonly property bool requiresCredentials: modelData ? wifiPanelRoot.requiresCredentials(modelData.security) : false
                readonly property bool isEnterprise: modelData ? wifiPanelRoot.isEnterprise(modelData.security) : false
                readonly property bool isPasswordOpen: wifiPanelRoot.passwordSsid !== "" && wifiPanelRoot.passwordSsid === (modelData ? modelData.ssid : "")
                readonly property bool acting: wifiPanelRoot.actionSsid === modelData.ssid

                function join() {
                    if (requiresCredentials && !isKnown)
                        wifiPanelRoot.openPasswordPrompt(modelData.ssid);
                    else
                        wifiPanelRoot.connectDirectly(modelData.ssid);
                }

                Layout.fillWidth: true
                spacing: 0

                // tussen bekende en overige netwerken
                Rectangle {
                    visible: net.index > 0 && Model.wifiSectionTitle(wifiPanelRoot.wifiNetworks, net.index) !== ""
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 6
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4
                    implicitHeight: 1
                    color: "#1affffff"
                }

                TuiLine {
                    id: netLine
                    number: String(net.index + 1)
                    text: net.modelData.ssid || "hidden network"
                    textColor: net.modelData.ssid ? Tui.text : Tui.dim
                    current: net.isConnected
                    hint: net.isConnected || net.acting ? "" : "connect"
                    detail: net.acting ? ({
                                connect: "connecting…",
                                disconnect: "disconnecting…",
                                forget: "forgetting…"
                            })[wifiPanelRoot.actionKind] || "" : ""
                    onClicked: {
                        if (!net.isConnected && !net.acting)
                            net.join();
                    }

                    TuiAction {
                        visible: net.isConnected
                        text: "disconnect"
                        onClicked: wifiPanelRoot.disconnectRow(net.modelData.ssid)
                    }
                    TuiAction {
                        visible: !net.isConnected && !net.acting
                        text: "connect"
                        onClicked: net.join()
                    }
                    TuiAction {
                        visible: net.isKnown && !net.isConnected
                        text: "forget"
                        onClicked: wifiPanelRoot.forget(net.modelData)
                    }

                    trailing: TuiBars {
                        pct: net.modelData.signal
                        selected: netLine.selected
                    }
                }

                TuiPrompt {
                    visible: net.isPasswordOpen && net.isEnterprise
                    label: "identity"
                    placeholder: "user@domain"
                    autoFocus: true
                    text: wifiPanelRoot.identityText
                    onTextChanged: wifiPanelRoot.identityText = text
                }
                TuiPrompt {
                    visible: net.isPasswordOpen
                    label: "password"
                    password: true
                    autoFocus: !net.isEnterprise
                    text: wifiPanelRoot.passwordText
                    onTextChanged: wifiPanelRoot.passwordText = text
                    onAccepted: wifiPanelRoot.submitPassword()
                }
            }
        }

        TuiLine {
            visible: !wifiPanelRoot.wifiStationAvailable || wifiPanelRoot.wifiNetworks.length === 0
            numbered: false
            selectable: false
            text: "no networks found"
            textColor: Tui.dim
        }
    }
}
