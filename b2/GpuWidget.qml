// GpuWidget.qml - NVIDIA via nvidia-smi, otherwise AMD sysfs gpu_busy_percent
import QtQuick
import Quickshell.Io

StatCell {
    id: root
    shortLabel: "G"
    longLabel: "gpu"
    known: false

    Process {
        id: proc
        command: ["sh", "-c", "if command -v nvidia-smi >/dev/null 2>&1; then nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | head -n1; else cat /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | head -n1; fi"]
        stdout: SplitParser {
            onRead: line => {
                const v = parseInt(line);
                if (!isNaN(v)) {
                    root.value = v;
                    root.known = true;
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }
}
