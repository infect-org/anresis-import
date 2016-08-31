(function() {
    'use strict';


    const Mapping = require('./Mapping');



    module.exports = class AnresisSexMapping extends Mapping {


        constructor() {
            super();

            this.type = 'resistanceLevel';
        }


        resolve(id, resistant, intermediate, susceptible) {
            if ((resistant + intermediate + susceptible) > 1) throw new Error(`Sample ${id} with more than on filed of resistant, intermediate and susceptible set!`);
            else {
                if (resistant) return 'resistant';
                else if (intermediate) return 'intermediate';
                else if (susceptible) return 'susceptible';
                else throw new Error(`Sample ${id} with none of resistant, intermediate and susceptible set!`);
            }
        }
    };
})();
