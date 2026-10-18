// CpuWidget.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root
    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"
    property int pct: 0
    property real prevTotal: -1
    property real prevIdle: 0

    implicitWidth: grid.implicitWidth
    implicitHeight: Math.max(24, grid.implicitHeight)

    function parse(line) {
        const f = line.trim().split(/\s+/).slice(1, 9).map(Number);
        if (f.length < 5)
            return;
        const idle = f[3] + f[4];
        const total = f.reduce((a, b) => a + b, 0);
        if (prevTotal >= 0 && total > prevTotal)
            pct = Math.max(0, Math.min(100, Math.round(100 * (1 - (idle - prevIdle) / (total - prevTotal)))));
        prevTotal = total;
        prevIdle = idle;
    }

    Process {
        id: proc
        command: ["head", "-n", "1", "/proc/stat"]
        stdout: SplitParser {
            onRead: line => root.parse(line)
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
            text: "cpu"
            color: Qt.rgba(Config.fgColor.r, Config.fgColor.g, Config.fgColor.b, 0.6)
            font.family: Config.fontFamily
            font.pixelSize: Math.round(15 * Config.fontScale)
            Layout.alignment: Qt.AlignCenter
        }
        Text {
            text: String(root.pct).padStart(2, " ") + "%"
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: Math.round(15 * Config.fontScale)
            font.bold: true
            Layout.alignment: Qt.AlignCenter
        }
    }
}
