// BatteryPill.qml - pill fill (bolt icon while charging); rotates with bar orientation
import QtQuick
import Quickshell
import Quickshell.Services.UPower

Item {
    id: root
    readonly property real s: Config.widgetScale("battery")
    readonly property var battery: UPower.displayDevice
    readonly property real percentage: battery ? battery.percentage : 0
    readonly property bool isCharging: battery ? (battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.FullyCharged) : false

    implicitWidth: isCharging ? Math.round(18 * s) : fill.implicitWidth
    implicitHeight: isCharging ? Math.round(20 * s) : fill.implicitHeight

    Text {
        anchors.centerIn: parent
        visible: root.isCharging
        text: "\udb85\udc0b"
        color: Qt.rgba(1, 1, 1, 0.95)
        font.family: Config.iconFont
        font.pixelSize: Math.round(16 * root.s)
    }

    FillBar {
        id: fill
        anchors.fill: parent
        visible: !root.isCharging
        sizeScale: root.s
        value: root.percentage
        fillColor: root.percentage > 0.50 ? Qt.rgba(1, 1, 1, 0.55) : (root.percentage >= 0.25 ? "#e6c641" : "#e64141")
    }
}
