function original_EEG = interpolate_segments(original_EEG)

%Create parameters to save all interpolation information
original_EEG.interpolated_info = {};

original_data = original_EEG.data;
number_channels = size(original_data,1);
% Minimum and maximum threshold
maximum_threshold_channel_pop = 500;
%Get the sampling ratio
signal_sampling_ratio = original_EEG.srate;
% Number of seconds of each analysed window
window_seconds = 5;
% Overlap percentage
overlap_percentage = 0.5;
% Number of samples to advance in each window
advance_samples = window_seconds*overlap_percentage*signal_sampling_ratio;
% Number of samples of each analysed window
window_seconds_samples = signal_sampling_ratio*window_seconds;
% Number of total samples in a segment
number_samples = size(original_data,2);
% Vector with all channel indexes
list_channel_indexes = 1:number_channels;

begin_windows = [];
end_windows = [];
% Get the beginning and end of each window. The last window should not be
% used because it only contains half of the window samples. That is why the
% range only goes from 1 to numberSamples-advanceSamples
for index=1:advance_samples:number_samples-advance_samples
    begin_windows = [begin_windows,index];
    end_index = index+window_seconds_samples-1;
    end_windows = [end_windows,end_index];
end

% Correct the last window in order to have the same samples as the others.
if end_windows(end)~=number_samples
    end_windows(end) = number_samples;
    begin_windows(end) = number_samples-window_seconds_samples+1;
end

for window_index=1:length(begin_windows)
    channels_with_pops = [];
    begin_window = begin_windows(window_index);
    end_window = end_windows(window_index);
    for channel_index=list_channel_indexes
        % Get original channel data
        original_channel_data = original_data(channel_index,begin_window:end_window);
        % Filter the channel data with 0.5 Hz high pass and 5 Hz low pass.
        % This will reduce the effect of muscular artifacts and evidence
        % the channel pops.
        filtered_original_channel_data = filtering_signal(original_channel_data,signal_sampling_ratio,0.5,5,50,4,4);
        % Get the absolute signal
        absolute_original_channel_data = abs(filtered_original_channel_data);
        % Get the maximum absolute values in the window
        maximum_sample = max(absolute_original_channel_data);
        % If the maximum is higher than the threshold
        % it is considerer as a pop and it is added to the channel with pops vector
        if maximum_sample>maximum_threshold_channel_pop
            channels_with_pops = [channels_with_pops,channel_index];
        end
    end
    
    if ~isempty(channels_with_pops) && length(channels_with_pops)<=round(0.10*number_channels)
        % Copy original data
        interp_EEG = original_EEG;
        % Copy the channel indexes
        list_channel_indexes_for_interp = list_channel_indexes;
        % Remove the channels with pops
        list_channel_indexes_for_interp(channels_with_pops) = [];
        interp_EEG.data = interp_EEG.data(list_channel_indexes_for_interp,:);
        % Number of remaining channels
        interp_EEG.nbchan = length(list_channel_indexes_for_interp);
        % Position of the remaining channels
        interp_EEG.chanlocs = interp_EEG.chanlocs(list_channel_indexes_for_interp);
        % Interpolation. The interpolation is the same using the entire
        % signal or just one window. Therefore, there is no problem of
        % interpolating overlapped windows.
        interp_EEG  =  eeg_interp(interp_EEG, original_EEG.chanlocs, 'spherical');
        original_EEG.data(channels_with_pops,begin_window:end_window) = interp_EEG.data(channels_with_pops,begin_window:end_window);
        original_EEG.interpolated_info{end+1} = {channels_with_pops,[begin_window,end_window]};
    end
end

filter_EEG_signals = filtering_signal(original_EEG.data,signal_sampling_ratio,0.5,100,50,4,4);
original_EEG.data = filter_EEG_signals;