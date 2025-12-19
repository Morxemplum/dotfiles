pragma Singleton
pragma ComponentBehavior : Bound

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property real lastCpuTotal: 0
    property real lastCpuIdle: 0

    property real cpuUsage: 0
    property real memUsagePercentage: 0
    property real cpuTemp: 0
    property string cpuTempStr: "0°C"

    Process {
        id: cpuProc
        command: ["head", "-1", "/proc/stat"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const p = data.trim().split(/\s+/)
                const idle = parseInt(p[4]) + parseInt(p[5])
                const total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0)
                if (root.lastCpuTotal > 0) {
                    root.cpuUsage = Math.round(100 * (1 - (idle - root.lastCpuIdle) / (total - root.lastCpuTotal)))
                }
                root.lastCpuTotal = total
                root.lastCpuIdle = idle
            }
        }
    }

    Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const p = data.trim().split(/\s+/)
                const totalMemory = parseInt(p[1])
                const usingMemory = parseInt(p[2])
                root.memUsagePercentage = Math.round(100 * (usingMemory / totalMemory))
            }
        }
    }
    
    Process {
        id: tempProc
        // Keep in mind this can very well change depending on the hardware
        // Try to find a way to display a failure?
        command: ["sh", "-c", "sensors coretemp-isa-0000 | grep Package"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const p = data.trim().split(/\s+/)
                root.cpuTempStr = p[3].slice(1)
                root.cpuTemp = parseInt(root.cpuTempStr.slice(0, -2))
            }
        }
    }


    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true
            memProc.running = true
            tempProc.running = true
        }
    }
}