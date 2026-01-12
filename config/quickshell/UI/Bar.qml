pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray

import QtQuick
import QtQuick.Effects

import "../Widgets" as Widgets
import "../Constants"
import "../Services"

PanelWindow {
    id: shellBar
    required property ShellScreen modelData
    property int activeApplet: Enums.ActiveApplet.None
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
            id: sysStats
            width: childrenRect.width
            height: parent.height - Config.barVerticalPadding * 2
            textColor: Config.textColor

            onHoverChanged: {
                if (hover) sysStatsTooltip.loading = true
                else sysStatsTooltip.active = false
            }

            onActiveItemChanged: {
                switch (activeItem) {
                    case cpu: 
                        SystemMonitor.threadUsageActivated()
                        break
                    case memory:
                        SystemMonitor.fullMemoryActivated()
                        break
                    case temperature:
                        SystemMonitor.tempCoresActivated()
                        break
                    default:
                        SystemMonitor.cpuTimer.stop()
                        SystemMonitor.memTimer.stop()
                        SystemMonitor.tempTimer.stop()
                        break
                }
            }

            Widgets.Tooltip {
                id: sysStatsTooltip
                bar: shellBar
                item: sysStats.activeItem
                text: (sysStats.activeItem == sysStats.cpu) ? SystemMonitor.cpuThreadUsage :
                        (sysStats.activeItem == sysStats.memory) ? SystemMonitor.memoryUsageString() :
                        (sysStats.activeItem == sysStats.temperature) ? SystemMonitor.cpuCoreTemps :
                        ""
                monospace: true
            }
        }

        Loader {
            id: currentHyprlandWindow
            asynchronous: true
            width: 1
            height: parent.height - Config.barVerticalPadding * 2
            visible: status == Loader.Ready

            source: Hyprclients.focusedProgram.length > 0 ? "../Widgets/HyprlandWindow.qml" : ""
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
            id: hyprworkspaces
            screen: shellBar.screen
            width: childrenRect.width // The width of this widget depends on number of workspaces
            height: parent.height - Config.barVerticalPadding * 2

            onHoveredItemChanged: {
                if (hoveredItem != null) workspacesTooltip.loading = true
                else workspacesTooltip.active = false
            }

            Widgets.Tooltip {
                id: workspacesTooltip
                bar: shellBar
                item: hyprworkspaces.hoveredItem
                text: hyprworkspaces.hoveredWorkspace != null ? "workspace " + hyprworkspaces.hoveredWorkspace.name : ""
            }
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
            id: utilities
            bar: shellBar
            width: childrenRect.width
            height: parent.height - Config.barVerticalPadding * 2

            onActiveItemChanged: {
                if (activeItem != null) utilTrayTooltip.loading = true
                else utilTrayTooltip.active = false

                switch (activeItem) {
                    case network:
                        Networking.dataActivated()
                        break
                    default:
                        Networking.dataTimer.stop()
                        Networking.lastRcv = -1
                        Networking.lastTrans = -1
                        break
                }
            }

            Widgets.Tooltip {
                id: utilTrayTooltip
                bar: shellBar
                item: utilities.activeItem
                text: (utilities.activeItem == utilities.clipboard) ? qsTr("Clipboard Manager") :
                        (utilities.activeItem == utilities.network) ? Networking.connectionInfoStr() :
                        (utilities.activeItem == utilities.sound) ? "Audio Volume" :
                        ""
            }
        }

        Widgets.AppTray {
            id: appTray
            barWindow: shellBar
            barItem: myBar
            visible: SystemTray.items.values.length > 0
            width: childrenRect.width
            height: parent.height - Config.barVerticalPadding * 2

            onHoveredItemChanged: {
                if (hoveredItem != null) appTrayTooltip.loading = true
                else appTrayTooltip.active = false
            }

            Widgets.Tooltip {
                id: appTrayTooltip
                bar: shellBar
                item: appTray.hoveredItem
                text: (appTray.hoveredTrayItem != null) ? appTray.hoveredTrayItem.tooltipTitle : ""
            }
        }
    }

    visible: !(Hyprland.focusedMonitor && modelData.name == Hyprland.focusedMonitor.name && Hyprclients.activeFullscreen)

    // A dummy window has to be created for our lazy loaders to work. This is intentional behavior from Quickshell
    // https://quickshell.org/docs/master/types/Quickshell/LazyLoader/
    PopupWindow {}
}