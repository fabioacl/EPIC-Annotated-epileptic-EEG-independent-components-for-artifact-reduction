function patient_data_segments = split_signals_in_segments(all_segments_data,min_duration,max_duration,sample_freq)

patient_data_segments = {};

min_duration_samples = min_duration*sample_freq;
max_duration_samples = max_duration*sample_freq;

num_signals = length(all_segments_data);

for signal_index=1:num_signals
    num_subsignals = length(all_segments_data{signal_index});
    for subsignal_index=1:num_subsignals
        subsignal_data = all_segments_data{signal_index}{subsignal_index};
        length_subsignal = size(subsignal_data,2);
        if length_subsignal>max_duration_samples
            for sample_subsignal_index=1:max_duration_samples:length_subsignal
                %If the small signal has ten minutes
                if sample_subsignal_index+max_duration_samples<=length_subsignal
                    begin_index = sample_subsignal_index;
                    end_index = (sample_subsignal_index+max_duration_samples-1);
                    small_signal = subsignal_data(:,begin_index:end_index); %-1 adjustment
                %If the small signal does not have ten minutes but it is
                %longer than the minimum duration
                elseif sample_subsignal_index+min_duration_samples<=length_subsignal
                    left_subsignal_samples = length_subsignal-sample_subsignal_index;
                    concatenate_subsignal_samples = max_duration_samples-left_subsignal_samples-1; %-1 adjustment
                    begin_index = sample_subsignal_index-concatenate_subsignal_samples;
                    end_index = sample_subsignal_index+left_subsignal_samples;
                    small_signal = subsignal_data(:,begin_index:end_index);
                %If the small signal is too small (below the minimum
                %duration
                else
                    small_signal = [];
                end
                if ~isempty(small_signal)
                    patient_data_segments{end+1} = small_signal;
                end
            end
        elseif length_subsignal>=min_duration_samples
            patient_data_segments{end+1} = subsignal_data;
        end
    end
end