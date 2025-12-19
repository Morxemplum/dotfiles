pragma ComponentBehavior : Bound
import QtQuick

import "../Constants"
import "../Services"

Item {
    id: root
    property color textColor

    Rectangle {
        property bool hover: false

        color: Config.accentColor

        width: parent.width
        height: parent.height
        radius: Config.widgetRadius

        Text {
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }
            // When hovering the cursor over the element, display the date
            text: parent.hover ? Time.date : Time.time
            color: root.textColor
            font {
                bold: true
                family: Config.displayFontFamily
                pointSize: Config.labelSize
            }
        }
        // Add hover behavior
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: {
                parent.hover = true
            }

            onExited: {
                parent.hover = false
            }
        }
    }
}