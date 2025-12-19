pragma Singleton
pragma ComponentBehavior : Bound

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property string date
    property string time

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

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: datetimeProc.running = true
    }
}