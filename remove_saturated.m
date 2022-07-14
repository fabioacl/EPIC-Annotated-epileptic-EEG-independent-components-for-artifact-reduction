function out=remove_saturated(signal_channel,tol,tolerance_saturated_window_seconds)

signal_channel_module=abs(signal_channel);

%Check where the signal saturates
saturated_signal_mask=(signal_channel_module>=tol);

%Assign a number to all saturated zones
signal_channel_abs(saturated_signal_mask)=1;
signal_channel_abs(saturated_signal_mask==0)=0;

%Find the indexes of the saturated windows
signal_channel_module_indexes=find(signal_channel_abs==1);

%Split all the saturated windows
out=split_all_windows(signal_channel_module_indexes,tolerance_saturated_window_seconds,length(signal_channel));

end