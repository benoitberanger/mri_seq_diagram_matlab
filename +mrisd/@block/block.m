classdef block < mrisd.element
    
    properties (SetAccess = public)
        
        %         % the "name" of the object is used for the diagram.plot()
        %         name       char
        %
        type       char % use mrisd.block_type.[TAB] // controlled by a setter method
        %
        %         % for plot
        %         onset      double
        %         middle     double
        %         offset     double
        %
        %         % element duration( arbitrary unit )
        %         duration   double
        %
        %         % visual stuff
        %         magnitude  double = 1 % like a scaling factor
        %
        %         % pointer
        %         diagram    mrisd.diagram
        
    end % properties
    
    properties( SetAccess = protected )
        
        element_array = {} % adc, gradient, echo ...
        
    end % properties
    
    methods
        
        %------------------------------------------------------------------
        % SETTER
        function set.type(self, value)
            switch value
                case mrisd.block_type.epi
                    self.generate_epi_block()
                otherwise
                    error('block %s does not exist', value)
            end % switch
        end % function
        
    end % methods

    methods (Access = private)
        
        function generate_epi_block(self)
            
        end % end
        
    end % methods
    
end % classdef
