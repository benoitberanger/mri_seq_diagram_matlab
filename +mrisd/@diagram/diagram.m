classdef diagram < handle
    
    properties( SetAccess = public )
        
        color_midline = [0.8 0.8 0.8] % light gray
        name char
        
    end % properties
    
    properties( SetAccess = protected )
        
        element_array = {} % adc, gradient, echo ...
        block_array   = {} % epi block
        t_min = 0 % X axis min/max
        t_max = 0 % X axis min/max
        
        fig % pointer to the figure
        ax  % pointer to the axes array
        
        channel_type  = {'RF', 'G_SS', 'G_PE', 'G_RO', 'ADC', ''}
        
    end % properties
    
    methods (Access = public)
        
        %------------------------------------------------------------------
        % constructor
        function self = diagram(name)
            if nargin > 0
                self.name = name;
            end
        end % function
        
        %------------------------------------------------------------------
        function obj = add_rf_pulse(self, name)
            obj = self.add_element('mrisd.rf_pulse', name);
        end % function
        
        %------------------------------------------------------------------
        function obj = add_gradient_slice_selection(self, name)
            obj      = self.add_element('mrisd.gradient', name);
            obj.type = mrisd.grad_type.slice_selection;
        end % function
        function obj = add_gradient_phase_encoding(self, name)
            obj      = self.add_element('mrisd.gradient', name);
            obj.type = mrisd.grad_type.phase_encoding;
        end % function
        function obj = add_gradient_readout(self, name)
            obj      = self.add_element('mrisd.gradient', name);
            obj.type = mrisd.grad_type.readout;
        end % function
        
        %------------------------------------------------------------------
        function obj = add_block_epi(self, name)
            obj      = self.add_block('mrisd.block', name);
            obj.type = mrisd.block_type.epi;
        end % function
        function obj = add_block_diff(self, name)
            obj      = self.add_block('mrisd.block', name);
            obj.type = mrisd.block_type.diff;
        end % function
        
        %------------------------------------------------------------------
        function obj = add_adc(self, name)
            obj = self.add_element('mrisd.adc', name);
        end % function
        
        %------------------------------------------------------------------
        function obj = add_echo(self, name)
            obj = self.add_element('mrisd.echo', name);
        end % function
        
        %------------------------------------------------------------------
        function obj = add_annotation(self, name)
            obj = self.add_element('mrisd.annotation', name);
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
            for el = 1 : length(self.element_array)
                self.t_min = min(self.t_min, self.element_array{el}.onset );
                self.t_max = max(self.t_max, self.element_array{el}.offset);
            end
            
            % open fig
            if ~isempty(self.name)
                self.fig = figure('Name',self.name,'NumberTitle','off');
            else
                self.fig = figure();
            end
            self.fig.Color = [1 1 1]; % white background
            
            nChan = length(self.channel_type);
            y_space = 1/nChan;
            
            % set axes, from bottom to top
            for a = nChan : -1 : 1
                
                % create axes, the place holder hor each curve type == channel
                ax(a) = axes(self.fig); %#ok<LAXES>
                hold(ax(a), 'on')
                ax(a).XLim = [self.t_min self.t_max];
                
                % on a figure, (0,0) "origin" point is at bottom left corner
                %                      x    y                      w    h
                ax(a).InnerPosition = [0.05 (nChan-a)*y_space+0.01 0.94 y_space*0.90];
                
                if ~strcmp( self.channel_type{a} , '' )
                    plot(ax(a), [self.t_min self.t_max], [0 0], 'Color', self.color_midline)
                end
                
                % seperate objects & plot curves
                switch self.channel_type{a}
                    
                    
                    case 'RF' %--------------------------------------------
                        
                        is_obj = cellfun(@(x) isa(x,'mrisd.rf_pulse'), self.element_array);
                        where_obj = find(is_obj);
                        
                        for i = 1 : numel(where_obj)
                            obj = self.element_array{where_obj(i)};
                            t = linspace(-(2*obj.n_lob+1), +(2*obj.n_lob+1), obj.n_points);
                            y = sinc( t );
                            x = linspace(obj.onset, obj.offset,obj.n_points);
                            plot( ax(a), ...
                                x, ...
                                y*obj.magnitude,...
                                'Color',obj.color)
                        end
                        
                    case 'G_SS' %------------------------------------------
                        
                        is_obj = cellfun(@(x) isa(x,'mrisd.gradient'), self.element_array);
                        where_obj = find(is_obj);
                        where_obj = where_obj( cellfun(@(x) strcmp(x.type, mrisd.grad_type.slice_selection), self.element_array(where_obj)) );
                        
                        self.draw_lob(where_obj, ax(a));
                        
                    case 'G_PE' %------------------------------------------
                        
                        is_obj = cellfun(@(x) isa(x,'mrisd.gradient'), self.element_array);
                        where_obj = find(is_obj);
                        where_obj = where_obj( cellfun(@(x) strcmp(x.type, mrisd.grad_type.phase_encoding), self.element_array(where_obj)) );
                        
                        self.draw_lob(where_obj, ax(a));
                        
                    case 'G_RO' %------------------------------------------
                        
                        is_obj = cellfun(@(x) isa(x,'mrisd.gradient'), self.element_array);
                        where_obj = find(is_obj);
                        where_obj = where_obj( cellfun(@(x) strcmp(x.type, mrisd.grad_type.readout), self.element_array(where_obj)) );
                        
                        self.draw_lob(where_obj, ax(a));
                        
                    case 'ADC' %-------------------------------------------
                        
                        % ADC
                        is_obj = cellfun(@(x) isa(x,'mrisd.adc'), self.element_array);
                        where_obj = find(is_obj);
                        
                        for i = 1 : numel(where_obj)
                            obj = self.element_array{where_obj(i)};
                            plot( ax(a), ...
                                [obj.onset obj.onset     obj.offset     obj.offset], ...
                                [0         obj.magnitude obj.magnitude  0         ], ...
                                'Color',obj.color)
                        end
                        
                        % Echo
                        is_obj = cellfun(@(x) isa(x,'mrisd.echo'), self.element_array);
                        where_obj = find(is_obj);
                        
                        for i = 1 : numel(where_obj)
                            obj = self.element_array{where_obj(i)};
                            
                            t = linspace(0, +2*pi*obj.n_lob+pi/2, obj.n_points);
                            half = cos(t) .* 2.^(-t/(2*pi*obj.lob_decay));
                            if     obj.asymmetry  < 0.5
                                idx = 1:round(obj.n_points*obj.asymmetry*2);
                                y = [fliplr(half(idx)) half];
                            elseif obj.asymmetry == 0.5
                                y = [fliplr(half) half];
                            elseif obj.asymmetry  > 0.5
                                idx = 1:round(obj.n_points*(1-obj.asymmetry)*2);
                                y = [fliplr(half) half(idx)];
                            end
                            
                            x = linspace(obj.onset, obj.offset, length(y));
                            plot( ax(a), ...
                                x, ...
                                y*obj.magnitude,...
                                'Color',obj.color)
                        end
                        
                    case ''% annotations ----------------------------------
                        
                        is_obj = cellfun(@(x) isa(x,'mrisd.annotation'), self.element_array);
                        where_obj = find(is_obj);
                        where_obj = fliplr(where_obj);
                        
                        spacing = 1/(numel(where_obj)+1);
                        
                        for i = 1 : numel(where_obj)
                            obj = self.element_array{where_obj(i)};
                            
                            x1 = self.get_absolute_fig_pos_x(ax(a), obj.onset );
                            x2 = self.get_absolute_fig_pos_x(ax(a), obj.offset);
                            y1 = ax(a).Position(2) + ax(a).Position(4)*spacing*i;
                            y2 = y1;
                            
                            annotation(self.fig,'doublearrow', [x1 x2], [y1 y2],'Color',obj.color.arrow)
                            annotation(self.fig,'textbox', [x1+(x2-x1)/2 y1 0 0], 'String', obj.name,...
                                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Interpreter', 'none')
                            annotation(self.fig,'line', [x1 x1], [y1 1], 'LineStyle','-','Color',obj.color.vbar)
                            annotation(self.fig,'line', [x2 x2], [y1 1], 'LineStyle','-','Color',obj.color.vbar)
                        end
                        
                        
                end % switch
                
                % make visal ajusments so each axes looks cleaner
                ax(a).YLabel.Interpreter = 'none';
                ax(a).YLabel.String      = self.channel_type{a};
                ax(a).XAxis.Color        = ax(a).Parent.Color;
                ax(a).YAxis.Color        = ax(a).Parent.Color;
                ax(a).YLabel.Color       = [0 0 0];
                ax(a).YLim               = [-1 +1];
                ax(a).XLim               = [self.t_min self.t_max];
                ax(a).FontWeight         = 'bold';
                ax(a).XTick              = [];
                ax(a).YTick              = [];
            end % for
            
            linkaxes(ax,'x')
            self.ax = ax; %#ok<*PROP>
            
        end % function
        
        function save_fig(self, filename)
            saveas(self.fig, filename)
        end % function
        
    end % methods
    
    methods (Access = {?mrisd.block})
        
        %------------------------------------------------------------------
        function obj = add_element(self, type, name)
            obj         = feval(type);
            obj.name    = name;
            obj.diagram = self;
            self.store_element(obj);
        end % function
        
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
        function obj = add_block(self, type, name)
            obj         = feval(type);
            obj.name    = name;
            obj.diagram = self;
            self.store_block(obj);
            self.store_element(obj.element_array),
        end % function
        
        function store_block(self, block_array)
            if iscell(block_array)
                for i = 1 : numel(block_array)
                    self.block_array{end+1} = block_array{i};
                    block_array{i}.diagram = self; % copy a pointer
                end
            else
                self.block_array{end+1} = block_array;
            end
        end % function
        
    end % methods
    
    methods (Access = protected)
        
        function draw_lob(self, where_obj, ax)
            
            for i = 1 : numel(where_obj)
                obj = self.element_array{where_obj(i)};
                
                if obj.n_lines > 1
                    
                    % specific color managment, we use jet (from blue to red) to show early vs late phase encoding lines
                    colors = jet(2*obj.n_lines+1);
                    
                    if sign(obj.magnitude) == -1 % reverse order when magnitude is negative
                        colors = flipud(colors);
                    end
                    
                    count = 0;
                    for line = -obj.n_lines : obj.n_lines
                        count = count + 1;
                        plot( ax, ...
                            [obj.onset  obj.onset+obj.dur_ramp_up  obj.onset+obj.dur_ramp_up+obj.dur_flattop  obj.offset]                         , ...
                            [0          obj.magnitude              obj.magnitude                              0         ] * (line/obj.n_lines), ...
                            'Color',colors(count,:))
                    end
                    if sign(obj.magnitude) == 1
                        y_arraow = +[ax.Position(2)                   ax.Position(2)+ax.Position(4)]*obj.magnitude;
                    else
                        y_arraow = -[ax.Position(2)+ax.Position(4) ax.Position(2)                  ]*obj.magnitude;
                    end
                    annotation(self.fig,'arrow', [1 1]*self.get_absolute_fig_pos_x(ax, obj.onset), y_arraow)
                
                else
                    
                    plot( ax, ...
                        [obj.onset  obj.onset+obj.dur_ramp_up  obj.onset+obj.dur_ramp_up+obj.dur_flattop  obj.offset] , ...
                        [0          obj.magnitude              obj.magnitude                              0         ], ...
                        'Color',obj.color)
                    
                end
            end
            
        end % function
        
        function x_fig = get_absolute_fig_pos_x(self, ax, x_ax)
            x_fig = ax.Position(1) + (x_ax-self.t_min)*ax.Position(3)/(self.t_max-self.t_min);
        end
        
    end % methods
    
end % classdef
