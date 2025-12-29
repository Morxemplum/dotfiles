pragma Singleton
pragma ComponentBehavior : Bound

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property string date
    property string time
    property string time12
    property string dateFull

    readonly property Timer tooltipTimer: fdtTimer

    function tooltipActivated() {
        fullDatetimeProc.running = true
        fdtTimer.start()
    }

    Process {
        id: datetimeProc
        command: ["date", "+%Y/%m/%d %H:%M:%S"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                // Yuck. JavaScript!
                const datetime = this.text.split(" ")
                root.date = datetime[0]
                root.time = datetime[1]
            }
        }
    }

    // TODO: Might be better to make 12 hour time a setting, instead of displaying it separately
    Process {
        id: fullDatetimeProc
        command: ["date", "+%I:%M:%S %p;%A, %B %d %Y"]

        stdout: StdioCollector {
            onStreamFinished: {
                const datetime = this.text.split(";")
                root.time12 = datetime[0]
                root.dateFull = datetime[1]
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: datetimeProc.running = true
    }

    Timer {
        id: fdtTimer
        interval: 1000
        running: false
        repeat: true
        onTriggered: fullDatetimeProc.running = true
    }
}