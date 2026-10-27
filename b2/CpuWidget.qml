// CpuWidget.qml
import QtQuick

StatCell {
    stat: SysStats.cpu
    shortLabel: "C"
    longLabel: "cpu"
    format: Config.cpuFormat
    kind: "cores"
}
