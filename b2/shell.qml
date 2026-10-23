// shell.qml
import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: perScreen
            required property var modelData

            NotificationToast {
                screen: perScreen.modelData
            }

            PanelWindow {
                id: win
                screen: perScreen.modelData
                color: "transparent"

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

                // ── geometry helpers (ALWAYS referenced as win.* from child objects) ──
                readonly property string pos: Config.barPosition
                readonly property bool horizontal: pos === "top" || pos === "bottom"
                readonly property real bt: Config.barHeight

                // side margin is applied to the bar surface (not the window) so panels keep full room
                readonly property real sideM: Math.max(0, Math.min(Config.barSideMargin, (horizontal ? width : height) / 2 - 60))

                readonly property real barX: horizontal ? sideM : (pos === "left" ? 0 : width - bt)
                readonly property real barY: horizontal ? (pos === "top" ? 0 : height - bt) : sideM
                readonly property real barW: horizontal ? Math.max(0, width - 2 * sideM) : bt
                readonly property real barH: horizontal ? bt : Math.max(0, height - 2 * sideM)

                readonly property real panelW: Config.panelWidthFor(BarState.activePanel)
                readonly property real contentH: {
                    switch (BarState.activePanel) {
                    case "media":
                        return mediaPanel.implicitHeight;
                    case "bluetooth":
                        return bluetoothPanel.neededHeight;
                    case "wifi":
                        return wifiPanel.neededHeight;
                    case "notifications":
                        return notificationPanel.neededHeight;
                    case "power":
                        return powerPanel.neededHeight;
                    case "brightness":
                        return brightnessPanel.neededHeight;
                    case "volume":
                        return volumePanel.neededHeight;
                    case "settings":
                        return Config.panelHeightFor("settings", 620);
                    }
                    return 0;
                }
                readonly property real panelH: BarState.activePanel === "settings" ? Config.panelHeightFor("settings", 620) : (Config.panelsAutoSize ? Math.min(Config.panelMaxHeight, Math.max(Config.panelMinHeight, contentH + 16)) : Config.panelHeightFor(BarState.activePanel, Config.panelMaxHeight))

                readonly property real panelX: {
                    if (horizontal) {
                        const inset = Config.panelRadius + 2;
                        const maxLeft = width - inset - panelW;
                        return Math.max(inset, Math.min(BarState.clickX - panelW / 2, maxLeft));
                    }
                    return pos === "left" ? bt + Config.barGap : width - bt - Config.barGap - panelW;
                }
                readonly property real panelY: {
                    if (horizontal)
                        return pos === "top" ? bt + Config.barGap : height - bt - Config.barGap - panelH;
                    const inset = Config.panelRadius + 2;
                    const maxTop = height - inset - panelH;
                    return Math.max(inset, Math.min(BarState.clickY - panelH / 2, maxTop));
                }

                // border sides: "pos" is the screen-edge side, "inner" faces the panels, "ends" are the two bar ends
                readonly property string inner: ({ top: "bottom", bottom: "top", left: "right", right: "left" })[pos]
                readonly property var ends: horizontal ? ["left", "right"] : ["top", "bottom"]
                readonly property var barBorderSides: Config.borderUnderline ? [inner] : [inner].concat(Config.barMargin > 0 ? [pos] : [], sideM > 0 ? ends : [])
                readonly property var panelBorderSides: ends.concat([inner], !Config.borderUnderline && Config.barGap > 0 ? [pos] : [])
                // a panel touching the bar opens the bar's inner line so both outlines read as one
                readonly property bool panelJoined: BarState.panelOpen && Config.barGap === 0

                anchors.top: horizontal ? (pos === "top") : true
                anchors.bottom: horizontal ? (pos === "bottom") : true
                anchors.left: horizontal ? true : (pos === "left")
                anchors.right: horizontal ? true : (pos === "right")

                margins.top: pos === "top" ? Config.barMargin : 0
                margins.bottom: pos === "bottom" ? Config.barMargin : 0
                margins.left: pos === "left" ? Config.barMargin : 0
                margins.right: pos === "right" ? Config.barMargin : 0

                exclusiveZone: Config.barHeight + 2

                implicitHeight: horizontal ? (bt + Config.barGap + Config.panelMaxHeight) : 0
                implicitWidth: horizontal ? 0 : (bt + Config.barGap + Config.panelWidthMax)

                mask: Region {
                    Region {
                        x: win.barX
                        y: win.barY
                        width: win.barW
                        height: win.barH
                    }
                    Region {
                        x: win.panelX
                        y: win.panelY
                        width: BarState.panelOpen ? win.panelW : 0
                        height: BarState.panelOpen ? win.panelH : 0
                    }
                }

                BackgroundEffect.blurRegion: Region {
                    Region {
                        x: win.barX
                        y: win.barY
                        width: win.barW
                        height: win.barH
                    }
                    Region {
                        x: win.panelX
                        y: win.panelY
                        width: BarState.panelOpen ? win.panelW : 0
                        height: BarState.panelOpen ? win.panelH : 0
                    }
                }

                property bool hovered: false

                Timer {
                    id: closeTimer
                    interval: 200
                    onTriggered: {
                        if (!win.hovered)
                            BarState.close();
                    }
                }

                onHoveredChanged: {
                    if (hovered)
                        closeTimer.stop();
                    else if (BarState.panelOpen)
                        closeTimer.start();
                }

                Item {
                    id: windowRoot
                    anchors.fill: parent

                    HoverHandler {
                        onHoveredChanged: win.hovered = hovered
                    }

                    Rectangle {
                        id: barSurface
                        x: win.barX
                        y: win.barY
                        width: win.barW
                        height: win.barH
                        color: Config.barBg
                        radius: Config.barRadius

                        Border {
                            anchors.fill: parent
                            radius: Config.barRadius
                            sides: win.barBorderSides
                            cutSide: win.panelJoined ? win.inner : ""
                            cutFrom: (win.horizontal ? win.panelX - win.barX : win.panelY - win.barY) + Config.borderWidth
                            cutTo: (win.horizontal ? win.panelX + win.panelW - win.barX : win.panelY + win.panelH - win.barY) - Config.borderWidth
                        }

                        Item {
                            anchors.fill: parent
                            anchors.leftMargin: win.horizontal ? Config.barInset : 0
                            anchors.rightMargin: win.horizontal ? Config.barInset : 0
                            anchors.topMargin: win.horizontal ? 0 : Config.barInset
                            anchors.bottomMargin: win.horizontal ? 0 : Config.barInset

                            BarContent {
                                anchors.fill: parent
                            }
                        }
                    }

                    Rectangle {
                        id: panelSurface
                        x: win.panelX
                        y: win.panelY
                        width: win.panelW
                        height: win.panelH
                        visible: BarState.panelOpen
                        color: Config.panelBg
                        radius: Config.panelRadius
                        clip: true

                        Border {
                            anchors.fill: parent
                            radius: Config.panelRadius
                            sides: win.panelBorderSides
                        }

                        Item {
                            anchors.fill: parent
                            anchors.margins: 8

                            MediaPanel {
                                id: mediaPanel
                                anchors.fill: parent
                                visible: BarState.activePanel === "media"
                                fgColor: Config.fgColor
                                accentColor: Config.accentColor
                                fontFamily: Config.fontFamily
                            }

                            BluetoothPanel2 {
                                id: bluetoothPanel
                                anchors.fill: parent
                                visible: BarState.activePanel === "bluetooth"
                                fgColor: Config.fgColor
                                accentColor: Config.accentColor
                                fontFamily: Config.fontFamily
                            }

                            WifiPanel {
                                id: wifiPanel
                                anchors.fill: parent
                                visible: BarState.activePanel === "wifi"
                                fgColor: Config.fgColor
                                accentColor: Config.accentColor
                                fontFamily: Config.fontFamily
                            }

                            NotificationPanel {
                                id: notificationPanel
                                anchors.fill: parent
                                visible: BarState.activePanel === "notifications"
                                fgColor: Config.fgColor
                                accentColor: Config.accentColor
                                fontFamily: Config.fontFamily
                                onCloseRequested: BarState.close()
                            }

                            PowerPanel {
                                id: powerPanel
                                anchors.fill: parent
                                visible: BarState.activePanel === "power"
                                fgColor: Config.fgColor
                                accentColor: Config.accentColor
                                fontFamily: Config.fontFamily
                            }

                            BrightnessPanel {
                                id: brightnessPanel
                                anchors.fill: parent
                                visible: BarState.activePanel === "brightness"
                                fgColor: Config.fgColor
                                accentColor: Config.accentColor
                                fontFamily: Config.fontFamily
                            }

                            VolumePanel {
                                id: volumePanel
                                anchors.fill: parent
                                visible: BarState.activePanel === "volume"
                                fgColor: Config.fgColor
                                accentColor: Config.accentColor
                                fontFamily: Config.fontFamily
                            }

                            SettingsPanel {
                                id: settingsPanel
                                anchors.fill: parent
                                visible: BarState.activePanel === "settings"
                            }
                        }
                    }
                }
            }
        }
    }
}
