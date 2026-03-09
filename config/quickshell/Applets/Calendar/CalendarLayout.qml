pragma ComponentBehavior : Bound

import QtQuick

import "../../Constants"
import "../../Services"

Rectangle {
    id: root
    readonly property real scaleFactor: (Environment.appletMonitor != null) ? Environment.appletMonitor.devicePixelRatio : 1
    color: Config.appletForegroundColor
    radius: Config.appletForegroundRadius

    Text {
        id: month
        anchors {
            top: parent.top
            topMargin: Config.appletPadding
            horizontalCenter: parent.horizontalCenter
        }
        height: Config.appletHeader2PointSize * root.scaleFactor
        color: Config.appletTextColor
        text: Date.monthStr
    
        font {
            bold: true
            family: Config.displayFontFamily
            pointSize: Config.appletHeader2PointSize
        }
    }

    Row {
        id: daysOfTheWeek
        anchors.top: month.bottom
        // TODO: Some people may prefer seeing their weekdays in a different order. Perhaps we can capture other common formats?
        // TODO: In addition, we may also want to try and provide more abbreviated versions of the days depending on the applet's size
        readonly property list<string> dayNames: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

        width: parent.width
        height: Config.appletHeader3PointSize * root.scaleFactor

        Repeater {
            model: daysOfTheWeek.dayNames.length

            Text {
                required property int index
                width: daysOfTheWeek.width / daysOfTheWeek.dayNames.length
                height: daysOfTheWeek.height
                horizontalAlignment: Text.AlignHCenter
                color: Config.appletTextColor
                text: daysOfTheWeek.dayNames[index]

                font {
                    bold: true
                    family: Config.standardFontFamily
                    pointSize: Config.appletHeader3PointSize
                }
            }
        }
    }

    Grid {
        columns: 7

        anchors.top: daysOfTheWeek.bottom
        width: parent.width

        Repeater {
            model: Date.numDays + Date.firstDayIndex

            Text {
                required property int index
                property int dayLabel: index - Date.firstDayIndex + 1
                width: daysOfTheWeek.width / daysOfTheWeek.dayNames.length
                height: width
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Config.appletTextColor
                text: (dayLabel > 0 && dayLabel <= Date.numDays) ? dayLabel : ""

                font {
                    family: Config.standardFontFamily
                    pointSize: Config.labelSize
                }
            }
        }
    }
}