%% Init

close all
clear
clc

% motsly for time axis scaling
pulse_dur = 1;
grad_dur = 2;


%% Create the diagram object
% "channel" types are {'RF', 'G_SS', 'G_PE', 'G_RO', 'ADC'}. Each channe is one curve container.
% Gradients are seperated into "logical" axis : slice selective, phase encoding, readout
% This seperation is done by filling .type, using an enumeration. Don't worry, its makes useful and very simple tu use.

DIAGRAM = mrisd.diagram();


%% Create each graphic element and set their paramters except position in time
%
% Each element (rf_pulse, gradient, adc) have 4 timing values :
% - onset
% - middle (default : duration/2)
% - offset
% - duration (default : offset-onset)
%
% And gradients have also :
% - dur_ramp_up
% - dur_flattop
% - dur_ramp_down  (duration = dur_ramp_up + dur_flattop + dur_ramp_down)
%

% Create RF excitation
RF_090            = DIAGRAM.add_rf_pulse('RF_090');
RF_090.flip_angle = 90;
RF_090.magnitude  = 0.5; % half the magnitude(1) because there will be a 180° pulse

% Create SliceSelective Gradient "setter"
G_SS090set      = DIAGRAM.add_gradient('G_SS090set');
G_SS090set.type = mrisd.grad_type.slice_selection; % grad_type is an enumeration, use [TAB] for auto-completion

% Timings
RF_090.duration = pulse_dur; % mostly used for scaling the time axis
G_SS090set.set_flattop_on_rf(RF_090); % will set .duration
G_SS090set.set_as_initial_element();  % begining of the diagram, .onset=0
RF_090.set_onset_at_grad_flattop(G_SS090set); % will set .onset and .offset

% Create SliceSelective Gradient "rewinder"
G_SS090rew           = DIAGRAM.add_gradient('G_SS090rew');
G_SS090rew.type      = mrisd.grad_type.slice_selection; % grad_type is an enumeration, use [TAB] for auto-completion
G_SS090rew.magnitude = -1;

% Timings
G_SS090rew.set_total_duration(RF_090.duration/2); % will set all .dur*, but no .onset or .offset
G_SS090rew.set_onset_at_elem_offset(G_SS090set);

% Create PhaseEncoding Gradient "setter"
G_PEset      = DIAGRAM.add_gradient('G_PEset');
G_PEset.type = mrisd.grad_type.phase_encoding;

% Timings
G_PEset.set_total_duration(grad_dur); % will set all duration, but no onset or offset
G_PEset.set_onset_at_elem_offset(G_SS090rew);

% Create RF refocusing
RF_180            = DIAGRAM.add_rf_pulse('RF_180');
RF_180.flip_angle = 180;

% Timings
RF_180.duration = pulse_dur; % mostly used for scaling the time axis

% Create SliceRefocussing Gradient "setter"
G_SS180set      = DIAGRAM.add_gradient('G_SS180set');
G_SS180set.type = mrisd.grad_type.slice_selection; % grad_type is an enumeration, use [TAB] for auto-completion

% Timings
G_SS180set.set_flattop_on_rf(RF_180);
G_SS180set.set_onset_at_elem_offset(G_PEset);
RF_180.set_onset_at_grad_flattop(G_SS180set);

% Create ADC
ADC = DIAGRAM.add_adc('ADC');

% Timings
ADC.duration = grad_dur;

% Create ReadOut gradient "prephase"
G_ROpre           = DIAGRAM.add_gradient('G_ROpre');
G_ROpre.type      = mrisd.grad_type.readout;
G_ROpre.magnitude = -1;

% Timings
G_ROpre.set_total_duration(ADC.duration/2);
G_ROpre.set_onset_at_elem_offset(G_SS180set);

% Create ReadOut gradient for ADC
G_ROadc      = DIAGRAM.add_gradient('G_ROadc');
G_ROadc.type = mrisd.grad_type.readout;

% Timings
G_ROadc.set_flattop_on_adc(ADC);
G_ROadc.set_onset_at_elem_offset(G_ROpre);
ADC.set_onset_at_grad_flattop(G_ROadc);


%% Now we draw
% Many checks will be performed in the .draw(), asserions should help filling missing informations.

DIAGRAM.Draw();

