function data = loadERP(dataDir,subj,m)

subName = subj{m};
try,load(fullfile(dataDir,'%s_erp.mat'));
catch,
    
    load(fullfile(dataDir,sprintf('%s_EEG.mat',subName))); % raw dataset
    
    for a = 1:2,

        erp_avg(:,:,a) = nanmean(prep.eeg(:,:,prep.astig==a),3);

        for o = 1:8,
            erp_ori(:,:,a,o) = nanmean(prep.eeg(:,:,prep.ori==o & prep.astig==a),3);
        end
        
    end

    coi = [17,13,24,2]; % channel of interest

    data.avg = erp_avg(:,coi,:);
    data.ori = erp_ori(:,coi,:,:);     
    
    save(fullfile(dataDir,'%s_erp.mat','data'));
end

end
