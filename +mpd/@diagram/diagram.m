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
            %             self.fig.Color = [1 1 1]; % white background
            
            nChan = length(self.channel_type);
            y_space = 1/nChan;
            
            % set axes, from bottom to top
            for a = nChan : -1 : 1
                
                % create axes, the place holder hor each curve type == channel
                ax(a) = axes(self.fig); %#ok<LAXES>
                hold(ax(a), 'on')
                ax(a).OuterPosition = [0.00 (nChan-a)*y_space 1.00 y_space*1.00];
                ax(a).InnerPosition = [0.05 (nChan-a)*y_space 0.95 y_space*0.90];
                
                % seperate objects
                switch self.channel_type{a}
                    case 'RF'
                        is_obj = cellfun(@(x) isa(x,'mpd.rf_pulse'), self.element_array);
                        where_obj = find(is_obj);
                    case 'G_SS'
                        is_obj = cellfun(@(x) isa(x,'mpd.gradient'), self.element_array);
                        where_obj = find(is_obj);
                        where_obj = where_obj( cellfun(@(x) strcmp(x.type, mpd.grad_type.slice_selection), self.element_array(where_obj)) );
                    case 'G_PE'
                        is_obj = cellfun(@(x) isa(x,'mpd.gradient'), self.element_array);
                        where_obj = find(is_obj);
                        where_obj = where_obj( cellfun(@(x) strcmp(x.type, mpd.grad_type.phase_encoding), self.element_array(where_obj)) );
                    case 'G_RO'
                        is_obj = cellfun(@(x) isa(x,'mpd.gradient'), self.element_array);
                        where_obj = find(is_obj);
                        where_obj = where_obj( cellfun(@(x) strcmp(x.type, mpd.grad_type.readout), self.element_array(where_obj)) );
                    case 'ADC'
                        is_obj = cellfun(@(x) isa(x,'mpd.adc')     , self.element_array);
                        where_obj = find(is_obj);
                end % switch
                
                % plot curve
                switch self.channel_type{a}
                    
                    case 'RF'
                        
                        for i = 1 : numel(where_obj)
                            obj = self.element_array{where_obj(i)};
                            plot( ax(a), ...
                                [obj.onset obj.onset obj.offset obj.offset], ...
                                [0 1 1 0] )
                        end
                        
                    case {'G_SS', 'G_PE', 'G_RO'}
                        
                        for i = 1 : numel(where_obj)
                            obj = self.element_array{where_obj(i)};
                            plot( ax(a), ...
                                [obj.onset obj.onset+obj.dur_ramp_up obj.onset+obj.dur_ramp_up+obj.dur_flattop obj.offset], ...
                                [0 1 1 0] )
                        end
                        
                    case 'ADC'
                        
                        for i = 1 : numel(where_obj)
                            obj = self.element_array{where_obj(i)};
                            plot( ax(a), ...
                                [obj.onset obj.onset obj.offset obj.offset], ...
                                [0 1 1 0] )
                        end
                        
                end % switch
                
                % make visal ajusments so each axes looks cleaner
                ax(a).XTick              = [];
                ax(a).YTick              = [];
                ax(a).YLabel.Interpreter = 'none';
                ax(a).YLabel.String      = self.channel_type{a};
                ax(a).XAxis.Color        = ax(a).Parent.Color;
                ax(a).YAxis.Color        = ax(a).Parent.Color;
                ax(a).YLabel.Color       = [0 0 0];
                
            end % for
            
            linkaxes(ax,'x')
            self.ax = ax; %#ok<*PROP>
            
        end % function
        
    end % methods
    
end % classdef
