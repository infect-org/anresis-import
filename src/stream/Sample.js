(function() {
    'use strict';


    module.exports = class SampleStream {


        constructor(data) {
            this.id = data.id;
            this.year = data.year;
            this.sex = data.sex;
            this.age = data.age;
            this.bacteria = data.bacteria;
            this.compound = data.compound;
            this.region = data.region;
            this.organGroup = data.organGroup;
            this.organ = data.organ;
            this.causedInfection = data.causedInfection;
            this.isHospitalized = data.isHospitalized;
            this.isNosocomial = data.isNosocomial;
            this.resistanceLevel = data.resistanceLevel;
        }
    };
})();
