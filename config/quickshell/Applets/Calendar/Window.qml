pragma ComponentBehavior : Bound

import Quickshell
import QtQuick

import "../../Constants"
import "../../Constants/Enums"
import "../../Services"

LazyLoader {
    id: root
    property PanelWindow bar
    property Item item
    readonly property bool toggled: (Environment.activeApplet == ActiveApplet.Value.Calendar) && 
                                    (Environment.appletMonitor == root.bar.screen)

    PopupWindow {
        id: popup
        readonly property real scaleFactor: (Environment.appletMonitor != null) ? Environment.appletMonitor.devicePixelRatio : 1
        anchor {
            window: root.bar
            rect {
                x: root.item != null ? root.bar.mapFromItem(root.item, 0, 0).x + root.item.width / 2 - width / 2 : 0
                y: Config.barHeight + Config.tooltipPadding
            }
        }
        // FIXME: Magic numbers
        implicitWidth: 400
        implicitHeight: 500
        color: "transparent"
        visible: root.active && root.item != null

        Rectangle {
            id: background
            anchors.fill: parent
            color: Config.appletBackgroundColor
            radius: Config.appletBorderRadius

            Text {
                id: year
                anchors {
                    top: parent.top
                    topMargin: Config.appletPadding
                    horizontalCenter: parent.horizontalCenter
                }
                height: Config.appletHeaderPointSize * popup.scaleFactor
                color: Config.appletTextColor
                text: Date.year
                

                font {
                    bold: true
                    family: Config.displayFontFamily
                    pointSize: Config.appletHeaderPointSize
                }
            }

            CalendarLayout {
                id: layout
                anchors {
                    top: year.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                width: parent.width - Config.appletPadding * 2
                height: childrenRect.height + Config.appletPadding * 2
            }
        }
    }

    onToggledChanged: {
        if (toggled) { 
            root.loading = true
            Date.currentDate.running = true
        } else root.active = false
    }
}