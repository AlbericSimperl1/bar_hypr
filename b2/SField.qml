import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

RowLayout {
    id: fr
    property string label
    property string value
    property bool isColor: false
    signal committed(string v)
    Layout.fillWidth: true
    spacing: 8
    SLbl {
        text: fr.label
    }
    Rectangle {
        visible: fr.isColor
        Layout.preferredWidth: 24
        Layout.preferredHeight: 24
        radius: 3
        color: fr.isColor ? fr.value : "transparent"
        border.color: "#20ffffff"
        border.width: 1
    }
    TextField {
        Layout.fillWidth: true
        text: fr.value
        color: Config.fgColor
        font.family: Config.fontFamily
        font.pixelSize: 12
        selectByMouse: true
        background: Rectangle {
            color: "transparent"
            border.color: "#20ffffff"
            border.width: 1
            radius: 3
        }
        onEditingFinished: {
            if (!fr.isColor || /^#[0-9a-fA-F]{6,8}$/.test(text))
                fr.committed(text);
        }
    }
}
