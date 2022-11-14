classdef diagram < handle
    
    properties( SetAccess = public )
        
        color_rf      = 'red'
        color_grad_ss = 'black'
        color_grad_ro = 'black'
        color_adc     = [0.5 0.5 0.5] % gray
        color_echo    = 'blue'
        
        color_midline = [0.8 0.8 0.8] % light gray
        color_arrow   = [0.9 0.9 0.9] % light gray
        color_vbar    = [0.9 0.9 0.9] % light gray
        
        sinc_n_lob    = 2   % integer values, { 0 (no lob), 1, 2, 3, ...}
        sinc_n_points = 100 % definition of the SINC (RF pulse)
        
        pe_n_lines    = 5
        
        echo_n_lob    = 10;  % integer values, { 0 (no lob), 1, 2, 3, ...}
        echo_n_points = 1000 % definition of the sin wave with exponential envelope
        echo_lob_decay= 2;   % lob number with half the height
        
    end % properties
    
    properties( SetAccess = protected )
        
        element_array = {}
        
        fig
        ax
        
        channel_type  = {'RF', 'G_SS', 'G_PE', 'G_RO', 'ADC', ''}
        
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
        function obj = add_echo(self, name)
            if nargin < 2
                name = '';
            end
            obj = self.add_element('mrisd.echo', name);
        end % function
        
        %------------------------------------------------------------------
        function obj = add_annotation(self, name)
            if nargin < 2
                name = '';
            end
            obj = self.add_element('mrisd.annotation', name);
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
                
                if ~strcmp( self.channel_type{a} , '' )
                    plot(ax(a), [t_min t_max], [0 0], 'Color', self.color_midline)
                end
                
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
                            annotation(self.fig,'arrow', [1 1]*get_absolute_fig_pos_x(ax(a), obj.onset, t_min, t_max), y_arraow)
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
                        
                        % ADC
                        is_obj = cellfun(@(x) isa(x,'mrisd.adc'), self.element_array);
                        where_obj = find(is_obj);
                        
                        for i = 1 : numel(where_obj)
                            obj = self.element_array{where_obj(i)};
                            plot( ax(a), ...
                                [obj.onset obj.onset     obj.offset     obj.offset], ...
                                [0         obj.magnitude obj.magnitude  0         ], ...
                                'Color',self.color_adc)
                        end
                        
                        % Echo
                        is_obj = cellfun(@(x) isa(x,'mrisd.echo'), self.element_array);
                        where_obj = find(is_obj);
                        
                        for i = 1 : numel(where_obj)
                            obj = self.element_array{where_obj(i)};
                            
                            t = linspace(0, +2*pi*self.echo_n_lob+pi/2, self.echo_n_points);
                            half = cos(t) .* 2.^(-t/(2*pi*self.echo_lob_decay));
                            if     obj.asymmetry  < 0.5
                                idx = 1:round(self.echo_n_points*obj.asymmetry*2);
                                y = [fliplr(half(idx)) half];
                            elseif obj.asymmetry == 0.5
                                y = [fliplr(half) half];
                            elseif obj.asymmetry  > 0.5
                                idx = 1:round(self.echo_n_points*(1-obj.asymmetry)*2);
                                y = [fliplr(half) half(idx)];
                            end
                            
                            x = linspace(obj.onset, obj.offset, length(y));
                            plot( ax(a), ...
                                x, ...
                                y*obj.magnitude,...
                                'Color',self.color_echo)
                        end
                        
                    case ''% annotations ----------------------------------
                        
                        is_obj = cellfun(@(x) isa(x,'mrisd.annotation'), self.element_array);
                        where_obj = find(is_obj);
                        where_obj = fliplr(where_obj);
                        
                        spacing = 1/(numel(where_obj)+1);
                        
                        for i = 1 : numel(where_obj)
                            obj = self.element_array{where_obj(i)};
                            
                            x1 = get_absolute_fig_pos_x(ax(a), obj.onset , t_min, t_max);
                            x2 = get_absolute_fig_pos_x(ax(a), obj.offset, t_min, t_max);
                            y1 = ax(a).Position(2) + ax(a).Position(4)*spacing*i;
                            y2 = y1;
                            
                            annotation(self.fig,'doublearrow', [x1 x2], [y1 y2],'Color',self.color_arrow)
                            annotation(self.fig,'textbox', [x1+(x2-x1)/2 y1 0 0], 'String', obj.name,...
                                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
                            annotation(self.fig,'line', [x1 x1], [y1 1], 'LineStyle','-','Color',self.color_vbar)
                            annotation(self.fig,'line', [x2 x2], [y1 1], 'LineStyle','-','Color',self.color_vbar)
                        end
                        
                        
                end % switch
                
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
    
    
end % classdef


function x_fig = get_absolute_fig_pos_x(ax, x_ax, t_min, t_max)
    x_fig = ax.Position(1) + (x_ax-t_min)*ax.Position(3)/(t_max-t_min);
end
