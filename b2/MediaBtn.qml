// MediaBtn.qml - glyph button for the media panel controls
import QtQuick
import QtQuick.Layouts

Text {
    id: btn
    property var player            // the MediaPanel
    property bool active: false
    property bool enabledBtn: player.canControl
    signal clicked
    color: active ? player.accentColor : player.fgColor
    opacity: enabledBtn ? (ma.containsMouse ? 1 : 0.85) : 0.35
    font.family: player.fontFamily
    Layout.alignment: Qt.AlignVCenter
    MouseArea {
        id: ma
        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: btn.enabledBtn ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (btn.enabledBtn)
            btn.clicked()
    }
}
