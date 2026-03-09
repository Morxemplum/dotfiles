pragma Singleton
pragma ComponentBehavior : Bound

import Quickshell
import Quickshell.Io
import QtQuick

// This is similar to Services.Time, but this module is much more specialized in getting date information and calendar layouts
Singleton {
    id: root

    property int year
    property int month
    property string monthStr
    property int day

    property int numWeeks
    property int numDays
    property int firstDayIndex

    readonly property Process currentDate: dateProc
    readonly property Process calendarFormat: numWeeksProc

    Process {
        id: dateProc
        command: ["date", "+%Y;%m;%d;%B"]

        stdout: StdioCollector {
            onStreamFinished: {
                const date = this.text.split(";")
                root.year = date[0]
                root.month = date[1]
                root.monthStr = date[3]
                root.day = date[2]
                numWeeksProc.running = true
            }
        }
    }

    Process {
        id: numWeeksProc
        command: ["sh", "-c", "cal " + root.month + " " + root.year + " | tail -n +3 | grep -v '^[[:space:]]*$' | wc -l"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.numWeeks = parseInt(this.text)
                firstDayProc.running = true
            }
        }
    }

    Process {
        id: firstDayProc
        command: ["sh", "-c", "date -d '" + root.year + "-0" + root.month + "-01' +%w"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.firstDayIndex = parseInt(this.text)
                numDaysProc.running = true
            }
        }
    }

    Process {
        id: numDaysProc
        command: ["sh", "-c", "date -d '" + root.year + "-0" + root.month + "-01 -1 day' +%d"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.numDays = parseInt(this.text)
            }
        }
    }
}