// shell.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool overviewActive: true

    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: perScreen
            required property var modelData

            NotificationToast {
                screen: perScreen.modelData
            }

            PanelWindow {
                id: barWindow
                screen: perScreen.modelData
                visible: root.overviewActive
                color: "transparent"

                // 1. FIXED: Added explicit Wayland layer and keyboard focus
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

                readonly property string pos: Config.barPosition
                readonly property bool horizontal: pos === "top" || pos === "bottom"
                readonly property bool vertical: !horizontal
                readonly property real barThickness: Config.barHeight + Config.barMargin * 2

                readonly property real panelW: Config.panelWidthFor(BarState.activePanel)
                readonly property real panelH: {
                    if (!BarState.panelOpen)
                        return Config.panelMinHeight;
                    const target = BarState.activePanel;
                    if (!Config.panelsAutoSize)
                        return Config.panelHeightFor(target, Config.panelMaxHeight);
                    switch (target) {
                    case "media":
                        return mediaPanel.implicitHeight;
                    case "bluetooth":
                        return Math.min(Config.panelMaxHeight, bluetoothPanel.neededHeight);
                    case "wifi":
                        return Math.min(Config.panelMaxHeight, wifiPanel.neededHeight);
                    case "notifications":
                        return Math.min(Config.panelMaxHeight, notificationPanel.neededHeight);
                    case "power":
                        return Math.min(Config.panelMaxHeight, powerPanel.neededHeight);
                    case "brightness":
                        return Math.min(Config.panelMaxHeight, brightnessPanel.neededHeight);
                    case "settings":
                        return Math.min(Config.panelMaxHeight, Config.panelHeightFor("settings", 620));
                    }
                    return Config.panelMinHeight;
                }

                anchors.top: horizontal ? (pos === "top") : true
                anchors.bottom: horizontal ? (pos === "bottom") : true
                anchors.left: horizontal ? true : (pos === "left")
                anchors.right: horizontal ? true : (pos === "right")

                exclusiveZone: Config.barHeight + 2

                implicitHeight: horizontal ? (barThickness + Config.barGap + Config.panelMaxHeight) : 0
                implicitWidth: vertical ? (barThickness + Config.barGap + Config.panelMaxHeight) : 0

                // 2. FIXED: Use barWindow.width / barWindow.height so the mask is not 0x0
                mask: Region {
                    Region {
                        x: horizontal ? 0 : (pos === "left" ? Config.barMargin : barWindow.width - barThickness)
                        y: horizontal ? (pos === "top" ? Config.barMargin : barWindow.height - barThickness) : 0
                        width: horizontal ? barWindow.width : barThickness
                        height: horizontal ? barThickness : barWindow.height
                    }
                    Region {
                        x: barWindow.panelX
                        y: barWindow.panelY
                        width: BarState.panelOpen ? panelW : 0
                        height: BarState.panelOpen ? panelH : 0
                    }
                }

                readonly property real panelX: {
                    if (!BarState.panelOpen)
                        return 0;
                    if (horizontal) {
                        const inset = Config.barMargin + Config.panelRadius + 2;
                        const maxLeft = width - inset - panelW;
                        return Math.max(inset, Math.min(BarState.clickX - panelW / 2, maxLeft));
                    }
                    return pos === "left" ? Config.barMargin + barThickness + Config.barGap : width - Config.barMargin - barThickness - Config.barGap - panelW;
                }
                readonly property real panelY: {
                    if (!BarState.panelOpen)
                        return 0;
                    if (horizontal) {
                        return pos === "top" ? Config.barMargin + barThickness + Config.barGap : height - Config.barMargin - barThickness - Config.barGap - panelH;
                    }
                    const inset = Config.barMargin + Config.panelRadius + 2;
                    const maxTop = height - inset - panelH;
                    return Math.max(inset, Math.min(BarState.clickY - panelH / 2, maxTop));
                }

                HoverHandler {
                    id: barHover
                }
                property bool hovered: barHover.hovered

                Timer {
                    id: closeTimer
                    interval: 200
                    onTriggered: if (!barWindow.hovered)
                        BarState.close()
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

                    Rectangle {
                        id: barSurface
                        x: horizontal ? 0 : (pos === "left" ? Config.barMargin : parent.width - barThickness)
                        y: horizontal ? (pos === "top" ? Config.barMargin : parent.height - barThickness) : 0
                        width: horizontal ? parent.width : barThickness
                        height: horizontal ? barThickness : parent.height
                        color: Config.barBg
                        radius: Config.barRadius
                        border.color: Config.borderColor
                        border.width: Config.borderColor.a > 0 ? 1 : 0

                        Item {
                            anchors.fill: parent
                            anchors.leftMargin: horizontal ? Config.barInset : 0
                            anchors.rightMargin: horizontal ? Config.barInset : 0
                            anchors.topMargin: horizontal ? 0 : Config.barInset
                            anchors.bottomMargin: horizontal ? 0 : Config.barInset

                            // 3. FIXED: Added anchors.fill: parent so it takes up space
                            BarContent {
                                anchors.fill: parent
                            }
                        }
                    }

                    Rectangle {
                        id: panelSurface
                        x: barWindow.panelX
                        y: barWindow.panelY
                        width: BarState.panelOpen ? barWindow.panelW : 0
                        height: BarState.panelOpen ? barWindow.panelH : 0
                        visible: BarState.panelOpen
                        color: Config.panelBg
                        radius: Config.panelRadius
                        border.color: Config.borderColor
                        border.width: Config.borderColor.a > 0 ? 1 : 0
                        clip: true

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

                            SettingsPanel {
                                id: settingsPanel
                                anchors.fill: parent
                                visible: BarState.activePanel === "settings"
                            }
                        }
                    }
                }

                // 4. FIXED: Use barWindow.width / barWindow.height for blur region
                BackgroundEffect.blurRegion: Region {
                    Region {
                        x: horizontal ? 0 : (pos === "left" ? Config.barMargin : barWindow.width - barThickness)
                        y: horizontal ? (pos === "top" ? Config.barMargin : barWindow.height - barThickness) : 0
                        width: horizontal ? barWindow.width : barThickness
                        height: horizontal ? barThickness : barWindow.height
                    }
                    Region {
                        x: barWindow.panelX
                        y: barWindow.panelY
                        width: BarState.panelOpen ? panelW : 0
                        height: BarState.panelOpen ? panelH : 0
                    }
                }
            }
        }
    }
}
