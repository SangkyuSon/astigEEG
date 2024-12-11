function data = glmWeightSummaryWhole(dataDir)

try,load(fullfile(dataDir,'GLMweightsWhole.mat'));
catch,

    subj = {'...'}; % Please request raw dataset to corresponding author for running subsequent part
    NoS = length(subj);

    for m = 1:NoS,
        glm = glmTuningWhole(dataDir,subj,m);
        weights(m,:,:) = squeeze(mean(glm.weight,2));
    end

    data.chronic.w_ret = weights(20:end,:,1);
    data.chronic.gain = weights(20:end,:,3);
    data.emme.w_ret = weights(1:19,:,1);
    data.emme.gain = weights(1:19,:,3);

    save(fullfile(dataDir,'GLMweightsWhole.mat'),'data');
end

end