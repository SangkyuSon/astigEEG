function data = glmTuning(dataDir,subj,m)

subName = subj{m};
try, load(fullfile(dataDir,sprintf('%s_glmTuning.mat',subName)));
    
    tune = tuning(dataDir,subName);
    atune = -permute(tune.aTuneTrial,[2,1,3]);
    atune = gfilt3(atune,15);
    atune = (atune-min(atune,[],1));
    atune = atune./sum(atune,1);
    [nC,n,nT] = size(atune);
    
    if m >= 20
        load(fullfile(dataDir,'diop.mat'))
        diop = diop(m-19);
    else, diop = 2;
    end
    
    ginf = mkGabors;
    P = simulTune(ginf.tex,diop,22.5)';
    P = P./sum(P,1);
    
    gain = -cosd(0:45:315)';
    gP = zeros(size(P));for o = 1:8,gP(:,o) = (P(:,o).*gain); end
    
    par = zeros(nT,n,2);
    parfor t = 1:nT,
        for k = 1:n,
            tdata = atune(:,k,t);
            coef = glmfit(P(:,tune.aOri(k)),tdata(:),'normal');
            w_ret = coef(2);
            
            residualTuning = tdata - (w_ret*P(:,tune.aOri(k)) + coef(1));
            
            coef = glmfit(gP(:,tune.aOri(k)),residualTuning(:),'normal','Constant','off');
            gain = coef(1);
            
            par(t,k,:) = [w_ret, gain];
        end
    end
    
    data.ori = tune.aOri;
    data.weight = par;
    
    save(fullfile(dataDir,sprintf('%s_glmTuning.mat',subName)),'data');
end

end
