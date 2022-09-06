classdef diagram < handle
    
    properties
        element_array cell
        fig
        ax
        channel_type = {'RF', 'G_SS', 'G_PE', 'G_RO', 'ADC'}
    end % properties
    
    methods
        
        function add_element(self, element_array)
            for i = 1 : numel(element_array)
                self.element_array{end+1} = element_array{i};
                element_array{i}.diagram = self; % copy a pointer
            end
        end % function
        
        function Draw( self )
            
            % open fig
            self.fig = figure();
            self.fig.Color = [1 1 1]; % white background
            
            nChan = length(self.channel_type);
            y_space = 1/nChan;
            
            % set axes, from bottom to top
            for a = nChan : -1 : 1
                ax(a) = axes(self.fig); %#ok<LAXES>
                ax(a).OuterPosition = [0.00 (nChan-a)*y_space 1.00 y_space*1.00];
                ax(a).InnerPosition = [0.05 (nChan-a)*y_space 0.95 y_space*0.90];
                ax(a).XTick = [];
                ax(a).YTick = [];
                ax(a).YLabel.Interpreter = 'none';
                ax(a).YLabel.String = self.channel_type{a};
                ax(a).XAxis.Color = ax(a).Parent.Color;
                ax(a).YAxis.Color = ax(a).Parent.Color;
                ax(a).YLabel.Color = [0 0 0];
            end
            self.ax = ax; %#ok<*PROP>
        end % function
        
    end % methods
    
end % classdef
