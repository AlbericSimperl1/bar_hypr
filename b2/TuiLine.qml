// TuiLine.qml - één regel: nummer, tekst, detail, en onder de muis een witte balk met acties
import QtQuick
import QtQuick.Layouts

Item {
    id: line

    property string number: ""
    property bool numbered: true
    property string text
    property string detail
    property string hint          // wat een klik op de regel doet
    property color textColor: Tui.text
    property color detailColor: Tui.dim
    property bool current: false  // wat nu actief is: vet, cursief, onderstreept
    property bool selectable: true
    readonly property bool selected: selectable && visible && (Tui.keys ? Tui.cursor === line : hover.hovered)
    readonly property bool tuiStop: selectable

    default property alias actions: acts.data
    property alias trailing: trail.data

    signal clicked

    Layout.fillWidth: true
    implicitHeight: Tui.lineH

    onSelectedChanged: {
        if (selected)
            Tui.cursor = line;
        else if (Tui.cursor === line && !Tui.keys)
            Tui.cursor = null;
    }

    function rowActions() {
        return Tui.actionsIn([acts, trail]);
    }
    // zonder klikactie doet enter de eerste actie, die heeft de muis ook als enige
    function activate() {
        const a = rowActions();
        if (hint)
            clicked();
        else if (a.length > 0)
            a[0].activate();
    }

    Rectangle {
        anchors.fill: parent
        visible: line.selected
        color: Tui.selBg
    }

    MouseArea {
        anchors.fill: parent
        enabled: line.selectable
        onClicked: line.clicked()
    }

    HoverHandler {
        id: hover
        enabled: line.selectable
        cursorShape: Qt.PointingHandCursor
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: line.numbered ? 0 : 8
        anchors.rightMargin: 6
        spacing: 12

        Text {
            visible: line.numbered
            Layout.preferredWidth: 28
            horizontalAlignment: Text.AlignRight
            text: line.number
            color: line.selected ? Tui.selText : Tui.dim
            font.family: Tui.family
            font.pixelSize: Tui.size
        }

        Text {
            Layout.fillWidth: true
            text: line.text
            elide: Text.ElideRight
            color: line.selected ? Tui.selText : line.textColor
            font.family: Tui.family
            font.pixelSize: Tui.size
            font.bold: line.current || line.selected
            font.italic: line.current
            font.underline: line.current
        }

        Text {
            visible: line.detail !== ""
            text: line.detail
            color: line.selected ? Tui.selText : line.detailColor
            font.family: Tui.family
            font.pixelSize: Tui.size
        }

        RowLayout {
            id: acts
            visible: line.selected && children.length > 0
            spacing: 12
        }

        RowLayout {
            id: trail
            visible: children.length > 0
            spacing: 8
        }
    }
}
