import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: wr
    property string widgetName
    property string zone
    readonly property bool isSpacer: Config.isSpacer(widgetName)
    readonly property bool on: isSpacer || Config.isEnabled(widgetName)

    Layout.fillWidth: true
    implicitHeight: 38
    radius: 3
    color: "#14ffffff"
    border.color: "#28ffffff"
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 8
        spacing: 6

        Text {
            text: wr.isSpacer ? "spacer" : wr.widgetName
            color: wr.on ? Config.fgColor : Qt.rgba(Config.fgColor.r, Config.fgColor.g, Config.fgColor.b, 0.4)
            font.family: Config.fontFamily
            font.pixelSize: 14
            font.italic: wr.isSpacer
            Layout.fillWidth: true
        }

        // zone buttons: L C R on horizontal bars, T M B on vertical bars
        SIconBtn {
            glyph: Config.zoneGlyph("left")
            active: wr.zone === "left"
            onActivated: Config.moveToZone(wr.widgetName, "left")
        }
        SIconBtn {
            glyph: Config.zoneGlyph("center")
            active: wr.zone === "center"
            onActivated: Config.moveToZone(wr.widgetName, "center")
        }
        SIconBtn {
            glyph: Config.zoneGlyph("right")
            active: wr.zone === "right"
            onActivated: Config.moveToZone(wr.widgetName, "right")
        }

        Item {
            Layout.preferredWidth: 6
        }

        // order buttons: left/right on horizontal bars, up/down on vertical bars
        SIconBtn {
            glyph: Config.vertical ? "\u25b2" : "\u25c0"
            onActivated: Config.moveInZone(wr.widgetName, -1, wr.zone)
        }
        SIconBtn {
            glyph: Config.vertical ? "\u25bc" : "\u25b6"
            onActivated: Config.moveInZone(wr.widgetName, 1, wr.zone)
        }

        Item {
            Layout.preferredWidth: 6
        }

        // spacer: width field + delete
        TextField {
            id: sizeFld
            visible: wr.isSpacer
            Layout.preferredWidth: 54
            Layout.preferredHeight: 24
            horizontalAlignment: Text.AlignRight
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: 12
            selectByMouse: true
            validator: RegularExpressionValidator {
                regularExpression: /^\d{0,4}$/
            }
            leftPadding: 4
            rightPadding: 4
            topPadding: 2
            bottomPadding: 2
            background: Rectangle {
                color: sizeFld.activeFocus ? "#18ffffff" : "transparent"
                border.color: sizeFld.activeFocus ? Config.accentColor : "#20ffffff"
                border.width: 1
                radius: 3
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
        }

        SIconBtn {
            visible: wr.isSpacer
            glyph: "\u2715"
            onActivated: Config.removeWidget(wr.widgetName)
        }

        // normal widget: enable toggle
        Rectangle {
            visible: !wr.isSpacer
            Layout.preferredWidth: 36
            Layout.preferredHeight: 18
            radius: 9
            color: wr.on ? Config.accentColor : "#30ffffff"
            border.color: "#40ffffff"
            border.width: 1
            Rectangle {
                x: wr.on ? 20 : 2
                y: 2
                width: 14
                height: 14
                radius: 7
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
