// BatteryWidget.qml
import QtQuick
import Quickshell
import Quickshell.Services.UPower

Item {
    id: root
    implicitWidth: flow.implicitWidth
    implicitHeight: flow.implicitHeight

    readonly property var bat: UPower.displayDevice
    readonly property int pct: bat ? Math.round(bat.percentage * 100) : 100
    readonly property bool charging: bat ? bat.state === UPowerDeviceState.Charging : false
    readonly property bool full: bat ? bat.state === UPowerDeviceState.FullyCharged : true

    readonly property string icon: {
        if (!bat)
            return "󰂑";
        if (charging)
            return "󰂄";
        if (full)
            return "󰁹";
        if (pct > 80)
            return "󰂂";
        if (pct > 60)
            return "󰂀";
        if (pct > 40)
            return "󰁾";
        if (pct > 20)
            return "󰁼";
        return "󰁺";
    }
    readonly property color iconColor: {
        if (!bat)
            return Config.fgColor;
        if (charging || full)
            return Config.accentColor;
        if (pct <= 15)
            return "#ff5555";
        return Config.fgColor;
    }

    Flow {
        id: flow
        flow: (Config.barPosition === "left" || Config.barPosition === "right") ? Flow.TopToBottom : Flow.LeftToRight
        spacing: 4

        Text {
            text: root.icon
            color: root.iconColor
            font.family: Config.fontFamily
            font.pixelSize: 24
        }
        Text {
            visible: !!root.bat
            text: root.pct + "%"
            color: root.iconColor
            font.family: Config.fontFamily
            font.pixelSize: 16
        }
    }
}
