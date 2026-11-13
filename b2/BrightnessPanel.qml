// quickshell/modules/panels/BrightnessPanel.qml
import QtQuick
import QtQuick.Layouts
import Quickshell

TuiPanel {
    id: brightnessPanelRoot

    mode: "light"
    total: 2

    readonly property int currentBrightness: Math.max(0, Osd.brightness)
    property bool nightlightActive: false
    property bool scheduleActive: false

    function toggleForceNightlight() {
        nightlightActive = !nightlightActive;
        Quickshell.execDetached(["sh", "-c", "~/.config/hypr/scripts/nightlight.sh " + (nightlightActive ? "force" : "off")]);
    }

    function toggleScheduleNightlight() {
        scheduleActive = !scheduleActive;
        Quickshell.execDetached(["sh", "-c", "~/.config/hypr/scripts/nightlight.sh " + (scheduleActive ? "schedule" : "off")]);
    }

    TuiPane {
        title: "brightness"

        TuiMeter {
            Layout.leftMargin: 40
            from: 0
            to: 100
            value: brightnessPanelRoot.currentBrightness
            wheelStep: 5
            label: brightnessPanelRoot.currentBrightness + "%"
            onMoved: v => Osd.setBrightness(v)
        }
    }

    TuiPane {
        title: "night light"

        TuiLine {
            number: "1"
            text: (brightnessPanelRoot.nightlightActive ? "[x]" : "[ ]") + " forced"
            detail: brightnessPanelRoot.nightlightActive ? "on" : "off"
            detailColor: brightnessPanelRoot.nightlightActive ? Tui.on : Tui.dim
            hint: "toggle"
            onClicked: brightnessPanelRoot.toggleForceNightlight()
        }
        TuiLine {
            number: "2"
            text: (brightnessPanelRoot.scheduleActive ? "[x]" : "[ ]") + " schedule"
            detail: brightnessPanelRoot.scheduleActive ? "on" : "off"
            detailColor: brightnessPanelRoot.scheduleActive ? Tui.on : Tui.dim
            hint: "toggle"
            onClicked: brightnessPanelRoot.toggleScheduleNightlight()
        }
    }
}
