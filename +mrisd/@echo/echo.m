classdef echo < mrisd.element
    
    properties (SetAccess = public)
        asymmetry double
    end % properties
    
    methods (Access = public)
        
        function set_using_ADC(self, ADC)
            self.duration = ADC.duration;
            self.onset    = ADC.onset;
            self.middle   = ADC.middle;
            self.offset   = ADC.offset;
        end
        
    end % methods
    
    methods % set methods, so the user can use which ever syntax he prefer
        
        % asymmetry
        function set_asymmetry(self, asymmetry)
            self.asymmetry = asymmetry; % this calls the set method just bellow
        end
        function set.asymmetry(self, asymmetry)
            self.asymmetry = asymmetry;
        end
        
    end % methods
    
end % classdef
