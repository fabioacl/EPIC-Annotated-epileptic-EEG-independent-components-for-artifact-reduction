function data = split_data_in_segments(data,min_segment_duration,sample_freq)

M = transpose(data);
idx = all(isnan(M),2);
idr = diff(find([1;diff(idx);1]));
data_segments = mat2cell(M,idr(:),size(M,2));
if isnan(M(1,1))
    data = data_segments(2:2:end);
else
    data = data_segments(1:2:end);
end

% Transpose data
num_segments = length(data);
% Minimum Samples Segment
min_samples_segment = min_segment_duration * sample_freq;
% Remove Segments Indexes
remove_segment_indexes = [];

for segment_index=1:num_segments
    data{segment_index} = transpose(data{segment_index});
    length_segment = size(data{segment_index},2);
    num_samples_segment = length_segment * sample_freq;
    if num_samples_segment<min_samples_segment
        remove_segment_indexes = [remove_segment_indexes,segment_index];
    end
end

data(remove_segment_indexes) = [];