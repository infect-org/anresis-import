(function() {
    'use strict';


    let log     = require('ee-log');
    let assert  = require('assert');
    let SOA     = require('./lib/SOA');
    let play    = require('./lib/play');
    let related = null;
    let db      = null;



    describe('Events', () => {
        before(function(done) {
            this.timeout(30000);
            SOA.ready().then((soa) => {
                related = soa.getOrm();
                db = related.mothershipTest;
                done();
            }).catch(done);
        });
        

        it('GET event id=100', (done) =>  play('event/get-plain.json', done));
    });
})();
