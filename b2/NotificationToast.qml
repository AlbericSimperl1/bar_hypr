// bar/horizontaal/NotificationToast.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: toastWindow
    visible: Notifications.toasts.count > 0
    implicitWidth: 340
    implicitHeight: 700
    color: "transparent"
    exclusiveZone: 0

    WlrLayershell.namespace: "quickshell"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Midden bovenaan
    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        top: 8
        left: 0
        right: 0
    }

    // Alleen de toasts zelf vangen input
    mask: Region {
        item: toastCol
    }

    // Container die de toasts horizontaal centreert
    Item {
        id: centerBox
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: toastCol.width
        height: toastCol.height

        Column {
            id: toastCol
            width: Config.toastWidth
            spacing: 8

            Repeater {
                model: Notifications.toasts

                delegate: Rectangle {
                    id: toast
                    required property string tid
                    required property string appName
                    required property string icon
                    required property string glyph
                    required property string title
                    required property string body
                    required property real value
                    required property int timeout
                    required property int token

                    // volume/brightness: icoon, slider, percentage op één rij
                    readonly property bool slider: value >= 0

                    width: toastCol.width
                    height: Math.max(Config.toastMinHeight, (slider ? osdRow : toastRow).implicitHeight + 24)
                    radius: 6
                    // zelfde kleuren als de bar; Hyprland blurt erachter (layer_rule op namespace "quickshell")
                    color: Config.barBg
                    border.width: 1
                    border.color: Config.borderColor

                    onTokenChanged: life.restart()

                    Timer {
                        id: life
                        interval: toast.timeout > 0 ? toast.timeout : 5000
                        running: true
                        onTriggered: Notifications.dismissToast(toast.tid)
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifications.dismissToast(toast.tid)
                    }

                    RowLayout {
                        id: osdRow
                        visible: toast.slider
                        x: 16
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 32
                        spacing: 14

                        Text {
                            text: toast.glyph
                            color: Config.fgColor
                            font.family: "MesloLGL Nerd Font Propo"
                            font.pixelSize: 38
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 4
                            radius: 2
                            color: Qt.rgba(Config.fgColor.r, Config.fgColor.g, Config.fgColor.b, 0.15)

                            Rectangle {
                                width: parent.width * Math.max(0, Math.min(1, toast.value))
                                height: parent.height
                                radius: 2
                                color: Config.accentColor

                                Behavior on width {
                                    NumberAnimation {
                                        duration: 90
                                    }
                                }
                            }
                        }

                        Text {
                            // vaste breedte van "100%" zodat de slider niet verspringt
                            Layout.minimumWidth: pctMetrics.width
                            horizontalAlignment: Text.AlignRight
                            text: toast.body
                            color: Config.fgColor
                            font.family: Config.fontFamily
                            font.pixelSize: 24
                            font.bold: true

                            TextMetrics {
                                id: pctMetrics
                                text: "100%"
                                font.family: Config.fontFamily
                                font.pixelSize: 24
                                font.bold: true
                            }
                        }
                    }

                    RowLayout {
                        id: toastRow
                        visible: !toast.slider
                        x: 12
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 24
                        spacing: 10

                        Rectangle {
                            Layout.preferredWidth: 46
                            Layout.preferredHeight: 46
                            Layout.alignment: Qt.AlignCenter
                            radius: 6
                            color: "#40000000"
                            clip: true

                            Image {
                                id: toastImg
                                anchors.fill: parent
                                anchors.margins: 3
                                source: toast.icon
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                                sourceSize.width: 72
                                sourceSize.height: 72
                                visible: status === Image.Ready
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: toastImg.status !== Image.Ready
                                text: toast.glyph !== "" ? toast.glyph : "\udb80\udc9a"
                                color: Config.fgColor
                                font.family: "MesloLGL Nerd Font Propo"
                                font.pixelSize: 40
                            }
                        }

                        Column {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                visible: toast.appName !== ""
                                width: parent.width
                                text: toast.appName
                                color: Qt.rgba(Config.fgColor.r, Config.fgColor.g, Config.fgColor.b, 0.7)
                                font.family: Config.fontFamily
                                font.pixelSize: Config.toastAppFontSize
                                elide: Text.ElideRight
                            }

                            Text {
                                visible: toast.title !== ""
                                width: parent.width
                                text: toast.title
                                color: Config.fgColor
                                font.family: Config.fontFamily
                                font.pixelSize: Config.toastTitleFontSize
                                font.bold: true
                                wrapMode: Text.Wrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }

                            Text {
                                visible: toast.body !== ""
                                width: parent.width
                                text: toast.body
                                color: Qt.rgba(Config.fgColor.r, Config.fgColor.g, Config.fgColor.b, 0.7)
                                font.family: Config.fontFamily
                                font.pixelSize: Config.toastBodyFontSize
                                wrapMode: Text.Wrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                            }

                            Rectangle {
                                visible: toast.value >= 0
                                width: parent.width
                                height: 4
                                radius: 2
                                color: Qt.rgba(Config.fgColor.r, Config.fgColor.g, Config.fgColor.b, 0.15)

                                Rectangle {
                                    width: parent.width * Math.max(0, Math.min(1, toast.value))
                                    height: parent.height
                                    radius: 2
                                    color: Config.fgColor

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 90
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
