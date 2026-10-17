// WidgetRegistry.qml
pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property var map: ({
        "clock":         clockComp,
        "ws":            wsComp,
        "media":         mediaComp,
        "bluetooth":     bluetoothComp,
        "wifi":          wifiComp,
        "notifications": notificationsComp,
        "brightness":    brightnessComp,
        "volume":        volumeComp,
        "cpuram":        cpuramComp,
        "battery":       batteryComp,
        "power":         powerComp,
        "settings":      settingsComp
    })

    function componentFor(name) { return map[name] || null; }

    Component { id: clockComp;         Clock {} }
    Component { id: wsComp;            Ws {} }
    Component { id: mediaComp;         MediaWidget {} }
    Component { id: brightnessComp;    Brightness { isOpen: BarState.activePanel === "brightness" } }
    Component { id: volumeComp;        VolumeWidget {} }
    Component { id: cpuramComp;        CpuRamWidget {} }
    Component { id: batteryComp;       BatteryWidget {} }

    // Inline simple widgets — no separate file needed
    Component {
        id: bluetoothComp
        Text {
            text: BarState.activePanel === "bluetooth" ? "󰅃" : ""
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: BarState.activePanel === "bluetooth" ? 22 : 22
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    const p = parent.mapToItem(null, parent.width / 2, parent.height / 2);
                    BarState.toggle("bluetooth", p.x, p.y);
                }
            }
        }
    }

    Component {
        id: wifiComp
        Text {
            text: BarState.activePanel === "wifi" ? "󰅃" : "󰤨"
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: BarState.activePanel === "wifi" ? 22 : 29
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    const p = parent.mapToItem(null, parent.width / 2, parent.height / 2);
                    BarState.toggle("wifi", p.x, p.y);
                }
            }
        }
    }

    Component {
        id: notificationsComp
        Item {
            implicitWidth: 16
            implicitHeight: 24
            readonly property bool isOpen: BarState.activePanel === "notifications"

            Text {
                anchors.centerIn: parent
                text: parent.isOpen ? "󰅃" : (Notifications.dndEnabled ? "\udb80\udc9b" : "\udb80\udc9a")
                color: Config.fgColor
                font.family: Config.fontFamily
                font.pixelSize: parent.isOpen ? 22 : 25
            }
            Rectangle {
                visible: Notifications.count > 0 && !Notifications.dndEnabled && !parent.isOpen
                anchors.top: parent.top; anchors.right: parent.right
                anchors.topMargin: 2; anchors.rightMargin: 1
                width: 5; height: 5; radius: 4
                color: "#88ff4444"
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        Notifications.toggleDnd();
                    } else {
                        const p = parent.mapToItem(null, parent.width / 2, parent.height / 2);
                        BarState.toggle("notifications", p.x, p.y);
                    }
                }
            }
        }
    }

    Component {
        id: powerComp
        Text {
            text: BarState.activePanel === "power" ? "󰅃" : "⏻"
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: BarState.activePanel === "power" ? 22 : 25
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    const p = parent.mapToItem(null, parent.width / 2, parent.height / 2);
                    BarState.toggle("power", p.x, p.y);
                }
            }
        }
    }

    Component {
        id: settingsComp
        Text {
            text: BarState.activePanel === "settings" ? "󰅃" : "󰒓"
            color: BarState.activePanel === "settings" ? Config.accentColor : Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: 24
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    const p = parent.mapToItem(null, parent.width / 2, parent.height / 2);
                    BarState.toggle("settings", p.x, p.y);
                }
            }
        }
    }
}