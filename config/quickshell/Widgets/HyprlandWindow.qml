pragma ComponentBehavior : Bound

import QtQuick

import ".."

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
        anchors {
            left: backdrop.left
            leftMargin: Config.widgetRadius
            top: backdrop.top
            // FIXME: Simplify this calculation. This one likes to be a pain in the ass for some reason
            topMargin: backdrop.height / 2 - this.font.pointSize * 3 / 4
        }
        height: parent.height
        color: Config.textColor
        text: Hyprclients.focusedProgram

        font {
            bold: true
            family: Config.displayFontFamily
            pointSize: Config.headerLabelSize
        }
    }
}