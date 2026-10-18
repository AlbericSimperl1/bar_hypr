import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: ib
    property string glyph
    property bool active: false
    signal activated
    implicitWidth: 28
    implicitHeight: 26
    radius: 3
    color: active ? Config.accentColor : (ibMa.containsMouse ? "#33ffffff" : "#18ffffff")
    border.color: active ? Config.accentColor : "#40ffffff"
    border.width: 1
    Text {
        anchors.centerIn: parent
        text: ib.glyph
        color: ib.active ? "#14130e" : Config.fgColor
        font.family: Config.fontFamily
        font.pixelSize: 13
        font.bold: true
    }
    MouseArea {
        id: ibMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: ib.activated()
    }
}
