pragma ComponentBehavior : Bound

import QtQuick

import ".."

Item {
    id: root

    Rectangle {
        id: backdrop
        color: '#000000'

        width: currWindow.width + 20
        height: parent.height 
        radius: 10
    }

    Text {
        id: currWindow
        anchors {
            left: backdrop.left
            leftMargin: 10
            top: backdrop.top
            topMargin: backdrop.height / 2 - this.font.pointSize * 3 / 4
        }
        height: parent.height
        color: "#fff"
        text: Hyprclients.focusedProgram

        font {
            bold: true
            family: "AdwaitaSans"
            pointSize: 12
        }
    }
}