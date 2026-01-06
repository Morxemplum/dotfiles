pragma Singleton
pragma ComponentBehavior : Bound

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property bool showVRAMUsage: true

    // CPU Related properties
    property real lastCpuTotal: 0
    property real lastCpuIdle: 0
    property list<real> lastCpuCoreTotal: []
    property list<real> lastCpuCoreIdle: []

    // Basic System Stats
    property real cpuUsage: 0
    property real memUsagePercentage: 0
    property real cpuTemp: 0
    property string cpuTempStr: "0°C"

    // Tooltip / Advanced System Stats
    property string cpuThreadUsage
    property real memUsed: 0
    property real memTotal: 1
    property bool isNVIDIA
    property real vramUsed: 0
    property real vramTotal: 1
    property int vramUsagePercentage: 0
    property string cpuCoreTemps

    // Item refs
    readonly property Timer cpuTimer: uptTimer
    readonly property Timer memTimer: ramTimer
    readonly property Timer tempTimer: tpcTimer

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

    function threadUsageActivated() {
        usagePerThreadProc.running = true
        uptTimer.start()
    }

    function fullMemoryActivated() {
        fullMemoryProc.running = true
        vramProc.running = root.showVRAMUsage
        ramTimer.start()
    }

    function tempCoresActivated() {
        tempPerCoreProc.running = true
        tpcTimer.start()
    }

    function memoryUsageString() {
        let str = qsTr("Memory Used (MB)") + ": " + root.memUsed + "\n" +
                  qsTr("Total Memory (MB)") + ": " + root.memTotal
        if (root.showVRAMUsage) {
            str += "\n\n" + 
                  qsTr("VRAM Used (MiB)") + ": " + root.vramUsed + " (" + root.vramUsagePercentage + "%)\n" +
                  qsTr("Total VRAM (MiB)") + ": " + root.vramTotal
        }
        return str
    }

    Process {
        id: usagePerThreadProc
        command: ["sh", "-c", "cat /proc/stat | grep '^cpu' | tail -n +2"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.split("\n")
                let string = ""
                let i = 0
                for (const line of lines) {
                    const p = line.split(/\s+/)
                    if (p.length <= 1) continue;
                    const idle = parseInt(p[4]) + parseInt(p[5])
                    const total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0)
                    if (root.lastCpuCoreTotal[i] > 0) {
                        const coreUsage = Math.round(100 * (1 - (idle - root.lastCpuCoreIdle[i]) / (total - root.lastCpuCoreTotal[i])))
                        string += "Thread " + i + ": " + coreUsage + "%\n"
                    }
                    root.lastCpuCoreTotal[i] = total
                    root.lastCpuCoreIdle[i] = idle
                    i++
                }
                root.cpuThreadUsage = string.length > 1 ? string.trim() : "Calculating thread usage..."
            }
        }
    }

    Process {
        id: fullMemoryProc
        command: ["sh", "-c", "free -m | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                const p = data.trim().split(/\s+/)
                root.memTotal = parseInt(p[1])
                root.memUsed = parseInt(p[2])
            }
        }
    }

    // This is a one-off process.
    Process {
        id: identifyNVIDIA
        command: ["sh", "-c", "lspci | grep VGA | grep NVIDIA"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.isNVIDIA = this.text.length > 0
            }
        }
    }

    Process {
        id: vramProc
        // FIXME: Figure out how to do this with non-NVIDIA GPUs
        command: root.isNVIDIA ? ["nvidia-smi","--query-gpu=memory.used,memory.total","--format=csv,noheader,nounits"] : ["echo", "Please implement me! :)"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.isNVIDIA) {
                    const info = this.text.split(", ")
                    root.vramUsed = info[0]
                    root.vramTotal = info[1]
                    root.vramUsagePercentage = Math.round(100 * (root.vramUsed / root.vramTotal))
                } else {
                    console.log("Non-NVIDIA Method for accessing VRAM not implemented")
                }
            }
        }
    }

    Process {
        id: tempPerCoreProc
        command: ["sh", "-c", "sensors coretemp-isa-0000 | tail -n +4"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.split("\n")
                let string = ""
                for (const line of lines) {
                    const info = line.split(/\s+/)
                    if (info.length <= 1) continue;
                    string += info.slice(0, 3).join(" ") + "\n"
                }
                root.cpuCoreTemps = string.trim()
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

    Timer {
        id: uptTimer
        interval: 1000
        running: false
        repeat: true
        onTriggered: usagePerThreadProc.running = true
    }

    Timer {
        id: ramTimer
        interval: 1000
        running: false
        repeat: true
        onTriggered: {
            fullMemoryProc.running = true
            vramProc.running = root.showVRAMUsage
        }
    }

    Timer {
        id: tpcTimer
        interval: 1000
        running: false
        repeat: true
        onTriggered: tempPerCoreProc.running = true
    }
}