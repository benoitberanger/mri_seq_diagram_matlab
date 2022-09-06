classdef gradient < mpd.element
    
    properties
        type char
        dur_ramp_up
        dur_ramp_down
        dur_flattop
    end % properties
    
    methods
        
        function set_total_duration( self, total_duration )
            self.duration      = total_duration;
            self.dur_ramp_up   = total_duration * 0.25;
            self.dur_flattop   = total_duration * 0.50;
            self.dur_ramp_down = total_duration * 0.25;
        end % function
        
    end % methods
    
end % classdef
