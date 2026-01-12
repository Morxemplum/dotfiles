//@ pragma UseQApplication
pragma ComponentBehavior: Bound
import Quickshell

import "./UI" as UI

Scope {
    id: root

    Variants {
        // I have multiple monitors, I want the bar to show on all of them
        model: Quickshell.screens;
        UI.Bar {}
    }
}



