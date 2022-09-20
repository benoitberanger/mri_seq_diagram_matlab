classdef diagram < handle
    
    properties( SetAccess = public )
        
        color_rf      = 'red'
        color_grad_ss = 'blue'
        color_grad_ro = 'blue'
        color_adc     = 'green'
        
        sinc_n_lob    = 2 % integer values, { 0 (no lob), 1, 2, 3, ...}
        sinc_n_points = 1000 % definition of the SINC (RF pulse)
        pe_n_lines    = 5
        
    end % properties
    
    properties( SetAccess = protected )
        
        element_array = {}
        
        fig
        ax
        
        channel_type  = {'RF', 'G_SS', 'G_PE', 'G_RO', 'ADC'}
        
    end % properties
    
    methods (Access = public)
        
        %------------------------------------------------------------------
        function obj = add_rf_pulse(self, name)
            if nargin < 2
                name = '';
            end
            obj = self.add_element('mrisd.rf_pulse', name);
        end % function
        
        %------------------------------------------------------------------
        function obj = add_gradient(self, name)
            if nargin < 2
                name = '';
            end
            obj = self.add_element('mrisd.gradient', name);
        end % function
        
        %------------------------------------------------------------------
        function obj = add_adc(self, name)
            if nargin < 2
                name = '';
            end
            obj = self.add_element('mrisd.adc', name);
        end % function
        
        %------------------------------------------------------------------
        function obj = add_element(self, type, name)
            obj         = feval(type);
            obj.name    = name;
            obj.diagram = self;
            self.store_element(obj);
        end % function
        
        %------------------------------------------------------------------
        function store_element(self, element_array)
            if iscell(element_array)
                for i = 1 : numel(element_array)
                    self.element_array{end+1} = element_array{i};
                    element_array{i}.diagram = self; % copy a pointer
                end
            else
                self.element_array{end+1} = element_array;
            end
        end % function
        
        %------------------------------------------------------------------
        function Draw( self )
            
            % checks
            for el = 1 : length(self.element_array)
                obj = self.element_array{el}; % shortcut (just a pointer copy)
                assert(~isempty(obj.name    ), 'Element #%d, <%s> have no name, please set it.', el, class(obj))
                assert(~isempty(obj.onset   ), '%s.onset empty'   , obj.name)
                assert(~isempty(obj.middle  ), '%s.middle empty'  , obj.name)
                assert(~isempty(obj.offset  ), '%s.offset empty'  , obj.name)
                assert(~isempty(obj.duration), '%s.duration empty', obj.name)
                assert(~(isa(obj,'mrisd.gradient') && isempty(obj.dur_ramp_up  )), '%s.dur_ramp_up is empty'  , obj.name)
                assert(~(isa(obj,'mrisd.gradient') && isempty(obj.dur_flattop  )), '%s.dur_flattop is empty'  , obj.name)
                assert(~(isa(obj,'mrisd.gradient') && isempty(obj.dur_ramp_down)), '%s.dur_ramp_down is empty', obj.name)
            end
            
            % get first and last timepoint
            t_min = 0;
            t_max = 0;
            for el = 1 : length(self.element_array)
                t_min = min(t_min, self.element_array{el}.onset );
                t_max = max(t_max, self.element_array{el}.offset);
            end
            
            % open fig
            self.fig = figure();
            self.fig.Color = [1 1 1]; % white background
            
            nChan = length(self.channel_type);
            y_space = 1/nChan;
            
            % set axes, from bottom to top
            for a = nChan : -1 : 1
                
                % create axes, the place holder hor each curve type == channel
                ax(a) = axes(self.fig); %#ok<LAXES>
                hold(ax(a), 'on')
                ax(a).XLim = [t_min t_max];
                
                % on a figure, (0,0) "origin" point is at bottom left corner
                %                      x    y                      w    h
                ax(a).InnerPosition = [0.05 (nChan-a)*y_space+0.01 0.94 y_space*0.90];
                
                % seperate objects & plot curves
                switch self.channel_type{a}
                    
                    
                    case 'RF' %--------------------------------------------
                        
                        is_obj = cellfun(@(x) isa(x,'mrisd.rf_pulse'), self.element_array);
                        where_obj = find(is_obj);
                        
                        for i = 1 : numel(where_obj)
                            obj = self.element_array{where_obj(i)};
                            t = linspace(-(2*self.sinc_n_lob+1), +(2*self.sinc_n_lob+1), self.sinc_n_points);
                            y = sinc( t );
                            x = linspace(obj.onset, obj.offset, self.sinc_n_points);
                            plot( ax(a), ...
                                x, ...
                                y*obj.magnitude,...
                                'Color',self.color_rf)
                        end
                        
                    case 'G_SS' %------------------------------------------
                        
                        is_obj = cellfun(@(x) isa(x,'mrisd.gradient'), self.element_array);
                        where_obj = find(is_obj);
                        where_obj = where_obj( cellfun(@(x) strcmp(x.type, mrisd.grad_type.slice_selection), self.element_array(where_obj)) );
                        
                        for i = 1 : numel(where_obj)
                            obj = self.element_array{where_obj(i)};
                            plot( ax(a), ...
                                [obj.onset  obj.onset+obj.dur_ramp_up  obj.onset+obj.dur_ramp_up+obj.dur_flattop  obj.offset] , ...
                                [0          obj.magnitude              obj.magnitude                              0          ], ...
                                'Color',self.color_grad_ss)
                        end
                        
                    case 'G_PE' %------------------------------------------
                        
                        is_obj = cellfun(@(x) isa(x,'mrisd.gradient'), self.element_array);
                        where_obj = find(is_obj);
                        where_obj = where_obj( cellfun(@(x) strcmp(x.type, mrisd.grad_type.phase_encoding), self.element_array(where_obj)) );
                        
                        for i = 1 : numel(where_obj)
                            obj = self.element_array{where_obj(i)};
                            
                            % specific color managment, we use jet (from blue to red) to show early vs late phase encoding lines
                            colors = jet(2*self.pe_n_lines+1);
                            
                            if sign(obj.magnitude) == -1 % reverse order when magnitude is negative
                                colors = flipud(colors);
                            end
                            
                            count = 0;
                            for line = -self.pe_n_lines : self.pe_n_lines
                                count = count + 1;
                                plot( ax(a), ...
                                    [obj.onset  obj.onset+obj.dur_ramp_up  obj.onset+obj.dur_ramp_up+obj.dur_flattop  obj.offset]                         , ...
                                    [0          obj.magnitude              obj.magnitude                              0         ] * (line/self.pe_n_lines), ...
                                    'Color',colors(count,:))
                            end                            
                            if sign(obj.magnitude) == 1
                                y_arraow = +[ax(a).Position(2)                   ax(a).Position(2)+ax(a).Position(4)]*obj.magnitude;
                            else
                                y_arraow = -[ax(a).Position(2)+ax(a).Position(4) ax(a).Position(2)                  ]*obj.magnitude;
                            end
                            annotation(self.fig,'arrow', [1 1]*(ax(a).Position(1) + (obj.onset-t_min)*ax(a).Position(3)/(t_max-t_min)), y_arraow)
                        end
                        
                    case 'G_RO' %------------------------------------------
                        
                        is_obj = cellfun(@(x) isa(x,'mrisd.gradient'), self.element_array);
                        where_obj = find(is_obj);
                        where_obj = where_obj( cellfun(@(x) strcmp(x.type, mrisd.grad_type.readout       ), self.element_array(where_obj)) );
                        
                        for i = 1 : numel(where_obj)
                            obj = self.element_array{where_obj(i)};
                            plot( ax(a), ...
                                [obj.onset  obj.onset+obj.dur_ramp_up  obj.onset+obj.dur_ramp_up+obj.dur_flattop  obj.offset] , ...
                                [0          obj.magnitude              obj.magnitude                              0         ], ...
                                'Color',self.color_grad_ro)
                        end
                        
                    case 'ADC' %-------------------------------------------
                        
                        is_obj = cellfun(@(x) isa(x,'mrisd.adc'), self.element_array);
                        where_obj = find(is_obj);
                        
                        for i = 1 : numel(where_obj)
                            obj = self.element_array{where_obj(i)};
                            plot( ax(a), ...
                                [obj.onset obj.onset     obj.offset     obj.offset], ...
                                [0         obj.magnitude obj.magnitude  0         ], ...
                                'Color',self.color_adc)
                        end
                        
                end % switch
                
                plot(ax(a), [t_min t_max], [0 0], 'Color', 'black', 'Linewidth', 0.5, 'LineStyle', ':')
                
                % make visal ajusments so each axes looks cleaner
                ax(a).YLabel.Interpreter = 'none';
                ax(a).YLabel.String      = self.channel_type{a};
                ax(a).XAxis.Color        = ax(a).Parent.Color;
                ax(a).YAxis.Color        = ax(a).Parent.Color;
                ax(a).YLabel.Color       = [0 0 0];
                ax(a).YLim               = [-1 +1];
                ax(a).XLim               = [t_min t_max];
                ax(a).FontWeight         = 'bold';
                ax(a).XTick              = [];
                ax(a).YTick              = [];
            end % for
            
            linkaxes(ax,'x')
            self.ax = ax; %#ok<*PROP>
            
        end % function
        
    end % methods
    
    
    methods % set methods, so the user can use which ever syntax he prefer
        
        % color_rf
        function set_color_rf(self, color_rf)
            self.color_rf = color_rf; % this calls the set method just bellow
        end
        function set.color_rf(self, color_rf)
            self.color_rf = color_rf;
        end
        
        % color_grad_ss
        function set_color_grad_ss(self, color_grad_ss)
            self.color_grad_ss = color_grad_ss; % this calls the set method just bellow
        end
        function set.color_grad_ss(self, color_grad_ss)
            self.color_grad_ss = color_grad_ss;
        end
        
        % color_grad_ro
        function set_color_grad_ro(self, color_grad_ro)
            self.color_grad_ro = color_grad_ro; % this calls the set method just bellow
        end
        function set.color_grad_ro(self, color_grad_ro)
            self.color_grad_ro = color_grad_ro;
        end
        
        % color_adc
        function set_color_adc(self, color_adc)
            self.color_adc = color_adc; % this calls the set method just bellow
        end
        function set.color_adc(self, color_adc)
            self.color_adc = color_adc;
        end
        
        % sinc_n_lob
        function set_sinc_n_lob(self, sinc_n_lob)
            self.sinc_n_lob = sinc_n_lob; % this calls the set method just bellow
        end
        function set.sinc_n_lob(self, sinc_n_lob)
            self.sinc_n_lob = sinc_n_lob;
        end
        
         % sinc_n_points
        function set_sinc_n_points(self, sinc_n_points)
            self.sinc_n_points = sinc_n_points; % this calls the set method just bellow
        end
        function set.sinc_n_points(self, sinc_n_points)
            self.sinc_n_points = sinc_n_points;
        end
        
        % pe_n_lines
        function set_pe_n_lines(self, pe_n_lines)
            self.pe_n_lines = pe_n_lines; % this calls the set method just bellow
        end
        function set.pe_n_lines(self, pe_n_lines)
            self.pe_n_lines = pe_n_lines;
        end
        
    end % methods
    
end % classdef
