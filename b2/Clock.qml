// Clock.qml - horizontal: "19.07 zo 18 okt"   vertical: stacked digits + stacked date
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    implicitWidth: vertical ? vcol.implicitWidth : hgrid.implicitWidth
    implicitHeight: vertical ? vcol.implicitHeight : hgrid.implicitHeight

    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"
    readonly property color muted: Qt.rgba(1, 0.95, 0.82, 0.78)
    readonly property var loc: Qt.locale(Config.dateLocale)

    // horizontal
    readonly property string timeStr: Qt.formatDateTime(clockTimer.now, Config.clockFormat)
    readonly property string dateStr: clockTimer.now.toLocaleDateString(loc, " " + Config.dateFormat).toLowerCase()

    // vertical
    readonly property string digits: Qt.formatDateTime(clockTimer.now, "HHmm")
    readonly property string dayName: loc.dayName(clockTimer.now.getDay(), Locale.ShortFormat).replace(/\./g, "").toLowerCase().slice(0, 2)
    readonly property string dayNum: String(clockTimer.now.getDate())
    readonly property string monthName: loc.monthName(clockTimer.now.getMonth(), Locale.ShortFormat).replace(/\./g, "").toLowerCase().slice(0, 3)

    GridLayout {
        id: hgrid
        visible: !root.vertical
        columns: 2
        columnSpacing: 8

        Text {
            text: root.timeStr
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: Math.round(19 * Config.fontScale)
            font.bold: true
            Layout.alignment: Qt.AlignCenter
        }
        Text {
            visible: Config.showDate
            text: root.dateStr
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: Math.round(19 * Config.fontScale)
            font.weight: 600
            Layout.alignment: Qt.AlignCenter
        }
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
                font.pixelSize: Math.round(15 * Config.fontScale)
                font.weight: 900
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: index === 1 ? 8 : 0
            }
        }

        Text {
            visible: Config.showDate
            text: root.dayName
            color: root.muted
            font.family: Config.fontFamily
            font.pixelSize: Math.round(11 * Config.fontScale)
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
        }
        Text {
            visible: Config.showDate
            text: root.dayNum
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: Math.round(11 * Config.fontScale)
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }
        Text {
            visible: Config.showDate
            text: root.monthName
            color: root.muted
            font.family: Config.fontFamily
            font.pixelSize: Math.round(11 * Config.fontScale)
            Layout.alignment: Qt.AlignHCenter
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
