pragma ComponentBehavior : Bound
import QtQuick

import ".."

Item {
    id: root
    property color text_color

    property color warning: '#ffff00'
    property color danger: '#ff8000'
    property real warningThreshold: 50
    property real dangerThreshold: 80

    Row {
        anchors.fill: parent
        spacing: 5

        Rectangle {
            property bool hover: false

            color: '#000000'

            width: 80
            height: parent.height
            radius: 10

            Text {
                anchors {
                    left: parent.left
                    leftMargin: 5
                    verticalCenter: parent.verticalCenter
                }
                // When hovering the cursor over the element, display the date
                text: "CPU: " + SystemMonitor.cpuUsage + "%"
                color: (SystemMonitor.cpuUsage >= root.dangerThreshold) ? root.danger : 
                        (SystemMonitor.cpuUsage >= root.warningThreshold) ? root.warning : 
                        root.text_color
                font {
                    bold: true
                    family: "NotoSansMono"
                    pointSize: 10
                }
            }
        }

        Rectangle {
            property bool hover: false

            color: '#000000'

            width: 80
            height: parent.height
            radius: 10

            Text {
                anchors {
                    left: parent.left
                    leftMargin: 5
                    verticalCenter: parent.verticalCenter
                }
                // When hovering the cursor over the element, display the date
                text: "Mem: " + SystemMonitor.memUsagePercentage + "%"
                color: (SystemMonitor.memUsagePercentage >= root.dangerThreshold) ? root.danger : 
                        (SystemMonitor.memUsagePercentage >= root.warningThreshold) ? root.warning : 
                        root.text_color
                font {
                    bold: true
                    family: "NotoSansMono"
                    pointSize: 10
                }
            }
        }

        Rectangle {
            property bool hover: false

            color: '#000000'

            width: 110
            height: parent.height
            radius: 10

            Text {
                anchors {
                    left: parent.left
                    leftMargin: 5
                    verticalCenter: parent.verticalCenter
                }
                // When hovering the cursor over the element, display the date
                text: "Temp: " + SystemMonitor.cpuTempStr
                color: (SystemMonitor.cpuTemp >= root.dangerThreshold) ? root.danger : 
                        (SystemMonitor.cpuTemp >= root.warningThreshold) ? root.warning : 
                        root.text_color
                font {
                    bold: true
                    family: "NotoSansMono"
                    pointSize: 10
                }
            }
        }
    }
    
}