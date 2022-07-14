%% Data
set_index = 1;
patient_number = 1;
data_filename = "Write here data filename";
data = importdata(data_filename);
fclose('all')

%% Remove flatlines, saturated segments and abnormal peaks
% Load EEGLAB and Close Figures
addpath("Write here EEGLAB Path")
eeglab
close all

used_sample_freq = 256; % At this moment, the signal preprocessing models are only prepared for 256 Hz.

% Remove Flatlines, saturated segments and abnormal peaks
reference_saturated_eeg_channels_indexes = [1,2,9,10,13,14,17]; %If these channels are saturated, the segment is removed. 
                                                                %These channels were select due to their position in the 
                                                                %10-20 International System: Fp1, Fp2, Cz, T7, T8, O1, O2.
fc_high = 0.5;
fc_low = 100;
fc_notch = 50;
n_high = 4;
n_low = 4;
saturated_tol = 5000; %microvolts
tolerance_seconds = 10; %tolerance before and after flatline removal (seconds)

% EEG Segmentation
min_duration=10; %seconds
max_duration=10*60; %seconds

% Bad Channel Interpolation
removal_ratio_threshold = 0.20;  %Percentage of saturated signal to remove channel
num_eeg_channels = size(data,1);
threshold_removal = 0.10;        %Percentage of bad channels to remove segment
eeg_channels_names = ["FP1","FP2","F3","F4","C3","C4","P3","P4","O1","O2","F7","F8","T7","T8",...
    "P7","P8","FZ","CZ","PZ"];

% Minimum Segment Duration
min_segment_duration = 10; % seconds

% Process data
disp(strcat("Set: ",string(set_index)))

% Remove experimental errors
disp("Removing Experimental Errors...");
all_segments_data = remove_experimental_errors(data,reference_saturated_eeg_channels_indexes,...
                            fc_high,fc_low,fc_notch,n_high,n_low,saturated_tol,tolerance_seconds,used_sample_freq,...
                            min_segment_duration);

% Split data in 10-minute segments
disp("Spliting Signals in 10-Minute Segments...");
patient_data_segments = split_signals_in_segments(all_segments_data,min_duration,max_duration,used_sample_freq);

% Interpolate Bad Channels
disp("Interpolating Bad Channels...");
patient_data_segments = interpolate_bad_channels(patient_data_segments,removal_ratio_threshold,threshold_removal,...
    eeg_channels_indexes,tolerance_seconds,saturated_tol,used_sample_freq,eeg_channels_names);
      
% Artifact Removal Method
disp("Removing Artifacts...");
num_ica_iterations = 1024;
patient_data_segments = artifact_removal(patient_data_segments,num_ica_iterations,used_sample_freq);
