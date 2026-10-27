// RamWidget.qml
import QtQuick

StatCell {
    stat: SysStats.ram
    shortLabel: "R"
    longLabel: "ram"
    format: Config.ramFormat
    kind: "mem"
}
