import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: wr
    property string widgetName
    property string zone
    readonly property bool on: Config.isEnabled(widgetName)

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
            text: wr.widgetName
            color: wr.on ? Config.fgColor : Qt.rgba(Config.fgColor.r, Config.fgColor.g, Config.fgColor.b, 0.4)
            font.family: Config.fontFamily
            font.pixelSize: 14
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

        Rectangle {
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
