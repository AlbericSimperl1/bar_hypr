// WidgetRegistry.qml
pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: reg

    readonly property var map: ({
            "clock": clockComp,
            "ws": wsComp,
            "media": mediaComp,
            "bluetooth": bluetoothComp,
            "wifi": wifiComp,
            "notifications": notificationsComp,
            "brightness": brightnessComp,
            "volume": volumeComp,
            "cpu": cpuComp,
            "ram": ramComp,
            "gpu": gpuComp,
            "disk": diskComp,
            "battery": batteryComp,
            "power": powerComp,
            "settings": settingsComp
        })

    function componentFor(name) {
        if (Config.isSpacer(name))
            return spacerComp;
        return map[name] || null;
    }

    Component {
        id: spacerComp
        Spacer {}
    }
    Component {
        id: clockComp
        Clock {}
    }
    Component {
        id: wsComp
        Ws {}
    }
    Component {
        id: mediaComp
        MediaWidget {}
    }
    Component {
        id: volumeComp
        VolumeWidget {}
    }
    Component {
        id: cpuComp
        CpuWidget {}
    }
    Component {
        id: ramComp
        RamWidget {}
    }
    Component {
        id: gpuComp
        GpuWidget {}
    }
    Component {
        id: diskComp
        DiskWidget {}
    }
    Component {
        id: batteryComp
        BatteryPill {}
    }
    Component {
        id: wifiComp
        WifiDots {}
    }

    Component {
        id: brightnessComp
        Brightness {
            fontFamily: Config.iconFont
            iconSize: Math.round(29 * Config.iconScale)
            fgColor: Config.fgColor
            accentColor: Config.accentColor
            onClicked: {
                const p = mapToItem(null, width / 2, height / 2);
                BarState.toggle("brightness", p.x, p.y);
            }
        }
    }

    Component {
        id: bluetoothComp
        BluetoothIcon {}
    }

    Component {
        id: notificationsComp
        PanelIcon {
            panel: "notifications"
            glyph: Notifications.dndEnabled ? "\udb80\udc9b" : "\udb80\udc9a"
            size: 25
            dy: 0
            onRightClicked: Notifications.toggleDnd()

            Rectangle {
                visible: Notifications.count > 0 && !Notifications.dndEnabled && BarState.activePanel !== "notifications"
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 2
                anchors.rightMargin: 1
                width: 5
                height: 5
                radius: 4
                color: "#88ff4444"
            }
        }
    }

    Component {
        id: powerComp
        PanelIcon {
            panel: "power"
            glyph: "\u23fb"
            size: 25
            dy: 0
        }
    }

    Component {
        id: settingsComp
        PanelIcon {
            panel: "settings"
            glyph: Config.settingsIcon !== "" ? Config.settingsIcon : "\uf1de"
            size: Config.settingsIconSize
            dy: 0
        }
    }
}
