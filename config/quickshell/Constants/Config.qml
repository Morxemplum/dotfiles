pragma Singleton
pragma ComponentBehavior : Bound

import Quickshell
import QtQuick

Singleton {
    property string wallpaperPath: "./themes/wallpapers/bees_on_yellow.jpg"

    // App Defaults
    property string terminalEmu: "kitty"
    property string sysMonitorApp: "btop"
    property string audioManager: "pwvucontrol"

    // Text Constants
    property string displayFontFamily: "AdwaitaSans"
    property string monoFontFamily: "NotoSansMono"
    property real labelSize: 10
    property real headerLabelSize: 12
    property real tooltipLabelSize: 12

    // Color palette
    property color primaryColor: "#000000"
    property color accentColor: '#00ffc8'
    property color urgentColor: '#8dff0000'
    property color textColor: '#ffffff'

    property color appletBackgroundColor: '#262626'
    property color appletTextColor: textColor
    property color toggleInactiveColor: '#4d4d4d'

    // Bar Related Constants
    property real barHeight: 40
    property real barHorizontalPadding: 5
    property real barVerticalPadding: 5

    property bool barBlurEnabled: true
    property real barBlurStrength: 2

    property color barFrostColor: '#454545'
    property color barTint: '#4f480c'
    property real barTintStrength: 0.5

    // Widget Related Constants
    property real widgetHorizontalPadding: 10
    property real widgetRadius: 10
    property real iconSize: 20

    // Tooltip Related Constants
    property real tooltipOpacity: 0.8
    property real tooltipPadding: 5

    // Slider Related Constants
    property real sliderBackgroundRadius: 3
    property real sliderBackgroundHeight: 10
}