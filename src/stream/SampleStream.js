(function() {
    'use strict';


    module.exports = class SampleStream {


        constructor() {
            this.finished = false;
        }





        read(numSamples) {
            if (this.finished) return Promise.reject(new Error(`Cannot read samples, the SampleStream has finished!`));
            else {
                return this.readSamples(numSamples).catch((err) => {
                    return Promise.reject(new Error(`Failed to read samples for the stream: ${err.message}`));
                });
            }
        }
    };
})();
