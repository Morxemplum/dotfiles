pragma ComponentBehavior : Bound

import QtQuick

import "../Constants"
import "../Services"

Item {
    id: root

    Rectangle {
        id: backdrop
        color: Config.accentColor

        width: currWindow.width + Config.widgetRadius + Config.widgetHorizontalPadding
        height: parent.height 
        radius: Config.widgetRadius
    }

    Text {
        id: currWindow
        anchors.centerIn: backdrop
        color: Config.textColor
        text: Hyprclients.focusedProgram

        font {
            bold: true
            family: Config.displayFontFamily
            pointSize: Config.headerLabelSize
        }
    }
}