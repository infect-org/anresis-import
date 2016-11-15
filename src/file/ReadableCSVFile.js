(function() {
    'use strict';


    const File  = require('./File');
    const csv   = require('fast-csv');
    const log   = require('ee-log');



    module.exports = class WritabelCSVFile extends File {




        constructor(path) {
            super(path);

            this.stream = csv({
                  headers: true
                , quoteColumns: true
            });

            this.cachedRecords = [];
            this.hasEnded = false;

            this.stream.on('end', () => {
                this.hasEnded = true;
            });

            // pipe to fs
            this.fsStream = this.getReadbaleStream();
            this.fsStream.pipe(this.stream);
        }





        read(numRecords) {
            // trigegr reading of the stream
            this.stream.on('readable', () => {});

            return new Promise((resolve, reject) => {
                const records = this.cachedRecords;
                this.cachedRecords = [];

                if (this.hasEnded) resolve([]);
                else {
                    const read = () => {
                        while(records.length < numRecords) {
                            const data = this.stream.read();
                            if (data) records.push(data);
                            else break;
                        }

                        if (records.length >= numRecords) {
                            this.cachedRecords = records.slice(numRecords);
                            resolve(records.slice(0, numRecords));
                        }
                        else if (this.hasEnded) resolve(records);
                        else {
                            if (this.stream.isPaused()) this.stream.resume();
                            if (this.fsStream.isPaused()) this.fsStream.resume();
                            setTimeout(read, 100);
                        }
                    };

                    read();
                }
            });
        }
    };
})();
