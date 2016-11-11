(function() {
    'use strict';


    const Mapping = require('./Mapping');



    module.exports = class AnresisSexMapping extends Mapping {


        constructor() {
            super();


            this.type = 'organGroup';

            this.map.set('Urogenital', 'Urogenital tract');
            this.map.set('Pregnancy', 'Gynecology & obstetrics');
            this.map.set('Blood', 'Blood');
            this.map.set('Respiratory tract / ear nose throat', 'Respiratory tract');
            this.map.set('Skin', 'Skin & soft tissue');
            this.map.set('Gastrointestinal tract', 'Gastrointestinal tract');
            this.map.set('Heart / Vessels', 'Heart & vessels');
            this.map.set('Musculosceletal system', 'Musculosceletal system');
            this.map.set('Central nervous system', 'Central nervous system');
            this.map.set('Eye', 'Eye');
        }
    };
})();
