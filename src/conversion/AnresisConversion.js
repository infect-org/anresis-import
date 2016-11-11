(function() {
    'use strict';


    const Conversion = require('./Conversion');
    const AnresisSampleStream = require('../stream/AnresisSampleStream');
    const exec = require('child_process').exec;
    const log = require('ee-log');




    module.exports = class AnresisConversion extends Conversion {


        constructor(options) {
            super(options);

            this.options.databaseName = 'anresisSearchImport';
        }






        /**
         * converts a binary stream into an import
         * stream representing single rows of a defined
         * dataset
         *
         * @param {string} filePath the path to the file that ha sto be converted
         *
         * @returns {promise}
         */
        convert(binaryFile) {

            // sooo... w'll import the sql dump into a
            // mysql database, and read single records
            // from it as requested.
            return this.importDump(binaryFile).then(() => {

                // the file isn't used anymore
                return binaryFile.delete();
            }).then(() => {

                const stream = new AnresisSampleStream(this.options);
                return Promise.resolve(stream);
            }).catch((err) => {
log(err);
                return binaryFile.delete().then(() => {
                    return Promise.reject(err);
                });
            });
        }
















        /**
         * imports the sql dump into the mysql db
         */
        importDump(binaryFile) {
            return Promise.resolve();
            const dbName = this.options.databaseName;
            const table = `${dbName}.resistance`;
            const originalDBName = 'search';
            const cn = `mysql --user=${this.options.user} --password=${this.options.pass} --host=${this.options.host} --port=${this.options.port}`;
            let idSQL = '';

            idSQL += `ALTER TABLE ${table} ADD COLUMN uniqueId varchar(40);`;
            idSQL += `CREATE UNIQUE INDEX idx_uniqueID on ${table}(uniqueId);`;
            idSQL += `SET SQL_SAFE_UPDATES = 0;`;
            idSQL += `UPDATE ${table} set uniqueId = SHA1(concat(lab_id, sample_id, COALESCE(mo_occurrence_number, ''), mo_name, mo_specname, ab_name, ab_clsname));`;
            idSQL += `SET SQL_SAFE_UPDATES = 1;`;


            return new Promise((resolve, reject) => {

                log.debug(`Creating new ${dbName} db on host ${this.options.host}`);
                exec(`${cn} -e 'DROP DATABASE IF EXISTS ${dbName}; CREATE DATABASE ${dbName};'`, (err) => {
                    if (err) reject(err);
                    else {

                        // rename db in script
                        log.debug(`Renaming db from ${originalDBName} to ${dbName} inside file ${binaryFile.path}`);
                        exec(`sed -i 's/${originalDBName}/${dbName}/g' ${binaryFile.path}`, (err) => {
                            if (err) reject(err);
                            else {

                                log.debug(`restoring dump on host ${this.options.host}`);
                                exec(`${cn} --database=${dbName} < ${binaryFile.path}`, (err) => {
                                    if (err) reject(err);
                                    else {

                                        log.debug(`Creating unique id key on host ${this.options.host}`);
                                        exec(`${cn} -e '${idSQL}'`, (err) => {
                                            if (err) reject(err);
                                            else {
                                                log.info('Conversion succeeded ...');
                                                resolve();
                                            }
                                        });
                                    }
                                });
                            }
                        });
                    }
                });
            });
        }
    }
})();
