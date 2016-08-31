(function() {
    'use strict';


    const AnresisSexMapping = require('./AnresisSexMapping');
    const AnresisBacteriaMapping = require('./AnresisBacteriaMapping');
    const AnresisCompoundMapping = require('./AnresisCompoundMapping');
    const AnresisOrganGroupMapping = require('./AnresisOrganGroupMapping');
    const AnresisOrganMapping = require('./AnresisOrganMapping');
    const AnresisRegionMapping = require('./AnresisRegionMapping');
    const AnresisResistanceLevelMapping = require('./AnresisResistanceLevelMapping');




    module.exports = class AnresisMappings {

        constructor() {
            this.sex = new AnresisSexMapping();
            this.bacteria = new AnresisBacteriaMapping();
            this.compound = new AnresisCompoundMapping();
            this.organGroup = new AnresisOrganGroupMapping();
            this.organ = new AnresisOrganMapping();
            this.region = new AnresisRegionMapping();
            this.resistanceLevel = new AnresisResistanceLevelMapping();
        }




        printMisses() {
            this.sex.printMisses();
            this.bacteria.printMisses();
            this.compound.printMisses();
            this.organGroup.printMisses();
            this.organ.printMisses();
            this.region.printMisses();
            this.resistanceLevel.printMisses();
        }
    };
})();
