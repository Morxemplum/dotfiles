pragma ComponentBehavior : Bound
import Quickshell
import QtQuick

import ".."

Item {
    id: root
    property color text_color

    Rectangle {
        property bool hover: false

        color: '#000000'

        width: parent.width
        height: parent.height
        radius: 10

        Text {
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }
            // When hovering the cursor over the element, display the date
            text: parent.hover ? Time.date : Time.time
            color: root.text_color
            font {
                bold: true
                family: "AdwaitaSans"
                pointSize: parent.height / 3
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