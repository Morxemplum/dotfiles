pragma ComponentBehavior : Bound

import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick

import "../Constants"
import "../Services"
import "../Applets/Minis" as Applets

Item {
    id: root
    required property PanelWindow bar
    property bool soundWidget: true
    property bool networkCtl: true
    property bool clipManager: true

    property int hoverCount: 0 // Debounce measure to stop prematurely setting the item to null
    property Item activeItem
    readonly property Item sound: soundTray
    readonly property Item network: networkStatus
    readonly property Item clipboard: clipboardManager

    Rectangle {
        id: backdrop
        color: Config.primaryColor

        width: container.width + Config.widgetRadius + Config.widgetHorizontalPadding
        height: parent.height
        radius: Config.widgetRadius
    }

    Row {
        id: container
        layoutDirection: Qt.RightToLeft
        anchors.centerIn: backdrop
        height: parent.height 

        Rectangle {
            id: soundTray
            anchors.verticalCenter: parent.verticalCenter
            visible: root.soundWidget

            width: this.height
            height: parent.height
            color: '#00000000'

            Image {
                anchors.centerIn: parent
                width: Config.iconSize
                height: Config.iconSize
                source: (Audio.volume == 0) ? "../themes/svg/no-audio.svg" :
                        "../themes/svg/sound-" + Math.min(Math.trunc(Audio.volumePercentage * 3 / 100) + 1, 3) + ".svg"
            } 

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                // TODO: When left clicked, open an applet where I can quick adjust volume of sink, source, and apps
                // TODO: When hovered, open a mini-applet for quick sink volume adjustment via scrolling
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        soundCtl.startDetached()
                    }
                }

                onEntered: {
                    miniSlider.loading = true
                }
                onExited: {
                    miniSlider.active = false
                }

                onWheel: event => {
                    const volumeAdjustAmount = 5
                    const dir = Math.sign(event.angleDelta.y)
                    const clamp = (num, min, max) => Math.min(Math.max(num, min), max)

                    if (Audio.defaultSinkId >= 0) {
                        // Base it off the percentage value to stop build up of floating point error
                        const newVolume = (Audio.volumePercentage + volumeAdjustAmount * dir) / 100
                        Audio.defaultNode.volume = clamp(newVolume, 0, 1)
                    }
                }
            }
        }

        // TODO: Make a notification widget to replace dunst

        Rectangle {
            id: networkStatus
            visible: root.networkCtl

            width: this.height
            height: parent.height
            color: '#00000000'

            Image {
                anchors {
                    centerIn: parent
                }
                width: Config.iconSize
                height: Config.iconSize
                source: (Networking.status == Enums.ConnectionStatus.Ethernet) ? "../themes/svg/ethernet-connection.svg" :
                        (Networking.status == Enums.ConnectionStatus.Limited) ? "../themes/svg/ethernet-limited-connection.svg" :
                        (Networking.status == Enums.ConnectionStatus.Wireless) ? "../themes/svg/wifi-" + Math.min(Math.trunc(Networking.wifiStrength / 25), 3) + ".svg" :
                        (Networking.status == Enums.ConnectionStatus.Pending) ? "../themes/svg/pending-connection.svg" :
                        "../themes/svg/no-connection.svg"
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onEntered: {
                    root.activeItem = networkStatus
                    root.hoverCount += 1
                }
                onExited: {
                    root.hoverCount -= 1
                    if (root.hoverCount <= 0) root.activeItem = null
                }
            }

            // Quickshell doesn't have a built-in method of getting network status, so we'll need to figure something out
            // We may have to actually try and create our own applet as an ideal solution. networkmanager_dmenu would be the temporary workaround
        }
        
        Rectangle {
            property bool hover: false

            id: clipboardManager
            anchors.verticalCenter: parent.verticalCenter
            visible: root.clipManager

            width: this.height
            height: parent.height
            color: '#00000000'

            Image {
                anchors.centerIn: parent
                width: Config.iconSize
                height: Config.iconSize
                source: "../themes/svg/clipboard.svg"
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onClicked: clipHist.running = true
                onEntered: {
                    root.activeItem = clipboardManager
                    root.hoverCount += 1
                }
                onExited: {
                    root.hoverCount -= 1
                    if (root.hoverCount <= 0) root.activeItem = null
                }
            }
        }
    }

    Process {
        id: soundCtl
        command: ["pwvucontrol"]
    }

    // TODO: Prompt a password before accessing the clipboard manager. Clipboards can contain sensitive information (e.g. passwords)
    Process {
        id: clipHist
        command: ["sh", "-c", "cliphist list | rofi -dmenu | cliphist decode | wl-copy"]
    }

    Applets.VolumeSlider {
        id: miniSlider
        bar: root.bar
        item: soundTray
    }
}