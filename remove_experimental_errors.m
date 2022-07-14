function all_segments_data = remove_experimental_errors(data,reference_saturated_eeg_channels_indexes,...
    fc_high,fc_low,fc_notch,n_high,n_low,saturated_tol,tolerance_seconds,sample_freq,min_segment_duration)

% Number of tolerance samples
tolerance_saturated_window_samples = tolerance_seconds*sample_freq;
tolerance_flat_window_samples = tolerance_seconds*sample_freq;

eeg_channels = 1:19; % EEG contains 19 channels

% Filter Signals
filtered_data = data;
for channel_index=eeg_channels
    filtered_data(channel_index,:) = filtering_signal(data(channel_index,:),sample_freq,fc_high,fc_low,fc_notch,n_high,n_low);
end
    
% Remove Flatlines, Constant Saturated Lines and NaN Values
for channel_index=eeg_channels
    signal_channel = data(channel_index,:);
    flat_window_indexes = remove_flat(signal_channel,sample_freq,tolerance_flat_window_samples);
    filtered_data(:,flat_window_indexes) = NaN;
end

% Split Data in Segments (Remove NaNs)
filtered_data = split_data_in_segments(filtered_data,min_segment_duration,sample_freq);

% Remove Abnormal Peaks
num_segments = length(filtered_data);
all_segments_data = {};
for segment_index=1:num_segments
    geometric_reference_channels_indexes = {};
    for channel_index=eeg_channels
        %Get saturated windows_indexes
        data_channel = filtered_data{segment_index}(channel_index,:);
        saturated_windows_indexes=remove_saturated(data_channel,saturated_tol,tolerance_saturated_window_samples);
        
        %Put all the saturated indexes in a cell array
        if ismember(channel_index,reference_saturated_eeg_channels_indexes)
            geometric_reference_channels_indexes{end+1}=saturated_windows_indexes;
        end
    end
    
    segment_data = filtered_data{segment_index};
    
    %Verify if the reference geometrical channels are corrupted. If the
    %saturated segment is saturated in all these channels, remove the
    %segment.
    number_of_main_channels=length(reference_saturated_eeg_channels_indexes);
    all_saturated_indexes=geometric_reference_channels_indexes{1};
    for channel_idx=2:number_of_main_channels
        channel_saturated_indexes=geometric_reference_channels_indexes{channel_idx};
        all_saturated_indexes=intersect(all_saturated_indexes,channel_saturated_indexes);
    end
    
    segment_data(:,all_saturated_indexes)=NaN;
    segment_data = split_data_in_segments(segment_data,min_segment_duration,sample_freq);
    
    %Save of the preprocessed signals
    all_segments_data{end+1} = segment_data;
end


