pragma ComponentBehavior : Bound

import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick

Item {
    id: root
    required property var barWindow
    required property var barItem

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

        Repeater {
            model: SystemTray.items.values.length

            // TODO: Defer items that have a status of passive into a dropdown applet/grid
            Item {
                required property int index
                property SystemTrayItem appTracker: SystemTray.items.values[index]

                anchors.verticalCenter: parent.verticalCenter
                width: this.height
                height: parent.height

                Rectangle {
                    id: appStatus
                    anchors.centerIn: parent

                    width: this.height
                    height: parent.height - 4
                    radius: 5

                    color: (parent.appTracker.status) == Status.NeedsAttention ? '#8dff0000' :
                            '#00000000'
                }

                IconImage {
                    anchors.centerIn: parent
                    implicitSize: 16
                    source: parent.appTracker.icon
                }

                // TODO: Add tooltip functionality to tray items
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton) {
                            parent.appTracker.activate()
                        } else if (mouse.button === Qt.MiddleButton) {
                            parent.appTracker.secondaryActivate()
                        } else if (mouse.button === Qt.RightButton) {
                            if (parent.appTracker.hasMenu) {
                                // Translate our mouse position to "global" coordinates (since I have multiple monitors, it's actually relative to the bar)
                                // If we ever make the bar float, this may need to be refactored.
                                var globalMouse = this.mapToItem(root.barItem, mouse.x, mouse.y)
                                // TODO: Try and pass theming information to the app tracker, if possible
                                parent.appTracker.display(root.barWindow, globalMouse.x, globalMouse.y)
                            }
                        }
                    }
                }

                /*
                Component.onCompleted: {
                    console.log("App name: " + appTracker.id)
                    console.log("Description: " + appTracker.title)
                    console.log("Icon path: " + appTracker.icon)
                    console.log("Tooltip title: " + appTracker.tooltipTitle)
                    console.log("Tooltip description: " + appTracker.tooltipDescription)
                    console.log("Status: " + appTracker.status)
                }
                */
            }
        }
    }
}