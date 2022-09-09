close all
clear
clc

% TR = 10;
% TE = 5;

pulse_dur = 1;
grad_dur = 2;

DIAGRAM           = mrisd.diagram();

RF_090            = DIAGRAM.add_rf_pulse('RF_090');
RF_090.flip_angle = 90;
RF_090.duration   = pulse_dur;
RF_090.magnitude  = 0.5;

G_SS090set           = DIAGRAM.add_gradient('G_SS090set');
G_SS090set.type      = mrisd.grad_type.slice_selection; % grad_type is an enumeration, use [TAB] for auto-completion
G_SS090set.set_flattop_on_rf(RF_090);

G_SS090rew           = DIAGRAM.add_gradient('G_SS090rew');
G_SS090rew.type      = mrisd.grad_type.slice_selection; % grad_type is an enumeration, use [TAB] for auto-completion
G_SS090rew.set_total_duration(RF_090.duration);
G_SS090rew.magnitude = -1;

G_PEset              = DIAGRAM.add_gradient('G_PEset');
G_PEset.type         = mrisd.grad_type.phase_encoding;
G_PEset.set_total_duration(grad_dur);

RF_180            = DIAGRAM.add_rf_pulse('RF_180');
RF_180.flip_angle = 180;
RF_180.duration   = pulse_dur;

G_SS180set        = G_SS090set.deepcopy('G_SS180set');
G_SS180rew        = G_SS090rew.deepcopy('G_SS180rew');

ADC               = DIAGRAM.add_adc('ADC');
ADC.duration      = grad_dur;

G_ROpre           = DIAGRAM.add_gradient('G_ROpre');
G_ROpre.type      = mrisd.grad_type.readout;
G_ROpre.set_total_duration(grad_dur);
G_ROpre.magnitude = -1;

G_ROadc              = DIAGRAM.add_gradient('G_ROadc');
G_ROadc.type         = mrisd.grad_type.readout;
G_ROadc.set_flattop_on_adc(ADC);


% put elements in the right order using dedicated methods
G_SS090set.set_as_initial_element   (           ); % begining of the diagram
RF_090.    set_onset_at_grad_flattop(G_SS090set);
G_SS090rew.set_onset_at_elem_offset (G_SS090set);
G_PEset.   set_onset_at_elem_offset (G_SS090rew);
G_SS180set.set_onset_at_elem_offset (G_PEset   );
RF_180.    set_onset_at_grad_flattop(G_SS180set);
G_SS180rew.set_onset_at_elem_offset (G_SS180set);
G_ROpre.   set_onset_at_elem_offset (G_SS180rew);
G_ROadc.   set_onset_at_elem_offset (G_ROpre   );
ADC.       set_onset_at_grad_flattop(G_ROadc   );

DIAGRAM.Draw();
