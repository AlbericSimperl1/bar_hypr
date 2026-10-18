// Spacer.qml - empty gap widget; width/height comes from Config.spacerSizes[widgetName]
import QtQuick

Item {
    id: root
    property string widgetName: ""
    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"
    readonly property real size: Config.spacerSize(widgetName)

    implicitWidth: vertical ? 1 : size
    implicitHeight: vertical ? size : 1
}
