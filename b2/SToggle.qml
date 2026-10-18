import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

RowLayout {
    id: tr
    property string label
    property bool value: false
    signal toggled(bool v)
    Layout.fillWidth: true
    spacing: 8
    SLbl {
        text: tr.label
    }
    Rectangle {
        Layout.preferredWidth: 40
        Layout.preferredHeight: 20
        radius: 10
        color: tr.value ? Config.accentColor : "#30ffffff"
        Rectangle {
            x: tr.value ? 22 : 2
            y: 2
            width: 16
            height: 16
            radius: 8
            color: tr.value ? "#14130e" : "#ffffff"
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: tr.toggled(!tr.value)
        }
    }
    Item {
        Layout.fillWidth: true
    }
}
