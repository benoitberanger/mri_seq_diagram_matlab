classdef block < mrisd.element
    
    properties (SetAccess = public)
        
        type  char   % use mrisd.block_type.[TAB] // controlled by a setter method
        color = struct % need to overload it (since its abstract)
        
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
