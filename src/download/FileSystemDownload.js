(function() {
    'use strict';


    const Download = require('./Download');
    const BinaryFile = require('../file/BinaryFile');
    const fs = require('fs');
    const exec = require('child_process').exec;
    const crypto = require('crypto');
    const path = require('path');
    const log = require('ee-log');







    module.exports = class FileSystemDownload extends Download {



        /**
         * gets the file from a http server, resolves if
         * the server responded with the status 200 and
         * actual data
         *
         * @returns {promise}
         */
        execute() {
            const filePath = path.join(this.options.tempDirectory, crypto.randomBytes(32).toString('hex'));

            return new Promise((resolve, reject) => {

                crypto.randomBytes(32);

                log.debug(`Copying file ${this.options.path} to ${filePath} ...`);
                exec(`cp ${this.options.path} ${filePath}`, (err) => {
                    if (err) reject(err);
                    else {
                        log.info('File downloaded ...');
                        resolve(new BinaryFile(filePath));
                    }
                });

            });
        }
    }
})();
