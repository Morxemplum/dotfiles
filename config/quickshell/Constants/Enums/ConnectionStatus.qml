pragma Singleton
import QtQuick

QtObject {
    enum Value {
        None = 0,
        Pending = 1,
        Wireless = 2,
        Ethernet = 3,
        Limited = 4
    }
}