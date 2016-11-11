(function() {
    'use strict';

    const Validation = require('./Validation');
    const WritableCSVFile = require('../file/WritableCSVFile');
    const crypto = require('crypto');
    const path = require('path');
    const log = require('ee-log');






    module.exports = class RValidation extends Validation {




        validate(sampleStream) {
            log.info(`Starting validation ...`);


            this.outFilePath = path.join(this.options.tempDirectory, crypto.randomBytes(32).toString('hex'));
            this.inFilePath = path.join(this.options.tempDirectory, crypto.randomBytes(32).toString('hex'));


            return this.createCSV(sampleStream).then(() => {
                return this.executeRValidation();
            }).then(() => {
                return this.createSampleStream();
            });
        }









        createSampleStream() {
            return Promise.resovle();
        }











        executeRValidation(sampleStream) {
            return new Promise((resolve, reject) => {
                resolve();
            }).then(() => {
                this.outCSV.delete();
            });
        }









        createCSV(sampleStream) {
            this.outCSV = new WritableCSVFile(this.outFilePath);

            log.debug(`storing samples in ${this.outFilePath} ...`);

            const saveRecords = (offset) => {
                return sampleStream.read(100).then((samples) => {
                    if (samples.length) {
                        log.debug(`writing 100 samples, starting at offset ${samples && samples.length ? samples[0].id : '[finished]'}, ${offset} ...`);

                        return this.outCSV.write(samples).then(() => {
                            return saveRecords(offset+100);
                        });
                    }
                    else {
                        sampleStream.close();
                        return this.outCSV.end();
                    }
                });
            };


            return saveRecords(0);
        }
    };
})();
