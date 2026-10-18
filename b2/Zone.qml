// Zone.qml
import QtQuick
import QtQuick.Layouts

GridLayout {
    id: zoneRoot
    property string zone: "left"
    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"
    readonly property int n: Math.max(1, rep.count)

    flow: vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
    rows: vertical ? n : 1
    columns: vertical ? 1 : n
    rowSpacing: Config.widgetSpacing
    columnSpacing: Config.widgetSpacing

    Repeater {
        id: rep
        model: Config.widgetsForZone(zoneRoot.zone)

        delegate: Loader {
            required property string modelData
            sourceComponent: WidgetRegistry.componentFor(modelData)
            onLoaded: {
                if (item && item.widgetName !== undefined)
                    item.widgetName = modelData;
            }
            Layout.alignment: zoneRoot.vertical ? Qt.AlignHCenter : Qt.AlignVCenter
            visible: !item || item.wantVisible === undefined || item.wantVisible
        }
    }
}
