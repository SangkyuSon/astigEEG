function [aerr,nerr,aIdx,nIdx,an,nn,diop,err,idx,RT] = getAllBias(dataDir,subName)

mname = getAllFiles(fullfile(dataDir,'ver3','behavior',subName),'*.mat',1);
mdata = [];
for mf = 1:length(mname)
    emat = load(mname{mf});
    fieldName = fieldnames(emat);
    emat = eval(sprintf('emat.%s',fieldName{1}));
    mdata = cat(1,mdata,emat);
end

% if length(unique(mdata(:,2)))==1
    err = orientationing(mdata(:,5)-(mdata(:,3)+mdata(:,4)),'ori');
    err = err - circ_mean_ori(err);
    
    aerr = err(mdata(:,1)==1);
    nerr = err(mdata(:,1)==2);
    
    idx = mdata(:,4)./22.5+1;
    aIdx = mdata(mdata(:,1)==1,4)./22.5+1;
    nIdx = mdata(mdata(:,1)==2,4)./22.5+1;
    
    
    an = length(aIdx);
    nn = length(nIdx);
    
    diop = mdata(:,2).*(mdata(:,1)==1);
    
    RT = mdata(:,6);
% else
%     err = mdata(:,4);
%     
%     aerr = err(mdata(:,1)==1);
%     nerr = err(mdata(:,1)==2);
%     
%     aIdx = mdata(mdata(:,1)==1,2)./22.5+1;
%     nIdx = mdata(mdata(:,1)==2,2)./22.5+1;
%     
%     an = length(aIdx);
%     nn = length(nIdx);
%     
% end

end