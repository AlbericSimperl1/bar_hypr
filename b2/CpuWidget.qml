// CpuWidget.qml
import QtQuick
import Quickshell.Io

StatCell {
    id: root
    shortLabel: "C"
    longLabel: "cpu"
    format: Config.cpuFormat
    kind: "cores"
    used: total > 0 ? value * total / 100 : -1

    property real prevTotal: -1
    property real prevIdle: 0

    function parse(line) {
        const f = line.trim().split(/\s+/).slice(1, 9).map(Number);
        if (f.length < 5)
            return;
        const idle = f[3] + f[4];
        const tot = f.reduce((a, b) => a + b, 0);
        if (prevTotal >= 0 && tot > prevTotal)
            value = Math.max(0, Math.min(100, Math.round(100 * (1 - (idle - prevIdle) / (tot - prevTotal)))));
        prevTotal = tot;
        prevIdle = idle;
    }

    // number of logical cores (the "available" side of used/total)
    Process {
        command: ["nproc"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                const v = parseInt(line);
                if (!isNaN(v) && v > 0)
                    root.total = v;
            }
        }
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
