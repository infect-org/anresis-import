(function() {
    'use strict';

    let log = require('ee-log');

    

    module.exports = (related) => {
        let db = related.mothershipTest;
        let Related = related.getORM();

        
        return Promise.series(['source_record', 'tenant', 'draft'].map((name, index) => {
            return new db.eventDataHierarchy({
                  name      : name
                , hierarchy : index
            }).save();
        })).then(() => {


            return new db.eventDataView({
                name: 'default'
            }).save();
        }).then(() => {

            return Promise.series(['source_record', 'tenant', 'draft'].map((name) => {
                return new db.eventDataConfig({
                      eventDataHierarchy: db.eventDataHierarchy({name: name})
                    , eventDataView: db.eventDataView({name: 'default'})
                    , tenant: db.tenant({name: 'cornercard'})
                }).save();
            }));
        });
    };  
})();
