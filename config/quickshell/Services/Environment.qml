pragma Singleton
pragma ComponentBehavior : Bound

import Quickshell

import "../Constants/Enums"

Singleton {
    property int activeApplet: ActiveApplet.Value.None
    property ShellScreen appletMonitor: null // We don't want the applet to appear on all screens
}