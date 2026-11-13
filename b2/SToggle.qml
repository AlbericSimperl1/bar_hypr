import QtQuick
import QtQuick.Layouts

RowLayout {
    id: tr
    property string label
    property bool value: false
    signal toggled(bool v)
    readonly property bool tuiStop: true
    readonly property string hint: "toggle"
    function activate() {
        toggled(!value);
    }
    Layout.fillWidth: true
    Layout.leftMargin: 8
    Layout.preferredHeight: Tui.lineH
    spacing: 8
    SLbl {
        text: tr.label
        selected: Tui.isCursor(tr)
    }
    Text {
        text: tr.value ? "[x]" : "[ ]"
        color: Tui.text
        font.family: Tui.family
        font.pixelSize: Tui.size
        font.bold: toggleMa.containsMouse
        Layout.fillWidth: true
        MouseArea {
            id: toggleMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: tr.toggled(!tr.value)
        }
    }
}
