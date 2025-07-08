function ginf = mkGabors

gabors.size        = round(deg2pixel(0.6))*20;
gabors.ratio       = gabors.size/round(deg2pixel(0.6));
gabors.lum         = 128;
gabors.spFreq      = 1/gabors.size;
gabors.sd          = gabors.size/5;
gabors.cont        = 1;
gabors.stimOri     = 0:22.5:157.5;
gabors.enlargeFac  = 3;

stim = ptb3gabor(gabors.size,gabors.lum,gabors.cont,gabors.spFreq,0,0,gabors.sd);
stim = (stim(:,:,1)-128).*(stim(:,:,2)./255);

winh = ((gabors.size*gabors.enlargeFac)/2-gabors.size/2+1):((gabors.size*gabors.enlargeFac)/2+gabors.size/2);
winv = ((gabors.size*gabors.enlargeFac)/2-gabors.size/2+1):((gabors.size*gabors.enlargeFac)/2+gabors.size/2);
btex = zeros(gabors.size*gabors.enlargeFac);
btex(winv,winh) = stim;

oIdx = 0;
tex = zeros(gabors.size*gabors.enlargeFac,gabors.size*gabors.enlargeFac,length(gabors.stimOri));
for o = gabors.stimOri,
    oIdx = oIdx + 1;
    tex(:,:,oIdx) = imrotate(btex,-o,'nearest','crop');
end

ginf.tex = tex;
ginf.ratio = gabors.ratio;
ginf.oris = gabors.stimOri;
ginf.size = size(tex,1);

end