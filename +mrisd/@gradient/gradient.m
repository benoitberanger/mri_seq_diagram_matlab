classdef gradient < mrisd.element
    
    properties (SetAccess = public)
        type          char
        dur_ramp_up   double
        dur_flattop   double
        dur_ramp_down double
    end % properties
    
    methods (Access = public)
        
        function set_total_duration( self, total_duration )
            self.duration      = total_duration;
            self.dur_ramp_up   = total_duration * 0.125;
            self.dur_flattop   = total_duration * 0.750;
            self.dur_ramp_down = total_duration * 0.125;
        end % function
        
        function set_flattop_on_rf( self, rf_obj, dur_ramp_up, dur_ramp_down )
            self.dur_flattop = rf_obj.duration;
            if nargin < 3
                self.dur_ramp_up   = rf_obj.duration/4;
            else
                self.dur_ramp_up   = dur_ramp_up;
            end
            if nargin < 4
                self.dur_ramp_down = rf_obj.duration/4;
            else
                self.dur_ramp_down   = dur_ramp_down;
            end
            
            self.duration = self.dur_ramp_up + self.dur_flattop + self.dur_ramp_down;
            self.onset    = rf_obj.onset - self.dur_ramp_up;
            self.offset   = self.onset + self.duration;
            self.middle   = self.onset + self.dur_ramp_up + self.dur_flattop/2;
        end
        
        function set_flattop_on_adc( self, adc_obj, dur_ramp_up, dur_ramp_down )
            self.dur_flattop = adc_obj.duration;
            if nargin < 3
                self.dur_ramp_up   = adc_obj.duration/4;
            else
                self.dur_ramp_up   = dur_ramp_up;
            end
            if nargin < 4
                self.dur_ramp_down = adc_obj.duration/4;
            else
                self.dur_ramp_down   = dur_ramp_down;
            end
            
            self.duration = self.dur_ramp_up + self.dur_flattop + self.dur_ramp_down;
            self.onset    = adc_obj.onset - self.dur_ramp_up;
            self.offset   = self.onset + self.duration;
            self.middle   = self.onset + self.dur_ramp_up + self.dur_flattop/2;
        end
        
    end % methods
    
    
    methods % set methods, so the user can use which ever syntax he prefer
        
        % type
        function set_type(self, type)
            self.type = type; % this calls the set method just bellow
        end
        function set.type(self, type)
            self.type = type;
        end
        function set_type_slice_selection(self)
            self.type = mrisd.grad_type.slice_selection;
        end
        function set_type_phase_encoding(self)
            self.type = mrisd.grad_type.phase_encoding;
        end
        function set_type_readout(self)
            self.type = mrisd.grad_type.readout;
        end
        
        % dur_ramp_up
        function set_dur_ramp_up(self, dur_ramp_up)
            self.dur_ramp_up = dur_ramp_up; % this calls the set method just bellow
        end
        function set.dur_ramp_up(self, dur_ramp_up)
            self.dur_ramp_up = dur_ramp_up;
        end
        
        % dur_flattop
        function set_dur_flattop(self, dur_flattop)
            self.dur_flattop = dur_flattop; % this calls the set method just bellow
        end
        function set.dur_flattop(self, dur_flattop)
            self.dur_flattop = dur_flattop;
        end
        
        % dur_ramp_down
        function set_dur_ramp_down(self, dur_ramp_down)
            self.dur_ramp_down = dur_ramp_down; % this calls the set method just bellow
        end
        function set.dur_ramp_down(self, dur_ramp_down)
            self.dur_ramp_down = dur_ramp_down;
        end
        
    end % methods
    
end % classdef
