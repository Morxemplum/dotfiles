pragma ComponentBehavior : Bound
import QtQuick

import "../Constants"
import "../Services"

Item {
    id: root
    property color textColor
    property bool hover: false

    Rectangle {
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
            hoverEnabled: true

            onEntered: root.hover = true
            onExited: root.hover = false
        }
    }
}