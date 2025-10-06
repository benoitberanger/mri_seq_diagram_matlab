classdef rf_pulse < mrisd.element
    
    properties (SetAccess = public)
        
        type       char    {mustBeMember(type,{'sinc','rect','hs'})} = 'sinc'
        flip_angle double
        
        % visual
        color    = 'red' % can be char or a vect3
        n_lob    = 2     % integer values, { 0 (no lob), 1, 2, 3, ...}
        n_points = 100   % definition of the SINC (RF pulse)

    end % properties
    
    methods (Access = public)
        
        function set_onset_at_grad_flattop( self, gradient )
            self.onset  = gradient.onset + gradient.dur_ramp_up;
            self.offset = self.onset + self.duration;
            self.middle = self.onset + self.duration/2;
        end % function
        
    end % methods
    
end % classdef
