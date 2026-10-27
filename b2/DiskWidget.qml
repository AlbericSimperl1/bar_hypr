// DiskWidget.qml - root filesystem
import QtQuick

StatCell {
    stat: SysStats.disk
    shortLabel: "D"
    longLabel: "disk"
    format: Config.diskFormat
    kind: "mem"
}
