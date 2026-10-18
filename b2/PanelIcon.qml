// PanelIcon.qml - fixed-height cell, glyph centered, click toggles a panel
import QtQuick

Item {
    id: ic
    property string panel: ""
    property string glyph: ""
    property int size: 25
    property real dy: 0            // per-icon vertical nudge
    readonly property bool isOpen: BarState.activePanel === panel
    default property alias extra: overlay.data
    signal rightClicked

    implicitWidth: Math.max(18, label.implicitWidth)
    implicitHeight: 24

    Text {
        id: label
        anchors.centerIn: parent
        anchors.verticalCenterOffset: ic.isOpen ? 0 : ic.dy
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: ic.isOpen ? "\udb80\udd43" : ic.glyph
        color: Config.fgColor
        font.family: Config.iconFont
        font.pixelSize: Math.round((ic.isOpen ? 22 : ic.size) * Config.iconScale)
    }

    Item {
        id: overlay
        anchors.fill: parent
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -3
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
