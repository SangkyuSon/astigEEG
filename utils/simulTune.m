function [E,oris] = simulTune(tex,diop,resol)

if size(diop,2)==1, ctex = simulTex(tex,diop); else, ctex = diop; end

mag = 20;
enlarge = 3;
gaborsSize = round(deg2pixel(0.6))*mag;

oris = (0:resol:(180-resol))';
spfq = [1/3,1,3]*1/gaborsSize;
phs = 0;

e = zeros(size(ctex,3),length(oris),length(spfq),length(phs),2);
for sf = 1:length(spfq),
    for p = 1:length(phs),
        for o = 1:length(oris),
            
            filter = ptb3gabor(gaborsSize*enlarge,128,1,spfq(sf),phs(p),0,1);
            filter = imrotate(filter(:,:,1) ,-oris(o),'nearest','crop')-128;
            
            for c = 1:size(ctex,3),
                tmp1 = filter(:,:,1).*ctex(:,:,c);
                e(c,o,sf,p,1) = mean(tmp1(:));
            end
        end
    end
end

E = mean(mean(abs(e(:,:,:,:,1)),3),4);

end
