// Border.qml - rounded border drawn only on the listed sides, optionally with a gap cut out of one side
import QtQuick

Item {
    id: root
    property var sides: ["top", "bottom", "left", "right"]
    property real radius: 0
    property real borderWidth: Config.borderWidth
    property color borderColor: Config.borderColor
    // gap in one side, from/to measured along that side in local coords (used where an attached panel joins)
    property string cutSide: ""
    property real cutFrom: 0
    property real cutTo: 0

    function has(s) {
        return sides.indexOf(s) >= 0;
    }

    // clip windows [x, y, w, h]; the cut is the strip of cutSide between cutFrom and cutTo left uncovered
    readonly property var regions: {
        const W = width, H = height, b = borderWidth;
        const a = Math.max(0, cutFrom), z = Math.min(cutSide === "left" || cutSide === "right" ? H : W, cutTo);
        if (!cutSide || z <= a)
            return [[0, 0, W, H]];
        switch (cutSide) {
        case "bottom":
            return [[0, 0, a, H], [z, 0, W - z, H], [a, 0, z - a, H - b]];
        case "top":
            return [[0, 0, a, H], [z, 0, W - z, H], [a, b, z - a, H - b]];
        case "right":
            return [[0, 0, W, a], [0, z, W, H - z], [0, a, W - b, z - a]];
        default:
            return [[0, 0, W, a], [0, z, W, H - z], [b, a, W - b, z - a]];
        }
    }

    Repeater {
        model: root.regions
        delegate: Item {
            required property var modelData
            x: modelData[0]
            y: modelData[1]
            width: modelData[2]
            height: modelData[3]
            clip: true

            // hidden sides are pushed just outside the clip, keeping the corner arcs of the visible ones
            Rectangle {
                readonly property real b: root.borderWidth
                x: -parent.x - (root.has("left") ? 0 : b)
                y: -parent.y - (root.has("top") ? 0 : b)
                width: root.width + (root.has("left") ? 0 : b) + (root.has("right") ? 0 : b)
                height: root.height + (root.has("top") ? 0 : b) + (root.has("bottom") ? 0 : b)
                color: "transparent"
                radius: root.radius
                border.color: root.borderColor
                border.width: b
            }
        }
    }
}
