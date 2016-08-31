(function() {
    'use strict';

    let log = require('ee-log');


    module.exports = (related) => {
        let db = related.mothershipTest;
        let Related = related.getORM();


        // tenants
        return Promise.series(['eventbooster', 'eventdata', 'cornercard', 'default', 'post'].map((name) => {
            return new db.tenant({
                  name: name
                , id_country: 1
            }).save();
        })).then(() => {

            // services
            return Promise.series([{
                  name: 'cluster'
                , token: '17fabed8d4f068d2d11ab91c66029041a6d2e1e9fe6e3534bcfdf26baa13dca8'
            }, {
                  name: 'eventData'
                , token: 'c8a8808dcf9f392832e8a21f48eaaa6ec8cfc0326386cd35e8ae33ca89f0cca8'
            }, {
                  name: 'generics'
                , token: '9dfc65736d0b3fa81251b96a49143707b763847ab01908ebb5ba7662799a9570'
            }, {
                  name: 'image'
                , token: '153f4aa1fe00fcc45879cf30917395ca9e9a3d3bb020daedb9f99cde3f075dc7'
            }, {
                  name: 'mail'
                , token: 'e833c24fb138c391469b54f13cc0cbe620d31ed2f470f005eab344acacff6a2a'
            }, {
                  name: 'object'
                , token: '10d546b13ecaa4d290d140511af2c334d122692c1ef50d8224302ac812e82536'
            }, {
                  name: 'report'
                , token: 'ece2b8947808b54fbfc9d88da0ba49ad41e316890fb52b15fd9cf2c44cce522a'
            }, {
                  name: 'resource'
                , token: 'bcf4acedde3564affa7d82f9679d56889ec89781b3ca6a10eb776a94d2f81594'
            }, {
                  name: 'shopping'
                , token: '728cbe24d36ce0e546d919a7a72d604869e35b4855e39900b890f4b9dcc191ab'
            }, {
                  name: 'user'
                , token: '7542b0ee530dcaf06a658b653eb806967224040b76f199db1f25876a4b9643d0'
            }, {
                  name: 'promotion'
                , token: 'da3562fc0b8b58831b6e15ccd763138be549b761458349a9e1c58b720b5ae72f'
            }, {
                  name: 'cornercard-frontend'
                , token: 'cefc09662d596aa29a39e8748e658f8d26b7b0b98943bd39a2fa67457d19d85a'
                , tenant: 'cornercard'
            }, {
                  name: 'api-frontend'
                , token: '1cc0afecaba63536f8bb62e7f41dcb6677565f674cd3cbd262bf9f308965fb68'
                , tenant: 'default'
            }, {
                  name: 'cinedata-import'
                , token: '95615e40d8eb8c34bae0488f24f01088559e23fbe957b94d15f70b9e84166ecf'
            }, {
                  name: 'backoffice'
                , token: '052f2ee6c249a655c866aa14e7a1d2ccfbc08782bb700a9a13eb6ed47b90dbeb'
            }, {
                  name: 'eventbooster-frontend'
                , token: '5b4fb25d20077c25fd0237294ae5bb5936de17af7559182e23c8183f8e2b3302'
                , tenant: 'eventbooster'
            }, {
                  name: 'post-ticket-frontend'
                , token: 'gf34c7d7dfe837cokl1c1c12c6hdia7c4d98bf7ae38cferwz5df5baa22751987'
            }].map((service) => {
                return new db.service({
                      identifier: service.name
                    , tenant: service.tenant ? db.tenant({name: service.tenant}) : null
                    , accessToken: [new db.accessToken({token: service.token})] 
                }).save();
            }));
        }).then(() => {

            // permission object type
            return new db.permissionObjectType({
                  identifier: 'controller'
                , description: 'permissions applying to controllers'
            }).save();
        }).then(() => {

            // permission action
            return Promise.series(['list', 'listOne', 'create', 'createOrUpdate', 'createRelation', 'update', 'updateRelation', 'delete', 'deleteRelation', 'describe'].map((identifier) => {
                return new db.permissionAction({
                      identifier: identifier
                    , description: `executes the ${identifier} action!`
                }).save();
            }));
        }).then(() => {

            // add the full range capability
            return new db.capability({
                  identifier: 'big-query'
                , description: 'allows the role to load more than 100 rows at once from the orm controller'
            }).save().then((capability) => {
                return Promise.all(['mail', 'eventbooster-frontend', 'cornercard-frontend', 'post-ticket-frontend', 'backoffice'].map((identifier) => {
                    return new db.permissionAction({
                          identifier: identifier
                        , description: `executes the ${identifier} action!`
                    }).save();
                }));
            });
        });
    };  
})();
