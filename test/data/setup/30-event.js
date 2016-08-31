(function() {
    'use strict';

    let log = require('ee-log');


    module.exports = (related) => {
        let db = related.mothershipTest;
        let Related = related.getORM();

        let types = ['event', 'festival', 'exhibition', 'theater', 'opening', 'closing', 'movie', 'movieShow'];


        let exec = (index) => {
            if (types.length > index) {
                return new db.eventType({
                    name: types[index]
                }).save().then(() => exec(index+1));
            }
            else return Promise.resolve();
        };

        return exec(0);
    };  
})();
