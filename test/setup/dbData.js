(function() {
    'use strict';
    
    // process.argv.push('--related-sql');

    let Related       = require('related'); 
    let Timestamps    = require('related-timestamps');
    let Localization  = require('related-localization');
    let path          = require('path');
    let log           = require('ee-log');
    let fs            = require('fs');
    let config        = require(require('./getConfigPath'));


    // custom serial promises execution
    Promise.series = function(promises) {
        return new Promise((resolve, reject) => {
            let results = [];

            let exec = (index) => {
                if (promises && Array.isArray(promises) && promises.length > index) {
                    promises[index].then((data) => {
                        results.push(data);
                        exec(index+1);
                    }).catch(reject);
                } else resolve(results);
            };

            exec(0);
        });
    };


    // first load the orm
    let related = new Related(config.db);

    related.use(new Timestamps());
    related.use(new Localization());

    related.load().then(() => {
        let base = path.join(__dirname, '../data/setup');
            

        fs.readdir(base, (err, files) => {
            if (err) log(err);
            else {
                let jsFiles = files.filter((f) => path.extname(f) === '.js').sort((a, b) => {
                    a = parseInt(a.substr(0, a.indexOf('-')), 10);
                    b = parseInt(b.substr(0, b.indexOf('-')), 10);
                    return a-b;
                });


                let exec = (index) => {
                    if (jsFiles.length > index) {
                        console.log(`executing script ${jsFiles[index]} ...`.grey);
                        require(path.join(base, jsFiles[index]))(related).then(() => exec(index+1)).catch(log);
                    }
                    else {
                        console.log('done executing insert scripts ...'.green);
                        process.exit();
                    }
                };

                exec(0);
            }
        });
    }).catch(log);
})();
