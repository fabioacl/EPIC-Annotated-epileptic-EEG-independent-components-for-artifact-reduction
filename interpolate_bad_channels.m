function preprocessed_patient_data_segments = interpolate_bad_channels(patient_data_segments,removal_ratio_threshold,threshold_removal,...
    eeg_channels_indexes,tolerance_seconds,saturated_tol,sample_freq,used_eeg_channels_names)

num_eeg_channels = length(eeg_channels_indexes);
threshold_removal_num_channels = round(threshold_removal*num_eeg_channels);
tolerance_saturated_window_samples=tolerance_seconds*sample_freq;
num_segments = length(patient_data_segments);
bad_eeg_channels=[];
good_eeg_channels=[];
all_bad_eeg_channels = {};
eliminated_signals = [];
preprocessed_patient_data_segments = {};

% Load EEG Channel Positions
eeg_channel_positions=load('eeg_channel_positions.mat','eeg_channel_positions').eeg_channel_positions;

patient_used_channels_names=cellfun(@upper,used_eeg_channels_names,'un',0);
eeg_channel_position_labels={eeg_channel_positions.labels};
used_eeg_channels_positions=[];

for channel_index=1:size(patient_used_channels_names,2)
    channel = patient_used_channels_names{channel_index};
    for label_index=1:size(eeg_channel_position_labels,2)
        label = char(eeg_channel_position_labels{label_index});
        if strcmp(label,channel)
            used_eeg_channels_positions = [used_eeg_channels_positions;eeg_channel_positions(label_index)];
        end
    end
end

for segment_index=1:num_segments
    segment_data = patient_data_segments{segment_index};
    bad_eeg_channels = [];
    good_eeg_channels = [];
    for channel_index=eeg_channels_indexes
        %Get saturated windows_indexes
        small_signal_channel = segment_data(channel_index,:);
        saturated_windows_indexes = remove_saturated(small_signal_channel,saturated_tol,tolerance_saturated_window_samples);
        small_signal_channel(saturated_windows_indexes) = NaN;
        removal_ratio = nnz(isnan(small_signal_channel))/length(small_signal_channel);
        if removal_ratio>=removal_ratio_threshold
            bad_eeg_channels=[bad_eeg_channels,channel_index];
        else
            good_eeg_channels=[good_eeg_channels,channel_index];
        end
    end
    
    EEG.setname = '';
    EEG.filename = '';
    EEG.filepath = '';
    EEG.subject = '';
    EEG.group = '';
    EEG.condition = '';
    EEG.session = [];
    EEG.comments = '';
    EEG.urchanlocs = [];
    EEG.chaninfo = [];
    EEG.ref = [];
    EEG.event = [];
    EEG.urevent = [];
    EEG.eventdescription = {};
    EEG.epoch = [];
    EEG.epochdescription = {};
    EEG.reject = [];
    EEG.stats = [];
    EEG.specdata = [];
    EEG.specicaact = [];
    EEG.splinefile = '';
    EEG.icasplinefile = '';
    EEG.dipfit = [];
    EEG.history = '';
    EEG.saved = 'no';
    EEG.etc = [];
    EEG.data = segment_data(eeg_channels_indexes,:);
    EEG.times = 0:1:(size(EEG.data,2)-1);
    EEG.xmin = 0;
    EEG.xmax = EEG.times(end)/sample_freq;
    EEG.nbchan = size(EEG.data,1);
    EEG.chanlocs = used_eeg_channels_positions;
    EEG.srate = sample_freq;
    EEG.pnts = size(EEG.data,2);
    EEG.trials = 1;
    EEG.icaact = [];
    EEG.icaweights = [];
    EEG.icasphere = [];
    EEG.icachansind = [];
    EEG.icawinv = [];
    EEG.ref = 'common';
    EEG.ecg_data = segment_data(num_eeg_channels+1:end,:);
    EEG.bad_channels = bad_eeg_channels;
    if length(bad_eeg_channels)<=threshold_removal_num_channels
        % If there are one or two bad channels, first we interpolate
        % the bad segments of the good ones using just the good channels data 
        % and then we interpolate the bad channels.
        if ~isempty(bad_eeg_channels)
            original_EEG = EEG;
            EEG.original_data = EEG.data;
            EEG.data = EEG.data(good_eeg_channels,:);
            EEG.nbchan = length(good_eeg_channels);
            EEG.chanlocs = EEG.chanlocs(good_eeg_channels);
            EEG = interpolate_segments(EEG);
            EEG = eeg_interp(EEG, original_EEG.chanlocs, 'spherical');
        else
            original_data = EEG.data;
            EEG = interpolate_segments(EEG);
            if ~isempty(EEG.interpolated_info)
                EEG.original_data = original_data;
            end
        end
        EEG = pop_reref(EEG,[]);
        EEG.number_dimensions = num_eeg_channels-1-length(bad_eeg_channels);
        if EEG.number_dimensions<16 % Rank = 19(channels) - 1(average reference) - 2 (threshold bad channels)
            EEG.used_data = false;
        else
            EEG.used_data = true;
        end
    else
        EEG.used_data = false;
    end
    
    preprocessed_patient_data_segments{end+1} = EEG;
end