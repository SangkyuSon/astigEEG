function data = connectivitySummary(dataDir)

chronicSubj = 20:42;
inducedSubj = 1:19;
try, load(fullfile(dataDir,'connectivitySummary.mat'));
    
    subj = {'...'}; 
    NoS = length(subj);
    
    for m = 1:NoS,
        
        data = connectivity(dataDir,subj,m);
        As(m,:,:,:,:) = data;
        
    end
    
    twin = (100:300)+100;
    tdata = (abs(A(chronicSubj,:,:,:,1))./mean(abs(A(inducedSubj,:,:,:,1)),1)-1)*100;
    data.chronic = mean(tdata(:,:,:,twin),4);
    
    tdata = (abs(A(inducedSubj,:,:,:,3))./mean(abs(A(inducedSubj,:,:,:,2)),1)-1)*100;
    data.induced = mean(tdata(:,:,:,twin),4);
    
    save(fullfile(dataDir,'connectivitySummary.mat'),'data');
end

end
