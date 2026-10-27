// GpuWidget.qml
import QtQuick

StatCell {
    stat: SysStats.gpu
    shortLabel: "G"
    longLabel: "gpu"
    format: Config.gpuFormat
    kind: "mem"
}
