// GpuWidget.qml - NVIDIA via nvidia-smi, otherwise AMD sysfs (gpu_busy_percent + vram)
import QtQuick
import Quickshell.Io

StatCell {
    id: root
    shortLabel: "G"
    longLabel: "gpu"
    known: false
    format: Config.gpuFormat
    kind: "mem"

    Process {
        id: proc
        // prints: percent usedMiB totalMiB
        command: ["sh", "-c", "if command -v nvidia-smi >/dev/null 2>&1; then nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits | head -n1 | tr -d ' ' | tr ',' ' '; else for d in /sys/class/drm/card*/device; do if [ -r \"$d/gpu_busy_percent\" ]; then echo \"$(cat $d/gpu_busy_percent) $(( $(cat $d/mem_info_vram_used 2>/dev/null || echo 0) / 1048576 )) $(( $(cat $d/mem_info_vram_total 2>/dev/null || echo 0) / 1048576 ))\"; break; fi; done; fi"]
        stdout: SplitParser {
            onRead: line => {
                const p = line.trim().split(/\s+/);
                const v = parseInt(p[0]);
                if (isNaN(v))
                    return;
                root.value = v;
                root.known = true;
                const u = parseFloat(p[1]);
                const t = parseFloat(p[2]);
                if (!isNaN(u) && !isNaN(t) && t > 0) {
                    root.used = u;
                    root.total = t;
                } else {
                    root.used = -1;
                    root.total = -1;
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
