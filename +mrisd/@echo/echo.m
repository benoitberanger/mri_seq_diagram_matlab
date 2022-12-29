classdef echo < mrisd.element
    
    properties (SetAccess = public)
        
        asymmetry double = 0.5 % from 0 to 1, with 0.5 is symetric echo
        
        % visual
        color     = 'blue'
        n_lob     = 10;  % integer values, { 0 (no lob), 1, 2, 3, ...}
        n_points  = 1000 % definition of the sin wave with exponential envelope
        lob_decay = 2;   % lob number with half the height
        
    end % properties
    
    methods (Access = public)
        
        function set_using_ADC(self, ADC)
            self.duration = ADC.duration;
            self.onset    = ADC.onset;
            self.middle   = ADC.middle;
            self.offset   = ADC.offset;
        end
        
    end % methods
    
end % classdef
