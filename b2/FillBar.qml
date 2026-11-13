// FillBar.qml - pill that fills with value (0..1): left to right, bottom to top on vertical bars
import QtQuick

Rectangle {
    id: root
    property real value: 0
    property real sizeScale: 1
    property color fillColor: Qt.rgba(1, 1, 1, 0.55)

    implicitWidth: Math.round((Config.vertical ? 6 : 35) * sizeScale)
    implicitHeight: Math.round((Config.vertical ? 35 : 6) * sizeScale)
    radius: 100
    color: Qt.rgba(1, 1, 1, 0.25)
    clip: true

    Rectangle {
        readonly property real p: Math.max(0.05, Math.min(1, root.value))
        x: 0
        y: Config.vertical ? parent.height - height : 0
        width: Config.vertical ? parent.width : parent.width * p
        height: Config.vertical ? parent.height * p : parent.height
        radius: 100
        color: root.fillColor

        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
    }
}
