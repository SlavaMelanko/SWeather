import QtQuick 2.5
import QtQuick.Dialogs 1.2
import Qt.labs.controls 1.0
import Qt.labs.controls.material 1.0

import "HttpRequest.js" as HttpRequest

ApplicationWindow {
	id: _applicationWindow
	width: 240; height: 320
	title: qsTr("SWeather")
	visible: true

	//
	// Property interface.
	//
	property string apiKey: '6f75ff20ca01b304bb986d7019d05adc'
	property string cityId: '706483' // Kharkiv, Ukraine.
	property string units: 'metric'

	//
	// Signals interface.
	//
	signal responseFailed(int status, string msg)
	signal responseReceived(string response)

	Rectangle {
		id: _nebulosity
		x: 10; y: 10
		width: 64; height: 64
		opacity: 1

		property alias source: _nebulosityImg.source

		Image {
			id: _nebulosityImg
			anchors.centerIn: parent
			cache: false
		}
	}
	Label {
		id: _location
		anchors {
			top: parent.top
			left: _nebulosity.right
			leftMargin: 10
		}
	}

	Label {
		id: _temperature
		x: 10
		anchors.top: _nebulosity.bottom
		text: qsTr("Temperature") +", " + "°C" + ":"
	}
	Label {
		id: _temperatureVal
		anchors {
			top: _nebulosity.bottom
			left: _temperature.right
			leftMargin: 10
		}
	}

	Label {
		id: _pressure
		x: 10
		anchors.top: _temperature.bottom
		text: qsTr("Pressure") +", " + qsTr("mmHg") + ":"
	}
	Label {
		id: _pressureVal
		anchors {
			top: _temperature.bottom
			left: _pressure.right
			leftMargin: 10
		}
	}

	Label {
		id: _humidity
		x: 10
		anchors.top: _pressure.bottom
		text: qsTr("Humidity") +", " + "%" + ":"
	}
	Label {
		id: _humidityVal
		anchors {
			top: _pressure.bottom
			left: _humidity.right
			leftMargin: 10
		}
	}

	Label {
		id: _windy
		x: 10
		anchors.top: _humidity.bottom
		text: qsTr("Windy") +", " + qsTr("m/s") + ":"
	}
	Label {
		id: _windyVal
		anchors {
			top: _humidity.bottom
			left: _windy.right
			leftMargin: 10
		}
	}

	Button {
		id: _btn
		width: parent.width / 2; height: parent.height / 10
		anchors.centerIn: parent
		text: qsTr("Test")

		onClicked: {
			var request = makeRequestUrl(cityId, apiKey, units)
			console.log(request)
			getResponse(request)
		}
	}

	MessageDialog {
		id: _msgBox
		icon: StandardIcon.Critical
		modality: Qt.WindowModal
		standardButtons: StandardButton.Ok
		title: qsTr("Error box")
		visible: false

		onAccepted: {
			Qt.quit()
		}
	}

	//
	// Slots implementations.
	//

	onResponseFailed: {
		if (status == 0) {
			_msgBox.informativeText = "No internet connection"
		} else {
			_msgBox.informativeText = status + ': ' + msg
		}

		_msgBox.visible = true
	}

	onResponseReceived: {
		//console.log(response)
		var data = JSON.parse(response)
		var location = data.city.name + ', ' + data.city.country

		for (var i = 0; i < 8; ++i) {
			console.log(data.list[i].dt_txt)
			console.log("       Main: " + data.list[i].weather[0].main)
			console.log("Description: " + data.list[i].weather[0].description)
			console.log("       Icon: " + data.list[i].weather[0].icon)
			console.log("     Clouds: " + data.list[i].clouds.all)
			console.log("Temperature: " + data.list[i].main.temp)
			console.log("   Pressure: " + data.list[i].main.pressure)
			console.log("       Wind: " + data.list[i].wind.speed)
		}

		var weatherDesc = data.list[0].weather[0].main
		var dt = new Date();
		dt.setTime(Date.parse(data.list[0].dt_txt))
		if (weatherDesc === "Clear") {
			var time = dt.getHours()
			if ((time >= 21 && time <= 23) || (time >= 0 && time < 6)) {
				_nebulosity.source = "qrc:///images/moon.png"
			} else {
				_nebulosity.source = "qrc:///images/sun.png"
			}
		}

		_location.text = location
		_temperatureVal.text = data.list[0].main.temp
		_pressureVal.text = data.list[0].main.pressure * 0.75
		_humidityVal.text = data.list[0].main.humidity
		_windyVal.text = data.list[0].wind.speed
	}

	//
	// JS function implementations.
	//

	//! Receives response from the server.
	// @1 - Request url.
	function getResponse(request_) {
		var xhr = new XMLHttpRequest;
		xhr.open("GET", request_, true);
		xhr.onreadystatechange = function() {
			if (xhr.readyState === XMLHttpRequest.DONE) {
				if (xhr.status === 200) {
					_applicationWindow.responseReceived(xhr.responseText)
				} else {
					_applicationWindow.responseFailed(xhr.status, xhr.statusText)
				}
			}
		}
		xhr.send(null)
	}

	//! Makes a request url.
	// @1 - City id.
	// @2 - API key.
	// @3 - Temperature unit. For temperature in Fahrenheit - imperial,
	//      Celsius - metric. Temperature in Kelvin is used by default.
	function makeRequestUrl(cityId_, apiKey_, units_) {
		var request = 'http://api.openweathermap.org/data/2.5/forecast/'
		request += 'city?id=' + cityId_
		request += '&units=' + units_
		request += '&APPID=' + apiKey_
		return request
	}
}
