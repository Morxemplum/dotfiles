pragma Singleton
pragma ComponentBehavior : Bound

import Quickshell
import QtQuick

Singleton {
    enum ConnectionStatus {
        None = 0,
        Pending = 1,
        Wireless = 2,
        Ethernet = 3,
        Limited = 4
    }
}