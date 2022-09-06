classdef adc < mpd.element
    
    properties
        
    end % properties
    
    methods
        
        function set_onset_at_grad_flattop( self, gradient )
            self.onset  = gradient.onset + gradient.dur_ramp_up;
            self.offset = self.onset + self.duration;
            self.middle = self.onset + self.duration/2;
        end % function
        
    end % methods
    
end % classdef
