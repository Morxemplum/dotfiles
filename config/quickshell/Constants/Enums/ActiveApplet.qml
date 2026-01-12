pragma Singleton
import QtQuick

QtObject {
    enum Value {
        None = 0,
        Calendar = 1,
        AudioMixer = 2,
        NetworkManagerApplet = 3,
        NowPlaying = 4
    }
}