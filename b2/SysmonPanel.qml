// SysmonPanel.qml - one row per system monitor: label, current value and a sparkline of recent samples
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property color fgColor: "#fff7e5"
    property color accentColor: "#ebd9b9"
    property color dimColor: Qt.rgba(fgColor.r, fgColor.g, fgColor.b, 0.6)
    property string fontFamily: "mononoki"

    readonly property real neededHeight: col.implicitHeight + 32

    ColumnLayout {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 16
        spacing: 14

        Repeater {
            model: [
                {
                    label: "cpu",
                    stat: SysStats.cpu,
                    kind: "cores"
                },
                {
                    label: "ram",
                    stat: SysStats.ram,
                    kind: "mem"
                },
                {
                    label: "gpu",
                    stat: SysStats.gpu,
                    kind: "mem"
                },
                {
                    label: "disk",
                    stat: SysStats.disk,
                    kind: "mem",
                    bar: true
                }
            ]

            delegate: ColumnLayout {
                id: row
                required property var modelData
                readonly property var stat: modelData.stat

                visible: stat.known
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: row.modelData.label
                        color: root.dimColor
                        font.family: root.fontFamily
                        font.pixelSize: 14
                        Layout.fillWidth: true
                    }
                    Text {
                        visible: row.stat.used >= 0 && row.stat.total > 0
                        text: SysStats.usedTotal(row.modelData.kind, row.stat.used, row.stat.total)
                        color: root.dimColor
                        font.family: root.fontFamily
                        font.pixelSize: 14
                    }
                    Text {
                        text: row.stat.value + "%"
                        color: root.fgColor
                        font.family: root.fontFamily
                        font.pixelSize: 15
                        font.bold: true
                    }
                }

                // disk barely moves, so it gets a fill bar instead of a graph
                Rectangle {
                    visible: row.modelData.bar === true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 6
                    color: "#10ffffff"
                    radius: 3

                    Rectangle {
                        width: parent.width * row.stat.value / 100
                        height: parent.height
                        radius: 3
                        color: root.accentColor
                    }
                }

                Rectangle {
                    visible: row.modelData.bar !== true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    color: "#10ffffff"
                    radius: 3

                    Canvas {
                        id: graph
                        anchors.fill: parent
                        readonly property var hist: row.stat.hist
                        onHistChanged: requestPaint()
                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()

                        onPaint: {
                            const ctx = getContext("2d");
                            ctx.reset();
                            const h = hist;
                            if (h.length < 2)
                                return;
                            // fixed time scale: newest sample sits at the right edge, history grows in from the left
                            const step = width / (SysStats.historyLen - 1);
                            const x0 = width - (h.length - 1) * step;
                            const y = v => height - 1 - v / 100 * (height - 2);

                            ctx.beginPath();
                            ctx.moveTo(x0, y(h[0]));
                            for (let i = 1; i < h.length; i++)
                                ctx.lineTo(x0 + i * step, y(h[i]));
                            ctx.strokeStyle = root.accentColor;
                            ctx.lineWidth = 1.5;
                            ctx.stroke();

                            ctx.lineTo(width, height);
                            ctx.lineTo(x0, height);
                            ctx.closePath();
                            ctx.globalAlpha = 0.18;
                            ctx.fillStyle = root.accentColor;
                            ctx.fill();
                        }
                    }
                }
            }
        }
    }
}
