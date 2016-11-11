(function() {
    'use strict';

    const fs = require('fs');



    module.exports = class Download {


        constructor(path) {
            this.path = path;
        }





        getReadbaleStream() {
            const stream = fs.createReadStream(this.path);
            stream.pause();
            return stream;
        }







        getWritableStream() {
            const stream = fs.createWriteStream(this.path);
            return stream;
        }






        delete() {
            return new Promise((resolve, reject) => {
                fs.unlink(this.path, (err) => {
                    if (err) reject(err);
                    else resolve();
                });
            });
        }
    };
})();
