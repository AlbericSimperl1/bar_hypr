// Config.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string _dir: Quickshell.env("HOME") + "/.config/quickshell"
    readonly property string _file: _dir + "/bar-config.json"

    // ── Bar layout (defaults mimic the old /bar/horizontaal bar) ──
    property string barPosition: "top"   // top | bottom | left | right
    property int barHeight: 24           // thickness
    property int barMargin: 0            // distance from screen edge
    property int barRadius: 0
    property int barInset: 18            // content padding along the bar
    property int barGap: 8               // gap between bar and panel
    property int barSideMargin: 0        // inset from the two ends of the bar
    property int borderWidth: 0

    // ── Look & feel ──
    property int widgetSpacing: 14
    property int fontScalePct: 100
    property int iconScalePct: 100
    readonly property real fontScale: fontScalePct / 100
    readonly property real iconScale: iconScalePct / 100
    property bool islandsEnabled: false
    property int islandPadding: 10       // along the bar
    property int islandInset: 3          // gap to bar edges, across the bar
    property int islandRadius: 6
    property color islandColor: "#22ffffff"

    // ── Colors ──
    property color barBg: "#20000207"
    property color fgColor: "#fff7e5"
    property color accentColor: "#ebd9b9"
    property color borderColor: "#2cffffff"
    property color panelBg: "#60000207"
    property string fontFamily: "mononoki"
    readonly property string iconFont: fontFamily   // old bar rendered icons with the main font + fallback

    // ── Panels ──
    property int panelWidth: 480
    property int panelMaxHeight: 650
    property int panelMinHeight: 140
    property int panelRadius: 3
    property bool panelsAutoSize: true
    readonly property int panelWidthMax: 800

    // ── Widget zones ──
    readonly property var allWidgets: ["ws", "clock", "media", "bluetooth", "wifi", "notifications", "brightness", "volume", "cpu", "ram", "battery", "power", "settings"]
    property var leftWidgets: ["clock"]
    property var centerWidgets: ["ws"]
    property var rightWidgets: ["media", "bluetooth", "wifi", "notifications", "brightness", "power", "settings", "volume", "cpu", "ram", "battery"]
    property var widgetDisabled: ({
            "volume": true,
            "cpu": true,
            "ram": true,
            "battery": true
        })

    // ── Widget formatting ──
    property string clockFormat: "HH.mm"
    property string dateFormat: "ddd d MMM"
    property string dateLocale: "nl_NL"
    property bool showDate: true
    property int workspaceCount: 9
    property bool workspaceShowNumbers: false
    property string volumeIconMode: "icon"   // icon | percent | both
    property int mediaTitleMax: 25

    property var panelSizes: ({
            "media": {
                "width": 520,
                "height": 650
            },
            "bluetooth": {
                "width": 480,
                "height": 650
            },
            "wifi": {
                "width": 480,
                "height": 420
            },
            "notifications": {
                "width": 480,
                "height": 650
            },
            "power": {
                "width": 480,
                "height": 220
            },
            "brightness": {
                "width": 480,
                "height": 210
            },
            "settings": {
                "width": 580,
                "height": 620
            }
        })

    // ── Persistence ──
    FileView {
        id: store
        path: root._file
        printErrors: false
        onLoaded: root._load(store.text())
    }

    Timer {
        id: saveTimer
        interval: 400
        onTriggered: root._save()
    }

    readonly property var _plainKeys: ["barPosition", "barHeight", "barMargin", "barRadius", "barInset", "barGap", "barSideMargin", "borderWidth", "widgetSpacing", "fontScalePct", "iconScalePct", "islandsEnabled", "islandPadding", "islandInset", "islandRadius", "fontFamily", "panelWidth", "panelMaxHeight", "panelMinHeight", "panelRadius", "panelsAutoSize", "clockFormat", "dateFormat", "dateLocale", "showDate", "workspaceCount", "workspaceShowNumbers", "volumeIconMode", "mediaTitleMax"]
    readonly property var _colorKeys: ["barBg", "fgColor", "accentColor", "borderColor", "panelBg", "islandColor"]

    function _save() {
        const data = {};
        _plainKeys.forEach(k => data[k] = root[k]);
        _colorKeys.forEach(k => data[k] = String(root[k]));
        data.leftWidgets = leftWidgets;
        data.centerWidgets = centerWidgets;
        data.rightWidgets = rightWidgets;
        data.widgetDisabled = widgetDisabled;
        data.panelSizes = panelSizes;
        store.setText(JSON.stringify(data, null, 2));
    }

    function _load(text) {
        let data;
        try {
            data = JSON.parse(text);
        } catch (e) {
            return;
        }
        if (!data || typeof data !== "object")
            return;
        _plainKeys.forEach(k => {
            if (data[k] !== undefined && data[k] !== null)
                root[k] = data[k];
        });
        _colorKeys.forEach(k => {
            if (data[k])
                root[k] = data[k];
        });
        if (Array.isArray(data.leftWidgets))
            leftWidgets = data.leftWidgets;
        if (Array.isArray(data.centerWidgets))
            centerWidgets = data.centerWidgets;
        if (Array.isArray(data.rightWidgets))
            rightWidgets = data.rightWidgets;
        if (data.widgetDisabled)
            widgetDisabled = data.widgetDisabled;
        if (data.panelSizes)
            panelSizes = data.panelSizes;
        _ensureAllPlaced();
    }

    readonly property var _defaultOff: ["volume", "cpu", "ram", "battery"]

    function _ensureAllPlaced() {
        // drop widgets that no longer exist (e.g. old "cpuram")
        const ok = w => allWidgets.indexOf(w) >= 0;
        leftWidgets = leftWidgets.filter(ok);
        centerWidgets = centerWidgets.filter(ok);
        rightWidgets = rightWidgets.filter(ok);

        const placed = new Set([...leftWidgets, ...centerWidgets, ...rightWidgets]);
        const missing = allWidgets.filter(w => !placed.has(w));
        if (missing.length > 0) {
            const d = Object.assign({}, widgetDisabled);
            missing.forEach(w => {
                if (_defaultOff.indexOf(w) >= 0 && d[w] === undefined)
                    d[w] = true;
            });
            widgetDisabled = d;
            rightWidgets = rightWidgets.concat(missing);
        }
    }

    // ── Helpers ──
    function save() {
        saveTimer.restart();
    }
    function isEnabled(name) {
        return !widgetDisabled[name];
    }
    function toggleWidget(name) {
        const d = Object.assign({}, widgetDisabled);
        d[name] = !d[name];
        widgetDisabled = d;
        save();
    }
    function widgetsForZone(zone) {
        const list = zone === "left" ? leftWidgets : zone === "center" ? centerWidgets : rightWidgets;
        return list.filter(w => isEnabled(w));
    }
    function moveInZone(name, delta, zone) {
        const key = zone + "Widgets";
        const list = root[key].slice();
        const idx = list.indexOf(name);
        if (idx < 0)
            return;
        const to = Math.max(0, Math.min(list.length - 1, idx + delta));
        if (to === idx)
            return;
        list.splice(idx, 1);
        list.splice(to, 0, name);
        root[key] = list;
        save();
    }
    function zoneOf(name) {
        if (leftWidgets.indexOf(name) >= 0)
            return "left";
        if (centerWidgets.indexOf(name) >= 0)
            return "center";
        return "right";
    }
    function moveToZone(name, toZone) {
        const from = zoneOf(name);
        if (from === toZone)
            return;
        root[from + "Widgets"] = root[from + "Widgets"].filter(w => w !== name);
        if (root[toZone + "Widgets"].indexOf(name) < 0)
            root[toZone + "Widgets"] = root[toZone + "Widgets"].concat([name]);
        save();
    }
    function panelWidthFor(name) {
        const p = panelSizes[name];
        return p && p.width ? p.width : panelWidth;
    }
    function panelHeightFor(name, fallback) {
        const p = panelSizes[name];
        const h = (p && p.height) ? p.height : (fallback || panelMaxHeight);
        return Math.min(h, panelMaxHeight);
    }

    onBarPositionChanged: saveTimer.restart()
    onBarHeightChanged: saveTimer.restart()
    onBarMarginChanged: saveTimer.restart()
    onBarRadiusChanged: saveTimer.restart()
    onBarInsetChanged: saveTimer.restart()
    onBarGapChanged: saveTimer.restart()
    onBarSideMarginChanged: saveTimer.restart()
    onBorderWidthChanged: saveTimer.restart()
    onWidgetSpacingChanged: saveTimer.restart()
    onFontScalePctChanged: saveTimer.restart()
    onIconScalePctChanged: saveTimer.restart()
    onIslandsEnabledChanged: saveTimer.restart()
    onIslandPaddingChanged: saveTimer.restart()
    onIslandInsetChanged: saveTimer.restart()
    onIslandRadiusChanged: saveTimer.restart()
    onIslandColorChanged: saveTimer.restart()
    onBarBgChanged: saveTimer.restart()
    onFgColorChanged: saveTimer.restart()
    onAccentColorChanged: saveTimer.restart()
    onBorderColorChanged: saveTimer.restart()
    onPanelBgChanged: saveTimer.restart()
    onFontFamilyChanged: saveTimer.restart()
    onPanelRadiusChanged: saveTimer.restart()
    onClockFormatChanged: saveTimer.restart()
    onDateFormatChanged: saveTimer.restart()
    onDateLocaleChanged: saveTimer.restart()
    onShowDateChanged: saveTimer.restart()
    onWorkspaceCountChanged: saveTimer.restart()
    onWorkspaceShowNumbersChanged: saveTimer.restart()
    onVolumeIconModeChanged: saveTimer.restart()
    onMediaTitleMaxChanged: saveTimer.restart()

    Component.onCompleted: {
        Quickshell.execDetached(["mkdir", "-p", root._dir]);
        _ensureAllPlaced();
    }
}
