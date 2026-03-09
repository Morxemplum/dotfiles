pragma ComponentBehavior : Bound
import Quickshell
import QtQuick

import "../Applets/Calendar" as Calendar
import "../Constants"
import "../Constants/Enums"
import "../Services"

Item {
    id: root
    property PanelWindow bar
    property color textColor
    property bool hover: false

    Rectangle {
        id: widget
        color: Config.primaryColor

        width: parent.width
        height: parent.height
        radius: Config.widgetRadius

        Text {
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }
            text: Time.time
            color: root.textColor
            font {
                bold: true
                family: Config.displayFontFamily
                pointSize: Config.labelSize
            }
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            hoverEnabled: true

            onEntered: root.hover = true
            onExited: root.hover = false

            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    if (Environment.activeApplet === ActiveApplet.Value.Calendar && Environment.appletMonitor == root.bar.screen) {
                        Environment.activeApplet = ActiveApplet.Value.None
                        Environment.appletMonitor = null
                    } else {
                        Environment.activeApplet = ActiveApplet.Value.Calendar
                        Environment.appletMonitor = root.bar.screen
                    }
                }
            }
        }
    }
    Calendar.Window {
        bar: root.bar
        item: widget
    }
}