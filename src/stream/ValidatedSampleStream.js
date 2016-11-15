(function() {
    'use strict';


    module.exports = class {



        constructor(readableStream, invalidIds) {
            this.readableStream = readableStream;
            this.invalidIds = invalidIds;

            this.cachedItems = [];
        }






        read(numRecords) {
            const data = this.cachedItems;

            const read = () => {
                return this.readableStream.read(100).then((records) => {
                    if (!records.length) return Promise.resolve(data);
                    else {
                        records.forEach(r => {
                            if (!this.invalidIds.has(r.id)) data.push(r);
                        });

                        if (data.length >= numRecords) {
                            this.cachedItems = data.slice(numRecords);
                            return Promise.resolve(data.slice(0, numRecords));
                        } else return read();
                    }
                });
            }


            return read();
        }






        delete() {
            this.readableStream.delete();
        }
    }
})();
