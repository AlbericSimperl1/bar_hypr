// Zone.qml
import QtQuick
import QtQuick.Layouts

GridLayout {
    id: zoneRoot
    property string zone: "left"
    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"

    columns: vertical ? 1 : 64
    rowSpacing: Config.widgetSpacing
    columnSpacing: Config.widgetSpacing

    Repeater {
        model: Config.widgetsForZone(zoneRoot.zone)

        delegate: Loader {
            required property string modelData
            sourceComponent: WidgetRegistry.componentFor(modelData)
            Layout.alignment: zoneRoot.vertical ? Qt.AlignHCenter : Qt.AlignVCenter
            visible: !item || item.wantVisible === undefined || item.wantVisible
        }
    }
}
