// TuiBars.qml - signaalsterkte als ▂▄▆█
import QtQuick

Row {
    id: bars
    property int pct: 0
    property bool selected: false
    readonly property int lit: Math.max(1, Math.min(4, Math.ceil(pct / 25)))

    Text {
        text: "▂▄▆█".slice(0, bars.lit)
        color: bars.selected ? Tui.selText : Tui.dim
        font.family: Tui.family
        font.pixelSize: Tui.size
    }
    Text {
        text: "▂▄▆█".slice(bars.lit)
        color: bars.selected ? "#a4a5a8" : "#6f7074"
        font.family: Tui.family
        font.pixelSize: Tui.size
    }
}
