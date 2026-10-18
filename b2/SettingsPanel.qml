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
            key: "style",
            label: "Style"
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

                    SLbl {
                        text: "POSITION"
                    }
                    RowLayout {
                        spacing: 6
                        Repeater {
                            model: ["top", "bottom", "left", "right"]
                            delegate: SChip {
                                required property string modelData
                                label: modelData
                                sel: Config.barPosition === modelData
                                onActivated: Config.barPosition = modelData
                            }
                        }
                    }

                    SSlider {
                        label: "Bar thickness"
                        from: 12
                        to: 120
                        suffix: "px"
                        value: Config.barHeight
                        onMoved: v => Config.barHeight = Math.round(v)
                    }
                    SSlider {
                        label: "Edge margin"
                        from: 0
                        to: 200
                        suffix: "px"
                        value: Config.barMargin
                        onMoved: v => Config.barMargin = Math.round(v)
                    }
                    SSlider {
                        label: "Side margin"
                        from: 0
                        to: 2400
                        suffix: "px"
                        value: Config.barSideMargin
                        onMoved: v => Config.barSideMargin = Math.round(v)
                    }
                    SSlider {
                        label: "Border width"
                        from: 0
                        to: 12
                        suffix: "px"
                        value: Config.borderWidth
                        onMoved: v => {
                            if (v >= 0.5 && Config.borderColor.a === 0)
                                Config.borderColor = "#66ffffff";
                            Config.borderWidth = Math.round(v);
                        }
                    }
                    SSlider {
                        label: "Bar inset"
                        from: 0
                        to: 300
                        suffix: "px"
                        value: Config.barInset
                        onMoved: v => Config.barInset = Math.round(v)
                    }
                    SSlider {
                        label: "Bar rounding"
                        from: 0
                        to: 60
                        suffix: "px"
                        value: Config.barRadius
                        onMoved: v => Config.barRadius = Math.round(v)
                    }
                    SSlider {
                        label: "Panel gap"
                        from: 0
                        to: 80
                        suffix: "px"
                        value: Config.barGap
                        onMoved: v => Config.barGap = Math.round(v)
                    }
                    SSlider {
                        label: "Panel rounding"
                        from: 0
                        to: 60
                        suffix: "px"
                        value: Config.panelRadius
                        onMoved: v => Config.panelRadius = Math.round(v)
                    }
                }

                // ── STYLE ──
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    visible: root.tab === "style"

                    SSlider {
                        label: "Widget spacing"
                        from: 0
                        to: 100
                        suffix: "px"
                        value: Config.widgetSpacing
                        onMoved: v => Config.widgetSpacing = Math.round(v)
                    }
                    SSlider {
                        label: "Font size"
                        from: 40
                        to: 300
                        suffix: "%"
                        value: Config.fontScalePct
                        onMoved: v => Config.fontScalePct = Math.round(v)
                    }
                    SSlider {
                        label: "Icon size"
                        from: 40
                        to: 300
                        suffix: "%"
                        value: Config.iconScalePct
                        onMoved: v => Config.iconScalePct = Math.round(v)
                    }
                    SField {
                        label: "Font family"
                        value: Config.fontFamily
                        onCommitted: v => Config.fontFamily = v
                    }

                    SLbl {
                        text: "ISLANDS"
                        Layout.topMargin: 8
                    }
                    SToggle {
                        label: "Enable islands"
                        value: Config.islandsEnabled
                        onToggled: v => Config.islandsEnabled = v
                    }
                    SSlider {
                        label: "Island padding"
                        from: 0
                        to: 100
                        suffix: "px"
                        value: Config.islandPadding
                        onMoved: v => Config.islandPadding = Math.round(v)
                    }
                    SSlider {
                        label: "Island inset"
                        from: 0
                        to: 40
                        suffix: "px"
                        value: Config.islandInset
                        onMoved: v => Config.islandInset = Math.round(v)
                    }
                    SSlider {
                        label: "Island rounding"
                        from: 0
                        to: 60
                        suffix: "px"
                        value: Config.islandRadius
                        onMoved: v => Config.islandRadius = Math.round(v)
                    }
                    SField {
                        label: "Island color"
                        isColor: true
                        value: String(Config.islandColor)
                        onCommitted: v => Config.islandColor = v
                    }
                }

                // ── COLORS ──
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    visible: root.tab === "colors"

                    SField {
                        label: "Bar background"
                        isColor: true
                        value: String(Config.barBg)
                        onCommitted: v => Config.barBg = v
                    }
                    SField {
                        label: "Foreground"
                        isColor: true
                        value: String(Config.fgColor)
                        onCommitted: v => Config.fgColor = v
                    }
                    SField {
                        label: "Accent"
                        isColor: true
                        value: String(Config.accentColor)
                        onCommitted: v => Config.accentColor = v
                    }
                    SField {
                        label: "Border"
                        isColor: true
                        value: String(Config.borderColor)
                        onCommitted: v => Config.borderColor = v
                    }
                    SField {
                        label: "Panel background"
                        isColor: true
                        value: String(Config.panelBg)
                        onCommitted: v => Config.panelBg = v
                    }
                }

                // ── WIDGETS (zones follow bar orientation) ──
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

                            SLbl {
                                text: Config.zoneLabel(zcol.modelData) + " ZONE"
                                Layout.topMargin: 6
                            }

                            readonly property var list: modelData === "left" ? Config.leftWidgets : (modelData === "center" ? Config.centerWidgets : Config.rightWidgets)

                            Repeater {
                                model: zcol.list
                                delegate: SWidgetRow {
                                    required property string modelData
                                    widgetName: modelData
                                    zone: zcol.modelData
                                }
                            }

                            Text {
                                visible: zcol.list.length === 0
                                text: "empty - move a widget here with " + (Config.vertical ? "T / M / B" : "L / C / R")
                                color: "#66fff7e5"
                                font.family: Config.fontFamily
                                font.pixelSize: 12
                                Layout.leftMargin: 4
                            }
                        }
                    }
                }

                // ── PANELS ──
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    visible: root.tab === "panels"

                    SToggle {
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
                            SSlider {
                                label: "Width"
                                from: 240
                                to: 800
                                suffix: "px"
                                value: root.panelSize(pcol.modelData, "width", 480)
                                onMoved: v => root.setPanelSize(pcol.modelData, "width", v)
                            }
                            SSlider {
                                label: "Height"
                                from: 100
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

                    SField {
                        label: "Clock format"
                        value: Config.clockFormat
                        onCommitted: v => Config.clockFormat = v
                    }
                    SField {
                        label: "Date format"
                        value: Config.dateFormat
                        onCommitted: v => Config.dateFormat = v
                    }
                    SField {
                        label: "Date locale"
                        value: Config.dateLocale
                        onCommitted: v => Config.dateLocale = v
                    }
                    SToggle {
                        label: "Show date"
                        value: Config.showDate
                        onToggled: v => Config.showDate = v
                    }
                    SSlider {
                        label: "Workspace count"
                        from: 1
                        to: 20
                        value: Config.workspaceCount
                        onMoved: v => Config.workspaceCount = Math.round(v)
                    }
                    RowLayout {
                        spacing: 6
                        SLbl {
                            text: "Volume display"
                        }
                        Repeater {
                            model: ["icon", "percent", "both"]
                            delegate: SChip {
                                required property string modelData
                                label: modelData
                                sel: Config.volumeIconMode === modelData
                                onActivated: Config.volumeIconMode = modelData
                            }
                        }
                    }
                    SSlider {
                        label: "Media title chars"
                        from: 5
                        to: 100
                        value: Config.mediaTitleMax
                        onMoved: v => Config.mediaTitleMax = Math.round(v)
                    }
                }
            }
        }
    }
}
