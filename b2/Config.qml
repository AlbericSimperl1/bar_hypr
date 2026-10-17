// Config.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string _dir: Quickshell.env("HOME") + "/.config/quickshell"
    readonly property string _file: _dir + "/bar-config.json"

    // ── Bar layout ─────────────────────────────────────────
    property string barPosition: "top"          // top | bottom | left | right
    property int barHeight: 28            // thickness (height for top/bottom, width for left/right)
    property int barMargin: 6
    property int barRadius: 0
    property int barInset: 18            // left/right content padding (or top/bottom for vertical)
    property int barGap: 8             // gap between bar and panel

    // ── Colors ─────────────────────────────────────────────
    property color barBg: "#20000207"
    property color fgColor: "#fff7e5"
    property color accentColor: "#ebd9b9"
    property color borderColor: "#2cffffff"
    property color panelBg: "#60000207"
    property string fontFamily: "mononoki"

    // ── Panels ─────────────────────────────────────────────
    property int panelWidth: 480
    property int panelMaxHeight: 650
    property int panelMinHeight: 140
    property int panelRadius: 3

    // ── Widget zones (ordered lists per zone) ──────────────
    readonly property var allWidgets: ["ws", "clock", "media", "bluetooth", "wifi", "notifications", "brightness", "volume", "cpuram", "battery", "power", "settings"]
    property var leftWidgets: ["ws", "clock"]
    property var centerWidgets: []
    property var rightWidgets: ["media", "bluetooth", "wifi", "notifications", "brightness", "volume", "cpuram", "battery", "power", "settings"]
    property var widgetDisabled: ({})

    // ── Widget formatting ──────────────────────────────────
    property string clockFormat: "HH.mm"
    property string dateFormat: "ddd d MMM"
    property string dateLocale: "nl_NL"
    property bool showDate: true
    property int workspaceCount: 9
    property bool workspaceShowNumbers: false
    property string volumeIconMode: "mixed"     // "icon" | "percent" | "both"
    property int mediaTitleMax: 25

    // ── Per-panel sizes (width/height override) ────────────
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

    // ── Persistence ────────────────────────────────────────
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

    function _save() {
        const data = {
            barPosition: root.barPosition,
            barHeight: root.barHeight,
            barMargin: root.barMargin,
            barRadius: root.barRadius,
            barInset: root.barInset,
            barGap: root.barGap,
            barBg: String(root.barBg),
            fgColor: String(root.fgColor),
            accentColor: String(root.accentColor),
            borderColor: String(root.borderColor),
            panelBg: String(root.panelBg),
            fontFamily: root.fontFamily,
            panelWidth: root.panelWidth,
            panelMaxHeight: root.panelMaxHeight,
            panelMinHeight: root.panelMinHeight,
            panelRadius: root.panelRadius,
            leftWidgets: root.leftWidgets,
            centerWidgets: root.centerWidgets,
            rightWidgets: root.rightWidgets,
            widgetDisabled: root.widgetDisabled,
            clockFormat: root.clockFormat,
            dateFormat: root.dateFormat,
            dateLocale: root.dateLocale,
            showDate: root.showDate,
            workspaceCount: root.workspaceCount,
            workspaceShowNumbers: root.workspaceShowNumbers,
            volumeIconMode: root.volumeIconMode,
            mediaTitleMax: root.mediaTitleMax,
            panelSizes: root.panelSizes
        };
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
        const set = (k, v) => {
            if (v !== undefined && v !== null)
                root[k] = v;
        };
        ["barPosition", "barHeight", "barMargin", "barRadius", "barInset", "barGap", "fontFamily", "panelWidth", "panelMaxHeight", "panelMinHeight", "panelRadius", "clockFormat", "dateFormat", "dateLocale", "showDate", "workspaceCount", "workspaceShowNumbers", "volumeIconMode", "mediaTitleMax"].forEach(k => set(k, data[k]));
        ["barBg", "fgColor", "accentColor", "borderColor", "panelBg"].forEach(k => {
            if (data[k])
                set(k, data[k]);
        });
        if (Array.isArray(data.leftWidgets))
            set("leftWidgets", data.leftWidgets);
        if (Array.isArray(data.centerWidgets))
            set("centerWidgets", data.centerWidgets);
        if (Array.isArray(data.rightWidgets))
            set("rightWidgets", data.rightWidgets);
        if (data.widgetDisabled)
            set("widgetDisabled", data.widgetDisabled);
        if (data.panelSizes)
            set("panelSizes", data.panelSizes);
        _ensureAllPlaced();
    }

    function _ensureAllPlaced() {
        const placed = new Set([...leftWidgets, ...centerWidgets, ...rightWidgets]);
        const missing = allWidgets.filter(w => !placed.has(w));
        if (missing.length > 0)
            rightWidgets = rightWidgets.concat(missing);
    }

    // ── Widget manipulation helpers ────────────────────────
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
        if (rightWidgets.indexOf(name) >= 0)
            return "right";
        return "right";
    }
    function moveToZone(name, toZone) {
        const from = zoneOf(name);
        if (from === toZone)
            return;
        const fromKey = from + "Widgets", toKey = toZone + "Widgets";
        root[fromKey] = root[fromKey].filter(w => w !== name);
        if (root[toKey].indexOf(name) < 0)
            root[toKey] = root[toKey].concat([name]);
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

    // autosave
    onBarPositionChanged: saveTimer.restart()
    onBarHeightChanged: saveTimer.restart()
    onBarMarginChanged: saveTimer.restart()
    onBarRadiusChanged: saveTimer.restart()
    onBarInsetChanged: saveTimer.restart()
    onBarGapChanged: saveTimer.restart()
    onBarBgChanged: saveTimer.restart()
    onFgColorChanged: saveTimer.restart()
    onAccentColorChanged: saveTimer.restart()
    onBorderColorChanged: saveTimer.restart()
    onPanelBgChanged: saveTimer.restart()
    onFontFamilyChanged: saveTimer.restart()
    onPanelWidthChanged: saveTimer.restart()
    onPanelMaxHeightChanged: saveTimer.restart()
    onPanelMinHeightChanged: saveTimer.restart()
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
