(function() {
    'use strict';

    const Validation                = require('./Validation');
    const WritableCSVFile           = require('../file/WritableCSVFile');
    const ReadableCSVFile           = require('../file/ReadableCSVFile');
    const ValidatedSampleStream     = require('../stream/ValidatedSampleStream');
    const crypto                    = require('crypto');
    const path                      = require('path');
    const exec                      = require('child_process').exec;
    const log                       = require('ee-log');






    module.exports = class RValidation extends Validation {




        validate(sampleStream) {
            log.info(`Starting validation ...`);


            this.outFilePath = '/home/ee/60e1ecbeb744b9fdc3a7672f86d76d0cb9179e442a90ea2c717a32548ff676d1'; // path.join(this.options.tempDirectory, crypto.randomBytes(32).toString('hex'));
            this.inFilePath = path.join(this.options.tempDirectory, crypto.randomBytes(32).toString('hex'));
            this.rScriptPath = path.join(__dirname, '../../r-scripts/import.R');


            return this.createCSV(sampleStream).then(() => {
                return this.executeRValidation();
            });
        }












        executeRValidation(sampleStream) {
            return new Promise((resolve, reject) => {
                const command = `Rscript ${this.rScriptPath} ${this.outFilePath} ${this.inFilePath}`;
                log.info(`Executing '${command}' ...`);


                exec(command, (err, stdOut, stdErr) => {
                    if (err) reject(err);
                    else resolve();
                });
            }).then(() => {

                // this is the place to load the valdiated records
                const invalidRecords = new Set();
                const inStream = new ReadableCSVFile(this.inFilePath);

                const read = () => {
                    if (inStream.hasEnded) {

                        // delete from fs
                        inStream.delete();
                        return Promise.resolve(invalidRecords);
                    }
                    else {
                        return inStream.read(1000).then((records) => {
                            records.forEach(r => invalidRecords.add(r.id));
                            return read();
                        });
                    }
                };

                return read();
            }).then((invalidRecords) => {

                // so, lets return the a validated sampel stream
                // which can be used to read all valid samples
                return Promise.resolve(new ValidatedSampleStream(new ReadableCSVFile(this.outFilePath), invalidRecords));
            });
        }









        createCSV(sampleStream) { return Promise.resolve();
            this.outCSV = new WritableCSVFile(this.outFilePath);

            log.debug(`storing samples in ${this.outFilePath} ...`);

            const saveRecords = (offset) => {
                return sampleStream.read(10000).then((samples) => {
                    if (samples.length) {
                        log.debug(`writing 100 samples, starting at offset ${samples && samples.length ? samples[0].id : '[finished]'}, ${offset} ...`);


                        // store smaples with valid values
                        return this.outCSV.write(samples.filter((sample) => {
                            return sample.bacteria && sample.compound;
                        })).then(() => {
                            return saveRecords(offset+10000);
                        });
                    }
                    else {
                        log.info(`All samples were written ...`);
                        sampleStream.close();
                        return this.outCSV.end();
                    }
                });
            };


            return saveRecords(0);
        }
    };
})();
