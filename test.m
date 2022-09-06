close all
clear
clc

TR = 10;
TE = 5;

pulse_dur = 1;
grad_dur = 1;

DIAGRAM           = mpd.diagram();

RF_090            = mpd.rf_pulse();
RF_090.flip_angle = 90;
RF_090.duration   = pulse_dur;

G_SS              = mpd.gradient();
G_SS.type         = mpd.grad_type.slice_selection; % grad_type is an enumeration, use [TAB] for auto-completion
G_SS.set_total_duration(grad_dur);

G_PE              = mpd.gradient();
G_PE.type         = mpd.grad_type.phase_encoding;
G_PE.set_total_duration(grad_dur);

RF_180            = mpd.rf_pulse();
RF_180.flip_angle = 180;
RF_180.duration   = 2.560;

G_SliceSel_180    = G_SS.copy();

G_RO              = mpd.gradient();
G_RO.type         = mpd.grad_type.readout;
G_RO.set_total_duration(grad_dur);       

ADC               = mpd.adc();
ADC.duration      = grad_dur;

DIAGRAM.add_element({ RF_090 G_SS G_PE RF_180 G_RO ADC })

% put elements in the right order using dedicated methods
G_SS.set_as_initial_element(); % begining of the diagram
RF_090.set_onset_at_grad_flattop(G_SS);
G_PE.set_onset_at_elem_offset(G_SS);
G_SliceSel_180.set_onset_at_elem_offset(G_PE);
RF_180.set_onset_at_grad_flattop(G_SliceSel_180);
G_RO.set_onset_at_elem_offset(G_SliceSel_180);
ADC.set_onset_at_grad_flattop(G_RO);

DIAGRAM.Draw();
