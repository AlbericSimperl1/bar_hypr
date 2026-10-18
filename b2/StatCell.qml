// StatCell.qml - label + number. Horizontal: "cpu 12%"   Vertical: "C" over "12"
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property string shortLabel: "C"
    property string longLabel: "cpu"
    property int value: 0
    property bool known: true

    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"
    readonly property color dim: Qt.rgba(Config.fgColor.r, Config.fgColor.g, Config.fgColor.b, 0.6)
    readonly property int fs: Math.round((vertical ? 12 : 15) * Config.fontScale)

    implicitWidth: grid.implicitWidth
    implicitHeight: vertical ? grid.implicitHeight : Math.max(24, grid.implicitHeight)

    GridLayout {
        id: grid
        anchors.centerIn: parent
        columns: root.vertical ? 1 : 2
        rowSpacing: 0
        columnSpacing: 6

        Text {
            text: root.vertical ? root.shortLabel : root.longLabel
            color: root.dim
            font.family: Config.fontFamily
            font.pixelSize: root.fs
            Layout.alignment: Qt.AlignCenter
        }
        Text {
            text: !root.known ? "-" : (root.vertical ? String(root.value) : String(root.value).padStart(2, " ") + "%")
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: root.fs
            font.bold: true
            Layout.alignment: Qt.AlignCenter
        }
    }
}
