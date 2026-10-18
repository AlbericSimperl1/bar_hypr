// Island.qml - optional background "pill" around one zone of widgets.
// Positioned with explicit x/y (no anchors) so switching bar orientation at runtime is reliable.
import QtQuick

Rectangle {
    id: isl
    property string zone: "left"
    property real crossSize: 0      // bar thickness available across the bar (set by BarContent)
    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"
    readonly property bool filled: Config.islandsEnabled && inner.implicitWidth > 0 && inner.implicitHeight > 0
    readonly property real pad: filled ? Config.islandPadding : 0
    readonly property real across: Config.islandsEnabled ? Math.max(0, crossSize - 2 * Config.islandInset) : 0

    readonly property real pw: parent ? parent.width : 0
    readonly property real ph: parent ? parent.height : 0

    visible: Config.widgetsForZone(zone).length > 0

    implicitWidth: vertical ? (Config.islandsEnabled ? across : inner.implicitWidth) : inner.implicitWidth + 2 * pad
    implicitHeight: vertical ? inner.implicitHeight + 2 * pad : (Config.islandsEnabled ? across : inner.implicitHeight)
    width: implicitWidth
    height: implicitHeight

    // left = start of bar (left / top), center = middle, right = end of bar (right / bottom)
    x: Math.round(vertical ? (pw - width) / 2 : (zone === "left" ? 0 : (zone === "right" ? pw - width : (pw - width) / 2)))
    y: Math.round(vertical ? (zone === "left" ? 0 : (zone === "right" ? ph - height : (ph - height) / 2)) : (ph - height) / 2)

    radius: Config.islandRadius
    color: filled ? Config.islandColor : "transparent"

    Zone {
        id: inner
        zone: isl.zone
        x: Math.round(isl.vertical ? (isl.width - implicitWidth) / 2 : isl.pad)
        y: Math.round(isl.vertical ? isl.pad : (isl.height - implicitHeight) / 2)
    }
}
