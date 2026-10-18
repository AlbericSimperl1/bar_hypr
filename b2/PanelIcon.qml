// PanelIcon.qml - clickable glyph that toggles a panel
import QtQuick

Text {
    id: ic
    property string panel: ""
    property string glyph: ""
    property int size: 25
    readonly property bool isOpen: BarState.activePanel === panel
    signal rightClicked

    text: isOpen ? "\udb80\udd43" : glyph
    color: Config.fgColor
    font.family: Config.iconFont
    font.pixelSize: isOpen ? 22 : size

    MouseArea {
        anchors.fill: parent
        anchors.margins: -4
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                ic.rightClicked();
            } else {
                const p = ic.mapToItem(null, ic.width / 2, ic.height / 2);
                BarState.toggle(ic.panel, p.x, p.y);
            }
        }
    }
}
