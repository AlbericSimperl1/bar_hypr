import QtQuick
import QtQuick.Layouts

Text {
    id: lbl
    property bool selected: false
    color: selected ? Tui.selText : Tui.text
    font.family: Tui.family
    font.pixelSize: Tui.size
    font.capitalization: Font.AllLowercase
    elide: Text.ElideRight
    Layout.preferredWidth: 172

    Rectangle {
        z: -1
        visible: lbl.selected
        anchors.fill: parent
        color: Tui.selBg
    }
}
