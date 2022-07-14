function signal_filtered=filtering_signal(signal,fs,fc_high,fc_low,fc_notch,n_high,n_low)

% The signal may have missing data related to connection problems
nan_indexes = find(isnan(signal));
signal(nan_indexes) = 0;

signal = double(signal);
signal = transpose(signal);
[b,a] = butter(n_high,fc_high/(fs/2),'high');
signal_filtered = filtfilt(b,a,signal);
[b,a] = butter(n_low,fc_low/(fs/2),'low');
signal_filtered = filtfilt(b,a,signal_filtered);
w_notch=fc_notch/(fs/2);
[b,a] = iirnotch(w_notch,w_notch/35);
signal_filtered = filtfilt(b,a,signal_filtered);
signal_filtered = transpose(signal_filtered);

signal_filtered(nan_indexes) = NaN;

end