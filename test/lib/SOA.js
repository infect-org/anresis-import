(function() {
    'use strict';


    let fs = require('fs');
    let path = require('path');
    

    // are we running on the ci?
    let runningLocal = fs.existsSync(path.join(__dirname, '../../config.js'));


    process.argv.push(runningLocal ? '--dev' : '--testing');
    process.argv.push('--api');
    process.argv.push('--cornercard');
    process.argv.push('--eventbooster');
    process.argv.push('--post');
    process.argv.push('--backoffice');


    // process.argv.push('--silent');
    process.argv.push('--no-permissions');
    process.argv.push('--debug-service');
    //process.argv.push('--related-sql');


    
    let SOAMain = require('../../src/Main');



    class TestSOA {


    	constructor() {

            // load the soa with the appropriate config
    		this.soa = new SOAMain({
                configPath: runningLocal ? path.join(__dirname, '../../config.localTest.js') : path.join(__dirname, '../../config.ciTest.js')
            });

    		this.soa.once('load', () => this.loaded = true);
    		console.log('initializing the SOA, this may take a moment ...'.green);
    	}




    	ready() {
    		if (this.loaded) return Promise.resolve();
    		else {
    			return new Promise((resolve, reject) => {
    				this.soa.once('load', (err) => {
    					if (err) reject(err);
    					else resolve(this.soa);
    				});
    			});
    		}
    	}
    };



    module.exports = new TestSOA();
})();
