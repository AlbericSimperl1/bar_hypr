// DateWidget.qml - horizontal: Config.dateFormat ("ma 2 nov")   vertical: stacked "ma / 2 / 11"
import QtQuick

Text {
    id: root
    property date now: new Date()
    readonly property var loc: Qt.locale(Config.dateLocale)

    text: Config.vertical
        ? loc.dayName(now.getDay(), Locale.ShortFormat).replace(/\./g, "").toLowerCase().slice(0, 2) + "\n" + now.getDate() + "\n" + (now.getMonth() + 1)
        : now.toLocaleDateString(loc, Config.dateFormat).toLowerCase()
    horizontalAlignment: Text.AlignHCenter
    color: Config.fgColor
    font.family: Config.fontFamily
    font.pixelSize: Config.fontPx("date", 17)
    font.bold: true

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }
}
