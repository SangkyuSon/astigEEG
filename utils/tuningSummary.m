function data = tuningSummary(dataDir)

try,load(fullfile(dataDir,'tuning.mat'));
catch,

    subj = {'...'}; % Please request raw dataset to corresponding author for running subsequent part
    NoS = length(subj);

    for m = 1:NoS,
        tuningData = tuning(dataDir,subj,m);
        
        for o = 1:8,
            atmp = tuningData.aTune(:,:,o);
            ntmp = tuningData.nTune(:,:,o);
            atmp2 = atmp;
            ntmp2 = ntmp;
            if  o==6 | o==7 | o==8
                atmp2(2:end,:) = flipud(atmp2(2:end,:));
                ntmp2(2:end,:) = flipud(ntmp2(2:end,:));
            end
            astig(m,:,:,o) = atmp2;
            emme(m,:,:,o) = ntmp2;
        end
    end

    data.chronic.astig = astig(20:end,:,:,:);
    data.chronic.emme = emme(20:end,:,:,:);
    data.emme.astig = astig(1:19,:,:,:);
    data.emme.emme = emme(1:19,:,:,:);

    save(fullfile(dataDir,'tuning.mat'),'data');
end




end