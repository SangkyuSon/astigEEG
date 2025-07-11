function drawFigureS5(dataDir)

figure;
nrow = 3;
ncol = 4;
groupName = {'chronic','induced'};
x = -99:625;

%% Figure S5A
data = glmWeightSummary(dataDir);
for g = 1:2, % group loop : 1 = chronic astigmatism group / 2 = induced astigmatism group
    subplot(nrow,ncol,g)
    data2plot = data.(groupName{g}).w_ret;
    shadedplot_custom(data2plot,[],'xAxis',x,'gfilt',10)
    ylim([-0.01,0.1])
    xlim([-100,600])
    subtitle(groupName{g})
    %xlabel('Time from stimulus onset (ms)')
    ylabel('W_r_e_t')
end

%% Figure S5B
bias = summarizeBias(dataDir);
biasHat = simulateBias(dataDir);

muComp = mean(biasHat.chronic-decal(bias.chronic',5)',2);

[co,p] = corr(data.chronic.gain,muComp,'type','Spearman');
subplot(nrow,ncol,ncol+1)
plot(x,co,'Color',[0,0,0]);
ylim([-0.5,1])

subplot(nrow,ncol,ncol+2)
[co,p] = corr(data.induced.w_ret,mean(bias.induced,2),'type','Spearman');
plot(x,co,'Color',[0,0,0]);
ylim([-0.5,1])
sigLine(p,'xAxis',x)

%% Figure S5C
cdata = load(fullfile(dataDir,'Fig3_1C.mat'));
for g = 1:2,
    
    X = cdata.data.(groupName{g}).gain_ori;
    y = cdata.data.(groupName{g}).err_ori;
    for m = 1:size(X,1),
        for t = 1:size(X,3)
            coef(m,t) = -glmfit(squeeze(X(m,:,t)),y(m,:),'Normal','Constant','off');
        end
    end
    
    subplot(nrow,ncol,ncol+g+2)
    shadedplot_custom(coef,[],'xAxis',x,'gfilt',30)
    ylim([-40,80])
    xlim([-100,600])
    ylabel(sprintf('Behavioral relevance\n(slope; a.u.)'))
    
end

%% Figure S5E
wdata = glmWeightSummaryWhole(dataDir);

dtyName = {'w_ret','gain'};
for g = 1:2, % group loop : 1 = chronic astigmatism group / 2 = induced astigmatism group
    
    for dty = 1:2,
        subplot(nrow,ncol,ncol*2+g+(dty-1)*2)
        
        data2plot = wdata.(groupName{g}).(dtyName{dty});
        shadedplot_custom(data2plot,[],'xAxis',x,'gfilt',10)
        
        if dty == 1, ylim([-0.01,0.1]); else ylim([-0.01,0.04]); end
        xlim([-100,600])
        subtitle(groupName{g})
        ylabel(dtyName{dty})
    end
end


end