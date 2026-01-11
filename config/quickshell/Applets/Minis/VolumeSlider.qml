pragma ComponentBehavior : Bound

import Quickshell
import QtQuick
import QtQuick.Controls

import "../../Constants"
import "../../Services"

LazyLoader {
    id: root
    property PanelWindow bar
    property Item item

    PopupWindow {
        id: popup
        anchor {
            window: root.bar
            rect {
                x: root.item != null ? root.bar.mapFromItem(root.item, 0, 0).x + root.item.width / 2 - width / 2 : 0
                y: Config.barHeight + Config.tooltipPadding
            }
        }
        implicitWidth: 200
        implicitHeight: 40
        color: Config.appletBackgroundColor
        visible: root.active

        Slider {
            id: slide
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: Config.tooltipPadding
            }
            from: 0
            value: Audio.volumePercentage
            to: 100
            enabled: false // This applet behaves like a tooltip. I don't want this slider to be adjusted through a click.

            background: Rectangle {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                }
                implicitWidth: popup.width - textLabel.width - Config.tooltipPadding * 3
                implicitHeight: Config.sliderBackgroundHeight
                height: implicitHeight
                radius: Config.sliderBackgroundRadius
                color: Config.toggleInactiveColor

                Rectangle {
                    width: slide.visualPosition * parent.width
                    height: parent.height
                    color: Config.accentColor
                    radius: Config.sliderBackgroundRadius
                }
            }
        }

        Text {
            id: textLabel
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: Config.tooltipPadding
            }
            width: 40 + Config.tooltipPadding
            color: Config.appletTextColor
            text: Audio.volumePercentage + "%"
            font {
                bold: true
                family: Config.displayFontFamily
                pointSize: Config.tooltipLabelSize
            }
            visible: true
        }
    }
}