// BtIcons.qml - shared Bluetooth glyph mapping (same icons as BluetoothPanel2)
pragma Singleton
import QtQuick
import Quickshell

Singleton {
    // idle glyph: plain bluetooth logo
    readonly property string base: "\uf293"
    readonly property string airpods: "\udb86\udc4f"

    function iconFor(d) {
        const name = String((d && (d.name || d.deviceName)) || "").toLowerCase();
        if (name.indexOf("airpods") >= 0)
            return airpods;

        const i = String((d && d.icon) || "").toLowerCase();
        if (i.indexOf("headset") >= 0 || i.indexOf("headphone") >= 0 || i.indexOf("audio") >= 0)
            return "\udb80\udecb";
        if (i.indexOf("keyboard") >= 0)
            return "\udb80\udf0c";
        if (i.indexOf("mouse") >= 0)
            return "\udb80\udf7d";
        if (i.indexOf("gaming") >= 0 || i.indexOf("joystick") >= 0)
            return "\udb80\udeb4";
        if (i.indexOf("phone") >= 0)
            return "\udb80\udff2";
        if (i.indexOf("computer") >= 0 || i.indexOf("laptop") >= 0)
            return "\udb80\udf79";
        return "\udb80\udcaf";
    }
}
