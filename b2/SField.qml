import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

RowLayout {
    id: fr
    property string label
    property string value
    property bool isColor: false
    signal committed(string v)
    readonly property bool tuiStop: true
    readonly property string hint: "edit"
    function activate() {
        fld.forceActiveFocus();
    }
    Layout.fillWidth: true
    Layout.leftMargin: 8
    Layout.preferredHeight: Tui.lineH
    spacing: 8
    SLbl {
        text: fr.label
        selected: Tui.isCursor(fr)
    }
    Rectangle {
        visible: fr.isColor
        Layout.preferredWidth: 20
        Layout.preferredHeight: 16
        color: fr.isColor ? fr.value : "transparent"
        border.color: Tui.rule
        border.width: 1
    }
    TextField {
        id: fld
        Layout.fillWidth: true
        Layout.preferredHeight: Tui.lineH
        padding: 0
        leftPadding: 4
        text: fr.value
        color: Tui.text
        font.family: Tui.family
        font.pixelSize: Tui.size
        selectByMouse: true
        background: Rectangle {
            color: fld.activeFocus ? "#18ffffff" : "transparent"
        }
        onEditingFinished: {
            if (!fr.isColor || /^#[0-9a-fA-F]{6,8}$/.test(text))
                fr.committed(text);
        }
    }
}
