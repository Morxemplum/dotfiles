pragma ComponentBehavior : Bound

import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick

import "../Constants"

Item {
    id: root
    required property PanelWindow barWindow
    required property Item barItem

    property real appRadius: 5
    property real appStatusVerticalPadding: 4

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
                    height: parent.height - root.appStatusVerticalPadding
                    radius: root.appRadius

                    color: (parent.appTracker.status) == Status.NeedsAttention ? Config.urgentColor :
                            '#00000000'
                }

                IconImage {
                    anchors.centerIn: parent
                    implicitSize: Config.iconSize
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
                                const globalMouse = this.mapToItem(root.barItem, mouse.x, mouse.y)
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