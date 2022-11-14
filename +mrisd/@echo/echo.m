classdef echo < mrisd.element
    
    properties (SetAccess = public)
        
        asymmetry double = 0.5 % from 0 to 1, with 0.5 is symetric echo
        
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
