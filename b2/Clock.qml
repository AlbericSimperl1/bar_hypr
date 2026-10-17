// Clock.qml
import QtQuick
import Quickshell

Item {
    id: root
    implicitWidth:  flow.implicitWidth
    implicitHeight: flow.implicitHeight

    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"
    readonly property string timeStr: Qt.formatDateTime(clockTimer.now, Config.clockFormat)
    readonly property string dateStr: {
        const loc = Qt.locale(Config.dateLocale);
        return clockTimer.now.toLocaleDateString(loc, " " + Config.dateFormat).toLowerCase();
    }

    Flow {
        id: flow
        flow: root.vertical ? Flow.TopToBottom : Flow.LeftToRight
        spacing: 8

        Text {
            text: root.timeStr
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: 19
            font.bold: true
        }
        Text {
            visible: Config.showDate
            text: root.dateStr
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: 19
            font.weight: 600
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