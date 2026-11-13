// TuiPrompt.qml - invoerregel: vet label, dan de tekst. Wist zichzelf zodra hij verdwijnt.
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

RowLayout {
    id: prompt

    property string label
    property alias placeholder: field.placeholderText
    property alias text: field.text
    property bool password: false
    property bool autoFocus: false
    signal accepted

    readonly property bool tuiStop: true
    readonly property string hint: "edit"
    function activate() {
        field.forceActiveFocus();
    }

    Layout.fillWidth: true
    Layout.leftMargin: 40
    implicitHeight: Tui.lineH
    spacing: 8

    onVisibleChanged: {
        if (!visible)
            field.text = "";
        else if (autoFocus)
            field.forceActiveFocus();
    }

    Text {
        text: prompt.label
        color: Tui.isCursor(prompt) ? Tui.selText : Tui.text
        font.family: Tui.family
        font.pixelSize: Tui.size
        font.bold: true
        Rectangle {
            z: -1
            visible: Tui.isCursor(prompt)
            anchors.fill: parent
            color: Tui.selBg
        }
    }

    TextField {
        id: field
        Layout.fillWidth: true
        Layout.preferredHeight: Tui.lineH
        padding: 0
        echoMode: prompt.password ? TextInput.Password : TextInput.Normal
        color: Tui.text
        placeholderTextColor: Tui.dim
        font.family: Tui.family
        font.pixelSize: Tui.size
        selectByMouse: true
        background: null
        onAccepted: prompt.accepted()
    }
}
