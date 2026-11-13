// TuiPanel.qml - opbouw van een panel: vaste kop (optioneel), scrollbare panes en de statusregel
import QtQuick
import QtQuick.Layouts

Item {
    id: panel

    property string mode
    property string hint          // vaste tekst voor de toetsen in de statusregel
    property int total: 0         // aantal genummerde regels; 0 verbergt de positie
    default property alias content: body.data
    property alias header: head.data
    property alias buttons: btns.data
    signal escaped                // esc in een invoerveld

    readonly property Item focused: Window.activeFocusItem
    readonly property bool typing: focused !== null && focused !== panel && focused !== Window.contentItem

    onVisibleChanged: {
        Tui.reset();
        if (visible)
            forceActiveFocus();
    }

    Keys.onPressed: event => {
        const k = event.key;
        const confirm = k === Qt.Key_Return || k === Qt.Key_Enter;
        event.accepted = true;
        if (!panel.activeFocus) {
            // een veld heeft de focus: pijltjes en typen blijven daar, enter en esc gaan eruit
            event.accepted = confirm || k === Qt.Key_Escape;
            if (event.accepted)
                panel.forceActiveFocus();
            if (k === Qt.Key_Escape)
                panel.escaped();
        } else if (k === Qt.Key_Down || k === Qt.Key_Up) {
            Tui.step(panel, k === Qt.Key_Down ? 1 : -1);
            panel.reveal();
        } else if (k === Qt.Key_Left || k === Qt.Key_Right) {
            Tui.sideways(panel, k === Qt.Key_Right ? 1 : -1);
            panel.reveal();
        } else if (confirm) {
            Tui.enter();
        } else if (k === Qt.Key_Escape) {
            BarState.close();
        } else {
            const hit = event.modifiers === Qt.NoModifier && Array.from(btns.children).find(b => b.key && b.key === event.text && b.visible && b.enabled);
            event.accepted = !!hit;
            if (hit)
                hit.activate();
        }
    }

    // tabs boven de lijst scrollen zo naar boven, knoppen eronder naar beneden
    function reveal() {
        const c = Tui.current;
        if (!c)
            return;
        const y = c.mapToItem(flick.contentItem, 0, 0).y;
        const fit = Math.min(y, Math.max(flick.contentY, y + c.height - flick.height));
        flick.contentY = Math.max(0, Math.min(fit, flick.contentHeight - flick.height));
    }

    // scrollen schuift regels onder een stilstaande muis door: alleen echte beweging telt
    HoverHandler {
        property real lastX: -1
        property real lastY: -1
        onPointChanged: {
            const p = point.scenePosition;
            if (lastX >= 0 && (p.x !== lastX || p.y !== lastY))
                Tui.keys = false;
            lastX = p.x;
            lastY = p.y;
        }
    }

    readonly property real neededHeight: (head.visible ? head.implicitHeight + main.spacing : 0) + body.implicitHeight + main.spacing + status.Layout.topMargin + Tui.lineH

    ColumnLayout {
        id: main
        anchors.fill: parent
        spacing: 4

        ColumnLayout {
            id: head
            visible: children.length > 0
            Layout.fillWidth: true
            spacing: 0
        }

        Flickable {
            id: flick
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: width
            contentHeight: body.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: body
                width: flick.width
                spacing: 4
            }

            Rectangle {
                visible: flick.contentHeight > flick.height + 1
                parent: flick
                x: flick.width - 3
                y: flick.visibleArea.yPosition * flick.height
                width: 3
                height: Math.max(24, flick.visibleArea.heightRatio * flick.height)
                color: Tui.rule
            }
        }

        Rectangle {
            id: status
            Layout.fillWidth: true
            Layout.preferredHeight: Tui.lineH
            Layout.topMargin: 2
            color: Tui.accent

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    Layout.fillHeight: true
                    implicitWidth: modeText.implicitWidth + 20
                    color: Tui.modeBg

                    Text {
                        id: modeText
                        anchors.centerIn: parent
                        text: panel.mode
                        color: Tui.accent
                        font.family: Tui.family
                        font.pixelSize: Tui.statusSize
                        font.bold: true
                    }
                }

                Text {
                    Layout.leftMargin: 10
                    Layout.fillWidth: true
                    textFormat: Text.StyledText
                    text: (panel.hint ? panel.hint + "  " : "") + Tui.keyHints(panel.typing)
                    elide: Text.ElideRight
                    color: Tui.statusText
                    font.family: Tui.family
                    font.pixelSize: Tui.statusSize
                }

                RowLayout {
                    id: btns
                    Layout.leftMargin: 12
                    Layout.rightMargin: 10
                    spacing: 12
                }

                Text {
                    visible: panel.total > 0
                    Layout.rightMargin: 10
                    text: ((Tui.current && Tui.current.number) || "-") + "/" + panel.total
                    color: Tui.statusText
                    font.family: Tui.family
                    font.pixelSize: Tui.statusSize
                    font.bold: true
                }
            }
        }
    }
}
