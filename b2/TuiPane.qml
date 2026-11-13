// TuiPane.qml - kader met de titel in de bovenrand. Losse randstukken in plaats van een achtergrond
// achter de titel, zodat de blur door de opening zichtbaar blijft (zoals de pane in rust-launcher).
import QtQuick
import QtQuick.Layouts

Item {
    id: pane

    property string title
    default property alias content: col.data

    readonly property int ruleY: Tui.lineH / 2 + 2

    Layout.fillWidth: true
    implicitHeight: Tui.lineH + col.implicitHeight + 9

    Text {
        id: titleText
        x: 14
        height: Tui.lineH
        verticalAlignment: Text.AlignVCenter
        text: pane.title
        color: Tui.text
        font.family: Tui.family
        font.pixelSize: Tui.size
        font.bold: true
        font.capitalization: Font.AllLowercase
    }

    Rectangle {
        y: pane.ruleY
        width: 8
        height: 1
        color: Tui.rule
    }
    Rectangle {
        x: titleText.x + titleText.width + 6
        y: pane.ruleY
        width: pane.width - x
        height: 1
        color: Tui.rule
    }
    Rectangle {
        y: pane.ruleY
        width: 1
        height: pane.height - y
        color: Tui.rule
    }
    Rectangle {
        x: pane.width - 1
        y: pane.ruleY
        width: 1
        height: pane.height - y
        color: Tui.rule
    }
    Rectangle {
        y: pane.height - 1
        width: pane.width
        height: 1
        color: Tui.rule
    }

    ColumnLayout {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 5
        anchors.rightMargin: 7
        anchors.topMargin: Tui.lineH + 2
        spacing: 0
    }
}
