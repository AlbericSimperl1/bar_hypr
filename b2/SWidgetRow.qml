import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

TuiLine {
    id: wr
    property string widgetName
    property string zone
    readonly property bool isSpacer: Config.isSpacer(widgetName)
    readonly property bool on: isSpacer || Config.isEnabled(widgetName)

    text: isSpacer ? "spacer" : (on ? "[x] " : "[ ] ") + widgetName
    textColor: on ? Tui.text : Tui.dim
    hint: isSpacer ? "" : "toggle"
    onClicked: if (!isSpacer)
        Config.toggleWidget(widgetName)

    // zone buttons: L C R on horizontal bars, T M B on vertical bars; the current zone is bold
    Repeater {
        model: ["left", "center", "right"]
        delegate: TuiAction {
            required property string modelData
            text: Config.zoneGlyph(modelData)
            font.underline: wr.zone !== modelData
            font.bold: wr.zone === modelData
            onClicked: Config.moveToZone(wr.widgetName, modelData)
        }
    }

    // order buttons: left/right on horizontal bars, up/down on vertical bars
    TuiAction {
        text: Config.vertical ? "▲" : "◀"
        font.underline: false
        onClicked: Config.moveInZone(wr.widgetName, -1, wr.zone)
    }
    TuiAction {
        text: Config.vertical ? "▼" : "▶"
        font.underline: false
        onClicked: Config.moveInZone(wr.widgetName, 1, wr.zone)
    }

    // spacer: width field + delete, also without hover
    trailing: [
        TextField {
            id: sizeFld
            visible: wr.isSpacer
            Layout.preferredWidth: 54
            Layout.preferredHeight: Tui.lineH
            horizontalAlignment: Text.AlignRight
            color: wr.selected ? Tui.selText : Tui.text
            font.family: Tui.family
            font.pixelSize: Tui.size
            selectByMouse: true
            validator: RegularExpressionValidator {
                regularExpression: /^\d{0,4}$/
            }
            padding: 0
            background: Rectangle {
                color: sizeFld.activeFocus ? "#18ffffff" : "transparent"
            }

            function sync() {
                sizeFld.text = String(Math.round(Config.spacerSize(wr.widgetName)));
            }
            function bump(d) {
                Config.setSpacerSize(wr.widgetName, Config.spacerSize(wr.widgetName) + d);
                sync();
            }

            Component.onCompleted: sync()
            onEditingFinished: {
                if (text !== "")
                    Config.setSpacerSize(wr.widgetName, parseInt(text, 10));
                sync();
            }
            onActiveFocusChanged: if (!activeFocus)
                sync()
            Keys.onPressed: event => {
                const big = (event.modifiers & Qt.ShiftModifier) ? 10 : 1;
                if (event.key === Qt.Key_Up) {
                    bump(big);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Down) {
                    bump(-big);
                    event.accepted = true;
                }
            }

            Connections {
                target: Config
                function onSpacerSizesChanged() {
                    if (!sizeFld.activeFocus)
                        sizeFld.sync();
                }
            }
        },
        TuiAction {
            visible: wr.isSpacer
            text: "✕"
            color: wr.selected ? Tui.selText : Tui.text
            font.underline: false
            onClicked: Config.removeWidget(wr.widgetName)
        }
    ]
}
