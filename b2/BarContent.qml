// BarContent.qml
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitHeight: Config.barHeight

    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"

    Loader {
        anchors.fill: parent
        sourceComponent: root.vertical ? columnComp : rowComp
    }

    Component {
        id: rowComp
        RowLayout {
            spacing: 18
            Layout.alignment: Qt.AlignVCenter

            Zone { zone: "left"; horizontal: true }
            Item { Layout.fillWidth: true }
            Zone { zone: "center"; horizontal: true }
            Item { Layout.fillWidth: true }
            Zone { zone: "right"; horizontal: true }
        }
    }

    Component {
        id: columnComp
        ColumnLayout {
            spacing: 12
            Layout.alignment: Qt.AlignHCenter

            Zone { zone: "left"; horizontal: false }
            Item { Layout.fillHeight: true }
            Zone { zone: "center"; horizontal: false }
            Item { Layout.fillHeight: true }
            Zone { zone: "right"; horizontal: false }
        }
    }

    // ─── Zone: a Flow of widgets for a given zone ─────────
    component Zone: Item {
        id: zoneItem
        property string zone
        property bool horizontal: true
        implicitWidth:  flow.implicitWidth
        implicitHeight: flow.implicitHeight

        Flow {
            id: flow
            flow: zoneItem.horizontal ? Flow.LeftToRight : Flow.TopToBottom
            spacing: 14

            Repeater {
                model: Config.widgetsForZone(zoneItem.zone)
                delegate: Loader {
                    id: widgetLoader
                    required property string modelData
                    sourceComponent: WidgetRegistry.componentFor(modelData)
                    onLoaded: {
                        if (item) {
                            item.Layout.alignment = Qt.AlignVCenter;
                        }
                    }
                }
            }
        }
    }
}