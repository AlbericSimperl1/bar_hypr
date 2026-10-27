// SysStats.qml - polls cpu/ram/gpu/disk once for every screen and keeps a short history for the sysmon graphs
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int historyLen: 60

    component Stat: QtObject {
        property int value: 0
        property bool known: true
        property real used: -1
        property real total: -1
        property var hist: []
        function add(v) {
            value = v;
            const h = hist.concat([v]);
            if (h.length > root.historyLen)
                h.shift();
            hist = h;
        }
    }

    property Stat cpu: Stat {}
    property Stat ram: Stat {}
    property Stat gpu: Stat {
        known: false
    }
    property Stat disk: Stat {}

    // "mem" -> MiB, "cores" -> cores
    function usedTotal(kind, used, total) {
        if (kind === "cores")
            return used.toFixed(1) + "/" + Math.round(total);
        if (total >= 1024)
            return (used / 1024).toFixed(1) + "/" + (total / 1024).toFixed(1) + "G";
        return Math.round(used) + "/" + Math.round(total) + "M";
    }

    // ── cpu ──
    property real _prevTotal: -1
    property real _prevIdle: 0

    function _parseCpu(line) {
        const f = line.trim().split(/\s+/).slice(1, 9).map(Number);
        if (f.length < 5)
            return;
        const idle = f[3] + f[4];
        const tot = f.reduce((a, b) => a + b, 0);
        if (_prevTotal >= 0 && tot > _prevTotal) {
            cpu.add(Math.max(0, Math.min(100, Math.round(100 * (1 - (idle - _prevIdle) / (tot - _prevTotal))))));
            if (cpu.total > 0)
                cpu.used = cpu.value * cpu.total / 100;
        }
        _prevTotal = tot;
        _prevIdle = idle;
    }

    // "percent used total" lines (ram, gpu, disk) -> stat
    function _parseTriple(s, line) {
        const p = line.trim().split(/\s+/);
        const v = parseInt(p[0]);
        if (isNaN(v))
            return;
        s.add(v);
        s.known = true;
        const u = parseFloat(p[1]);
        const t = parseFloat(p[2]);
        const ok = !isNaN(u) && !isNaN(t) && t > 0;
        s.used = ok ? u : -1;
        s.total = ok ? t : -1;
    }

    // number of logical cores (the "available" side of used/total)
    Process {
        command: ["nproc"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                const v = parseInt(line);
                if (!isNaN(v) && v > 0)
                    root.cpu.total = v;
            }
        }
    }

    Process {
        id: cpuProc
        command: ["head", "-n", "1", "/proc/stat"]
        stdout: SplitParser {
            onRead: line => root._parseCpu(line)
        }
    }

    Process {
        id: ramProc
        // prints: percent usedMiB totalMiB
        command: ["awk", "/MemTotal/{t=$2}/MemAvailable/{a=$2}END{printf \"%d %d %d\\n\", (t-a)*100/t, (t-a)/1024, t/1024}", "/proc/meminfo"]
        stdout: SplitParser {
            onRead: line => root._parseTriple(root.ram, line)
        }
    }

    Process {
        id: gpuProc
        // NVIDIA via nvidia-smi, otherwise AMD sysfs (gpu_busy_percent + vram). prints: percent usedMiB totalMiB
        command: ["sh", "-c", "if command -v nvidia-smi >/dev/null 2>&1; then nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits | head -n1 | tr -d ' ' | tr ',' ' '; else for d in /sys/class/drm/card*/device; do if [ -r \"$d/gpu_busy_percent\" ]; then echo \"$(cat $d/gpu_busy_percent) $(( $(cat $d/mem_info_vram_used 2>/dev/null || echo 0) / 1048576 )) $(( $(cat $d/mem_info_vram_total 2>/dev/null || echo 0) / 1048576 ))\"; break; fi; done; fi"]
        stdout: SplitParser {
            onRead: line => root._parseTriple(root.gpu, line)
        }
    }

    Process {
        id: diskProc
        // root filesystem; header line is skipped by the NaN check. prints: percent% usedMiB sizeMiB
        command: ["df", "-m", "--output=pcent,used,size", "/"]
        stdout: SplitParser {
            onRead: line => root._parseTriple(root.disk, line)
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuProc.running = true;
            ramProc.running = true;
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: gpuProc.running = true
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: diskProc.running = true
    }
}
