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
            "cpuram": cpuramComp,
            "battery": batteryComp,
            "power": powerComp,
            "settings": settingsComp
        })

    function componentFor(name) {
        return map[name] || null;
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
        id: cpuramComp
        CpuRamWidget {}
    }
    Component {
        id: batteryComp
        BatteryWidget {}
    }

    Component {
        id: brightnessComp
        Brightness {
            fontFamily: Config.iconFont
            fgColor: Config.fgColor
            accentColor: Config.accentColor
            isOpen: BarState.activePanel === "brightness"
            onClicked: {
                const p = mapToItem(null, width / 2, height / 2);
                BarState.toggle("brightness", p.x, p.y);
            }
        }
    }

    Component {
        id: bluetoothComp
        PanelIcon {
            panel: "bluetooth"
            glyph: "\udb80\udcaf"
            size: 22
        }
    }

    Component {
        id: wifiComp
        PanelIcon {
            panel: "wifi"
            glyph: "\udb82\udd28"
            size: 29
        }
    }

    Component {
        id: notificationsComp
        PanelIcon {
            panel: "notifications"
            glyph: Notifications.dndEnabled ? "\udb80\udc9b" : "\udb80\udc9a"
            size: 25
            onRightClicked: Notifications.toggleDnd()

            Rectangle {
                visible: Notifications.count > 0 && !Notifications.dndEnabled && !parent.isOpen
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
        }
    }

    Component {
        id: settingsComp
        PanelIcon {
            panel: "settings"
            glyph: "\udb81\udc93"
            size: 24
        }
    }
}
