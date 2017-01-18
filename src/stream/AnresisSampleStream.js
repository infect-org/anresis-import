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



            // storage for susbstanceClass compund mapping
            this.compundMapping = new Map();


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


                return new Related([{
                      database      : options.target.databaseName
                    , schema        : options.target.databaseName
                    , type          : 'postgres'
                    , hosts: [{
                          host      : options.target.host
                        , username  : options.target.user
                        , password  : options.target.pass
                        , port      : options.target.port
                        , pools     : ['master', 'read', 'write']
                    }]
                }]).load().then((db) => {
                    this.targetDb = db[options.target.databaseName];


                    this.executeQueue();
                });
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
                } else this.readNextSampleSet(numSamples).then(resolve).catch(reject);
            });
        }






        readNextSampleSet(numSamples) {
            if (this.error) return Promise.reject(this.error);
            else if (this.finished) return Promise.reject(new Error(`Cannot read samples, the SampleStream has finished!`));
            else {
                this.ready = false;

                const filter = {};

                if (this.offset) filter.uniqueId = this.db.getORM().gt(this.offset);

                return this.db.resistance('*', filter).order('uniqueId').limit(numSamples).raw().find().then((samples) => {

                    const newSamples = [];
                   /*const origSamples = [];
                    const createdSamples = [];*/



                    return Promise.all(samples.map((sample) => {
                        //sample.testId = Math.random()*10000000;

                        const ourClass = this.mappings.substanceClass.resolve(sample.uniqueId, sample.ab_name);
                        const ourCompound = this.mappings.compound.resolve(sample.uniqueId, sample.ab_name);
                        const ourBacteria = this.mappings.bacteria.resolve(sample.uniqueId, sample.mo_name);


                        // we need to know the data on our side
                        if (ourBacteria && (ourCompound || ourClass)) {
                            return Promise.resolve().then(() => {
                                if (ourClass) {

                                    return Promise.resolve().then(() => {
                                        if (this.compundMapping.has(ourClass)) return Promise.resolve(this.compundMapping.get(ourClass));
                                        else {
                                            return this.targetDb.substanceClass('*', {
                                                identifier: ourClass
                                            }).findOne().then((cls) => {
                                                if (cls) {
                                                    const classes = [cls];

                                                    return this.targetDb.substanceClass({
                                                          left      : Related.gte(cls.left)
                                                        , right     : Related.lte(cls.right)
                                                    }).raw().find().then((childClasses) => {
                                                        childClasses.forEach(c => classes.push(c));


                                                        // so, there we go
                                                        return this.targetDb.compound('identifier').getSubstance().getSubstanceClass({
                                                            id: Related.in(classes.map(c => c.id))
                                                        }).raw().find().then((compounds) => {
                                                            this.compundMapping.set(ourClass, compounds);

                                                            return Promise.resolve(compounds);
                                                        });
                                                    });

                                                } else {
                                                    this.compundMapping.set(ourClass, [])
                                                    return Promise.resolve();
                                                }
                                            });
                                        }
                                    }).then((compunds) => {
                                        if (compunds) {
                                            compunds.forEach((compound) => {

                                                // ATTENTION: dear michael, you have to think about a unique id 
                                                // that is really unique! this one is not unique at all
                                                const newSample = new Sample({
                                                      id                : sample.uniqueId
                                                    , year              : sample.sample_year
                                                    , sex               : this.mappings.sex.resolve(sample.uniqueId, sample.sex)
                                                    , age               : sample.age
                                                    , bacteria          : ourBacteria
                                                    , compound          : compound.identifier
                                                    , region            : this.mappings.region.resolve(sample.uniqueId, sample.region)
                                                    , organGroup        : this.mappings.organGroup.resolve(sample.uniqueId, sample.org_name)
                                                    , organ             : this.mappings.organ.resolve(sample.uniqueId, sample.org_name)
                                                    , causedInfection   : !!sample.is_infection
                                                    , isHospitalized    : !!sample.is_hospitalized
                                                    , isNosocomial      : !!sample.is_possibly_nosocomial
                                                    , resistanceLevel   : this.mappings.resistanceLevel.resolve(sample.uniqueId, sample.resistant, sample.intermediate, sample.susceptible)
                                                });

                                              /*  newSample.testId = sample.testId;
                                                createdSamples.push(newSample);*/
                                                newSamples.push(newSample);
                                            });
                                        }

                                        return Promise.resolve();
                                    });
                                } else return Promise.resolve();
                            }).then(() => {
                                if (ourCompound) {
                                    const newSample = new Sample({
                                          id                : sample.uniqueId
                                        , year              : sample.sample_year
                                        , sex               : this.mappings.sex.resolve(sample.uniqueId, sample.sex)
                                        , age               : sample.age
                                        , bacteria          : ourBacteria
                                        , compound          : ourCompound
                                        , region            : this.mappings.region.resolve(sample.uniqueId, sample.region)
                                        , organGroup        : this.mappings.organGroup.resolve(sample.uniqueId, sample.org_name)
                                        , organ             : this.mappings.organ.resolve(sample.uniqueId, sample.org_name)
                                        , causedInfection   : !!sample.is_infection
                                        , isHospitalized    : !!sample.is_hospitalized
                                        , isNosocomial      : !!sample.is_possibly_nosocomial
                                        , resistanceLevel   : this.mappings.resistanceLevel.resolve(sample.uniqueId, sample.resistant, sample.intermediate, sample.susceptible)
                                    })
/*
                                    newSample.testId = sample.testId;
                                    newSample.sample = sample;
                                    origSamples.push(newSample);*/
                                    newSamples.push(newSample);
                                }

                                return Promise.resolve();
                            });
                        } else return Promise.resolve();
                        
                    })).then(() => {
                        /*const fs = require('fs');

                        origSamples.sort((a, b) => a.testId > b.testId ? 1 : -1);
                        createdSamples.sort((a, b) => a.testId > b.testId ? 1 : -1);

                        fs.writeFileSync('/home/ee/origSamples.json', JSON.stringify(origSamples, null, 4));
                        fs.writeFileSync('/home/ee/createdSamples.json', JSON.stringify(createdSamples, null, 4));
                        fs.writeFileSync('/home/ee/anresisSamples.json', JSON.stringify(samples, null, 4));
                        log.success('done');*/

                        // store offset
                        if (newSamples.length) this.offset = newSamples[newSamples.length-1].id;
                        else this.finished = true;

                        this.ready = true;

                        return Promise.resolve(newSamples);
                    });
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
