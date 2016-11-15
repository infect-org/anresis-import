(function() {
    'use strict';


    const File = require('./File');
    const csv = require('fast-csv');



    module.exports = class WritabelCSVFile extends File {




        constructor(path) {
            super(path);

            this.stream = csv.createWriteStream({
                  headers: true
                , quoteColumns: true
            });

            // pipe to fs
            this.fsStream = this.getWritableStream();
            this.stream.pipe(this.fsStream);
        }





        write(objectArray) {
            objectArray.forEach((item) => {
                this.stream.write(item);
            });

            return new Promise((resolve) => {
                process.nextTick(resolve);
            });
        }





        end() {
            return new Promise((resolve, reject) => {
                this.fsStream.on('finish', resolve);

                this.stream.end();
            });
        }
    };
})();
