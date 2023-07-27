%% Init

close all
clear
clc

% motsly for time axis scaling
pulse_dur = 1;
grad_dur = 2;
delta = 3;
DELTA = 8;
epi_block_duration = 10;
TE = 25; % this places ADC middle (and RF middle if needed)
TR = 35;


%% Create the diagram object
% "channel" types are {'RF', 'G_SS', 'G_PE', 'G_RO', 'ADC'}. Each channe is one curve container.
%
% Gradients are seperated into "logical" axis : slice selective, phase encoding, readout

% Create diagram object
% This object will contain all the information
% All rf, gradient, adc objects are also objects, contained in a diagram
DIAGRAM = mrisd.diagram('se_epi_diffusion_3D');


%% Create each graphic element and set their paramters except position in time

% Create RF excitation
RF_090            = DIAGRAM.add_rf_pulse('RF_090');
RF_090.flip_angle = 90;
RF_090.magnitude  = 0.5; % half the magnitude(1) because there will be a 180° pulse

% Create RF refocusing
RF_180 = DIAGRAM.add_rf_pulse('RF_180');
RF_180.flip_angle = 180;

% Create SliceSelective Gradient "setter"
G_SS090set = DIAGRAM.add_gradient_slice_selection('G_SS090set');

% Create SliceSelective Gradient "rewinder"
G_SS090rew           = DIAGRAM.add_gradient_slice_selection('G_SS090rew');
G_SS090rew.magnitude = -1;

% Create SliceRefocussing Gradient "setter"
G_SS180set = DIAGRAM.add_gradient_slice_selection('G_SS180set');

% Create diffusion gradients using block
block_diff_L = DIAGRAM.add_block_diff('block_diff_L');
block_diff_L.generate_block();
block_diff_R = DIAGRAM.add_block_diff('block_diff_R');
block_diff_R.generate_block();
annot_delta = DIAGRAM.add_annotation('delta');
annot_DELTA = DIAGRAM.add_annotation('DELTA');

% Create EPI block
block_EPI = DIAGRAM.add_block_epi('block_EPI');
block_EPI.epi.n_pe = 11; % number of phase encoding steps (lines)
block_EPI.generate_block();

annot_halfTE = DIAGRAM.add_annotation('TE/2');
annot_TE     = DIAGRAM.add_annotation('TE'  );

nextRF            = DIAGRAM.add_rf_pulse('nextRF');
nextRF.flip_angle = RF_090.flip_angle;
nextRF.magnitude  = RF_090.magnitude;

nextGSS      = DIAGRAM.add_gradient_slice_selection('nextGSS');

annot_TR     = DIAGRAM.add_annotation('TR');


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

RF_090.set_as_initial_element(pulse_dur); % set duration(use input argument), .onset = 0, ...

RF_180.duration = pulse_dur;
RF_180.set_middle_using_TRTE(RF_090.middle + TE/2); % this sets .middle, then the rest (onset/offset/duration)

% Now place gradients

G_SS090set.set_flattop_on_rf(RF_090); % will set all timings

G_SS090rew.set_moment(G_SS090set.get_rewind_moment()); % will set all .dur*, but no .onset or .offset
G_SS090rew.set_onset_at_elem_offset(G_SS090set);

G_SS180set.set_flattop_on_rf(RF_180);

block_diff_L.duration = delta;
block_diff_L.set_middle_using_TRTE(RF_090.middle + TE/2 - DELTA/2);
block_diff_L.update_block_elements(); % blocks contains many elements, this method will compute timings in all of them
block_diff_R.duration = delta;
block_diff_R.set_middle_using_TRTE(RF_090.middle + TE/2 + DELTA/2);
block_diff_R.update_block_elements(); % blocks contains many elements, this method will compute timings in all of them
annot_delta.set_onset_and_duration(block_diff_L.onset, block_diff_L.duration);
annot_DELTA.set_onset_and_duration(block_diff_L.onset, DELTA);

block_EPI.duration = epi_block_duration;
block_EPI.set_middle_using_TRTE(RF_090.middle + TE);
block_EPI.update_block_elements(); % blocks contains many elements, this method will compute timings in all of them

annot_halfTE.set_onset_and_duration(RF_090.middle, TE/2);
annot_TE.    set_onset_and_duration(RF_090.middle, TE  );

% for TR visualization :

nextRF.duration = RF_090.duration;
nextRF.set_middle_using_TRTE(RF_090.middle + TR);

nextGSS.set_flattop_on_rf(nextRF);

annot_TR.set_onset_and_duration(RF_090.middle, TR);


%% Now we draw
% Many checks will be performed in the .draw(), asserions should help filling missing informations.

DIAGRAM.Draw();

% save the fig :
% DIAGRAM.save_fig('spin_echo.png')
% DIAGRAM.save_fig('spin_echo.svg')
