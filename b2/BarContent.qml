// BarContent.qml
import QtQuick

Item {
    id: root
    readonly property bool vertical: Config.barPosition === "left" || Config.barPosition === "right"

    Zone {
        zone: "left"
        anchors.left: root.vertical ? undefined : root.left
        anchors.top: root.vertical ? root.top : undefined
        anchors.verticalCenter: root.vertical ? undefined : root.verticalCenter
        anchors.horizontalCenter: root.vertical ? root.horizontalCenter : undefined
    }

    Zone {
        zone: "center"
        anchors.centerIn: parent
    }

    Zone {
        zone: "right"
        anchors.right: root.vertical ? undefined : root.right
        anchors.bottom: root.vertical ? root.bottom : undefined
        anchors.verticalCenter: root.vertical ? undefined : root.verticalCenter
        anchors.horizontalCenter: root.vertical ? root.horizontalCenter : undefined
    }
}
