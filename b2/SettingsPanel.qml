// SettingsPanel.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    property string tab: "bar"
    readonly property var tabs: [
        {
            key: "bar",
            label: "Bar"
        },
        {
            key: "colors",
            label: "Colors"
        },
        {
            key: "widgets",
            label: "Widgets"
        },
        {
            key: "panels",
            label: "Panels"
        },
        {
            key: "format",
            label: "Format"
        }
    ]

    function setPanelSize(name, key, v) {
        const next = Object.assign({}, Config.panelSizes);
        const cur = Object.assign({}, next[name] || {});
        cur[key] = Math.round(v);
        next[name] = cur;
        Config.panelSizes = next;
        Config.save();
    }
    function panelSize(name, key, def) {
        const p = Config.panelSizes[name];
        return p && p[key] ? p[key] : def;
    }

    // ── inline components (only reference Config + own props) ──
    component Lbl: Text {
        color: Qt.rgba(Config.fgColor.r, Config.fgColor.g, Config.fgColor.b, 0.6)
        font.family: Config.fontFamily
        font.pixelSize: 12
        Layout.preferredWidth: 140
    }

    component Chip: Rectangle {
        id: chip
        property string label
        property bool sel: false
        signal activated
        implicitWidth: 70
        implicitHeight: 28
        radius: 3
        color: sel ? Config.accentColor : (chipMa.containsMouse ? "#14ffffff" : "transparent")
        border.color: "#20ffffff"
        border.width: 1
        Text {
            anchors.centerIn: parent
            text: chip.label
            color: chip.sel ? "#14130e" : Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: 12
            font.capitalization: Font.Capitalize
        }
        MouseArea {
            id: chipMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: chip.activated()
        }
    }

    component SliderRow: RowLayout {
        id: sr
        property string label
        property real from: 0
        property real to: 100
        property real value: 50
        property string suffix: ""
        signal moved(real v)
        Layout.fillWidth: true
        spacing: 8

        Lbl {
            text: sr.label
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 10
            color: "#15ffffff"
            border.color: "#20ffffff"
            border.width: 1
            radius: 2
            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, (sr.value - sr.from) / (sr.to - sr.from)))
                height: parent.height
                radius: 2
                color: Config.accentColor
            }
            MouseArea {
                anchors.fill: parent
                anchors.topMargin: -6
                anchors.bottomMargin: -6
                cursorShape: Qt.PointingHandCursor
                function apply(mx) {
                    sr.moved(sr.from + (sr.to - sr.from) * Math.max(0, Math.min(1, mx / width)));
                }
                onPressed: m => apply(m.x)
                onPositionChanged: m => {
                    if (pressed)
                        apply(m.x);
                }
            }
        }
        Text {
            text: Math.round(sr.value) + sr.suffix
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: 12
            horizontalAlignment: Text.AlignRight
            Layout.preferredWidth: 48
        }
    }

    component ToggleRow: RowLayout {
        id: tr
        property string label
        property bool value: false
        signal toggled(bool v)
        Layout.fillWidth: true
        spacing: 8
        Lbl {
            text: tr.label
        }
        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 20
            radius: 10
            color: tr.value ? Config.accentColor : "#30ffffff"
            Rectangle {
                x: tr.value ? 22 : 2
                y: 2
                width: 16
                height: 16
                radius: 8
                color: tr.value ? "#14130e" : "#ffffff"
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: tr.toggled(!tr.value)
            }
        }
        Item {
            Layout.fillWidth: true
        }
    }

    component FieldRow: RowLayout {
        id: fr
        property string label
        property string value
        property bool isColor: false
        signal committed(string v)
        Layout.fillWidth: true
        spacing: 8
        Lbl {
            text: fr.label
        }
        Rectangle {
            visible: fr.isColor
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            radius: 3
            color: fr.isColor ? fr.value : "transparent"
            border.color: "#20ffffff"
            border.width: 1
        }
        TextField {
            Layout.fillWidth: true
            text: fr.value
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: 12
            selectByMouse: true
            background: Rectangle {
                color: "transparent"
                border.color: "#20ffffff"
                border.width: 1
                radius: 3
            }
            onEditingFinished: {
                if (!fr.isColor || /^#[0-9a-fA-F]{6,8}$/.test(text))
                    fr.committed(text);
            }
        }
    }

    component WidgetRow: Rectangle {
        id: wr
        property string widgetName
        property string zone
        readonly property bool on: Config.isEnabled(widgetName)

        Layout.fillWidth: true
        implicitHeight: 34
        radius: 3
        color: wrMa.containsMouse ? "#1affffff" : "#12ffffff"
        border.color: "#20ffffff"
        border.width: 1

        MouseArea {
            id: wrMa
            anchors.fill: parent
            hoverEnabled: true
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 8
            spacing: 10

            Text {
                text: wr.widgetName
                color: wr.on ? Config.fgColor : Qt.rgba(Config.fgColor.r, Config.fgColor.g, Config.fgColor.b, 0.4)
                font.family: Config.fontFamily
                font.pixelSize: 13
                Layout.fillWidth: true
            }

            Repeater {
                model: ["left", "center", "right"]
                delegate: Text {
                    id: zb
                    required property string modelData
                    text: modelData === "left" ? "⇤" : (modelData === "center" ? "≡" : "⇥")
                    color: wr.zone === modelData ? Config.accentColor : (zbMa.containsMouse ? Config.fgColor : "#66fff7e5")
                    font.pixelSize: 16
                    MouseArea {
                        id: zbMa
                        anchors.fill: parent
                        anchors.margins: -3
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Config.moveToZone(wr.widgetName, zb.modelData)
                    }
                }
            }

            Text {
                text: "↑"
                color: upMa.containsMouse ? Config.fgColor : "#66fff7e5"
                font.pixelSize: 16
                MouseArea {
                    id: upMa
                    anchors.fill: parent
                    anchors.margins: -3
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Config.moveInZone(wr.widgetName, -1, wr.zone)
                }
            }
            Text {
                text: "↓"
                color: dnMa.containsMouse ? Config.fgColor : "#66fff7e5"
                font.pixelSize: 16
                MouseArea {
                    id: dnMa
                    anchors.fill: parent
                    anchors.margins: -3
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Config.moveInZone(wr.widgetName, 1, wr.zone)
                }
            }

            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 16
                radius: 8
                color: wr.on ? Config.accentColor : "#30ffffff"
                Rectangle {
                    x: wr.on ? 14 : 2
                    y: 2
                    width: 12
                    height: 12
                    radius: 6
                    color: wr.on ? "#14130e" : "#ffffff"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Config.toggleWidget(wr.widgetName)
                }
            }
        }
    }

    // ── layout ──
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Text {
            text: "Settings"
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: 20
            font.bold: true
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            color: "transparent"
            border.color: "#20ffffff"
            border.width: 1
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.margins: 2
                spacing: 0

                Repeater {
                    model: root.tabs
                    delegate: Item {
                        id: tabItem
                        required property var modelData
                        readonly property bool sel: root.tab === modelData.key
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Rectangle {
                            anchors.fill: parent
                            radius: 3
                            color: tabItem.sel ? Config.accentColor : (tabMa.containsMouse ? "#14ffffff" : "transparent")
                        }
                        Text {
                            anchors.centerIn: parent
                            text: tabItem.modelData.label
                            color: tabItem.sel ? "#14130e" : Config.fgColor
                            font.family: Config.fontFamily
                            font.pixelSize: 13
                            font.bold: tabItem.sel
                        }
                        MouseArea {
                            id: tabMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.tab = tabItem.modelData.key
                        }
                    }
                }
            }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: width
            contentHeight: content.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: content
                width: parent.width
                spacing: 8

                // ── BAR ──
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    visible: root.tab === "bar"

                    Lbl {
                        text: "POSITION"
                    }
                    RowLayout {
                        spacing: 6
                        Repeater {
                            model: ["top", "bottom", "left", "right"]
                            delegate: Chip {
                                required property string modelData
                                label: modelData
                                sel: Config.barPosition === modelData
                                onActivated: Config.barPosition = modelData
                            }
                        }
                    }

                    SliderRow {
                        label: "Bar height"
                        from: 16
                        to: 60
                        suffix: "px"
                        value: Config.barHeight
                        onMoved: v => Config.barHeight = Math.round(v)
                    }
                    SliderRow {
                        label: "Edge margin"
                        from: 0
                        to: 24
                        suffix: "px"
                        value: Config.barMargin
                        onMoved: v => Config.barMargin = Math.round(v)
                    }
                    SliderRow {
                        label: "Bar inset"
                        from: 0
                        to: 48
                        suffix: "px"
                        value: Config.barInset
                        onMoved: v => Config.barInset = Math.round(v)
                    }
                    SliderRow {
                        label: "Bar rounding"
                        from: 0
                        to: 24
                        suffix: "px"
                        value: Config.barRadius
                        onMoved: v => Config.barRadius = Math.round(v)
                    }
                    SliderRow {
                        label: "Panel gap"
                        from: 0
                        to: 24
                        suffix: "px"
                        value: Config.barGap
                        onMoved: v => Config.barGap = Math.round(v)
                    }
                    SliderRow {
                        label: "Panel rounding"
                        from: 0
                        to: 20
                        suffix: "px"
                        value: Config.panelRadius
                        onMoved: v => Config.panelRadius = Math.round(v)
                    }
                }

                // ── COLORS ──
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    visible: root.tab === "colors"

                    FieldRow {
                        label: "Bar background"
                        isColor: true
                        value: String(Config.barBg)
                        onCommitted: v => Config.barBg = v
                    }
                    FieldRow {
                        label: "Foreground"
                        isColor: true
                        value: String(Config.fgColor)
                        onCommitted: v => Config.fgColor = v
                    }
                    FieldRow {
                        label: "Accent"
                        isColor: true
                        value: String(Config.accentColor)
                        onCommitted: v => Config.accentColor = v
                    }
                    FieldRow {
                        label: "Border"
                        isColor: true
                        value: String(Config.borderColor)
                        onCommitted: v => Config.borderColor = v
                    }
                    FieldRow {
                        label: "Panel background"
                        isColor: true
                        value: String(Config.panelBg)
                        onCommitted: v => Config.panelBg = v
                    }
                    FieldRow {
                        label: "Font family"
                        value: Config.fontFamily
                        onCommitted: v => Config.fontFamily = v
                    }
                    FieldRow {
                        label: "Icon font"
                        value: Config.iconFont
                        onCommitted: v => Config.iconFont = v
                    }
                }

                // ── WIDGETS ──
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    visible: root.tab === "widgets"

                    Repeater {
                        model: ["left", "center", "right"]
                        delegate: ColumnLayout {
                            id: zcol
                            required property string modelData
                            Layout.fillWidth: true
                            spacing: 4

                            Lbl {
                                text: zcol.modelData.toUpperCase() + " ZONE"
                                Layout.topMargin: 6
                            }

                            Repeater {
                                model: zcol.modelData === "left" ? Config.leftWidgets : (zcol.modelData === "center" ? Config.centerWidgets : Config.rightWidgets)
                                delegate: WidgetRow {
                                    required property string modelData
                                    widgetName: modelData
                                    zone: zcol.modelData
                                }
                            }
                        }
                    }
                }

                // ── PANELS ──
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    visible: root.tab === "panels"

                    ToggleRow {
                        label: "Auto-size height"
                        value: Config.panelsAutoSize
                        onToggled: v => {
                            Config.panelsAutoSize = v;
                            Config.save();
                        }
                    }

                    Repeater {
                        model: ["media", "bluetooth", "wifi", "notifications", "power", "brightness", "settings"]
                        delegate: ColumnLayout {
                            id: pcol
                            required property string modelData
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: pcol.modelData
                                color: Config.fgColor
                                font.family: Config.fontFamily
                                font.pixelSize: 13
                                font.bold: true
                                font.capitalization: Font.Capitalize
                            }
                            SliderRow {
                                label: "Width"
                                from: 320
                                to: 800
                                suffix: "px"
                                value: root.panelSize(pcol.modelData, "width", 480)
                                onMoved: v => root.setPanelSize(pcol.modelData, "width", v)
                            }
                            SliderRow {
                                label: "Height"
                                from: 140
                                to: 650
                                suffix: "px"
                                value: root.panelSize(pcol.modelData, "height", 650)
                                onMoved: v => root.setPanelSize(pcol.modelData, "height", v)
                            }
                        }
                    }
                }

                // ── FORMAT ──
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    visible: root.tab === "format"

                    FieldRow {
                        label: "Clock format"
                        value: Config.clockFormat
                        onCommitted: v => Config.clockFormat = v
                    }
                    FieldRow {
                        label: "Date format"
                        value: Config.dateFormat
                        onCommitted: v => Config.dateFormat = v
                    }
                    FieldRow {
                        label: "Date locale"
                        value: Config.dateLocale
                        onCommitted: v => Config.dateLocale = v
                    }
                    ToggleRow {
                        label: "Show date"
                        value: Config.showDate
                        onToggled: v => Config.showDate = v
                    }
                    SliderRow {
                        label: "Workspace count"
                        from: 1
                        to: 20
                        value: Config.workspaceCount
                        onMoved: v => Config.workspaceCount = Math.round(v)
                    }
                    ToggleRow {
                        label: "Workspace numbers"
                        value: Config.workspaceShowNumbers
                        onToggled: v => Config.workspaceShowNumbers = v
                    }
                    RowLayout {
                        spacing: 6
                        Lbl {
                            text: "Volume display"
                        }
                        Repeater {
                            model: ["icon", "percent", "both"]
                            delegate: Chip {
                                required property string modelData
                                label: modelData
                                sel: Config.volumeIconMode === modelData
                                onActivated: Config.volumeIconMode = modelData
                            }
                        }
                    }
                    SliderRow {
                        label: "Media title chars"
                        from: 10
                        to: 60
                        value: Config.mediaTitleMax
                        onMoved: v => Config.mediaTitleMax = Math.round(v)
                    }
                }
            }
        }
    }
}
