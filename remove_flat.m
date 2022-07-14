function out=remove_flat(signal_channel,signal_sampling_ratio,tolerance_flat_window_seconds)

%Differentiation of the signal to check where it is constant
diff_signal_channel=diff(signal_channel);

%Module of the differentiation of the signal to save the absolute
%differences. This will allow to check where the signal is constant. For
%example, using a moving mean on positive and negative differences, there
%could be some cases where the average could be 0. That is why I use the
%absolut values.
abs_diff_signal_channel=abs(diff_signal_channel);

%Use a moving mean window to average all the differences. The flat zones
%are going to have a moving mean equals to 0. This was used because there could
%be some cases in the signal where the difference (diff) between consecutive
%samples is zero.
movmean_diff_signal_channel=movmean(abs_diff_signal_channel,0.5*signal_sampling_ratio);

%Find the indexes of the flat windows
flat_windows_indexes=find(movmean_diff_signal_channel==0);

%Split all the flat windows
out=split_all_windows(flat_windows_indexes,tolerance_flat_window_seconds,length(signal_channel));

end