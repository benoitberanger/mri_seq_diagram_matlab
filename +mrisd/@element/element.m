classdef element < handle & matlab.mixin.Copyable
    
    properties (SetAccess = public)
        
        name       char
        
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
        diagram    mrisd.diagram
        
    end % properties
    
    
    methods (Access = public)
        
        %------------------------------------------------------------------
        function self = element( name )
            if nargin < 1
                return
            end
            self.name = name;
        end % function
        
        %------------------------------------------------------------------
        function set_as_initial_element( self, duration )
            if nargin > 1
                self.duration = duration;
            end
            assert( ~isempty(self.duration), 'duration must be set')
            self.onset  = 0;
            self.offset = self.duration;
            self.middle = self.duration/2;
        end % function
        
        %------------------------------------------------------------------
        function set_onset_at_elem_offset( self, elem )
            self.onset  = elem.offset;
            self.offset = self.onset + self.duration;
            self.middle = self.onset + self.duration/2;
        end % function
        
        %------------------------------------------------------------------
        function set_onset_at_elem_onset( self, elem )
            self.onset  = elem.onset;
            self.offset = self.onset + self.duration;
            self.middle = self.onset + self.duration/2;
        end % function
        
        %------------------------------------------------------------------
        function set_offset_at_elem_offset( self, elem )
            self.offset = elem.offset;
            self.onset  = self.offset - self.duration;
            self.middle = self.offset - self.duration/2;
        end % function
        
        %------------------------------------------------------------------
        function set_offset_at_elem_onset( self, elem )
            self.offset = elem.onset;
            self.onset  = self.offset - self.duration;
            self.middle = self.offset - self.duration/2;
        end % function
        
        %------------------------------------------------------------------
        function set_middle_using_TE(self, TE)
            self.middle = TE;
            self.onset  = TE - self.duration/2;
            self.offset = TE + self.duration/2;
        end
        
        %------------------------------------------------------------------
        function set_onset_and_duration(self, onset,duration)
            self.onset    = onset;
            self.duration = duration;
            self.offset   = onset + duration;
            self.middle   = onset + duration/2;
        end
        
        %------------------------------------------------------------------
        function new = deepcopy(self, name)
            new = self.copy();
            if nargin > 1
                new.name = name;
            end
        end
        
    end % methods
    
    
    methods % set methods, so the user can use which ever syntax he prefer
        
        % name
        function set_name(self, name)
            self.name = name; % this calls the set method just bellow
        end
        function set.name(self, name)
            self.name = name;
        end
        
        % duration
        function set_duration(self, duration)
            self.duration = duration; % this calls the set method just bellow
        end
        function set.duration(self, duration)
            self.duration = duration;
        end
        
        % onset
        function set_onset(self, onset)
            self.onset = onset; % this calls the set method just bellow
        end
        function set.onset(self, onset)
            self.onset = onset;
        end
        
        % middle
        function set_middle(self, middle)
            self.middle = middle; % this calls the set method just bellow
        end
        function set.middle(self, middle)
            self.middle = middle;
        end
        
        % offset
        function set_offset(self, offset)
            self.offset = offset; % this calls the set method just bellow
        end
        function set.offset(self, offset)
            self.offset = offset;
        end
        
        % magnitude
        function set_magnitude(self, magnitude)
            self.magnitude = magnitude; % this calls the set method just bellow
        end
        function set.magnitude(self, magnitude)
            % assert(isnumeric(magnitude) && isscalar(magnitude) && magnitude>=-1 && magnitude<=+1, '%s.magnitude muse be a [-1 .. +1]', self.name)
            self.magnitude = magnitude;
        end
        
    end % methods
    
end % classdef
