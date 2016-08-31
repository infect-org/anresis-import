(function() {
    'use strict';


    const FileSystemDownload = require('./download/FileSystemDownload');
    const HTTPDownload = require('./download/HTTPDownload');
    const AnresisConversion = require('./conversion/AnresisConversion');
    const config = require('../config.js');
    const log = require('ee-log');



    module.exports = class InfectImport {



        constructor() {
            config.dataSource.tempDirectory = config.tempDirectory;
            config.dataConversion.tempDirectory = config.tempDirectory;


            log.info('Starting import ...');

            this.download().then((binaryFile) => {
                return this.convert(binaryFile);
            }).then((sampleStream) => {

                return sampleStream.read(100).then((samples) => {
                    log(samples);
                    log.success('import ok!');

                    sampleStream.close();
                });
            }).catch(log);
        }









        /**
         * convert to internal representation
         *
         */
        convert(binaryFile) {
            log.info('Starting conversion ...');
            let conversion;

            switch (config.dataConversion.type) {
                case 'anresis':
                    conversion = new AnresisConversion(config.dataConversion);
                    break;

                default:
                    throw new Error(`Unknown conversion ${config.dataConversion.type}!`);
            }


            return conversion.convert(binaryFile).catch((err) => {
                return Promise.reject(new Error(`Failed to convert file: ${err.message}`));
            });
        }










        /**
         * gets the dump file from whatever datasource
         * is configured
         *
         * @returns {promise}
         */
        download() {
            log.info('Starting download ...');
            let downloader;

            switch (config.dataSource.type) {
                case 'file':
                    downloader = new FileSystemDownload(config.dataSource);
                    break;
                case 'http':
                    downloader = new HTTPDownload(config.dataSource);
                    break;

                default:
                    throw new Error(`Unknown downloader ${config.dataSource.type}!`);
            }


            return downloader.execute().catch((err) => {
                return Promise.reject(new Error(`Failed to download file: ${err.message}`));
            });
        }
    }
})();
