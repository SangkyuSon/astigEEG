function ctex = simulTex(tex,diop)

mag = 20;
r = estBlur(diop);
ctex = zeros(size(tex));
for o = 1:size(tex,3),
    otex = tex(:,:,o);
    ktex = mkKernel(mag,r);
    ctex(:,:,o) = conv2(otex,ktex,'same');
end

end

function r = estBlur(diop)

N = 2.4; % nadal distance (cm)
L = 0.35; % crystal lens size (cm)
R = ((40.6/800)/60)*N; % pixel retina ratio
nN = (L*N)/(R+L);

N1 = (1/(1/nN*100+diop))*100;
N2 = N - N1;
blur = L*N2/N1;
r = blur/R-1;

end