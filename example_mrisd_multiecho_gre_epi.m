%% Init

close all
clear
clc

% motsly for time axis scaling
pulse_dur = 1;
grad_dur = 2;
epi_n_pe = 7;
epi_block_duration = 7;
TE1 = 10;
TE2 = 20;
TE3 = 30;
TR = 40;


%% Create the diagram object
% "channel" types are {'RF', 'G_SS', 'G_PE', 'G_RO', 'ADC'}. Each channe is one curve container.
%
% Gradients are seperated into "logical" axis : slice selective, phase encoding, readout

% Create diagram object
% This object will contain all the information
% All rf, gradient, adc objects are also objects, contained in a diagram
DIAGRAM = mrisd.diagram('gre_epi');


%% Create each graphic element and set their paramters except position in time

% Create RF excitation
RF_alpha            = DIAGRAM.add_rf_pulse('RF_alpha');
RF_alpha.magnitude  = 1;

% Create SliceSelective Gradient "setter"
G_SSset = DIAGRAM.add_gradient_slice_selection('G_SSset');

% Create SliceSelective Gradient "rewinder"
G_SSrew           = DIAGRAM.add_gradient_slice_selection('G_SSrew');
G_SSrew.magnitude = -1;

% Create EPI blocks
block_EPI_1 = DIAGRAM.add_block_epi('block_EPI_1');
block_EPI_1.epi.n_pe = epi_n_pe; % number of phase encoding steps (lines)
block_EPI_1.color.echo = [247, 215, 2]/255;
block_EPI_1.generate_block();
block_EPI_2 = DIAGRAM.add_block_epi('block_EPI_2');
block_EPI_2.epi.n_pe = epi_n_pe;
block_EPI_2.color.echo = [255, 156, 8]/255;
block_EPI_2.generate_block();
block_EPI_3 = DIAGRAM.add_block_epi('block_EPI_3');
block_EPI_3.epi.n_pe = epi_n_pe;
block_EPI_3.color.echo = [255, 8, 8]/255;
block_EPI_3.generate_block();

nextRF            = DIAGRAM.add_rf_pulse('nextRF');
nextRF.flip_angle = RF_alpha.flip_angle;
nextRF.magnitude  = RF_alpha.magnitude;
nextRF.color      = RF_alpha.color;

nextGSS = DIAGRAM.add_gradient_slice_selection('nextGSS');

annot_TE_1 = DIAGRAM.add_annotation('TE1');
annot_TE_2 = DIAGRAM.add_annotation('TE2');
annot_TE_3 = DIAGRAM.add_annotation('TE3');
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

G_SSrew.set_moment(G_SSset.get_rewind_moment()); % will set all .dur*, but no .onset or .offset
G_SSrew.set_onset_at_elem_offset(G_SSset);

block_EPI_1.duration = epi_block_duration;
block_EPI_1.set_middle_using_TRTE(RF_alpha.middle + TE1);
block_EPI_1.update_block_elements(); % blocks contains many elements, this method will compute timings in all of them
block_EPI_2.duration = epi_block_duration;
block_EPI_2.set_middle_using_TRTE(RF_alpha.middle + TE2);
block_EPI_2.update_block_elements();
block_EPI_3.duration = epi_block_duration;
block_EPI_3.set_middle_using_TRTE(RF_alpha.middle + TE3);
block_EPI_3.update_block_elements();

annot_TE_1.set_onset_and_duration(RF_alpha.middle, TE1);
annot_TE_2.set_onset_and_duration(RF_alpha.middle, TE2);
annot_TE_3.set_onset_and_duration(RF_alpha.middle, TE3);

% for TR visualization :

nextRF.duration = RF_alpha.duration;
nextRF.set_middle_using_TRTE(RF_alpha.middle + TR);

nextGSS.set_flattop_on_rf(nextRF);

annot_TR.set_onset_and_duration(RF_alpha.middle, TR);


%% Now we draw
% Many checks will be performed in the .draw(), asserions should help filling missing informations.

DIAGRAM.Draw();

% save the fig :
% DIAGRAM.save_fig('diagram_multiecho_gre_epi.png')
% DIAGRAM.save_fig('diagram_multiecho_gre_epi.svg')
