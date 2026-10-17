// SettingsPanel.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    property color fgColor:     Config.fgColor
    property color accentColor: Config.accentColor
    property color dimColor:    Qt.rgba(fgColor.r, fgColor.g, fgColor.b, 0.6)
    property color lineColor:   "#20ffffff"
    property color cardColor:   "#12ffffff"
    property color dangerColor: "#ff5555"
    property string fontFamily: Config.fontFamily

    property string tab: "bar"
    readonly property var tabs: [
        { key: "bar",     label: "Bar" },
        { key: "colors",  label: "Colors" },
        { key: "widgets", label: "Widgets" },
        { key: "panels",  label: "Panels" },
        { key: "format",  label: "Format" }
    ]

    // ── Reusable builders ────────────────────────────────
    Component {
        id: sectionHeader
        Text {
            property string text: ""
            color: root.dimColor
            font.family: root.fontFamily
            font.pixelSize: 12
            font.capitalization: Font.AllUppercase
            Layout.fillWidth: true
            Layout.topMargin: 8
            Layout.bottomMargin: 4
        }
    }

    ColumnLayout {
        id: layoutRoot
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // Header
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Settings"
                color: root.fgColor
                font.family: root.fontFamily
                font.pixelSize: 20
                font.bold: true
                Layout.fillWidth: true
            }
            Text {
                text: "󰒓"
                color: root.accentColor
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 22
            }
        }

        // Tabs
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 34
            color: "transparent"
            border.color: root.lineColor
            border.width: 1
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.margins: 2
                spacing: 0

                Repeater {
                    model: root.tabs
                    delegate: Item {
                        required property var modelData
                        readonly property bool sel: root.tab === modelData.key
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Rectangle {
                            anchors.fill: parent
                            radius: 3
                            color: parent.sel ? root.accentColor : (tabMa.containsMouse ? "#14ffffff" : "transparent")
                        }
                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            color: parent.sel ? "#14130e" : root.fgColor
                            font.family: root.fontFamily
                            font.pixelSize: 13
                            font.bold: parent.sel
                        }
                        MouseArea {
                            id: tabMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.tab = modelData.key
                        }
                    }
                }
            }
        }

        // Tab content
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentHeight: contentColumn.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: contentColumn
                width: parent.width
                spacing: 6

                // ── BAR TAB ─────────────────────────────
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    visible: root.tab === "bar"

                    Text {
                        text: "Position"
                        color: root.dimColor
                        font.family: root.fontFamily
                        font.pixelSize: 12
                        font.capitalization: Font.AllUppercase
                    }
                    RowLayout {
                        spacing: 6
                        Repeater {
                            model: ["top", "bottom", "left", "right"]
                            delegate: Rectangle {
                                required property string modelData
                                readonly property bool sel: Config.barPosition === modelData
                                implicitWidth: 68
                                implicitHeight: 30
                                radius: 3
                                color: sel ? root.accentColor : (posMa.containsMouse ? "#14ffffff" : "transparent")
                                border.color: root.lineColor
                                border.width: 1
                                Text {
                                    anchors.centerIn: parent
                                    text: parent.modelData
                                    color: parent.sel ? "#14130e" : root.fgColor
                                    font.family: root.fontFamily
                                    font.pixelSize: 13
                                    font.capitalization: Font.Capitalize
                                }
                                MouseArea {
                                    id: posMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Config.barPosition = parent.modelData
                                }
                            }
                        }
                    }

                    Slider { label: "Bar height";    from: 20; to: 60;  suffix: "px"; value: Config.barHeight;     onMoved: v => Config.barHeight = Math.round(v) }
                    Slider { label: "Bar margin";    from: 0;  to: 24;  suffix: "px"; value: Config.barMargin;     onMoved: v => Config.barMargin = Math.round(v) }
                    Slider { label: "Bar inset";     from: 0;  to: 48;  suffix: "px"; value: Config.barInset;      onMoved: v => Config.barInset = Math.round(v) }
                    Slider { label: "Bar rounding";  from: 0;  to: 24;  suffix: "px"; value: Config.barRadius;     onMoved: v => Config.barRadius = Math.round(v) }
                    Slider { label: "Panel gap";     from: 0;  to: 24;  suffix: "px"; value: Config.barGap;        onMoved: v => Config.barGap = Math.round(v) }
                    Slider { label: "Panel rounding";from: 0;  to: 20;  suffix: "px"; value: Config.panelRadius;   onMoved: v => Config.panelRadius = Math.round(v) }
                }

                // ── COLORS TAB ──────────────────────────
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    visible: root.tab === "colors"

                    ColorField { label: "Bar background";  value: Config.barBg;       onChanged: c => Config.barBg = c }
                    ColorField { label: "Foreground";      value: Config.fgColor;      onChanged: c => Config.fgColor = c }
                    ColorField { label: "Accent";          value: Config.accentColor;  onChanged: c => Config.accentColor = c }
                    ColorField { label: "Border";          value: Config.borderColor;  onChanged: c => Config.borderColor = c }
                    ColorField { label: "Panel background";value: Config.panelBg;      onChanged: c => Config.panelBg = c }

                    TextField {
                        Layout.fillWidth: true
                        text: Config.fontFamily
                        color: root.fgColor
                        font.family: root.fontFamily
                        font.pixelSize: 13
                        placeholderText: "Font family"
                        background: Rectangle {
                            color: "transparent"
                            border.color: root.lineColor
                            border.width: 1
                            radius: 3
                        }
                        onTextChanged: Config.fontFamily = text
                    }
                }

                // ── WIDGETS TAB ─────────────────────────
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    visible: root.tab === "widgets"

                    Repeater {
                        model: ["left", "center", "right"]
                        delegate: ColumnLayout {
                            required property string modelData
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: parent.modelData + " zone"
                                color: root.dimColor
                                font.family: root.fontFamily
                                font.pixelSize: 12
                                font.capitalization: Font.AllUppercase
                                Layout.topMargin: 6
                            }

                            Repeater {
                                model: (function() {
                                    const arr = parent.parent.modelData === "left" ? Config.leftWidgets
                                              : parent.parent.modelData === "center" ? Config.centerWidgets
                                              : Config.rightWidgets;
                                    return arr;
                                })()
                                delegate: WidgetRow {
                                    required property string modelData
                                    widgetName: modelData
                                    zone: parent.parent.parent.modelData
                                }
                            }
                        }
                    }
                }

                // ── PANELS TAB ──────────────────────────
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    visible: root.tab === "panels"

                    Repeater {
                        model: ["media", "bluetooth", "wifi", "notifications", "power", "brightness", "settings"]
                        delegate: ColumnLayout {
                            required property string modelData
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: parent.modelData
                                color: root.fgColor
                                font.family: root.fontFamily
                                font.pixelSize: 13
                                font.bold: true
                                font.capitalization: Font.Capitalize
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Slider {
                                    Layout.fillWidth: true
                                    label: "Width"
                                    from: 320; to: 800; suffix: "px"
                                    value: (Config.panelSizes[parent.parent.modelData] || { width: 480 }).width
                                    onMoved: v => {
                                        const next = Object.assign({}, Config.panelSizes);
                                        next[parent.parent.modelData] = Object.assign(
                                            {}, next[parent.parent.modelData] || {},
                                            { width: Math.round(v) });
                                        Config.panelSizes = next;
                                        Config.save();
                                    }
                                }
                                Slider {
                                    Layout.fillWidth: true
                                    label: "Height"
                                    from: 140; to: 800; suffix: "px"
                                    value: (Config.panelSizes[parent.parent.modelData] || { height: 650 }).height
                                    onMoved: v => {
                                        const next = Object.assign({}, Config.panelSizes);
                                        next[parent.parent.modelData] = Object.assign(
                                            {}, next[parent.parent.modelData] || {},
                                            { height: Math.round(v) });
                                        Config.panelSizes = next;
                                        Config.save();
                                    }
                                }
                            }
                        }
                    }
                }

                // ── FORMAT TAB ──────────────────────────
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    visible: root.tab === "format"

                    FormatField { label: "Clock format";   value: Config.clockFormat;  onChanged: v => Config.clockFormat = v }
                    FormatField { label: "Date format";    value: Config.dateFormat;   onChanged: v => Config.dateFormat = v }
                    FormatField { label: "Date locale";    value: Config.dateLocale;   onChanged: v => Config.dateLocale = v }
                    Toggle { label: "Show date";           value: Config.showDate;     onToggled: v => Config.showDate = v }

                    Slider { label: "Workspace count"; from: 1; to: 20; suffix: ""; value: Config.workspaceCount; onMoved: v => Config.workspaceCount = Math.round(v) }
                    Toggle { label: "Workspace numbers"; value: Config.workspaceShowNumbers; onToggled: v => Config.workspaceShowNumbers = v }

                    RowLayout {
                        spacing: 6
                        Text {
                            text: "Volume display"
                            color: root.dimColor
                            font.family: root.fontFamily
                            font.pixelSize: 12
                            Layout.preferredWidth: 140
                        }
                        Repeater {
                            model: ["icon", "percent", "both"]
                            delegate: Rectangle {
                                required property string modelData
                                readonly property bool sel: Config.volumeIconMode === modelData
                                implicitWidth: 76
                                implicitHeight: 28
                                radius: 3
                                color: sel ? root.accentColor : "transparent"
                                border.color: root.lineColor
                                border.width: 1
                                Text {
                                    anchors.centerIn: parent
                                    text: parent.modelData
                                    color: parent.sel ? "#14130e" : root.fgColor
                                    font.family: root.fontFamily
                                    font.pixelSize: 12
                                    font.capitalization: Font.Capitalize
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Config.volumeIconMode = parent.modelData
                                }
                            }
                        }
                    }

                    Slider { label: "Media title chars"; from: 10; to: 60; suffix: ""; value: Config.mediaTitleMax; onMoved: v => Config.mediaTitleMax = Math.round(v) }
                }
            }
        }
    }

    // ── Reusable child components ────────────────────────

    component ColorField: RowLayout {
        id: cf
        property string label
        property color  value
        signal changed(color c)
        Layout.fillWidth: true
        spacing: 8
        Text {
            text: cf.label
            color: root.dimColor
            font.family: root.fontFamily
            font.pixelSize: 12
            Layout.preferredWidth: 140
        }
        Rectangle {
            width: 24; height: 24
            radius: 3
            color: cf.value
            border.color: root.lineColor
            border.width: 1
        }
        TextField {
            Layout.fillWidth: true
            text: String(cf.value)
            color: root.fgColor
            font.family: root.fontFamily
            font.pixelSize: 12
            background: Rectangle {
                color: "transparent"
                border.color: root.lineColor
                border.width: 1
                radius: 3
            }
            onEditingFinished: {
                if (/^#[0-9a-fA-F]{6,8}$/.test(text))
                    cf.changed(text);
            }
        }
    }

    component Slider: RowLayout {
        id: s
        property string label
        property real   from: 0
        property real   to: 100
        property real   value: 50
        property string suffix: ""
        signal moved(real v)
        Layout.fillWidth: true
        spacing: 8

        Text {
            text: s.label
            color: root.dimColor
            font.family: root.fontFamily
            font.pixelSize: 12
            Layout.preferredWidth: 140
        }
        Rectangle {
            Layout.fillWidth: true
            height: 10
            color: "#15ffffff"
            border.color: root.lineColor
            border.width: 1
            radius: 2
            Rectangle {
                width: parent.width * ((s.value - s.from) / (s.to - s.from))
                height: parent.height
                color: root.accentColor
                radius: 2
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                function apply(mx) {
                    const p = Math.max(0, Math.min(1, mx / width));
                    s.moved(s.from + (s.to - s.from) * p);
                }
                onPressed: m => apply(m.x)
                onPositionChanged: m => { if (pressed) apply(m.x); }
            }
        }
        Text {
            text: Math.round(s.value) + s.suffix
            color: root.fgColor
            font.family: root.fontFamily
            font.pixelSize: 12
            Layout.preferredWidth: 48
            horizontalAlignment: Text.AlignRight
        }
    }

    component FormatField: RowLayout {
        id: ff
        property string label
        property string value
        signal changed(string v)
        Layout.fillWidth: true
        spacing: 8
        Text {
            text: ff.label
            color: root.dimColor
            font.family: root.fontFamily
            font.pixelSize: 12
            Layout.preferredWidth: 140
        }
        TextField {
            Layout.fillWidth: true
            text: ff.value
            color: root.fgColor
            font.family: root.fontFamily
            font.pixelSize: 12
            background: Rectangle {
                color: "transparent"
                border.color: root.lineColor
                border.width: 1
                radius: 3
            }
            onEditingFinished: ff.changed(text)
        }
    }

    component Toggle: RowLayout {
        id: t
        property string label
        property bool   value
        signal toggled(bool v)
        Layout.fillWidth: true
        spacing: 8
        Text {
            text: t.label
            color: root.dimColor
            font.family: root.fontFamily
            font.pixelSize: 12
            Layout.preferredWidth: 140
        }
        Rectangle {
            width: 40; height: 20; radius: 10
            color: t.value ? root.accentColor : "#30ffffff"
            border.color: root.lineColor
            border.width: 1
            Rectangle {
                x: t.value ? 22 : 2
                y: 2
                width: 16; height: 16; radius: 8
                color: t.value ? "#14130e" : "#ffffff"
                Behavior on x { NumberAnimation { duration: 120 } }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: t.toggled(!t.value)
            }
        }
    }

    component WidgetRow: Rectangle {
        id: wr
        property string widgetName
        property string zone

        Layout.fillWidth: true
        implicitHeight: 36
        radius: 3
        color: wrMa.containsMouse ? "#1affffff" : root.cardColor
        border.color: root.lineColor
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 6
            spacing: 6

            Text {
                text: {
                    const map = {
                        "ws": "󰙅", "clock": "󰥔", "media": "󰎈",
                        "bluetooth": "", "wifi": "󰤨", "notifications": "󰂚",
                        "brightness": "󰃠", "volume": "󰕾", "cpuram": "󰍛",
                        "battery": "󰁹", "power": "⏻", "settings": "󰒓"
                    };
                    return map[wr.widgetName] || "•";
                }
                color: Config.isEnabled(wr.widgetName) ? root.fgColor : root.dimColor
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 16
                Layout.preferredWidth: 24
            }

            Text {
                text: wr.widgetName
                color: Config.isEnabled(wr.widgetName) ? root.fgColor : root.dimColor
                font.family: root.fontFamily
                font.pixelSize: 13
                Layout.fillWidth: true
            }

            // Zone switch buttons
            Repeater {
                model: ["left", "center", "right"]
                delegate: Text {
                    required property string modelData
                    readonly property bool active: wr.zone === modelData
                    text: modelData === "left" ? "⇤" : modelData === "center" ? "≡" : "⇥"
                    color: parent.active ? root.accentColor : (zoneMa.containsMouse ? root.fgColor : root.dimColor)
                    font.family: root.fontFamily
                    font.pixelSize: 14
                    MouseArea {
                        id: zoneMa
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: Config.moveToZone(wr.widgetName, modelData)
                    }
                }
            }

            Text {
                text: "↑"
                color: upMa.containsMouse ? root.fgColor : root.dimColor
                font.family: root.fontFamily
                font.pixelSize: 16
                MouseArea {
                    id: upMa
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: Config.moveInZone(wr.widgetName, -1, wr.zone)
                }
            }
            Text {
                text: "↓"
                color: downMa.containsMouse ? root.fgColor : root.dimColor
                font.family: root.fontFamily
                font.pixelSize: 16
                MouseArea {
                    id: downMa
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: Config.moveInZone(wr.widgetName, 1, wr.zone)
                }
            }

            // Enable / disable toggle
            Rectangle {
                width: 24; height: 16; radius: 8
                color: Config.isEnabled(wr.widgetName) ? root.accentColor : "#30ffffff"
                Rectangle {
                    x: Config.isEnabled(wr.widgetName) ? 10 : 2
                    y: 2; width: 12; height: 12; radius: 6
                    color: Config.isEnabled(wr.widgetName) ? "#14130e" : "#ffffff"
                    Behavior on x { NumberAnimation { duration: 120 } }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Config.toggleWidget(wr.widgetName)
                }
            }
        }
    }
}