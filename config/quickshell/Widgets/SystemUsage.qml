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
    property real tempWarningThreshold: 75
    property real tempDangerThreshold: 95

    Rectangle {
        id: backdrop
        property bool hover: false

        anchors {
            left: parent.left
            leftMargin: 5
            verticalCenter: parent.verticalCenter
        }

        color: '#000000'
        width: container.width + 20
        height: parent.height
        radius: 10
    }

    Row {
        id: container
        spacing: 5

        anchors {
            centerIn: backdrop
        }

        Image {
            anchors {
                verticalCenter: parent.verticalCenter
            }
            width: 20
            height: 20
            source: "../themes/svg/cpu.svg"
        }

        Text {
            anchors {
                verticalCenter: parent.verticalCenter
            }
            width: 30
            text: SystemMonitor.cpuUsage + "%"
            color: (SystemMonitor.cpuUsage >= root.dangerThreshold) ? root.danger : 
                    (SystemMonitor.cpuUsage >= root.warningThreshold) ? root.warning : 
                    root.text_color
            font {
                bold: true
                family: "NotoSansMono"
                pointSize: 10
            }
        }

        Image {
            anchors {
                verticalCenter: parent.verticalCenter
            }
            width: 20
            height: 20
            source: "../themes/svg/ram.svg"
        }

        Text {
            anchors {
                verticalCenter: parent.verticalCenter
            }
            width: 30
            text: SystemMonitor.memUsagePercentage + "%"
            color: (SystemMonitor.memUsagePercentage >= root.dangerThreshold) ? root.danger : 
                    (SystemMonitor.memUsagePercentage >= root.warningThreshold) ? root.warning : 
                    root.text_color
            font {
                bold: true
                family: "NotoSansMono"
                pointSize: 10
            }
        }

        Image {
            anchors {
                verticalCenter: parent.verticalCenter
            }
            width: 20
            height: 20
            source: (SystemMonitor.cpuTemp >= root.tempDangerThreshold) ? "../themes/svg/temperature-danger.svg" : 
                    (SystemMonitor.cpuTemp >= root.tempWarningThreshold) ? "../themes/svg/temperature-high.svg" : 
                    "../themes/svg/temperature-normal.svg"
        }

        Text {
            anchors {
                verticalCenter: parent.verticalCenter
            }
            width: 50
            text: SystemMonitor.cpuTempStr
            color: (SystemMonitor.cpuTemp >= root.tempDangerThreshold) ? root.danger : 
                    (SystemMonitor.cpuTemp >= root.tempWarningThreshold) ? root.warning : 
                    root.text_color
            font {
                bold: true
                family: "NotoSansMono"
                pointSize: 10
            }
        }
    }
    
}