classdef element < handle & matlab.mixin.Copyable
    
    properties
        
        % time stuff
        
        %- for plot
        onset      double
        middle     double
        offset     double
        
        %- element duration( arbitrary unit )
        duration   double
        
        % visual stuff
        magnitude  double = 1 % like a scaling factor
        
        % pointer
        diagram    mpd.diagram
    end % properties
    
    methods
        
        function set_as_initial_element( self )
            assert( ~isempty(self.duration), 'duration must be set')
            self.onset  = 0;
            self.offset = self.duration;
            self.middle = self.duration/2;
        end % function
        
        function set_onset_at_elem_offset( self, elem )
            self.onset  = elem.offset;
            self.offset = self.onset + self.duration;
            self.middle = self.onset + self.duration/2;
        end % function
        
    end % methods
    
end % classdef
