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

    enum ActiveApplet {
        None = 0,
        Calendar = 1,
        AudioMixer = 2,
        NetworkManagerApplet = 3,
        NowPlaying = 4
    }
}