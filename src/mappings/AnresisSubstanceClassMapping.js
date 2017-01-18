(function() {
    'use strict';


    const Mapping = require('./Mapping');



    module.exports = class AnresisSubstanceClassMapping extends Mapping {


        constructor() {
            super();


            this.type = 'substanceClass';

            this.map.set('Gentamicin HLAR', 'aminoglykoside');
            this.map.set('Oxacillin', 'betalactame');
            this.map.set('Aztreonam', 'monobactam');
            this.map.set('Ticarcillin-clavulanic acid', 'betalactame');
            this.map.set('Extended spectrum beta-lactamase', 'betalactame');
            this.map.set('Streptomycin HLAR', 'aminoglykoside');
        }
    };
})();
