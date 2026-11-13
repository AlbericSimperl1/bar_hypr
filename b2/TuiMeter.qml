// TuiMeter.qml - meter uit blokjes op de breedte van een letter: slepen, klikken en optioneel scrollen
import QtQuick
import QtQuick.Layouts

Item {
    id: meter

    property real from: 0
    property real to: 100
    property real value: 0
    property real tick: -1        // streepje op deze waarde, bv. 100% bij volume tot 150%
    property string label
    property bool muted: false
    property bool interactive: true
    property real wheelStep: 0    // 0: scrollen gaat door naar de lijst eromheen

    signal moved(real v)
    signal touched

    readonly property bool tuiStop: interactive
    readonly property string hint: ""
    function adjust(d) {
        const step = wheelStep > 0 ? wheelStep : (to - from) / 20;
        moved(Math.max(from, Math.min(to, value + d * step)));
    }
    function activate() {
    }

    readonly property real fraction: to > from ? Math.max(0, Math.min(1, (value - from) / (to - from))) : 0

    Layout.fillWidth: true
    implicitHeight: Tui.lineH

    Text {
        id: labelText
        visible: meter.label !== ""
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        text: meter.label
        color: Tui.dim
        font.family: Tui.family
        font.pixelSize: Tui.size
    }

    Canvas {
        id: bar
        anchors.left: parent.left
        anchors.right: labelText.visible ? labelText.left : parent.right
        anchors.rightMargin: labelText.visible ? 12 : 0
        anchors.verticalCenter: parent.verticalCenter
        height: Tui.meterH

        readonly property int cell: 9

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const n = Math.floor(width / cell);
            let lit = Math.round(meter.fraction * n);
            if (meter.fraction > 0 && lit === 0)
                lit = 1;
            for (let i = 0; i < n; i++) {
                ctx.fillStyle = i < lit ? (meter.muted ? Tui.dim : Tui.text) : Tui.rest;
                ctx.fillRect(i * cell, 0, cell - 1, height);
            }
            if (meter.tick >= meter.from) {
                ctx.fillStyle = Tui.text;
                ctx.fillRect(Math.round((meter.tick - meter.from) / (meter.to - meter.from) * n) * cell - 1, 0, 1, height);
            }
        }
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onAvailableChanged: requestPaint()
        Connections {
            target: meter
            function onFractionChanged() {
                bar.requestPaint();
            }
            function onMutedChanged() {
                bar.requestPaint();
            }
        }
    }

    Rectangle {
        visible: Tui.isCursor(meter)
        anchors.fill: bar
        anchors.margins: -3
        color: "transparent"
        border.color: Tui.selBg
    }

    MouseArea {
        anchors.left: bar.left
        anchors.right: bar.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        enabled: meter.interactive
        preventStealing: true
        cursorShape: Qt.PointingHandCursor

        function apply(x) {
            meter.moved(meter.from + (meter.to - meter.from) * Math.max(0, Math.min(1, x / width)));
        }
        onPressed: m => {
            meter.touched();
            apply(m.x);
        }
        onPositionChanged: m => {
            if (pressed)
                apply(m.x);
        }
        onWheel: w => {
            if (meter.wheelStep > 0)
                meter.moved(Math.max(meter.from, Math.min(meter.to, meter.value + (w.angleDelta.y > 0 ? meter.wheelStep : -meter.wheelStep))));
            else
                w.accepted = false;
        }
    }
}
