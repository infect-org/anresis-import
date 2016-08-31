(function() {
    'use strict';

    let log = require('ee-log');


    module.exports = (related) => {
        let db = related.mothershipTest;
        let Related = related.getORM();

        return new db.event({
              startdate: new Date(2000, 9, 2)
            , id_tenant: 1
            , id: 100
            , eventType: db.eventType({name: 'event'})
            , eventData: [new db.eventData({
                eventDataConfig: [db.eventDataConfig({
                      eventDataHierarchy: db.eventDataHierarchy({name: 'tenant'})
                    , eventDataView: db.eventDataView({name: 'default'})
                    , tenant: db.tenant({name: 'cornercard'})
                })]
            })]
        }).save();
    };  
})();
