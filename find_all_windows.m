function [removal_windows_indexes_begins,removal_windows_indexes_ends]=find_all_windows(removal_windows_indexes)

removal_windows_indexes_begins=[removal_windows_indexes(1)];
removal_windows_indexes_ends=[];

%Find the indexes of the gaps
removal_windows_indexes_gaps=diff(removal_windows_indexes);
removal_windows_indexes_gaps_begins=find(removal_windows_indexes_gaps~=1);

%Find the begin and the end of each flat windows
for begin_gap=removal_windows_indexes_gaps_begins'
    removal_windows_indexes_begins=[removal_windows_indexes_begins,removal_windows_indexes(begin_gap+1)];
    removal_windows_indexes_ends=[removal_windows_indexes_ends,removal_windows_indexes(begin_gap)];
end

removal_windows_indexes_ends=[removal_windows_indexes_ends,removal_windows_indexes(end)];

end