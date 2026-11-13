import QtQuick

Rectangle {
    id: ib
    property string glyph
    property bool active: false
    signal activated
    implicitWidth: 28
    implicitHeight: Tui.lineH
    color: active ? Tui.selBg : (ibMa.containsMouse ? "#14ffffff" : "transparent")
    Text {
        anchors.centerIn: parent
        text: ib.glyph
        color: ib.active ? Tui.selText : Tui.text
        font.family: Tui.family
        font.pixelSize: Tui.size
    }
    MouseArea {
        id: ibMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: ib.activated()
    }
}
