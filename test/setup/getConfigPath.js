(function() {
    'use strict';


    let fs = require('fs');
    let path = require('path');


    // are we running on the ci?
    let runningLocal = fs.existsSync(path.join(__dirname, '../../config.js'));

    module.exports = runningLocal ? path.join(__dirname, '../../config.localTest.js') : path.join(__dirname, '../../config.ciTest.js');
})();