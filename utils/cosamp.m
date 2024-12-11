function amp = cosamp2(data)
% data in shape of (number of subject) X (given orientations) X (time)
% orientation of interest need to be at middle channel

dat = [];
if length(size(data))==2, dat(1,:,:) = data; else dat = data; end
[NoS,nCh,nT] = size(dat); 

C = drawTunings(180/nCh,15);

amp = zeros(NoS,nT);
for m = 1:NoS,
    for t = 1:nT,
        amp(m,t) = mean(C(:,nCh/2+1)'.*dat(m,:,t));
    end
end

end