function drawFigureS3(dataDir)

data = ERPsummary(dataDir);

groupName = {'chronic','induced'};
channelName = {'Oz','Pz','Cz','Fz'};
cn = length(channelName);
x = -99:625;
nrow = 4;

figure
%% Figure S3A
for c = 1:cn,
    for g = 1:2, % chronic or induced group
        for ae = 1:2, % astig vision condition (1) or emme vision condition (2)
            if ae == 1, col = [1,0,0]; else col = [0,0,0]; end
            data2plot = movmean(squeeze(mean(data.(groupName{g}).erp(:,c,:,ae),1)),50);
            data2plot = data2plot - mean(data2plot(1:50));
            
            subplot(nrow,cn,c+(g-1)*cn)
            plot(x,data2plot,'Color',col)
            hold on;
            xlim([x(1),x(end)])
            ylim([-1,1]*5)
            set(gca,'YDir','reverse')
            
            if g == 1, subtitle(channelName{c}); end
            if c == 1, ylabel(groupName{g}); end
        end
    end
end

%% Figure S3B
coltmp = linspace(0,1,5);
col = cat(2,[coltmp,coltmp(2:end-1)]',zeros(8,2));

for c = 1:cn,
    for o = 1:8, % orientation (1 = orthogonal direction to the astigmatic axis, 2 = 22.5 deg clockwise direction, ... and so on)
        for g = 1:2, % chronic or induced group
            data2plot = movmean(squeeze(mean(data.(groupName{g}).erp_ori(:,c,:,o),1)),50);
            data2plot = data2plot - mean(data2plot(1:50));
            
            subplot(nrow,cn,c+(g+1)*cn)
            plot(x,data2plot,'Color',col(o,:,:))
            hold on;
            xlim([x(1),x(end)])
            ylim([-1,1]*5)
            set(gca,'YDir','reverse')
             
            if c == 1, ylabel(groupName{g}); end
        end
    end
end


end