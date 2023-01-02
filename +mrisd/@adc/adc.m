classdef adc < mrisd.element
    
    properties (SetAccess = public)
        
        % visual
        color = [0.5 0.5 0.5] % gray
        
    end % properties
    
    methods (Access = public)
        
        function set_onset_at_grad_flattop( self, gradient )
            self.onset  = gradient.onset + gradient.dur_ramp_up;
            self.offset = self.onset + self.duration;
            self.middle = self.onset + self.duration/2;
        end % function
        
    end % methods
    
end % classdef
