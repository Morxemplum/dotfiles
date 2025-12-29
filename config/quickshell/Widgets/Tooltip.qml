pragma ComponentBehavior : Bound

import Quickshell
import QtQuick

import "../Constants"

LazyLoader {
    id: root
    property PanelWindow bar
    property Item item
    property string text

    PopupWindow {
        anchor {
            window: root.bar
            rect {
                x: root.bar.mapFromItem(root.item, 0, 0).x + root.item.width / 2 - width / 2
                y: Config.barHeight + Config.tooltipPadding
            }
        }
        implicitWidth: tooltipLabel.width + Config.tooltipPadding * 2
        implicitHeight: tooltipLabel.height + Config.tooltipPadding * 2
        color: Qt.rgba(Config.accentColor.r, Config.accentColor.g, Config.accentColor.b, Config.tooltipOpacity)
        visible: root.active

        Text {
            id: tooltipLabel
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }
            text: root.text
            color: Config.textColor
            font {
                family: Config.displayFontFamily
                pointSize: Config.tooltipLabelSize
            }
        }
    }
}