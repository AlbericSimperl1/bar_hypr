// bar/horizontaal/NotificationPanel.qml
import QtQuick
import QtQuick.Layouts

TuiPanel {
    id: root

    mode: "notif"
    total: items.length

    property string tab: "all"
    readonly property var tabs: [
        {
            key: "all",
            label: "all"
        },
        {
            key: "today",
            label: "today"
        },
        {
            key: "yesterday",
            label: "yesterday"
        },
        {
            key: "older",
            label: "older"
        }
    ]

    readonly property var items: {
        const ref = Notifications.now;
        const all = Notifications.history;
        if (root.tab === "all")
            return all;
        const out = [];
        for (let i = 0; i < all.length; i++)
            if (Notifications.bucketOf(all[i].time, ref) === root.tab)
                out.push(all[i]);
        return out;
    }

    header: TuiTabs {
        model: root.tabs
        current: root.tab
        onPicked: key => root.tab = key
    }

    buttons: [
        TuiAction {
            key: "d"
            text: Notifications.dndEnabled ? "[x] dnd" : "[ ] dnd"
            font.pixelSize: Tui.statusSize
            onClicked: Notifications.toggleDnd()
        },
        TuiAction {
            visible: root.items.length > 0
            key: "c"
            text: "clear all"
            font.pixelSize: Tui.statusSize
            onClicked: Notifications.clearAll()
        }
    ]

    TuiPane {
        title: "notifications"

        TuiLine {
            visible: root.items.length === 0
            numbered: false
            selectable: false
            text: "no notifications"
            textColor: Tui.dim
        }

        Repeater {
            model: root.items

            delegate: Item {
                id: card
                required property var modelData
                required property int index
                readonly property var n: modelData
                readonly property string number: String(index + 1)
                readonly property bool tuiStop: true
                readonly property bool expanded: Notifications.expandedKey === n.key
                readonly property bool selected: visible && (Tui.keys ? Tui.cursor === card : cardHover.hovered)
                readonly property string hint: expanded ? "collapse" : "expand"

                Layout.fillWidth: true
                implicitHeight: cardRow.implicitHeight

                onSelectedChanged: {
                    if (selected)
                        Tui.cursor = card;
                    else if (Tui.cursor === card && !Tui.keys)
                        Tui.cursor = null;
                }

                function rowActions() {
                    return Tui.actionsIn([cardActions]);
                }
                function activate() {
                    Notifications.toggleExpand(n.key);
                }

                Rectangle {
                    anchors.fill: parent
                    visible: card.selected
                    color: Tui.selBg
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton)
                            Notifications.invokeDefault(card.n.key);
                        else
                            Notifications.toggleExpand(card.n.key);
                    }
                }

                HoverHandler {
                    id: cardHover
                    cursorShape: Qt.PointingHandCursor
                }

                RowLayout {
                    id: cardRow
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.rightMargin: 6
                    spacing: 12

                    Text {
                        Layout.preferredWidth: 28
                        Layout.alignment: Qt.AlignTop
                        horizontalAlignment: Text.AlignRight
                        text: card.number
                        color: card.selected ? Tui.selText : Tui.dim
                        font.family: Tui.family
                        font.pixelSize: Tui.size
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Text {
                                Layout.fillWidth: true
                                text: card.n.summary
                                color: card.selected ? Tui.selText : (card.n.urgency === 2 ? Tui.danger : Tui.text)
                                font.family: Tui.family
                                font.pixelSize: Tui.size
                                font.bold: card.selected
                                wrapMode: Text.Wrap
                                maximumLineCount: card.expanded ? 20 : 2
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.alignment: Qt.AlignTop
                                text: Notifications.timeAgo(card.n.time, Notifications.now)
                                color: card.selected ? Tui.selText : Tui.dim
                                font.family: Tui.family
                                font.pixelSize: Tui.size
                            }
                        }

                        Text {
                            visible: card.n.body !== ""
                            Layout.fillWidth: true
                            text: card.n.body
                            color: card.selected ? Tui.selText : Tui.text
                            font.family: Tui.family
                            font.pixelSize: Tui.size
                            wrapMode: Text.Wrap
                            maximumLineCount: card.expanded ? 1000 : 3
                            elide: Text.ElideRight
                        }

                        RowLayout {
                            id: cardActions
                            Layout.fillWidth: true
                            Layout.preferredHeight: Tui.lineH
                            spacing: 12

                            Text {
                                Layout.fillWidth: true
                                text: card.n.appName
                                elide: Text.ElideRight
                                color: card.selected ? Tui.selText : Tui.dim
                                font.family: Tui.family
                                font.pixelSize: Tui.size
                            }
                            Repeater {
                                model: card.selected && card.n.actions ? card.n.actions : []
                                delegate: TuiAction {
                                    required property var modelData
                                    visible: modelData.text !== ""
                                    text: modelData.text
                                    onClicked: Notifications.invoke(card.n.key, modelData.identifier)
                                }
                            }
                            TuiAction {
                                visible: card.selected
                                text: "dismiss"
                                onClicked: Notifications.remove(card.n.key)
                            }
                        }
                    }
                }
            }
        }
    }
}
