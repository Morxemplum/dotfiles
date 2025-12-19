pragma ComponentBehavior : Bound
import QtQuick

import "../Constants"
import "../Services"

Item {
    id: root
    property color textColor
    property real statSpacing: 5
    property real labelWidth: 30
    property real tempLabelWidth: 50

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
            verticalCenter: parent.verticalCenter
        }

        color: Config.accentColor
        width: container.width + Config.widgetRadius + Config.widgetHorizontalPadding
        height: parent.height
        radius: Config.widgetRadius
    }

    Row {
        id: container
        spacing: root.statSpacing

        anchors {
            centerIn: backdrop
        }

        Image {
            anchors {
                verticalCenter: parent.verticalCenter
            }
            width: this.height
            height: Config.iconSize
            source: "../themes/svg/cpu.svg"
        }

        Text {
            anchors {
                verticalCenter: parent.verticalCenter
            }
            width: root.labelWidth
            text: SystemMonitor.cpuUsage + "%"
            color: (SystemMonitor.cpuUsage >= root.dangerThreshold) ? root.danger : 
                    (SystemMonitor.cpuUsage >= root.warningThreshold) ? root.warning : 
                    root.textColor
            font {
                bold: true
                family: Config.monoFontFamily
                pointSize: Config.labelSize
            }
        }

        Image {
            anchors {
                verticalCenter: parent.verticalCenter
            }
            width: this.height
            height: Config.iconSize
            source: "../themes/svg/ram.svg"
        }

        Text {
            anchors {
                verticalCenter: parent.verticalCenter
            }
            width: root.labelWidth

            text: SystemMonitor.memUsagePercentage + "%"
            color: (SystemMonitor.memUsagePercentage >= root.dangerThreshold) ? root.danger : 
                    (SystemMonitor.memUsagePercentage >= root.warningThreshold) ? root.warning : 
                    root.textColor
            font {
                bold: true
                family: Config.monoFontFamily
                pointSize: Config.labelSize
            }
        }

        Image {
            anchors {
                verticalCenter: parent.verticalCenter
            }
            width: this.height
            height: Config.iconSize
            source: (SystemMonitor.cpuTemp >= root.tempDangerThreshold) ? "../themes/svg/temperature-danger.svg" : 
                    (SystemMonitor.cpuTemp >= root.tempWarningThreshold) ? "../themes/svg/temperature-high.svg" : 
                    "../themes/svg/temperature-normal.svg"
        }

        Text {
            anchors {
                verticalCenter: parent.verticalCenter
            }
            width: root.tempLabelWidth
            text: SystemMonitor.cpuTempStr
            color: (SystemMonitor.cpuTemp >= root.tempDangerThreshold) ? root.danger : 
                    (SystemMonitor.cpuTemp >= root.tempWarningThreshold) ? root.warning : 
                    root.textColor
            font {
                bold: true
                family: Config.monoFontFamily
                pointSize: Config.labelSize
            }
        }
    }
    
}