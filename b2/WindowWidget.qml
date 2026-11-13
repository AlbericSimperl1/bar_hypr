// WindowWidget.qml - app icon + title of the focused window; vertical bar: icon only
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets

Row {
    id: root
    spacing: 6
    visible: win !== null

    readonly property var win: Hyprland.activeToplevel
    readonly property string appId: win ? (win.wayland ? win.wayland.appId : (win.lastIpcObject.class || "")) : ""
    readonly property var entry: appId ? DesktopEntries.heuristicLookup(appId) : null
    readonly property int px: Config.fontPx("window", 17)
    readonly property string appName: entry ? entry.name : appId
    // drop a trailing " - Discord" / " — Mozilla Firefox" so the app name isn't shown twice
    readonly property string shortTitle: {
        const t = win ? win.title : "";
        if (!appName) return t;
        const n = appName.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
        return t.replace(new RegExp("\\s+[-—|]\\s+[^-—|]*" + n + "[^-—|]*$", "i"), "");
    }

    // IconImage {
    //     anchors.verticalCenter: parent.verticalCenter
    //     implicitSize: Config.iconPx("window", 18)
    //     source: Quickshell.iconPath(root.entry ? root.entry.icon : root.appId, "application-x-executable")
    // }

    Text {
        visible: !Config.vertical
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, root.px * 20)
        elide: Text.ElideRight
        text: !root.shortTitle || root.shortTitle === root.appName ? root.appName
            : root.appName ? root.appName + " - " + root.shortTitle : root.shortTitle
        color: Config.fgColor
        font.family: Config.fontFamily
        font.pixelSize: root.px
        font.bold: true
    }
}
