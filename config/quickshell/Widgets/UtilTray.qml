pragma ComponentBehavior : Bound

import Quickshell
import Quickshell.Io
import QtQuick

import ".."

Item {
    id: root
    required property var bar
    property bool soundWidget: true
    property bool networkCtl: true
    property bool clipManager: true

    Rectangle {
        id: backdrop
        color: '#000000'

        width: container.width + 20
        height: parent.height 
        radius: 10
    }

    Row {
        id: container
        layoutDirection: Qt.RightToLeft
        anchors {
            centerIn: backdrop
        }
        height: parent.height 

        Rectangle {
            id: soundTray
            anchors.verticalCenter: parent.verticalCenter
            visible: root.soundWidget

            width: this.height
            height: parent.height
            color: '#00000000'

            Image {
                anchors {
                    centerIn: parent
                }
                width: 20
                height: 20
                // FIXME: Find a more efficient way to write this?
                source: (Audio.volume == 0) ? "../themes/svg/no-audio.svg" :
                        (Audio.volume < (1 / 3)) ? "../themes/svg/sound-1.svg" :
                        (Audio.volume < (2 / 3)) ? "../themes/svg/sound-2.svg" :
                        "../themes/svg/sound-3.svg"
            }

            MouseArea {
                anchors.fill: parent
                // TODO: Make an intermediate solution where I can just adjust the volume of the slider
                // Eventually, this functionality will be reserved for a right click instead of a left click
                onClicked: {
                    soundCtl.running = true
                }
            }
        }

        // TODO: Make a notification widget to replace dunst

        // TODO: Replace this with an IconImage of an SVG icon that dynamically changes based on connection status and type of connection
        Rectangle {
            id: networkStatus
            visible: root.networkCtl

            width: this.height
            height: parent.height
            color: '#00ffb3'

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
                anchors {
                    centerIn: parent
                }
                width: 20
                height: 20
                source: "../themes/svg/clipboard.svg"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    clipHist.running = true
                }
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