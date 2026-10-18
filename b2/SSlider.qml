import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

RowLayout {
    id: sr
    property string label
    property real from: 0
    property real to: 100
    property real value: 50
    property string suffix: ""
    signal moved(real v)
    Layout.fillWidth: true
    spacing: 8

    SLbl {
        text: sr.label
    }
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 10
        color: "#15ffffff"
        border.color: "#20ffffff"
        border.width: 1
        radius: 2
        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, (sr.value - sr.from) / (sr.to - sr.from)))
            height: parent.height
            radius: 2
            color: Config.accentColor
        }
        MouseArea {
            anchors.fill: parent
            anchors.topMargin: -6
            anchors.bottomMargin: -6
            cursorShape: Qt.PointingHandCursor
            function apply(mx) {
                sr.moved(sr.from + (sr.to - sr.from) * Math.max(0, Math.min(1, mx / width)));
            }
            onPressed: m => apply(m.x)
            onPositionChanged: m => {
                if (pressed)
                    apply(m.x);
            }
        }
    }
    Text {
        text: Math.round(sr.value) + sr.suffix
        color: Config.fgColor
        font.family: Config.fontFamily
        font.pixelSize: 12
        horizontalAlignment: Text.AlignRight
        Layout.preferredWidth: 48
    }
}
