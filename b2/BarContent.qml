// BarContent.qml
import QtQuick

Item {
    id: root
    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"
    readonly property real cross: vertical ? width : height

    Island {
        zone: "left"
        crossSize: root.cross
    }

    Island {
        zone: "center"
        crossSize: root.cross
    }

    Island {
        zone: "right"
        crossSize: root.cross
    }
}
