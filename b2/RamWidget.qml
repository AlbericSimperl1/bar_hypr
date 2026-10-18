// RamWidget.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root
    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"
    property int pct: 0

    implicitWidth: grid.implicitWidth
    implicitHeight: Math.max(24, grid.implicitHeight)

    Process {
        id: proc
        command: ["awk", "/MemTotal/{t=$2}/MemAvailable/{a=$2}END{printf \"%d\\n\", (t-a)*100/t}", "/proc/meminfo"]
        stdout: SplitParser {
            onRead: line => {
                const v = parseInt(line);
                if (!isNaN(v))
                    root.pct = v;
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }

    GridLayout {
        id: grid
        anchors.centerIn: parent
        columns: root.vertical ? 1 : 2
        rowSpacing: 0
        columnSpacing: 6

        Text {
            text: "ram"
            color: Qt.rgba(Config.fgColor.r, Config.fgColor.g, Config.fgColor.b, 0.6)
            font.family: Config.fontFamily
            font.pixelSize: 15
            Layout.alignment: Qt.AlignCenter
        }
        Text {
            text: String(root.pct).padStart(2, " ") + "%"
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: 15
            font.bold: true
            Layout.alignment: Qt.AlignCenter
        }
    }
}
