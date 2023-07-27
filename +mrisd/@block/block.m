classdef block < mrisd.element

    properties (SetAccess = public)

        type  char     % use mrisd.block_type.[TAB] // controlled by a setter method
        color = struct % need to overload it (since its abstract)

        % block stuff
        epi  struct = struct('n_pe', 9);
        diff struct = struct('n_pe', 9, 'n_diff', 16);

    end % properties

    properties( SetAccess = protected )

        element_array = {} % adc, gradient, echo ...

    end % properties

    methods (Access = public)

        function update_block_elements(self)
            switch self.type
                case mrisd.block_type.epi
                    self.update_epi_elements();
                case mrisd.block_type.diff
                    self.update_diff_elements();
            end
        end % function

        function generate_block(self)
            switch self.type
                case mrisd.block_type.epi
                    self.generate_epi_block();
                case mrisd.block_type.diff
                    self.generate_diff_block();
            end
        end % function

    end % methods

    methods

        %------------------------------------------------------------------
        % SETTER

        function set.type(self, value)
            switch value
                case mrisd.block_type.epi
                    self.type = value;
                case mrisd.block_type.diff
                    self.type = value;
                otherwise
                    error('block %s does not exist', value)
            end % switch
        end % function

    end % methods

    methods (Access = protected)

        %------------------------------------------------------------------
        % block functions : diff

        function generate_diff_block(self)
            self.add_gradient_slice_selection([self.name '::G_Z']);
            self.add_gradient_phase_encoding ([self.name '::G_Y']);
            self.add_gradient_readout        ([self.name '::G_X']);
        end % end

        function update_diff_elements(self)
            GX = self.get_elem([self.name '::G_X']);
            GY = self.get_elem([self.name '::G_Y']);
            GZ = self.get_elem([self.name '::G_Z']);
            GX.set_total_duration(self.duration);
            GY.set_total_duration(self.duration);
            GZ.set_total_duration(self.duration);
            GX.set_onset_and_duration(self.onset, self.duration);
            GY.set_onset_and_duration(self.onset, self.duration);
            GZ.set_onset_and_duration(self.onset, self.duration);
            GX.n_lines = self.diff.n_diff;
            GY.n_lines = self.diff.n_diff;
            GZ.n_lines = self.diff.n_diff;
        end % function

        %------------------------------------------------------------------
        % block functions : epi

        function generate_epi_block(self)

            % PhaseEncoding
            G_blockEPI_PEpre = self.add_gradient_phase_encoding('G_blockEPI_PEpre');
            G_blockEPI_PEpre.magnitude = -1;
            for i_pe = 1 : self.epi.n_pe
                obj = self.add_gradient_phase_encoding(sprintf('G_blockEPI_PE_%d', i_pe));
                obj.magnitude = 0.5;
            end

            % Readout
            G_blockEPI_ROpre = self.add_gradient_readout('G_blockEPI_ROpre');
            G_blockEPI_ROpre.magnitude = -1;
            polarity = -1;
            for i_pe = 1 : self.epi.n_pe
                obj = self.add_gradient_readout(sprintf('G_blockEPI_RO_%d', i_pe));
                polarity = polarity * -1;
                obj.magnitude = polarity;
            end

            % prepare magnitude of Echos
            if mod(self.epi.n_pe,2) == 0 % even
                magnitude_L = 1 :  self.epi.n_pe/2;
                magnitude = [magnitude_L fliplr(magnitude_L)] / max(magnitude_L);
            else % odd
                magnitude_L = 1 : (self.epi.n_pe-1)/2;
                magnitude = [magnitude_L magnitude_L(end)+1 fliplr(magnitude_L)] / (magnitude_L(end)+1);
            end

            % ADC & Echos
            for i_pe = 1 : self.epi.n_pe
                self.add_adc (sprintf('G_blockEPI_ADC_%d', i_pe));
                obj = self.add_echo(sprintf('G_blockEPI_Echo_%d', i_pe));
                obj.magnitude = magnitude(i_pe);
            end

        end % end

        function update_epi_elements(self)
            duration_RO = self.duration / self.epi.n_pe;

            for i_pe = 1 : self.epi.n_pe
                RO_i = self.get_elem(sprintf('G_blockEPI_RO_%d', i_pe));
                RO_i.set_total_duration(duration_RO);
                RO_i.set_onset_and_duration(self.onset + (i_pe-1) * duration_RO, duration_RO);

                ADC_i = self.get_elem(sprintf('G_blockEPI_ADC_%d', i_pe));
                ADC_i.duration = RO_i.dur_flattop;
                ADC_i.set_onset_at_grad_flattop(RO_i);

                Echo = self.get_elem(sprintf('G_blockEPI_Echo_%d', i_pe));
                Echo.set_using_ADC(ADC_i);

                PE_i = self.get_elem(sprintf('G_blockEPI_PE_%d', i_pe));
                PE_i.set_total_duration(RO_i.dur_ramp_up);
                PE_i.set_onset_at_elem_onset(RO_i);
                PE_i.color = 'black';
                PE_i.n_lines = 1;
            end

            RO_pre = self.get_elem('G_blockEPI_ROpre');
            RO_pre.set_moment(RO_i.get_total_moment()/2);
            RO_pre.set_offset_at_elem_onset(self.get_elem('G_blockEPI_RO_1'));

            PE_pre = self.get_elem('G_blockEPI_PEpre');
            PE_pre.set_moment((PE_i.get_total_moment() * self.epi.n_pe)/2);
            PE_pre.set_offset_at_elem_onset(self.get_elem('G_blockEPI_PE_1'));
            PE_pre.color = 'black';
            PE_pre.n_lines = 1;

        end % function

        %------------------------------------------------------------------
        % commun methods

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
        function obj = add_adc(self, name)
            obj      = self.add_element('mrisd.adc', name);
        end % function
        function obj = add_echo(self, name)
            obj      = self.add_element('mrisd.echo', name);
        end % function

        function obj = add_element(self, type, name)
            obj         = feval(type);
            obj.name    = name;
            obj.diagram = self.diagram;
            self.element_array{end+1} = obj;
            self.diagram.store_element(obj);
        end % function

        function obj = get_elem(self, name)
            names = cellfun(@(x) x.name, self.element_array, 'UniformOutput', 0)';
            idx = strcmp(names, name);
            obj = self.element_array{idx};
        end

    end % methods

end % classdef
