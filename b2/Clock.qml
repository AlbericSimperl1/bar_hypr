// Clock.qml - horizontal: "19.07"   vertical: stacked digits
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    implicitWidth: vertical ? vcol.implicitWidth : htext.implicitWidth
    implicitHeight: vertical ? vcol.implicitHeight : htext.implicitHeight

    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"
    readonly property color muted: Qt.rgba(1, 0.95, 0.82, 0.78)
    readonly property string digits: Qt.formatDateTime(clockTimer.now, "HHmm")

    Text {
        id: htext
        visible: !root.vertical
        text: Qt.formatDateTime(clockTimer.now, Config.clockFormat)
        color: Config.fgColor
        font.family: Config.fontFamily
        font.pixelSize: Config.fontPx("clock", 17)
        font.bold: true
    }

    ColumnLayout {
        id: vcol
        visible: root.vertical
        spacing: 0

        Repeater {
            model: 4
            delegate: Text {
                required property int index
                text: root.digits.charAt(index)
                color: index < 2 ? Config.fgColor : root.muted
                font.family: Config.fontFamily
                font.pixelSize: Config.fontPx("clock", 15)
                font.weight: 900
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: index === 1 ? 8 : 0
            }
        }
    }

    Timer {
        id: clockTimer
        property date now: new Date()
        interval: 1000
        running: true
        repeat: true
        onTriggered: now = new Date()
    }
}
