pragma Singleton
pragma ComponentBehavior : Bound

import Quickshell
import Quickshell.Io
import QtQuick

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
                networkRoot.name = info[3]
            }
        }
    }

    // If primary connection is wifi, get wifi information
    Process {
        id: wifiInfoPrc
        command: ["sh", "-c", "nmcli -t -f IN-USE,SIGNAL,SSID dev wifi list ifname wlan0 | awk -F: '$1==\"*\" {print $2}'"]

        stdout: StdioCollector {
            onStreamFinished: {
                const info = this.text.split(/[:]/)
                networkRoot.wifiStrength = info[1]
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: statusHeartbeat.running = true
    }
}