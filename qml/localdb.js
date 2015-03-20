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
