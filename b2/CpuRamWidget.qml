// CpuRamWidget.qml
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    implicitWidth:  flow.implicitWidth
    implicitHeight: flow.implicitHeight

    property real cpu: 0
    property real ram: 0

    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"

    // read /proc/stat once a second
    Process {
        id: cpuProc
        command: ["bash", "-c", "read -r _ u n s i w x _ < /proc/stat; echo $u $n $s $i $w $x"]
        stdout: SplitParser { onRead: line => { /* handled in js */ } }
    }

    // Simpler: use a script that computes deltas for us
    Process {
        id: proc
        command: ["bash", "-c",
            "awk '/^cpu /{u=$2;n=$3;s=$4;i=$5;w=$6;x=$7}END{print u+n+s+i+w+x}' /proc/stat; " +
            "awk '/MemTotal/{t=$2}/MemAvailable/{a=$2}END{print (t-a)/t*100}' /proc/meminfo"]
        stdout: SplitParser {
            property var lines: []
            onRead: line => {
                lines.push(line);
                if (lines.length >= 2) {
                    const total = parseFloat(lines[0]);
                    if (!isNaN(total)) {
                        if (root._last !== undefined) {
                            root.cpu = Math.max(0, Math.min(100, 100 * (total - root._last) / 200));
                        }
                        root._last = total;
                    }
                    const ramPct = parseFloat(lines[1]);
                    if (!isNaN(ramPct)) root.ram = ramPct;
                    lines = [];
                }
            }
        }
        running: true
    }

    property real _last: undefined

    Timer { interval: 2000; running: true; repeat: true; onTriggered: proc.running = true }

    Flow {
        id: flow
        flow: root.vertical ? Flow.TopToBottom : Flow.LeftToRight
        spacing: 6

        Text {
            text: "󰍛 " + Math.round(root.cpu) + "%"
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: 15
        }
        Text {
            text: "󰘚 " + Math.round(root.ram) + "%"
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: 15
        }
    }
}