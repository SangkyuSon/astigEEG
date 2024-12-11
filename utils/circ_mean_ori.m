function out = circ_mean_ori(ori,w,dim)
if nargin < 2, w = []; end
if nargin < 3, dim = 1; end
if dim == 2, ori = ori'; end
[x,y] = size(ori);
out = zeros(y,1);
for i1 = 1:y, out(i1,1) = rad2deg(circ_mean(deg2rad(ori(:,i1).*2),w))./2; end
if dim == 2, out = out'; end
end
%if size(ori,1) == 1, ori = ori'; end
%out = rad2deg(circ_mean(deg2rad(ori.*2)))./2;