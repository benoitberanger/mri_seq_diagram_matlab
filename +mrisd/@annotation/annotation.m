classdef annotation < mrisd.element
    
    properties (SetAccess = public)
        
        % visual
        color = struct(...
            'arrow'  , [0.9 0.9 0.9] ,... % light gray
            'vbar'   , [0.9 0.9 0.9]  ... % light gray
            )
        
    end % properties
    
    methods (Access = public)
    end % methods
    
end % classdef
