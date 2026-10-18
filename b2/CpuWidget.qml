// CpuWidget.qml
import QtQuick
import Quickshell.Io

StatCell {
    id: root
    shortLabel: "C"
    longLabel: "cpu"

    property real prevTotal: -1
    property real prevIdle: 0

    function parse(line) {
        const f = line.trim().split(/\s+/).slice(1, 9).map(Number);
        if (f.length < 5)
            return;
        const idle = f[3] + f[4];
        const total = f.reduce((a, b) => a + b, 0);
        if (prevTotal >= 0 && total > prevTotal)
            value = Math.max(0, Math.min(100, Math.round(100 * (1 - (idle - prevIdle) / (total - prevTotal)))));
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
}
