(function() {
    'use strict';

    const fs = require('fs');



    module.exports = class Download {


        constructor(path) {
            this.path = path;
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
