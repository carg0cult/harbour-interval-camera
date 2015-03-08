import QtQuick 2.0
import QtMultimedia 5.0
import QtPositioning 5.2
import Sailfish.Silica 1.0


Page {
    id: page

    Column {
        id: column
        width: parent.width

        PageHeader { title: "Interval Camera" }

        TextField {
            id: interval
            width: parent.width
            label: qsTr("Distance between photos in m")
            text: "30"
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            validator: DoubleValidator {}
            EnterKey.iconSource: "image://theme/icon-m-enter-close"
            EnterKey.enabled: text.length > 0
            EnterKey.onClicked: focus = false
        }
    }

    TextSwitch {
        id: runSwitch
        text: qsTr("Run")
        anchors.verticalCenter: parent.verticalCenter
        onCheckedChanged: checked ? posSource.start() : posSource.stop()
    }

    Camera {
        id: camera
    }

    PositionSource {
        id: posSource
        updateInterval: 1000
        active: false
        property var lastCoordinate: QtPositioning.coordinate(90, 0)

        onPositionChanged: {
            var coord = posSource.position.coordinate
            var distance = coord.distanceTo(posSource.lastCoordinate)
            if (distance > interval.text) {
                camera.imageCapture.setMetadata("GPSLatitude", coord.latitude)
                camera.imageCapture.setMetadata("GPSLongitude", coord.longitude)
                camera.imageCapture.capture()
                posSource.lastCoordinate.latitude = coord.latitude
                posSource.lastCoordinate.longitude = coord.longitude
            }
        }
    }
}
