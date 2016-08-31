(function() {
    'use strict';


    const Download = require('./Download');
    const request = require('request');







    module.exports = class HTTPDownload extends Download {



        /**
         * gets the file from a http server, resolves if
         * the server responded with the status 200 and
         * actual data
         *
         * @returns {promise}
         */
        execute() {

            // only allow get requests!
            this.options.method = 'get';

            // get the file
            return new Promise((resolve, reject) => {
                request(this.options, (err, response, body) => {
                    if (err) reject(err);
                    else if (response.statusCode === 200 && body) resolve(body);
                    else reject(new Error(`Failed to download file, the server responded with the status ${response.statusCode}!`));
                });
            });
        }
    }
})();
