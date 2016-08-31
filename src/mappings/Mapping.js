(function() {
    'use strict';


    const log = require('ee-log');


    module.exports = class Mapping {


        constructor() {
            this.map = new Map();
            this.missedHits = new Map();
        }




        resolve(id, input) {
            if (this.map.has(input)) return this.map.get(input);
            else {
                this.storeMissedHit(input, id);
                return null;
            }
        }




        storeMissedHit(input, id) {
            if (!this.missedHits.has(input)) this.missedHits.set(input, []);
            this.missedHits.get(input).push(id);
        }




        printMisses() {
            log.success(`---------------- ${this.type} ----------------`);
            for (const key of this.missedHits.keys()) log.info(key);
        }
    };
})();
