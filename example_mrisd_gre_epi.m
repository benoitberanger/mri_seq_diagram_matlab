%% Init

close all
clear
clc

% motsly for time axis scaling
pulse_dur = 1;
grad_dur = 2;
epi_block_duration = 10;
TE = 8;
TR = 15;


%% Create the diagram object
% "channel" types are {'RF', 'G_SS', 'G_PE', 'G_RO', 'ADC'}. Each channe is one curve container.
%
% Gradients are seperated into "logical" axis : slice selective, phase encoding, readout
% This seperation is done by filling .type, using an enumeration. Don't worry, its makes useful and very simple tu use.
%

% Create diagram object
% This object will contain all the information
% All rf, gradient, adc objects are also objects, contained in a diagram
DIAGRAM = mrisd.diagram();


%% Create each graphic element and set their paramters except position in time

% Create RF excitation
RF_alpha            = DIAGRAM.add_rf_pulse('RF_alpha');
RF_alpha.magnitude  = 1; % half the magnitude(1) because there will be a 180° pulse

% Create SliceSelective Gradient "setter"
G_SSset      = DIAGRAM.add_gradient_slice_selection('G_SSset');

% Create SliceSelective Gradient "rewinder"
G_SSrew           = DIAGRAM.add_gradient_slice_selection('G_SSrew');
G_SSrew.magnitude = -1;

% Create EPI block
block_EPI = DIAGRAM.add_block_epi('block_EPI');

nextRF            = DIAGRAM.add_rf_pulse('nextRF');
nextRF.flip_angle = RF_alpha.flip_angle;
nextRF.magnitude  = RF_alpha.magnitude;

nextGSS = DIAGRAM.add_gradient_slice_selection('nextGSS');

annot_TE = DIAGRAM.add_annotation('TE');
annot_TR = DIAGRAM.add_annotation('TR');


%% Timings
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

% Place the main objects, used to define TE, TE/2, ...

RF_alpha.set_as_initial_element(pulse_dur); % set duration(use input argument), .onset = 0, ...

% Now place gradients

G_SSset.set_flattop_on_rf(RF_alpha); % will set all timings

G_SSrew.set_total_duration(RF_alpha.duration/2); % will set all .dur*, but no .onset or .offset
G_SSrew.set_onset_at_elem_offset(G_SSset);

block_EPI.duration = epi_block_duration;
block_EPI.set_middle_using_TRTE(RF_alpha.middle + TE);
block_EPI.update_block_elements();

annot_TE.set_onset_and_duration(RF_alpha.middle, TE  );

% for TR visualization :

nextRF.duration = RF_alpha.duration;
nextRF.set_middle_using_TRTE(RF_alpha.middle + TR);

nextGSS.set_flattop_on_rf(nextRF);

annot_TR.set_onset_and_duration(RF_alpha.middle, TR);


%% Now we draw
% Many checks will be performed in the .draw(), asserions should help filling missing informations.

DIAGRAM.Draw();

