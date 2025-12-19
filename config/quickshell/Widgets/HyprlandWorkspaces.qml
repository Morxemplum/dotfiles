pragma ComponentBehavior : Bound

import Quickshell
import Quickshell.Hyprland
import QtQuick

import "../Constants"

Item {
    id: root
    required property ShellScreen screen
    property real activeSize: 15
    property real passiveSize: 12
    property real workspaceSpacing: 8

    property color activeColor: "#ffffff"
    property color inactiveColor: "#3e3e3e"

    Rectangle {
        id: backdrop
        color: Config.accentColor

        width: container.width + Config.widgetRadius + Config.widgetHorizontalPadding
        height: parent.height 
        radius: Config.widgetRadius
    }
    Row {
        id: container
        spacing: root.workspaceSpacing

        anchors {
            centerIn: backdrop
        }
        
        Repeater {
            // Only show active workspaces. I don't want to see all 9 of them. It's a waste of space
            model: Hyprland.workspaces.values.length

            Rectangle {
                required property int index
                property HyprlandWorkspace workspace: Hyprland.workspaces.values[index]
                // First method works best for a single monitor, but the current definition works better for multiple monitors
                // property bool isActive: Hyprland.focusedWorkspace?.id == (index + 1)
                property bool isActive: workspace.active && workspace.monitor.name == root.screen.name
                property bool hover: false

                anchors {
                    verticalCenter: parent.verticalCenter
                }

                implicitWidth: (isActive || hover) ? root.activeSize : root.passiveSize
                implicitHeight: (isActive || hover) ? root.activeSize : root.passiveSize
                radius: (isActive || hover) ? root.activeSize : root.passiveSize

                color: isActive ? root.activeColor : root.inactiveColor

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: !parent.isActive
                    onClicked: Hyprland.dispatch("workspace " + parent.workspace.id)

                    onEntered: {
                        parent.hover = true
                    }
        
                    onExited: {
                        parent.hover = false
                    }
                }
            }
        }
    }
}