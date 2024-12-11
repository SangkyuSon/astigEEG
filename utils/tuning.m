function data = tuning(dataDir,subj,m)

subName = subj{m};
ROI = [13,14,15,16,17,18,19,20,44,45,46,47,48,49,50,51,52]; % posterior channels index

try, load(fullfile(dataDir,sprintf('%s_tuning.mat',subName)));
catch,
    % Note, please request raw dataset to corresponding author for running subsequent part
    
    % once load EEG dataset, this consist of 3 dictionaries
    % prep.EEG = EEG file in size of (electrode) X (time points=725; stimulus onset at 100) X (trial)
    % prep.astig = vector indicating astigmatic vision condition or emmetropic vision condition (1 = astig / 2 = emme)
    % prep.ori = orientation offset from the astigmatic axis (1 = 22.5 deg, 2 = 45 deg, ...8 = 180 deg)
    
    load(fullfile(dataDir,sprintf('%s_EEG.mat',subName))); % raw dataset
    
    [~,nT,n] = size(prep.eeg);
    for k = 1:n, for ch = 1:64, prep.eeg(ch,:,k) = ft_preproc_bandstopfilter(prep.eeg(ch,:,k),1000,[58,62]); end; end % this requires fieldtrip
    
    aIdx = prep.ori(prep.astig==1);
    nIdx = prep.ori(prep.astig==2);
    
    an = length(aIdx);
    nn = length(nIdx);
    
    nB = permute(prep.eeg(selch,:,prep.astig==2),[3,1,2]);
    aB = permute(prep.eeg(selch,:,prep.astig==1),[3,1,2]);
    
    nC = 8;
    
    bootNo = 1000;
    
    %% emmetropic vision condition
    nTune = zeros(nn,nC,nT);
    parfor k = 1:nn,
        left = setdiff(1:nn,k);
        trTune = zeros(nC,nT);
        for t = 1:nT,
            trTune(:,t) = mahalTuning(nB(left,:,t),nB(k,:,t),nIdx(left));
        end
        nTune(k,:,:) = CollMtx(trTune,5,nIdx(k));
    end
    
    for o = 1:8,
        munTune(:,:,o) = squeeze(mean(nTune(nIdx==o,:,:),1));
    end
    
    %% astigmatic vision condition
    aTune = zeros(an,nC,nT);
    parfor k = 1:an,
        left = setdiff(1:an,k);
        trTune = zeros(nC,nT);
        for t = 1:nT,
            trTune(:,t) = mahalTuning(aB(left,:,t),aB(k,:,t),aIdx(left));
        end
        aTune(k,:,:) = CollMtx(trTune,5,aIdx(k));
    end
    
    for o = 1:8,
        muaTune(:,:,o) = squeeze(mean(aTune(aIdx==o,:,:),1));
    end
    
    data.nTune = munTune;
    data.aTune = muaTune;
    
    data.nTuneTrial = nTune;
    data.aTuneTrial = aTune;
    
    data.aOri = aIdx;
    data.nOri = nIdx;
    
    save(fullfile(dataDir,sprintf('%s_tuning.mat',subName)),'data');
end

end