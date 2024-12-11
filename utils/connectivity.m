function data = connectivity(dataDir,subj,m)

subName = subj{m};
try, load(fullfile(dataDir,sprintf('%s_connectivity.mat',subName)));
    
    chansort = 1:64;
    nsort = []; for o = 1:6, nsort = [nsort,chansort(boolean(sum(1:64 == setROI(o)',1)))]; end
    pard = glmTuningAllChan(dataDir,subj,m);

    pard = (pard-mean(pard(:)))./std(pard(:));
    
    stepSz = 1;
    twinSz = 200/stepSz;
    pard = pard(:,nsort,stepSz/2+1:stepSz:end);
    [n,nCh,nT] = size(pard);
    
    repNo = 10;
    foldNo = 5;
    
    cs = zeros(nT,2);
    rs = zeros(nT,2);
    A = zeros(nCh,nCh,nT,2);
    parfor t = 1:nT
        
        twin = (-twinSz/2:twinSz/2)+t;
        twin(twin<1) = [];
        twin(twin>nT) = [];
        tn = length(twin);
        
        
        for q = 1:3,
            if q == 1,
                qn = n;
                qoi = 1:qn;
            elseif q == 2,
                qn = floor(n/2);
                qoi = (0*qn+1):(1*qn);
            elseif q == 3,
                qn = floor(n/2);
                qoi = (1*qn+1):(2*qn);
            end
            
            qpard = pard(qoi,:,:);
            
            tA = zeros(nCh,nCh,repNo,foldNo);
            tcs = zeros(repNo,foldNo);
            trs = zeros(repNo,foldNo);
            for rep = 1:repNo,
                foldIdx = [repelem(1:foldNo,floor(qn/foldNo)),1:mod(qn,foldNo)];
                foldIdx = foldIdx(randperm(qn));
                for f = 1:foldNo,
                    left = foldIdx~=f;
                    sel = foldIdx==f;
                    
                    dyn = squeeze(mean(qpard(left,:,twin),1));
                    orig = squeeze(mean(qpard(sel,:,twin),1));
                    
                    kA = diff(dyn,[],2)*pinv(dyn(:,1:end-1));
                    
                    tA(:,:,rep,f) = kA;
                end
            end
            A(:,:,t,q) = mean(mean(tA,3),4);
        end
    end
    data = A; % transition matrix
    
    save(fullfile(dataDir,sprintf('%s_connectivity.mat',subName)),'data');
end

end

function selCh = setROI(roi)
if roi == 1,     selCh = [[16,17,18],[14,15,16,17,18]+32];
elseif roi == 2, selCh = [[14,13,19],[13,12,20,19]+32];
elseif roi == 3, selCh = [[11,12,23,22],[11,21,22]+32];
elseif roi == 4, selCh = [[8,24,25],[9,8,25,24]+32];
elseif roi == 5, selCh = [[6,7,29,28],[7,26]+32];
elseif roi == 6, selCh = [[3,2,30],[5,4,31,28,2,3,30]+32];
end
end