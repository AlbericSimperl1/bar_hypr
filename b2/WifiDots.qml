// WifiDots.qml - signal strength as 3 dots (column on side bars, row on top/bottom)
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking

Item {
    id: root
    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"

    readonly property var wifiDevice: {
        if (!Networking.devices)
            return null;
        const devs = Networking.devices.values;
        for (let i = 0; i < devs.length; i++)
            if (devs[i] && devs[i].type === DeviceType.Wifi)
                return devs[i];
        return null;
    }
    readonly property var connectedWifi: {
        if (!wifiDevice || !wifiDevice.networks)
            return null;
        const nets = wifiDevice.networks.values;
        for (let i = 0; i < nets.length; i++)
            if (nets[i] && nets[i].connected)
                return nets[i];
        return null;
    }
    readonly property real signalStrength: connectedWifi ? (connectedWifi.signalStrength || 0) : 0
    readonly property int activeDots: {
        if (!connectedWifi)
            return 0;
        if (signalStrength >= 0.75)
            return 3;
        if (signalStrength >= 0.33)
            return 2;
        return 1;
    }

    implicitWidth: grid.implicitWidth
    implicitHeight: Math.max(24, grid.implicitHeight)

    GridLayout {
        id: grid
        anchors.centerIn: parent
        columns: root.vertical ? 1 : 3
        rowSpacing: 3
        columnSpacing: 3

        Repeater {
            model: 3
            delegate: Rectangle {
                required property int index
                readonly property int level: root.vertical ? 3 - index : index + 1
                Layout.preferredWidth: Math.round(6 * Config.iconScale)
                Layout.preferredHeight: Math.round(6 * Config.iconScale)
                radius: 6
                color: root.activeDots >= level ? Qt.rgba(1, 1, 1, 0.95) : Qt.rgba(1, 1, 1, 0.25)
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -4
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            const p = root.mapToItem(null, root.width / 2, root.height / 2);
            BarState.toggle("wifi", p.x, p.y);
        }
    }
}
