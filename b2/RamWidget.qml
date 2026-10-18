// RamWidget.qml
import QtQuick
import Quickshell.Io

StatCell {
    id: root
    shortLabel: "R"
    longLabel: "ram"

    Process {
        id: proc
        command: ["awk", "/MemTotal/{t=$2}/MemAvailable/{a=$2}END{printf \"%d\\n\", (t-a)*100/t}", "/proc/meminfo"]
        stdout: SplitParser {
            onRead: line => {
                const v = parseInt(line);
                if (!isNaN(v))
                    root.value = v;
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
