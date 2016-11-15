(function() {
    'use strict';



    const Related = require('related');
    const RelatedTimeStamps = require('related-timestamps');
    const log = require('ee-log');





    module.exports = class {


        constructor(options) {
            this.options = options;

            this.related = new Related(options);
            this.related.use(new RelatedTimeStamps());


            this.offet = 0;
        }





        import(sampleStream) {
            return this.related.load().then((orm) => {
                this.db = orm[this.options.schema];


                const importRecords = () => {
                    return sampleStream.read(10).then((records) => {
                        log.debug(`Ẁriting ${records.length} records at offset ${this.offet} to db ...`);
                        if (records.length) {
                            this.offet += records.length;
                            return Promise.all(records.map((record) => {
                                return this.importRecord(record);
                            })).then(() => {

                                setTimeout(importRecords, 100);
                            });
                        } else {
                            sampleStream.delete();
                            return Promise.resolve();
                        }
                    });

                };


                return importRecords();
            });
        }







        importRecord(record) {

            // check if the record is already in the db
            return this.db.resistanceSample({
                  dataSource        : this.db.dataSource({identifier: 'anresis-search'})
                , dataSourceId      : record.id
            }).findOne().then((exisintRecord) => {
                if (!exisintRecord) {
                    return new this.db.resistanceSample({
                          bacteria          : this.db.bacteria().getSpecies({identifier: record.bacteria})
                        , compound          : this.db.compound({identifier: record.compound})
                        , dataSource        : this.db.dataSource({identifier: 'anresis-search'})
                        , resistanceLevel   : this.db.resistanceLevel({identifier: record.resistanceLevel})
                        , sex               : this.db.sex({identifier: record.sex})
                        , tenant            : this.db.tenant({identifier: 'insel-spital'})
                        , region            : this.db.region({identifier: record.region})
                        , city              : null
                        , organ             : null
                        , organGroup        : this.db.organGroup({identifier: record.organGroup})
                        , dataSourceId      : record.id
                        , sampleDate        : null
                        , sampleYear        : record.year
                        , resistanceValue   : null
                        , patientAge        : record.age
                        , causedInfection   : record.causedInfection
                        , isHospitalized    : record.isHospitalized
                        , isNosocomial      : record.isNosocomial
                    }).save().catch(() => {
                        return Promise.resolve();
                    });
                }
            });
        }
    }
})();
