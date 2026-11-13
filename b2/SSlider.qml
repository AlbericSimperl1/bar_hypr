import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

// Slider with drag + keyboard + typed value.
//  - drag / click the track
//  - track focused: arrows = +-step, Shift+arrows / PageUp / PageDown = +-10*step, Home / End = min / max
//  - type a number in the field, Enter (or leaving the field) applies it
RowLayout {
    id: sr
    property string label
    property real from: 0
    property real to: 100
    property real value: 50
    property real step: 1
    property string suffix: ""
    signal moved(real v)
    readonly property bool tuiStop: true
    readonly property string hint: "edit"
    function adjust(d) {
        nudge(d * step);
    }
    function activate() {
        fld.forceActiveFocus();
        fld.selectAll();
    }
    Layout.fillWidth: true
    Layout.leftMargin: 8
    Layout.preferredHeight: Tui.lineH
    spacing: 8
    activeFocusOnTab: true

    function clamp(v) {
        return Math.max(sr.from, Math.min(sr.to, v));
    }
    function nudge(d) {
        sr.moved(sr.clamp(Math.round(sr.value) + d));
    }

    Keys.onPressed: event => {
        const big = (event.modifiers & Qt.ShiftModifier) ? 10 : 1;
        switch (event.key) {
        case Qt.Key_Left:
        case Qt.Key_Down:
            sr.nudge(-sr.step * big);
            break;
        case Qt.Key_Right:
        case Qt.Key_Up:
            sr.nudge(sr.step * big);
            break;
        case Qt.Key_PageDown:
            sr.nudge(-sr.step * 10);
            break;
        case Qt.Key_PageUp:
            sr.nudge(sr.step * 10);
            break;
        case Qt.Key_Home:
            sr.moved(sr.from);
            break;
        case Qt.Key_End:
            sr.moved(sr.to);
            break;
        default:
            event.accepted = false;
            return;
        }
        event.accepted = true;
    }

    SLbl {
        text: sr.label
        selected: Tui.isCursor(sr)
    }

    TuiMeter {
        from: sr.from
        to: sr.to
        value: sr.value
        onTouched: sr.forceActiveFocus()
        onMoved: v => sr.moved(v)
    }

    TextField {
        id: fld
        Layout.preferredWidth: 56
        Layout.preferredHeight: Tui.lineH
        horizontalAlignment: Text.AlignRight
        color: Tui.text
        font.family: Tui.family
        font.pixelSize: Tui.size
        selectByMouse: true
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        validator: RegularExpressionValidator {
            regularExpression: /^\d{0,5}$/
        }
        leftPadding: 4
        rightPadding: 4
        topPadding: 2
        bottomPadding: 2
        background: Rectangle {
            color: fld.activeFocus ? "#18ffffff" : "transparent"
        }

        function sync() {
            fld.text = String(Math.round(sr.value));
        }
        function commit() {
            if (fld.text === "")
                return;
            const v = parseInt(fld.text, 10);
            if (!isNaN(v))
                sr.moved(sr.clamp(v));
        }

        Component.onCompleted: sync()
        onEditingFinished: {
            commit();
            sync();
        }
        onActiveFocusChanged: if (!activeFocus)
            sync()
        Keys.onUpPressed: {
            sr.nudge(sr.step);
            sync();
        }
        Keys.onDownPressed: {
            sr.nudge(-sr.step);
            sync();
        }
        Keys.onEscapePressed: {
            sync();
            sr.forceActiveFocus();
        }

        Connections {
            target: sr
            function onValueChanged() {
                if (!fld.activeFocus)
                    fld.sync();
            }
        }
    }

    Text {
        visible: sr.suffix !== ""
        text: sr.suffix
        color: Tui.dim
        font.family: Tui.family
        font.pixelSize: Tui.statusSize
        Layout.preferredWidth: 20
    }
}
