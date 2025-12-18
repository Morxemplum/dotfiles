pragma Singleton
pragma ComponentBehavior : Bound

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: audioRoot
    property real defaultSinkId: Pipewire.defaultAudioSink.id
    property real volume: Pipewire.defaultAudioSink.audio.volume
    property int volumePercentage: volume * 100

    PwNodeLinkTracker {
        id: tracker
        node: Pipewire.defaultAudioSink
    }
    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }
}