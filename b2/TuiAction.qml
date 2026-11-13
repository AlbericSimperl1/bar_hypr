// TuiAction.qml - onderstreepte tekstknop, voor op de witte selectiebalk en de statusregel
import QtQuick
import QtQuick.Layouts

Text {
    id: action
    signal clicked

    property string key           // sneltoets in de statusregel, staat vet voor de tekst
    Layout.leftMargin: key ? keyText.implicitWidth + 6 : 0

    readonly property bool tuiStop: true
    readonly property string hint: text
    function activate() {
        if (enabled)
            clicked();
    }

    color: Tui.selText
    font.family: Tui.family
    font.pixelSize: Tui.size
    font.underline: true
    font.bold: ma.containsMouse

    Text {
        id: keyText
        visible: action.key !== ""
        anchors.right: parent.left
        anchors.rightMargin: 6
        text: action.key
        color: action.color
        font.family: action.font.family
        font.pixelSize: action.font.pixelSize
        font.bold: true
    }

    // ligt over de tekst: de kleur van de actie zelf hangt af van waar hij staat
    Rectangle {
        visible: Tui.isCursor(action) || Tui.sub === action
        anchors.fill: parent
        anchors.margins: -2
        color: Tui.modeBg
        Text {
            anchors.centerIn: parent
            text: action.text
            color: Tui.selBg
            font: action.font
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        enabled: action.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: action.clicked()
    }
}
