pragma Singleton
pragma ComponentBehavior : Bound

import Quickshell
import Quickshell.Io
import QtQml
import QtQuick

import "../Constants/"

// Quickshell does not offer any utility to help assist with networking, so we
// will need to use processes to try and determine network statuses and other
// information.

// This module makes the assumption that you are using NetworkManager for your
// networking.
Singleton {
    id: networkRoot

    property int status: Enums.ConnectionStatus.None
    property string device
    property string name
    property int wifiStrength

    // Up/Down data (in bytes). These must be real as QML int is only signed 32-bit
    property real totalRcv 
    property real totalTrans
    property real lastRcv: -1
    property real lastTrans: -1
    property real rateRcv: 0
    property real rateTrans: 0
    readonly property Timer dataTimer: dt

    // Get the general connectivity status first.
    Process {
        id: statusHeartbeat
        command: ["nmcli", "-f", "CONNECTIVITY", "-t", "general"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                switch (this.text.trim()) {
                    case "full":
                        connectionTypePrc.running = true
                        break;
                    case "limited":
                        networkRoot.status = Enums.ConnectionStatus.Limited
                        break;
                    default:
                        networkRoot.status = Enums.ConnectionStatus.None
                        break;
                }
            }
        }
    }

    // Get info about the primary connection
    Process {
        id: connectionTypePrc
        command: ["sh", "-c", "nmcli -f DEVICE,TYPE,STATE,CONNECTION -t device status | head -1"]

        stdout: StdioCollector {
            onStreamFinished: {
                const info = this.text.split(/[:]/)
                networkRoot.device = info[0]
                switch (info[1]) {
                    case "ethernet":
                        networkRoot.status = Enums.ConnectionStatus.Ethernet
                        break
                    case "wifi":
                        networkRoot.status = Enums.ConnectionStatus.Wireless
                        wifiInfoPrc.running = true
                        break
                    default:
                        networkRoot.status = Enums.ConnectionStatus.Pending
                }
                // TODO: Rewrite the command so that it can iterate down the list if the current connection happens to be disconnected
                if (info[2] == "disconnected") {
                    networkRoot.status = Enums.ConnectionStatus.None
                }
                networkRoot.name = info[3].trim()
            }
        }
    }

    // If primary connection is wifi, get wifi information
    Process {
        id: wifiInfoPrc
        command: ["sh", "-c", "nmcli -t -f IN-USE,SIGNAL,SSID dev wifi list ifname wlan0 | awk -F: '$1==\"*\" {print $2}'"]

        stdout: StdioCollector {
            onStreamFinished: {
                networkRoot.wifiStrength = parseInt(this.text)
            }
        }
    }

    function formatFileSize(bytes) {
        const sizes = ['B', 'KB', 'MB', 'GB', 'TB', "PB"];
        if (bytes === 0) return '0 B';
        const i = parseInt(Math.floor(Math.log(bytes) / Math.log(1000)));
        let rate = (bytes / Math.pow(1000, i))
        if (i > 0) rate = rate.toPrecision(4)
        return rate + ' ' + sizes[i];
    }

    function getStatusString() {
        switch (networkRoot.status) {
            case Enums.ConnectionStatus.None:
                return qsTr("No connection")
            case Enums.ConnectionStatus.Pending:
                return qsTr("Connecting...")
            case Enums.ConnectionStatus.Wireless | Enums.ConnectionStatus.Ethernet:
                return qsTr("Connected")
            case Enums.ConnectionStatus.Limited:
                return qsTr("Limited")
        }
    }

    function connectionInfoStr() {
        switch (networkRoot.status) {
            case Enums.ConnectionStatus.None | Enums.ConnectionStatus.Pending:
                return getStatusString()
            default:
                let str = networkRoot.name + " (" + networkRoot.device + ")\n"
                str += qsTr("Status") + ": " + getStatusString() + "\n" 
                str += (networkRoot.status == Enums.ConnectionStatus.Wireless) ? qsTr("Wi-Fi Signal") + ": " + networkRoot.wifiStrength + "%\n\n" : "\n"
                // TODO: Maybe add an option to show the rates in bits instead of bytes?
                str += qsTr("Data Received") + ": \n" + formatFileSize(networkRoot.totalRcv) + " (" + formatFileSize(networkRoot.rateRcv) + "/s)\n"
                str += qsTr("Data Transmitted") + ": \n" + formatFileSize(networkRoot.totalTrans) + " (" + formatFileSize(networkRoot.rateTrans) + "/s)"
                return str
        }
    }

    function dataActivated() {
        networkDataPrc.running = true
        dt.start()
    }

    // Get data stats for our network connection
    Process {
        id: networkDataPrc
        command: ["sh", "-c", "cat /proc/net/dev | grep " + networkRoot.device]
        stdout: StdioCollector {
            onStreamFinished: {
                const info = this.text.split(/\s+/)
                if (info.length <= 1) return
                networkRoot.totalRcv = info[1]
                networkRoot.totalTrans = info[9]
                if (networkRoot.lastRcv >= 0) {
                    networkRoot.rateRcv = networkRoot.totalRcv - networkRoot.lastRcv
                    networkRoot.rateTrans = networkRoot.totalTrans - networkRoot.lastTrans
                }
                networkRoot.lastRcv = networkRoot.totalRcv
                networkRoot.lastTrans = networkRoot.totalTrans
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: statusHeartbeat.running = true
    }

    Timer {
        id: dt
        interval: 1000
        running: false
        repeat: true
        onTriggered: networkDataPrc.running = true
    }
}