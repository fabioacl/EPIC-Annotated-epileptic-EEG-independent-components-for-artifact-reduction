function patient_data_segments = artifact_removal(patient_data_segments,num_iterations,sample_freq)

num_segments = length(patient_data_segments);

for segment_index=1:num_segments
    EEG = patient_data_segments{segment_index};
    if EEG.used_data==1
        EEG = pop_runica(EEG,'extended',1,'interupt','on','steps',num_iterations,'pca',EEG.number_dimensions);
        % Get Time series, PSD and Topoplot and model
        number_ica_components = size(EEG.icawinv,2);
        ica_timeseries_matrix = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
        [ica_psd_matrix,~] = spectopo(ica_timeseries_matrix, 0, sample_freq,'plot','off');
        ica_psd_matrix = ica_psd_matrix(:,2:91);
        ica_topoplots_matrix = [];
        for ica_component_index = 1:number_ica_components
            ica_component_topoplot = topoplot(EEG.icawinv(:,ica_component_index), EEG.chanlocs, ...
                'verbose', 'off', 'chaninfo', EEG.chaninfo, 'numcontour', 8);
            ica_topoplots_matrix(:,:,ica_component_index) = ica_component_topoplot.CData;
            close
        end

        %Save EEG ICA Data
        dlmwrite('ica_timeseries.txt',ica_timeseries_matrix);
        dlmwrite('ica_psd.txt',ica_psd_matrix);
        dlmwrite('ica_topoplot.txt',ica_topoplots_matrix);

        system("~/.conda/envs/deeplearning/bin/python '/mnt/6a3bf9e0-7462-43d9-b6ae-3aa1a8be2f6a/fabioacl/Fabio/Fabio_Task_3/Epileptic-Seizure-Prediction/EEG Preprocessing/predict_ica_sample.py'");

        ica_components_labels = importdata('ica_components_labels.txt');
        if length(ica_components_labels)>sum(ica_components_labels)
            EEG.old_data = EEG.data;
            ica_labels_indexes = find(ica_components_labels==1);
            ica_labels_indexes = ica_labels_indexes';
            EEG = pop_subcomp(EEG, ica_labels_indexes, 0);
            patient_data_segments{segment_index} = EEG;
        end
    end
end
        