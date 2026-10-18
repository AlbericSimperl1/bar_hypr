// BluetoothIcon.qml - bar icon: bluetooth logo when idle, connected device's icon otherwise
import QtQuick
import Quickshell.Bluetooth

PanelIcon {
    id: ic
    panel: "bluetooth"
    dy: 0

    readonly property var adapter: Bluetooth.defaultAdapter

    // first connected device (bindings re-evaluate on device list / connected / icon changes)
    readonly property var connectedDevice: {
        const devs = adapter && adapter.devices ? adapter.devices.values : [];
        for (let i = 0; i < devs.length; i++)
            if (devs[i] && devs[i].connected)
                return devs[i];
        return null;
    }

    glyph: connectedDevice ? BtIcons.iconFor(connectedDevice) : BtIcons.base
    size: connectedDevice ? 24 : 22
}
