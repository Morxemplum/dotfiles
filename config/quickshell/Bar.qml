pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray

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
            required property ShellScreen modelData
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

                Loader {
                    id: currentHyprlandWindow
                    asynchronous: true
                    width: 1
                    height: parent.height - Config.barVerticalPadding * 2
                    visible: status == Loader.Ready

                    source: Hyprclients.focusedProgram.length > 0 ? "./Widgets/HyprlandWindow.qml" : ""
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
                    id: clock
                    width: 100
                    height: parent.height - Config.barVerticalPadding * 2
                    textColor: Config.textColor

                    onHoverChanged: {
                        if (hover) {
                            clockTooltip.loading = true
                            Time.tooltipActivated()
                        } else {
                            clockTooltip.active = false
                            Time.tooltipTimer.stop()
                        }
                    }

                    Widgets.Tooltip {
                        id: clockTooltip
                        bar: shellBar
                        item: clock
                        text: Time.time12 + "\n" + Time.dateFull
                    }
                }

                Widgets.UtilTray {
                    bar: shellBar
                    width: childrenRect.width
                    height: parent.height - Config.barVerticalPadding * 2
                }
                
                Loader {
                    id: appTray
                    property url sauce: SystemTray.items.values.length > 0 ? "./Widgets/AppTray.qml" : ""

                    asynchronous: true
                    // With a Loader, you can't use childrenRect. You need to calculate the width manually
                    width: this.height * SystemTray.items.values.length + Config.widgetRadius + Config.widgetHorizontalPadding
                    height: parent.height - Config.barVerticalPadding * 2
                    visible: status == Loader.Ready

                    // Hacky workaround to setting the source and feeding the required properties
                    // This is based on a real Qt bug: https://qt-project.atlassian.net/browse/QTBUG-125071
                    onSauceChanged: {
                        const requiredProperties = {
                            "barWindow": shellBar,
                            "barItem": myBar
                        }
                        this.setSource(sauce, requiredProperties)
                    }
                }
            }

            visible: !(Hyprland.focusedMonitor && modelData.name == Hyprland.focusedMonitor.name && Hyprclients.activeFullscreen)
        }
    }
}