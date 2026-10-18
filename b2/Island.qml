// Island.qml - optional background "pill" around one zone of widgets
import QtQuick

Rectangle {
    id: isl
    property string zone: "left"
    property real crossSize: 0      // bar thickness available across the bar (set by BarContent)
    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"
    readonly property bool filled: Config.islandsEnabled && inner.implicitWidth > 0 && inner.implicitHeight > 0
    readonly property real pad: filled ? Config.islandPadding : 0
    readonly property real across: Config.islandsEnabled ? Math.max(0, crossSize - 2 * Config.islandInset) : 0

    visible: Config.widgetsForZone(zone).length > 0

    implicitWidth: vertical ? (Config.islandsEnabled ? across : inner.implicitWidth) : inner.implicitWidth + 2 * pad
    implicitHeight: vertical ? inner.implicitHeight + 2 * pad : (Config.islandsEnabled ? across : inner.implicitHeight)
    width: implicitWidth
    height: implicitHeight

    radius: Config.islandRadius
    color: filled ? Config.islandColor : "transparent"

    Zone {
        id: inner
        zone: isl.zone
        anchors.centerIn: parent
    }
}
