close all
clear
clc

% TR = 10;
% TE = 5;

pulse_dur = 1;
grad_dur = 2;

DIAGRAM           = mpd.diagram();

RF_090            = mpd.rf_pulse('RF_090');
RF_090.flip_angle = 90;
RF_090.duration   = pulse_dur;
RF_090.magnitude  = 0.5;

G_SS090set           = mpd.gradient('G_SS090set');
G_SS090set.type      = mpd.grad_type.slice_selection; % grad_type is an enumeration, use [TAB] for auto-completion
G_SS090set.set_flattop_on_rf(RF_090);

G_SS090rew           = mpd.gradient('G_SS090rew');
G_SS090rew.type      = mpd.grad_type.slice_selection; % grad_type is an enumeration, use [TAB] for auto-completion
G_SS090rew.set_total_duration(RF_090.duration);
G_SS090rew.magnitude = -1;

G_PEset              = mpd.gradient('G_PEset');
G_PEset.type         = mpd.grad_type.phase_encoding;
G_PEset.set_total_duration(grad_dur);

RF_180            = mpd.rf_pulse('RF_180');
RF_180.flip_angle = 180;
RF_180.duration   = pulse_dur;

G_SS180set        = G_SS090set.deepcopy('G_SS180set');
G_SS180rew        = G_SS090rew.deepcopy('G_SS180rew');

ADC               = mpd.adc('ADC');
ADC.duration      = grad_dur;

G_ROpre           = mpd.gradient('G_ROpre');
G_ROpre.type      = mpd.grad_type.readout;
G_ROpre.set_total_duration(grad_dur);
G_ROpre.magnitude = -1;

G_ROadc              = mpd.gradient('G_ROadc');
G_ROadc.type         = mpd.grad_type.readout;
G_ROadc.set_flattop_on_adc(ADC);


DIAGRAM.add_element({ RF_090 G_SS090set G_SS090rew G_PEset RF_180 G_SS180set G_SS180rew G_ROpre G_ROadc ADC })

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
