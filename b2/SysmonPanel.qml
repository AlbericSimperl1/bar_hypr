// SysmonPanel.qml - one pane per system monitor: usage, current value and a graph of recent samples
import QtQuick
import QtQuick.Layouts

TuiPanel {
    id: root

    mode: "sys"

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

        delegate: TuiPane {
            id: row
            required property var modelData
            readonly property var stat: modelData.stat

            visible: stat.known
            title: modelData.label

            TuiLine {
                numbered: false
                selectable: false
                text: row.stat.used >= 0 && row.stat.total > 0 ? SysStats.usedTotal(row.modelData.kind, row.stat.used, row.stat.total) : ""
                textColor: Tui.dim
                detail: row.stat.value + "%"
                detailColor: Tui.text
            }

            // disk barely moves, so it gets a meter instead of a graph
            TuiMeter {
                visible: row.modelData.bar === true
                Layout.leftMargin: 8
                Layout.rightMargin: 6
                interactive: false
                value: row.stat.value
            }

            Rectangle {
                visible: row.modelData.bar !== true
                Layout.fillWidth: true
                Layout.leftMargin: 8
                Layout.rightMargin: 6
                Layout.preferredHeight: 36
                color: "#10ffffff"

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
                        ctx.strokeStyle = Tui.accent;
                        ctx.lineWidth = 1.5;
                        ctx.stroke();

                        ctx.lineTo(width, height);
                        ctx.lineTo(x0, height);
                        ctx.closePath();
                        ctx.globalAlpha = 0.18;
                        ctx.fillStyle = Tui.accent;
                        ctx.fill();
                    }
                }
            }
        }
    }
}
