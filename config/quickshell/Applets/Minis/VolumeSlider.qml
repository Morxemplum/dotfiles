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
        // FIXME: Magic numbers
        implicitWidth: 200
        implicitHeight: 40
        color: "transparent"
        visible: root.active && root.item != null

        Rectangle {
            id: background
            anchors.fill: parent
            color: Config.appletBackgroundColor
            radius: Config.tooltipRadius

            Slider {
                id: slide
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: Config.tooltipPadding + Config.tooltipRadius / 2
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
                    implicitWidth: popup.width - textLabel.width - Config.tooltipPadding * 3 - Config.tooltipRadius
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
                    rightMargin: Config.tooltipPadding + Config.tooltipRadius / 2
                }
                // FIXME: Magic number
                width: 40
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
}