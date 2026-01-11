pragma ComponentBehavior : Bound

import Quickshell
import QtQuick

import "../Constants"

LazyLoader {
    id: root
    property bool visibleCondition: true
    property PanelWindow bar
    property Item item
    property string text
    property bool monospace: false

    PopupWindow {
        anchor {
            window: root.bar
            rect {
                x: root.item != null ? root.bar.mapFromItem(root.item, 0, 0).x + root.item.width / 2 - width / 2 : 0
                y: Config.barHeight + Config.tooltipPadding
            }
        }
        color: "transparent"
        implicitWidth: tooltipLabel.width + Config.tooltipPadding * 2 + Config.tooltipRadius / 2
        implicitHeight: tooltipLabel.height + Config.tooltipPadding * 2 + Config.tooltipRadius / 2
        visible: root.active && root.item != null && root.visibleCondition

        Rectangle {
            id: background
            anchors.fill: parent
            color: Qt.rgba(Config.primaryColor.r, Config.primaryColor.g, Config.primaryColor.b, Config.tooltipOpacity)
            radius: Config.tooltipRadius

            Text {
                id: tooltipLabel
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                text: root.text
                color: Config.textColor
                font {
                    family: root.monospace ? Config.monoFontFamily : Config.displayFontFamily
                    pointSize: Config.tooltipLabelSize
                }
            }
        }
    }
}