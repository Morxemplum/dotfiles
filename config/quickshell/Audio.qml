pragma Singleton
pragma ComponentBehavior : Bound

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: audioRoot
    // FIXME: Make sure that these values are only assigned once the sink is being tracked. We get warnings from Quickshell upon initializiation
    readonly property real defaultSinkId: Pipewire.defaultAudioSink.id
    readonly property real volume: Pipewire.defaultAudioSink.audio.volume
    readonly property int volumePercentage: volume * 100

    PwNodeLinkTracker {
        id: tracker
        node: Pipewire.defaultAudioSink
    }
    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }
}