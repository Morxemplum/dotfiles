pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Hyprland

import QtQuick
import QtQuick.Effects

import "./Widgets" as Widgets
import "./Constants"
import "./Services"

Scope {
    id: root

    Variants {
        // I have multiple monitors, I want the bar to show on all of them
        model: Quickshell.screens;

        PanelWindow {
            id: shellBar

            required property var modelData

            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: Config.barHeight
            color: "#00000000"

            // This item is meant to redraw a mask of the current wallpaper
            Item {
                id: myBar
                anchors.fill: parent
                visible: !Config.barBlurEnabled

                Image {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    height: shellBar.screen.height
                    source: Config.wallpaperPath
                }
            }
            // Our upcoming blur will introduce transparency, this rectangle will help cancel out the alpha
            Rectangle {
                anchors.fill: parent
                color: Config.barFrostColor
            }
            // Blur the image above
            MultiEffect {
                source: myBar
                anchors.fill: parent
                blurEnabled: Config.barBlurEnabled
                blur: 1
                blurMultiplier: Config.barBlurStrength
            }
            Rectangle {
                anchors.fill: parent
                color: Config.barTint
                opacity: Config.barTintStrength
            }

            // Left Group of Widgets
            Row {
                id: leftGroup
                anchors {
                    top: parent.top
                    topMargin: Config.barVerticalPadding
                    left: parent.left
                    leftMargin: Config.barHorizontalPadding
                }
                spacing: Config.barHorizontalPadding
                height: parent.height

                Widgets.SystemUsage {
                    width: childrenRect.width
                    height: parent.height - Config.barVerticalPadding * 2
                    textColor: Config.textColor
                }

                Widgets.HyprlandWindow {
                    width: childrenRect.width
                    height: parent.height - Config.barVerticalPadding * 2
                }
            }

            Row {
                id: centerGroup
                anchors {
                    top: parent.top
                    topMargin: Config.barVerticalPadding
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: Config.barHorizontalPadding
                height: parent.height

                Widgets.HyprlandWorkspaces {
                    screen: shellBar.screen
                    width: childrenRect.width // The width of this widget depends on number of workspaces
                    height: parent.height - Config.barVerticalPadding * 2
                }
            }

            // Right Group of Widgets
            Row {
                id: rightGroup
                anchors {
                    top: parent.top
                    topMargin: Config.barVerticalPadding
                    right: parent.right
                    rightMargin: Config.barHorizontalPadding
                }
                spacing: Config.barHorizontalPadding
                height: parent.height
                layoutDirection: Qt.RightToLeft

                Widgets.Clock {
                    width: 100
                    height: parent.height - Config.barVerticalPadding * 2
                    textColor: Config.textColor
                }

                Widgets.UtilTray {
                    bar: shellBar
                    width: childrenRect.width
                    height: parent.height - Config.barVerticalPadding * 2
                }

                Widgets.AppTray {
                    barWindow: shellBar
                    barItem: myBar
                    width: childrenRect.width
                    height: parent.height - Config.barVerticalPadding * 2
                }
            }
            
            Loader { id: hyprclientsListener }
            Loader { id: audioListener }

            Component.onCompleted: {
                hyprclientsListener.source = "Hyprclients.qml"
                audioListener.source = "Audio.qml"
            }

            visible: !(Hyprland.focusedMonitor && modelData.name == Hyprland.focusedMonitor.name && Hyprclients.activeFullscreen)
        }
    }
}