(function() {
    'use strict';


    const Mapping = require('./Mapping');



    module.exports = class AnresisSexMapping extends Mapping {


        constructor() {
            super();


            this.type = 'compound';

            this.map.set('Vancomycin', 'vancomycin');
            this.map.set('Amoxicillin-clavulanic acid', 'amoxicillin/clavulanate');
            this.map.set('Trimethoprim-sulfamethoxazole', 'cotrimoxazole');
            this.map.set('Fosfomycin', 'fosfomycin');
            this.map.set('Tigecyclin', 'tigecycline');
            this.map.set('Cefepime', 'cefepime');
            this.map.set('Nitrofurantoin', 'nitrofurantoin');
            this.map.set('Piperacillin-tazobactam', 'piperacillin/tazobactam');
            this.map.set('Linezolid', 'linezolid');
            this.map.set('Fusidic acid', 'fusidic acid');
            this.map.set('Tetracycline', 'doxycycline');
            this.map.set('Penicillin', 'penicillin');
            this.map.set('Rifampicin', 'rifampicin');
            this.map.set('Clindamycin', 'clindamycin');
            this.map.set('Ciprofloxacin', 'ciprofloxacin');
            this.map.set('Teicoplanin', 'teicoplanin');
            this.map.set('Ceftazidime', 'ceftazidime');
            this.map.set('Azithromycin', 'azithromycin');
            this.map.set('Ceftriaxone not specified', 'cefuroxime axetil');
            this.map.set('Erythromycin', 'erithromycin');
            this.map.set('Levofloxacin', 'levofloxacin');
            this.map.set('Clarithromycin', 'clarithromycin');
            this.map.set('Minocycline', 'minocycline');
        }
    };
})();
