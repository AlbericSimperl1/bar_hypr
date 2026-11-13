// quickshell/modules/panels/PowerPanel.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

TuiPanel {
    id: powerPanelRoot

    mode: "power"
    total: 8

    property string currentProfile: "balanced"

    // Haalt de initiële status op
    Process {
        id: profileProcess
        command: ["powerprofilesctl", "get"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                if (line.trim() !== "")
                    powerPanelRoot.currentProfile = line.trim();
            }
        }
    }

    function setProfile(profile) {
        Quickshell.execDetached(["powerprofilesctl", "set", profile]);
        currentProfile = profile;
    }

    TuiPane {
        title: "profile"

        Repeater {
            model: ["power-saver", "balanced", "performance"]
            delegate: TuiLine {
                required property string modelData
                required property int index
                number: String(index + 1)
                text: modelData
                current: powerPanelRoot.currentProfile === modelData
                hint: "set " + modelData
                onClicked: powerPanelRoot.setProfile(modelData)
            }
        }
    }

    TuiPane {
        title: "session"

        Repeater {
            model: [
                {
                    name: "lock",
                    cmd: ["sh", "-c", "~/.config/hypr/scripts/lock.sh"]
                },
                {
                    name: "logout",
                    cmd: ["uwsm", "stop"]
                },
                {
                    name: "suspend",
                    cmd: ["systemctl", "suspend"]
                },
                {
                    name: "reboot",
                    cmd: ["systemctl", "reboot"]
                },
                {
                    name: "shutdown",
                    cmd: ["systemctl", "poweroff"],
                    danger: true
                }
            ]
            delegate: TuiLine {
                required property var modelData
                required property int index
                number: String(index + 4)
                text: modelData.name
                textColor: modelData.danger ? Tui.danger : Tui.text
                hint: modelData.name
                onClicked: Quickshell.execDetached(modelData.cmd)
            }
        }
    }
}
