function pmk = skewnessPDF(dat,xx)
% Pearson moment coefficient of skewness

if size(dat,2)==1, dat = dat'; end
if nargin < 2, xx = 1:length(dat); end
dat = dat - min(dat);
%dat = dat + range(dat);

dat = dat./sum(dat);

%repdist = repelem(xx,round(dat*10000));
%pmk = skewness(repdist);

mu = sum(dat.*xx);
sd = sqrt(sum((xx-mu).^2.*dat));

%pmk = (sum(xx.^3.*dat) - 3*mu*sd^2 - mu^3)/sd^3;
pmk = sum(((xx-mu)./sd).^3.*dat);
%pmk = sum(((xx-mu)./sd).^3.*dat);

end

