(function() {
    'use strict';

    let log = require('ee-log');


    module.exports = (related) => {
        let db = related.mothershipTest;
        let Related = related.getORM();
        let languages = ['de', 'fr', 'it'];

        // languages
        return Promise.series(languages.map((code) => {
            return new db.language({
                code: code
            }).save();
        })).then(() => {

            // language locales
            return Promise.series(languages.map((code, index) => {
                return Promise.series(languages.map((lCode, lIndex) => {
                    return new db.languageLocale({
                          id_language: index+1
                        , id_languageLocale: lIndex+1
                        , name: `${code} => ${lCode}`
                    }).save();
                }));
            }));
        }).then(() => {

            // countries
            return Promise.series(['ch', 'de', 'nl'].map((code) => {
                let locales = languages.map((lCode, lIndex) => {
                    return new db.countryLocale({
                          id_language: lIndex+1
                        , name: `«${code} in ${lCode}»`
                    });
                });


                return new db.country({
                      code: code
                    , countryLocale: locales
                }).save();
            }));
        }).then(() => {

            // counties
            return Promise.series(['be', 'zh', 'so'].map((code) => {
                let locales = languages.map((lCode, lIndex) => {
                    return new db.countyLocale({
                          id_language: lIndex+1
                        , name: `«${code} in ${lCode}»`
                    });
                });


                return new db.county({
                      code: code
                    , countyLocale: locales
                    , id_country: 1
                }).save();
            }));
        }).then(() => {

            // districts
            return Promise.series(['be', 'zh', 'so'].map((code, index) => {
                let locales = languages.map((lCode, lIndex) => {
                    return new db.districtLocale({
                          id_language: lIndex+1
                        , name: `«default for ${code} in ${lCode}»`
                    });
                });


                return new db.district({
                      districtLocale: locales
                    , id_county: index+1
                }).save();
            }));
        }).then(() => {

            // municipalities for be
            return Promise.series(['Bern', 'Ittigen', 'Ostermundigen'].map((name, index) => {
                let locales = languages.map((lCode, lIndex) => {
                    return new db.municipalityLocale({
                          id_language: lIndex+1
                        , name: `«${name} in ${lCode}»`
                    });
                });

                let cityLocales = languages.map((lCode, lIndex) => {
                    return new db.cityLocale({
                          id_language: lIndex+1
                        , name: `«${name} in ${lCode}»`
                    });
                });

                return new db.municipality({
                      municipalityLocale: locales
                    , id_district: index+1
                    , city: [new db.city({
                          cityLocale: cityLocales
                        , zip: 4500+index
                        , lat: 49+index
                        , lng: 11+index
                    })]
                }).save();
            }));
        }).then(() => {

            // municipalities for so
            return Promise.series(['Solothurn', 'Gerlafingen', 'Flumenthal'].map((name, index) => {
                let locales = languages.map((lCode, lIndex) => {
                    return new db.municipalityLocale({
                          id_language: lIndex+1
                        , name: `«${name} in ${lCode}»`
                    });
                });

                let cityLocales = languages.map((lCode, lIndex) => {
                    return new db.cityLocale({
                          id_language: lIndex+1
                        , name: `«${name} in ${lCode}»`
                    });
                });

                return new db.municipality({
                      municipalityLocale: locales
                    , id_district: index+1
                    , city: [new db.city({
                          cityLocale: cityLocales
                        , zip: 4500+index
                        , lat: 43+index
                        , lng: 8+index
                    })]
                }).save();
            }));
        }).then(() => {

            // municipalities for zh
            return Promise.series(['Zürich', 'Wetzikon', 'Winterthur'].map((name, index) => {
                let locales = languages.map((lCode, lIndex) => {
                    return new db.municipalityLocale({
                          id_language: lIndex+1
                        , name: `«${name} in ${lCode}»`
                    });
                });

                let cityLocales = languages.map((lCode, lIndex) => {
                    return new db.cityLocale({
                          id_language: lIndex+1
                        , name: `«${name} in ${lCode}»`
                    });
                });


                return new db.municipality({
                      municipalityLocale: locales
                    , id_district: index+1
                    , city: [new db.city({
                          cityLocale: cityLocales
                        , zip: 8000+index
                        , lat: 46+index
                        , lng: 5+index
                    })]
                }).save();
            }));
        });
    };  
})();
