// BarContent.qml
import QtQuick

Item {
    id: root
    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"
    readonly property real cross: vertical ? width : height

    Island {
        zone: "left"
        crossSize: root.cross
        anchors.left: root.vertical ? undefined : root.left
        anchors.top: root.vertical ? root.top : undefined
        anchors.verticalCenter: root.vertical ? undefined : root.verticalCenter
        anchors.horizontalCenter: root.vertical ? root.horizontalCenter : undefined
    }

    Island {
        zone: "center"
        crossSize: root.cross
        anchors.centerIn: parent
    }

    Island {
        zone: "right"
        crossSize: root.cross
        anchors.right: root.vertical ? undefined : root.right
        anchors.bottom: root.vertical ? root.bottom : undefined
        anchors.verticalCenter: root.vertical ? undefined : root.verticalCenter
        anchors.horizontalCenter: root.vertical ? root.horizontalCenter : undefined
    }
}
