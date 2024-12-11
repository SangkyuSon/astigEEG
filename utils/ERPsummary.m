function data = ERPsummary(dataDir)

try,load(fullfile(dataDir,'erp.mat'));
catch,
    
    subj = {'...'}; % Please request raw dataset to corresponding author for running subsequent part
    NoS = length(subj);
    
    for m = 1:NoS,
        data = loadERP(dataDir,subj,m);
        avg(m,:,:,:) = data.avg;
        ori(m,:,:,:,:) = data.ori;
    end
    
    data.chronic.erp = avg(20:end,:,:,:);
    data.chronic.erp_ori = ori(20:end,:,:,:,:);
    data.induced.erp = avg(1:19,:,:,:);
    data.induced.erp_ori = ori(1:19,:,:,:,:);

    save(fullfile(dataDir,'erp.mat'),'data');
end

end
