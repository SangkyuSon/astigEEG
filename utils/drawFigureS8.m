function drawFigureS8(dataDir)

x = -99:625;
cdata = load(fullfile(dataDir,'Fig5_1.mat'));
groupName = {'induced1st','induced2nd'};
for g = 1:2,
    
    clear coef
    X = cdata.data.(groupName{g}).gain_ori;
    y = cdata.data.(groupName{g}).err_ori;
    for m = 1:size(X,1),
        for t = 1:size(X,3)
            coef(m,t) = -glmfit(squeeze(X(m,:,t)),y(m,:),'Normal','Constant','off');
        end
    end
    
    subplot(1,2,g)
    shadedplot_custom(coef,[],'xAxis',x,'gfilt',20)
    ylim([-40,80])
    xlim([-100,600])
    ylabel(sprintf('Behavioral relevance\n(slope; a.u.)'))
    
end

end