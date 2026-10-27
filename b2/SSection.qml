import QtQuick
import QtQuick.Layouts

// titled card that groups related settings
Rectangle {
    id: sec
    property string title
    default property alias content: body.data
    Layout.fillWidth: true
    implicitHeight: col.implicitHeight + 20
    color: "#0affffff"
    border.color: "#20ffffff"
    border.width: 1
    radius: 4

    ColumnLayout {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        spacing: 8

        Text {
            text: sec.title
            color: Config.accentColor
            font.family: Config.fontFamily
            font.pixelSize: 12
            font.bold: true
            font.capitalization: Font.AllUppercase
            font.letterSpacing: 1
        }
        ColumnLayout {
            id: body
            Layout.fillWidth: true
            spacing: 8
        }
    }
}
