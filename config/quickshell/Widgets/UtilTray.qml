pragma ComponentBehavior : Bound

import Quickshell
import Quickshell.Io
import QtQuick

import "../Constants"
import "../Services"

Item {
    id: root
    required property PanelWindow bar
    property bool soundWidget: true
    property bool networkCtl: true
    property bool clipManager: true

    Rectangle {
        id: backdrop
        color: Config.accentColor

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
                // TODO: Make an intermediate solution where I can just adjust the volume of the slider
                // Eventually, this functionality will be reserved for a right click instead of a left click
                onClicked: soundCtl.running = true
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
                onClicked: clipHist.running = true
            }
        }
    }

    Process {
        id: soundCtl
        command: ["pwvucontrol"]
    }

    Process {
        id: clipHist
        command: ["sh", "-c", "cliphist list | rofi -dmenu | cliphist decode | wl-copy"]
    }

    // TODO: This will be a standalone applet to quickly adjust volume
    PopupWindow {
        id: volumeSlider

        anchor.item: soundTray
        anchor.rect.x: soundTray.x - width / 4
        anchor.rect.y: soundTray.y + root.bar.height
        implicitWidth: 32
        implicitHeight: 128
        visible: false
    }
}