pragma Singleton
pragma ComponentBehavior : Bound

import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

Item {
    id: root
    property string focusedProgram
    property string focusedWindow
    property bool activeFullscreen

    Process {
        id: activeWindow
        command: ["hyprctl", "activewindow", "-j"]

        stdout: StdioCollector {
            onStreamFinished: {
                const parsedJSON = JSON.parse(this.text)
                var title = parsedJSON["initialTitle"]
                const delimiters = ["—", "-"]
                var badTitle = false

                // Borderless fullscreen applications under XWayland aren't picked up as fullscreen by Hyprland
                if (parsedJSON["xwayland"] && parsedJSON["floating"]) {
                    const monitor = Hyprland.focusedMonitor
                    if (monitor != null) {
                        // X11 doesn't support fractional scaling, so we have to calculate the scale factor to the truncated integer scale
                        const scaleFactor = monitor.scale / Math.floor(monitor.scale)
                        const scaledWidth = monitor.width / scaleFactor
                        const scaledHeight = monitor.height / scaleFactor

                        root.activeFullscreen = (parsedJSON["size"][0] == scaledWidth && parsedJSON["size"][1] == scaledHeight)
                    }
                } else {
                    root.activeFullscreen = parsedJSON["fullscreen"]
                }

                // If the title isn't properly initialized, then refer to the current title
                if (title.trim() == "") {
                    title = parsedJSON["title"]
                }
                // Unfortunately initialTitle is not always perfect. So we'll find common delimiters and identify bad titles
                for (const delimiter of delimiters) {
                    if (title.includes(delimiter)) {
                        badTitle = true
                        break;
                    }
                }
                if (badTitle) {
                    var programClass = parsedJSON["class"]
                    // Classes will often include the full namespace, so strip out to the very program we want
                    const namespaceCheck = programClass.lastIndexOf(".") 
                    if (namespaceCheck >= 0) {
                        programClass = programClass.substring(namespaceCheck + 1)
                    }
                    const spacingDelimiters = ["-", "_"]
                    // Thanks JavaScript for not having a basic replace character function
                    function replaceChar(str, index, c) {
                        return str.substring(0, index) + c + str.substring(index + 1)
                    }
                    // Replace common space delimiters with spaces, and capitalize letters at the beginning and after spaces
                    for (var i = 0; i < programClass.length; i++) {
                        if (i == 0) {
                            programClass = replaceChar(programClass, i, programClass[i].toUpperCase())
                        }
                        if (spacingDelimiters.includes(programClass[i])) {
                            programClass = replaceChar(programClass, i, " ")
                            programClass = replaceChar(programClass, i + 1, programClass[i + 1].toUpperCase())
                        }
                    }
                    root.focusedProgram = programClass
                    
                } else {
                    root.focusedProgram = title
                }
            }
        }
    }
    
    Connections {
        target: Hyprland

        function onRawEvent(event) {
            const splitData = event.data.split(",")
            switch (event.name) {
                case "activewindow":
                    // The direct data gives the current class and title
                    // This is no good for my use case, as programs will often change the title to convey additional information
                    // I found the best trait that fits my use case is initialTitle, but I'll save a separate property with the current one
                    
                    root.focusedWindow = splitData[1]
                    activeWindow.running = true
                    break;
            }
        }
    }
    
}