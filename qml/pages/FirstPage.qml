/*
    Copyright (C) 2015 Robert Voigt

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import QtMultimedia 5.0
import QtPositioning 5.2
import QtSensors 5.0
import Sailfish.Silica 1.0
import "../localdb.js" as DB


Page {
	id: page

	Column {
		id: column
		width: parent.width

		PageHeader { title: qsTr("Interval Camera") }

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
        onCheckedChanged: {
            checked ? posSource.start() : posSource.stop()
            checked ? orSensor.start() : orSensor.stop()
        }
	}

	Camera {
		id: camera
	}

	PositionSource {
		id: posSource
        updateInterval: 3000
		active: false
        property var lastCoordinate: QtPositioning.coordinate(90, 0)

		onPositionChanged: {
			var coord = posSource.position.coordinate
			var distance = coord.distanceTo(posSource.lastCoordinate)
            if (distance > interval.text) {
                setGpsData(coord)
                setOrientation(orSensor.reading.orientation)
                camera.imageCapture.setMetadata("Date", posSource.position.timestamp)

                camera.imageCapture.capture()
				posSource.lastCoordinate.latitude = coord.latitude
				posSource.lastCoordinate.longitude = coord.longitude
			}
		}

        function setGpsData(coord) {
            camera.imageCapture.setMetadata("GPSLatitude", coord.latitude)
            camera.imageCapture.setMetadata("GPSLongitude", coord.longitude)
            camera.imageCapture.setMetadata("GPSAltitude", coord.altitude)
        }

        function setOrientation(orientation) {
            if (orientation === OrientationReading.RightUp)
                camera.imageCapture.setMetadata("Orientation", 0)
            else if (orientation === OrientationReading.TopUp)
                camera.imageCapture.setMetadata("Orientation", 270)
            else if (orientation === OrientationReading.LeftUp)
                camera.imageCapture.setMetadata("Orientation", 180)
            else if (orientation === OrientationReading.TopDown)
                camera.imageCapture.setMetadata("Orientation", 90)
        }
	}

    OrientationSensor {
        id: orSensor
        active: false
    }

	Component.onCompleted: {
		DB.initializeDB()
		DB.readData()
	}

	Component.onDestruction: {
		DB.storeData();
	}
}
