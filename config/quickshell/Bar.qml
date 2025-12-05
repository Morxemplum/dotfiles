pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Effects

import "./Widgets" as Widgets

Scope {
    id: root
    property real vertical_padding: 5

    Variants {
        // I have multiple monitors, I want the bar to show on all of them
        model: Quickshell.screens;

        PanelWindow {
            id: shellbar

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
                id: mybar
                anchors.fill: parent
                visible: false // We are applying post-processing, so let's not render the image twice

                Image {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    height: shellbar.screen.height
                    source: "./themes/wallpapers/bees_on_yellow.jpg"
                }
            }
            // Our upcoming blur will introduce transparency, this rectangle will help cancel out the alpha
            Rectangle {
                id: backpanel
                anchors.fill: parent
                color: '#454545'
            }
            // Blur the image above
            MultiEffect {
                source: mybar
                anchors.fill: parent
                blurEnabled: true
                blur: 1
                blurMultiplier: 2
            }
            Rectangle {
                id: backdrop
                anchors.fill: parent
                color: '#4f480c'
                opacity: 0.5
            }

            // Time
            Widgets.Clock {
                width: 100
                height: parent.height - root.vertical_padding * 2
                anchors {
                    top: parent.top
                    topMargin: root.vertical_padding
                    horizontalCenter: parent.horizontalCenter
                    horizontalCenterOffset: -this.width / 2
                }
                color: '#ffffff'
            }
        }
    }
}