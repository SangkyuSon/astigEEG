function ktex = mkKernel(ksz,ovalratio)

vhfac = sign(ovalratio);
ovalratio = abs(ovalratio+vhfac);

w = round(((ovalratio)*ksz)/2);
[x,y] = meshgrid(1:2*w);
if vhfac == 1,
    ktex = sqrt(((x-w)./(1)).^2 + ((y-w)./(ovalratio)).^2) < ksz/2;
elseif vhfac == -1,
    ktex = sqrt(((x-w)./(ovalratio)).^2 + ((y-w)./(1)).^2) < ksz/2;
elseif vhfac == 0,
    ktex = sqrt(((x-w)./(1)).^2 + ((y-w)./(1)).^2) < ksz/2;
end
ktex = ktex./sum(ktex(:));

end
