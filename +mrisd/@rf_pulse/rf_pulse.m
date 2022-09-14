classdef rf_pulse < mrisd.element
    
    properties (SetAccess = public)
        
        flip_angle double
        
    end % properties
    
    methods (Access = public)
        
        function set_onset_at_grad_flattop( self, gradient )
            self.onset  = gradient.onset + gradient.dur_ramp_up;
            self.offset = self.onset + self.duration;
            self.middle = self.onset + self.duration/2;
        end % function
        
    end % methods
    
    
    methods % set methods, so the user can use which ever syntax he prefer
        
        % flip_angle
        function set_flip_angle(self, flip_angle)
            self.flip_angle = flip_angle; % this calls the set method just bellow
        end
        function set.flip_angle(self, flip_angle)
            self.flip_angle = flip_angle;
        end
        
    end % methods
    
end % classdef
