pragma ComponentBehavior: Bound
import Quickshell

import QtQuick
import QtQuick.Effects

import "./Widgets" as Widgets

Scope {
    id: root
    property real horizontal_padding: 5
    property real vertical_padding: 5

    Variants {
        // I have multiple monitors, I want the bar to show on all of them
        model: Quickshell.screens;

        PanelWindow {
            id: shell_bar

            required property var modelData

            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: 40
            color: "#00000000"

            // This item is meant to redraw a mask of the current wallpaper
            Item {
                id: my_bar
                anchors.fill: parent
                visible: false // We are applying post-processing, so let's not render the image twice

                Image {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    height: shell_bar.screen.height
                    source: "./themes/wallpapers/bees_on_yellow.jpg"
                }
            }
            // Our upcoming blur will introduce transparency, this rectangle will help cancel out the alpha
            Rectangle {
                anchors.fill: parent
                color: '#454545'
            }
            // Blur the image above
            MultiEffect {
                source: my_bar
                anchors.fill: parent
                blurEnabled: true
                blur: 1
                blurMultiplier: 2
            }
            Rectangle {
                anchors.fill: parent
                color: '#4f480c'
                opacity: 0.5
            }

            // Left Group of Widgets
            Row {
                id: left_group
                anchors {
                    top: parent.top
                    topMargin: root.vertical_padding
                    left: parent.left
                    leftMargin: root.horizontal_padding
                }
                spacing: root.horizontal_padding
                height: parent.height

                Widgets.SystemUsage {
                    width: 80
                    height: parent.height - root.vertical_padding * 2
                    text_color: "#ffffff"
                }
            }

            // Right Group of Widgets
            Row {
                id: right_group
                anchors {
                    top: parent.top
                    topMargin: root.vertical_padding
                    right: parent.right
                    rightMargin: root.horizontal_padding
                }
                spacing: root.horizontal_padding
                height: parent.height
                layoutDirection: Qt.RightToLeft

                Widgets.Clock {
                    width: 100
                    height: parent.height - root.vertical_padding * 2
                    text_color: '#ffffff'
                }
            }
        }
    }
}