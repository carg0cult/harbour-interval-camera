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

	Component.onCompleted: {
		DB.initializeDB()
		DB.readData()
	}

	Component.onDestruction: {
		DB.storeData();
	}
}
