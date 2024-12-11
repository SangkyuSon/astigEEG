function out = orientationing(oris,cutType)
% out = orientationing(oris,cutType)
% cutType = 'dir' or 'ori'
if nargin < 2, cutType = 'ori'; end
switch cutType
    case 'dir'
        cut = 360;
    case 'ori'
        cut = 180;
end
out = zeros(size(oris));
for col = 1:size(oris,2)
    temp = mod(oris(:,col),cut);
    temp(temp> cut/2) = temp(temp> cut/2) - cut;
    out(:,col) = temp;
end
end