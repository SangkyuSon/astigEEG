function data = glmWeightSummaryMedianSplit(dataDir)

try,load(fullfile(dataDir,'GLMweightsMS.mat'));
catch,

    subj = {'...'}; % Please request raw dataset to corresponding author for running subsequent part
    NoS = length(subj);

    qno = 2;
    for m = 1:NoS,
        glm = glmTuning(dataDir,subj,m);
        
        trn = size(glm.weight,2);
        medPnt = round(trn/qno);
        
        for q = 1:qno,
            if q == 1, trsel = 1:medPnt;
            else       trsel = medPnt+1:trn; end
            
        end
        weights(m,:,:,q) = squeeze(mean(glm.weight(:,trsel,:),2));
    end

    for q = 1:qno,
        data.chronic.w_ret(:,:,q) = weights(20:end,:,1,q);
        data.chronic.gain(:,:,q) = weights(20:end,:,2,q);
        data.emme.w_ret(:,:,q) = weights(1:19,:,1,q);
        data.emme.gain(:,:,q) = weights(1:19,:,2,q);
    end

    save(fullfile(dataDir,'GLMweightsMS.mat'),'data');
end

end