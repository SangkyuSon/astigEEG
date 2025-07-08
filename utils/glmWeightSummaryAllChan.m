function data = glmWeightSummaryAllChan(dataDir)

try, load(fullfile(dataDir,'GLMweightsAllChan.mat'));
catch,
    
    
    subj = {'...'}; % Please request raw dataset to corresponding author for running subsequent part
    NoS = length(subj);
    
    for m = 1:NoS,
        
        data = glmTuningAllChan(dataDir,subj,m);
        muGain(m,:,:) = squeeze(mean(data,1));
        
    end
    
    tn = 8;   
    for t = 1:tn,
        twin = (((t-1)*30+1):(t*30))+100+80;
        windowedGain(:,:,t) = mean(muGain(:,:,twin),3);
    end
    
    data.chronic = windowedGain(20:end,:,:);
    data.induced = windowedGain(1:19,:,:);
    
    save(fullfile(dataDir,'GLMweightsAllChan.mat'),'data');
end

end

