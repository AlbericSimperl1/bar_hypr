// Clock.qml
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    implicitWidth: grid.implicitWidth
    implicitHeight: grid.implicitHeight

    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"
    readonly property string timeStr: Qt.formatDateTime(clockTimer.now, Config.clockFormat)
    readonly property string dateStr: {
        const loc = Qt.locale(Config.dateLocale);
        return clockTimer.now.toLocaleDateString(loc, " " + Config.dateFormat).toLowerCase();
    }

    GridLayout {
        id: grid
        columns: root.vertical ? 1 : 2
        columnSpacing: 8
        rowSpacing: 2

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

    Timer {
        id: clockTimer
        property date now: new Date()
        interval: 1000
        running: true
        repeat: true
        onTriggered: now = new Date()
    }
}
