// StatCell.qml - label + value.
// Horizontal: "cpu 12%" / "ram 5.2/31.2G" / "ram 18% 5.2/31.2G"   Vertical: "C" over "12" (two lines for used/total)
// Values come from a SysStats stat; clicking opens the shared sysmon panel.
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property string shortLabel: "C"
    property string longLabel: "cpu"
    required property var stat
    readonly property int value: stat.value
    readonly property bool known: stat.known

    // percent | used | usedTotal | both
    property string format: "percent"
    // "mem" -> used/total in MiB, "cores" -> used/total in cores
    property string kind: "mem"
    readonly property real used: stat.used
    readonly property real total: stat.total

    readonly property bool hasDetail: used >= 0 && total > 0

    function _mem(v) {
        return v >= 1024 ? (v / 1024).toFixed(1) + "G" : Math.round(v) + "M";
    }

    readonly property string usedText: kind === "cores" ? used.toFixed(1) : _mem(used)
    readonly property string totalText: kind === "cores" ? String(Math.round(total)) : _mem(total)
    readonly property string utText: SysStats.usedTotal(kind, used, total)

    readonly property string display: {
        if (!hasDetail || format === "percent")
            return String(value).padStart(2, " ") + "%";
        if (format === "used")
            return usedText;
        if (format === "usedTotal")
            return utText;
        return value + "% " + utText;
    }
    readonly property string displayV: {
        if (!hasDetail || format === "percent")
            return String(value);
        if (format === "used")
            return usedText;
        if (format === "usedTotal")
            return usedText + "\n" + totalText;
        return value + "\n" + usedText;
    }

    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"
    readonly property color dim: Qt.rgba(Config.fgColor.r, Config.fgColor.g, Config.fgColor.b, 0.6)
    readonly property int fs: Math.round((vertical ? 12 : 15) * Config.fontScale)

    implicitWidth: grid.implicitWidth
    implicitHeight: vertical ? grid.implicitHeight : Math.max(24, grid.implicitHeight)

    GridLayout {
        id: grid
        anchors.centerIn: parent
        columns: root.vertical ? 1 : 2
        rowSpacing: 0
        columnSpacing: 6

        Text {
            text: root.vertical ? root.shortLabel : root.longLabel
            color: root.dim
            font.family: Config.fontFamily
            font.pixelSize: root.fs
            Layout.alignment: Qt.AlignCenter
        }
        Text {
            text: !root.known ? "-" : (root.vertical ? root.displayV : root.display)
            color: Config.fgColor
            font.family: Config.fontFamily
            font.pixelSize: root.fs
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -3
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            const p = root.mapToItem(null, root.width / 2, root.height / 2);
            BarState.toggle("sysmon", p.x, p.y);
        }
    }
}
