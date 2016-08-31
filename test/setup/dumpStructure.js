(function() {
	'use strict';

	let path = require('path');
	let fs = require('fs');
	let cp = require('child_process');
	let log = require('ee-log');

	let config = require(path.join(__dirname, '../../config.js'));

	let user = 'postgres';
	let pass = 'secret';
	let host = 'localhost';
	let port = 5432;


	config.db.forEach((db) => {
		if (db.database === 'eventbooster' || db.schema === 'eventbooster') {
			user = db.hosts[0].username;
			pass = db.hosts[0].password;
			host = db.hosts[0].host || host;
			port = db.hosts[0].port || port;
		}
	});


	//log(`PGPASSWORD="${pass}" pg_dump --schema=eventbooster -s -x --clean -U ${user} -h ${host} -p ${port} --create eventbooster`);



	cp.exec(`PGPASSWORD="${pass}" pg_dump --schema=eventbooster -s -x --clean -U ${user} -h ${host} -p ${port} --create eventbooster`, {maxBuffer: 1024*1024*20}, (err, stdOut, stdErr) => {
		if (err) log(err);
		else {
			fs.writeFileSync(path.join(__dirname, '../data/sql/createdb.sql'), stdOut.toString().replace(/eventbooster/g, `"mothershipTest"`));
			console.log('done'.green);
		}
	});
})();