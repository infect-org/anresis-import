(function() {
    'use strict';


    const SampleStream = require('./SampleStream');
    const Related = require('related');
    const AnresisMappings = require('../mappings/AnresisMappings');
    const Sample = require('./Sample');
    const log = require('ee-log');



    module.exports = class AnresisSampleStream extends SampleStream {




        constructor(options) {
            super();


            // mappings
            this.mappings = new AnresisMappings();


            this.options = options;

            // at which records are we currently?
            this.offset;


            // are we ready yet?
            this.ready = false;

            // waiting calls
            this.queue = [];


            // set up db
            new Related([{
                  database      : options.databaseName
                , schema        : options.databaseName
                , type          : 'mysql'
                , hosts: [{
                      host      : options.host
                    , username  : options.user
                    , password  : options.pass
                    , port      : options.port
                    , pools     : ['master', 'read', 'write']
                }]
            }]).load().then((db) => {
                this.db = db[options.databaseName];


                this.executeQueue();
            }).catch((err) => {
                this.error = err;
                this.finished = true;
                this.ready = false;


                // fail the queue
                this.rejectQueue(err);
            });
        }







        readSamples(numSamples) {
            if (this.error) return Promise.reject(this.error);

            return new Promise((resolve, reject) => {
                if (!this.ready) {
                    this.queue.push({
                          resolve: resolve
                        , reject: reject
                        , numSamples: numSamples
                    });
                } else return this.readNextSampleSet(numSamples);
            });
        }






        readNextSampleSet(numSamples) {
            if (this.error) return Promise.reject(this.error);
            else if (this.finished) return Promise.reject(new Error(`Cannot read samples, the SampleStream has finished!`));
            else {
                this.ready = false;

                const filer = {};

                if (this.offset) filter.uniqueId = this.db.getORM().gt(this.offset);

                return this.db.resistance('*', filer).order('uniqueId').limit(numSamples).raw().find().then((samples) => {


                    // convert
                    const newSamples = samples.map((sample) => {
                        return new Sample({
                              id                : sample.uniqueId
                            , year              : sample.sample_year
                            , sex               : this.mappings.sex.resolve(sample.uniqueId, sample.sex)
                            , age               : sample.age
                            , bacteria          : this.mappings.bacteria.resolve(sample.uniqueId, sample.mo_name)
                            , compound          : this.mappings.compound.resolve(sample.uniqueId, sample.ab_name)
                            , region            : this.mappings.region.resolve(sample.uniqueId, sample.region)
                            , organGroup        : this.mappings.organGroup.resolve(sample.uniqueId, sample.org_name)
                            , organ             : this.mappings.organ.resolve(sample.uniqueId, sample.org_name)
                            , causedInfection   : !!sample.is_infection
                            , isHospitalized    : !!sample.is_hospitalized
                            , isNosocomial      : !!sample.is_possibly_nosocomial
                            , resistanceLevel   : this.mappings.resistanceLevel.resolve(sample.uniqueId, sample.resistant, sample.intermediate, sample.susceptible)
                        });
                    });

                    // store offset
                    if (newSamples.length) this.offset = newSamples[newSamples.length-1].uniqueId;


                    process.nextTick(() => {
                        this.executeQueue();
                    });

                    return Promise.resolve(newSamples);
                });
            }
        }







        executeQueue() {
            if (this.queue && this.queue.length) {
                const item = this.queue.shift();

                return this.readNextSampleSet(item.numSamples).then((samples) => {

                    item.resolve(samples);
                    return this.executeQueue();
                }).catch((err) => {

                    item.reject(err);
                    this.rejectQueue(err);
                    return Promise.reject(err);
                });
            }
            else {

                this.ready = true;
                return Promise.resolve();
            }
        }





        rejectQueue(err) {
            this.queue.forEach((item) => {
                item.reject(err);
            });
        }







        close() {
            this.mappings.printMisses();
        }
    };
})();
