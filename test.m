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

G_SS090           = mpd.gradient();
G_SS090.type      = mpd.grad_type.slice_selection; % grad_type is an enumeration, use [TAB] for auto-completion
G_SS090.set_flattop_on_rf(RF_090);

G_PE              = mpd.gradient();
G_PE.type         = mpd.grad_type.phase_encoding;
G_PE.set_total_duration(grad_dur);

RF_180            = mpd.rf_pulse();
RF_180.flip_angle = 180;
RF_180.duration   = pulse_dur;

G_SS180           = G_SS090.copy();

ADC               = mpd.adc();
ADC.duration      = grad_dur;

G_RO              = mpd.gradient();
G_RO.type         = mpd.grad_type.readout;
G_RO.set_flattop_on_adc(ADC);

DIAGRAM.add_element({ RF_090 G_SS090 G_PE RF_180 G_SS180 G_RO ADC })

% put elements in the right order using dedicated methods
G_SS090.set_as_initial_element   (       ); % begining of the diagram
RF_090. set_onset_at_grad_flattop(G_SS090);
G_PE.   set_onset_at_elem_offset (G_SS090);
G_SS180.set_onset_at_elem_offset (G_PE   );
RF_180. set_onset_at_grad_flattop(G_SS180);
G_RO.   set_onset_at_elem_offset (G_SS180);
ADC.    set_onset_at_grad_flattop(G_RO   );

DIAGRAM.Draw();
