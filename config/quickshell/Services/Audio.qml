pragma Singleton
pragma ComponentBehavior : Bound

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: audioRoot
    readonly property real defaultSinkId: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.id : -1
    readonly property real volume: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio.volume : 0
    readonly property int volumePercentage: volume * 100

    PwNodeLinkTracker {
        id: tracker
        node: Pipewire.defaultAudioSink
    }
    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }
}