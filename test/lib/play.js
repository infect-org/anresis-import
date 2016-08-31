(function() {
    'use strict';

    let Playr = require('playr');
    let Scenario = require('playr-json-scenario');
    let path = require('path');

    
    module.exports = function(file, done) {
        let playbook = new Playr();

        playbook.run(new Scenario({
              path: path.join(__dirname, '../data/integration', file)
            , url: 'http://cornercard.127.0.0.1.xip.io:8000'
            , log: true
        }));

        playbook.use(new Scenario.ResponseValidator());
        playbook.play().then((stats) => done()).catch(done);
    };
})();
