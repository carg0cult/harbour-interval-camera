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

.import QtQuick.LocalStorage 2.0 as LS


function connectDB() {
	return LS.LocalStorage.openDatabaseSync("IntervalCamera", "1.0", "Interval Camera database", 100000);
}


function initializeDB() {
	var db = connectDB();

	db.transaction( function(tx) {
		tx.executeSql('CREATE TABLE IF NOT EXISTS data(name TEXT, value TEXT)');
	});
	return db;
}


function readData() {
	var db = connectDB();
	if(!db) {
		return;
	}
	db.transaction( function(tx) {
		var result = tx.executeSql('select * from data where name = "interval"');
		if (result.rows.length === 1) {
			var value = result.rows[0].value;
			var obj = JSON.parse(value)
			interval.text = obj.interval;
		}
	});
}


function storeData() {
	var db = connectDB();
	if(!db) {
		return;
	}
	db.transaction( function(tx) {
		var result = tx.executeSql('SELECT * from data where name = "interval"');
		var obj = { interval: interval.text };
		if(result.rows.length === 1) {
			result = tx.executeSql('UPDATE data set value=? where name = "interval"', [JSON.stringify(obj)]);
		} else {
			result = tx.executeSql('INSERT INTO data VALUES (?,?)', ['interval', JSON.stringify(obj)]);
		}
	});
}
