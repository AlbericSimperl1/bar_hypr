// BatteryPill.qml - pill fill (bolt icon while charging); rotates with bar orientation
import QtQuick
import Quickshell
import Quickshell.Services.UPower

Item {
    id: root
    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"

    readonly property var battery: UPower.displayDevice
    readonly property real percentage: battery ? battery.percentage : 0
    readonly property bool isCharging: battery ? (battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.FullyCharged) : false

    implicitWidth: isCharging ? 18 : (vertical ? 6 : 35)
    implicitHeight: isCharging ? 20 : (vertical ? 35 : 6)

    Text {
        anchors.centerIn: parent
        visible: root.isCharging
        text: "\udb85\udc0b"
        color: Qt.rgba(1, 1, 1, 0.95)
        font.family: Config.iconFont
        font.pixelSize: 16
    }

    Rectangle {
        anchors.fill: parent
        radius: 100
        color: Qt.rgba(1, 1, 1, 0.25)
        visible: !root.isCharging
        clip: true

        Rectangle {
            readonly property real p: Math.max(0.05, root.percentage)
            x: 0
            y: root.vertical ? parent.height - height : 0
            width: root.vertical ? parent.width : parent.width * p
            height: root.vertical ? parent.height * p : parent.height
            radius: 100
            color: root.percentage > 0.50 ? Qt.rgba(1, 1, 1, 0.55) : (root.percentage >= 0.25 ? "#e6c641" : "#e64141")

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
}
