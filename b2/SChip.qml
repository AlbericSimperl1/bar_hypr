import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: chip
    property string label
    property bool sel: false
    signal activated
    implicitWidth: 70
    implicitHeight: 28
    radius: 3
    color: sel ? Config.accentColor : (chipMa.containsMouse ? "#14ffffff" : "transparent")
    border.color: "#20ffffff"
    border.width: 1
    Text {
        anchors.centerIn: parent
        text: chip.label
        color: chip.sel ? "#14130e" : Config.fgColor
        font.family: Config.fontFamily
        font.pixelSize: 12
        font.capitalization: Font.Capitalize
    }
    MouseArea {
        id: chipMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: chip.activated()
    }
}
