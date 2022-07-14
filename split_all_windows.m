function out=split_all_windows(signal_windows_indexes,tolerance_window_seconds,signal_channel_length)

flat_windows_indexes=[];

if ~isempty(signal_windows_indexes)
    %Find the begin and end indexes of each flat window
    [signal_windows_indexes_begins,signal_windows_indexes_ends]=find_all_windows(signal_windows_indexes);

    for signal_windows_index=1:length(signal_windows_indexes_begins)
        begin_signal_mask=signal_windows_indexes_begins(signal_windows_index);
        end_signal_mask=signal_windows_indexes_ends(signal_windows_index);

        %Calculate border conditions
        left_tolerance=begin_signal_mask-tolerance_window_seconds;
        right_tolerance=end_signal_mask+tolerance_window_seconds;

        %Applying border conditions
        if left_tolerance<1
            left_tolerance=1;
        end

        if right_tolerance>signal_channel_length
            right_tolerance=signal_channel_length;
        end
        flat_windows_indexes=[flat_windows_indexes,left_tolerance:right_tolerance];
    end
end

out=flat_windows_indexes;

end