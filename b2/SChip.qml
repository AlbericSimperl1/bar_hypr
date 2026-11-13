import QtQuick

Rectangle {
    id: chip
    property string label
    property bool sel: false
    property bool on: false
    signal activated
    readonly property bool tuiStop: true
    readonly property string hint: label
    function activate() {
        activated();
    }
    border.color: Tui.isCursor(chip) ? Tui.accent : "transparent"
    implicitWidth: chipText.implicitWidth + 12
    implicitHeight: Tui.lineH
    color: sel ? Tui.selBg : (chipMa.containsMouse ? "#14ffffff" : "transparent")
    Text {
        id: chipText
        anchors.centerIn: parent
        text: chip.label
        color: chip.sel ? Tui.selText : (!chip.enabled ? Tui.dim : (chip.on ? Tui.on : Tui.text))
        font.family: Tui.family
        font.pixelSize: Tui.size
        font.bold: chip.sel
        font.underline: Tui.isCursor(chip)
        font.capitalization: Font.AllLowercase
    }
    MouseArea {
        id: chipMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: chip.activated()
    }
}
