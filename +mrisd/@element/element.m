classdef (Abstract) element < handle
    
    properties (SetAccess = public)
        
        % the "name" of the object is used for the diagram.plot()
        name       char
        
        % element duration( arbitrary unit )
        onset      double
        middle     double
        offset     double
        duration   double
        
        % visual stuff
        magnitude  double = 1 % like a scaling factor
        
        % pointer
        diagram    mrisd.diagram
        
    end % properties
    
    
    properties (Abstract)
        
        color
        
    end % properties
    
    
    methods (Access = public)
        
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
        function set_middle_using_TRTE(self, TRTE)
            self.middle = TRTE;
            self.onset  = TRTE - self.duration/2;
            self.offset = TRTE + self.duration/2;
        end
        
        %------------------------------------------------------------------
        function set_onset_and_duration(self, onset, duration)
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
    
end % classdef
