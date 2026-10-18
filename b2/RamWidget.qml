// RamWidget.qml
import QtQuick
import Quickshell.Io

StatCell {
    id: root
    shortLabel: "R"
    longLabel: "ram"
    format: Config.ramFormat
    kind: "mem"

    Process {
        id: proc
        // prints: percent usedKiB totalKiB
        command: ["awk", "/MemTotal/{t=$2}/MemAvailable/{a=$2}END{printf \"%d %d %d\\n\", (t-a)*100/t, t-a, t}", "/proc/meminfo"]
        stdout: SplitParser {
            onRead: line => {
                const p = line.trim().split(/\s+/);
                const v = parseInt(p[0]);
                if (isNaN(v))
                    return;
                root.value = v;
                const u = parseFloat(p[1]);
                const t = parseFloat(p[2]);
                if (!isNaN(u) && !isNaN(t) && t > 0) {
                    root.used = u / 1024;
                    root.total = t / 1024;
                }
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
}
