function data = glmTuningAllChan(dataDir,subj,m)

subName = subj{m};
try, load(fullfile(dataDir,sprintf('%s_glmTuningAllChan.mat',subName)));
    
    load(fullfile(dataDir,sprintf('%s_EEG.mat',subName))); % raw dataset
    [nCh,nT,n] = size(prep.eeg);
    
    for k = 1:n, for ch = 1:64, prep.eeg(ch,:,k) = ft_preproc_bandstopfilter(prep.eeg(ch,:,k),1000,[58,62]); end; end % this requires field trip package
    eeg = permute(prep.eeg,[3,1,2]);
    
    aIdx = prep.ori(prep.astig==1);
    an = length(aIdx);
    nC = 8;
    
    aB = eeg(prep.astig==1,:,:);
    
    [sel,pos] = getPos;
    minchno = 5;
    selIdx = [];
    for ch = 1:nCh
        if sel(ch).no > minchno,
            selIdx = [selIdx,ch];
        end
    end
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
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
    
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    par = zeros(an,nCh,nT);
    parfor k = 1:an,
        left = setdiff(1:an,k);
        
        chpar = zeros(nCh,nT);
        for ch = selIdx,
            trTune = zeros(nC,nT);
            for t = 1:nT,
                trTune(:,t) = mahalTuning(aB(left,sel(ch).ch,t),aB(k,sel(ch).ch,t),aIdx(left));
            end
            trTune = gfilt2(trTune,15);
            trTune = max(trTune,[],1)-trTune;
            trTune = trTune./sum(trTune,1);
            
            trpar = zeros(nT,1);
            for t = 1:nT,
                tdata = trTune(:,t);
                coef = glmfit(P(:,aIdx(k)),tdata,'normal');
                w_ret = coef(2);
                
                resi = tdata - (w_ret*P(:,aIdx(k)) + coef(1));
                
                coef = glmfit(gP(:,aIdx(k)),resi,'normal','Constant','off');
                gain = coef(1);
                
                trpar(t,1) = gain;
            end
            chpar(ch,:) = trpar;
        end
        par(k,:,:) = chpar;
    end
    
    data = par;
    
    save(fullfile(dataDir,sprintf('%s_glmTuningAllChan.mat',subName)),'data');
end

end

function [sel,pos] = getPos,
pos = [-0.121 0.371;0 0.195;-0.164 0.202;-0.316 0.229;-0.466 0.151;-0.278 0.112;-0.093 0.097;-0.195 0;-0.39 0;-0.466 -0.151;-0.279 -0.107;-0.093 -0.097;0 -0.195;-0.164 -0.202;-0.316 -0.229;-0.121 -0.371;0 -0.39;0.121 -0.371;0.164 -0.202;0.316 -0.229;0.466 -0.151;0.279 -0.107;0.093 -0.097;0 0;0.195 0;0.39 0;0.466 0.151;0.279 0.107;0.093 0.097;0.164 0.202;0.316 0.229;0.121 0.371;-0.229 0.316;-0.12 0.298;0 0.291;-0.08 0.197;-0.242 0.211;-0.371 0.121;-0.186 0.103;-0.1 0;-0.295 0;-0.371 -0.121;-0.186 -0.103;-0.08 -0.197;-0.242 -0.211;-0.229 -0.316;-0.12 -0.298;0 -0.291;0.12 -0.298;0.229 -0.316;0.242 -0.211;0.08 -0.197;0 -0.095;0.186 -0.103;0.371 -0.121;0.295 0;0.1 0;0.186 0.103;0.371 0.121;0.242 0.211;0.229 0.316;0.12 0.298;0.08 0.197;0 -0.486 ];
for ch = 1:64,
    sel(ch).ch = [ch;setdiff(find(sqrt(sum((pos-pos(ch,:)).^2,2)) < 0.25),ch)];
    sel(ch).no = length(sel(ch).ch);
end
end
