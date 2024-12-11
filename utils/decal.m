function [out] = decal(A,bone,oriMode)
%dedecalcomaniation modified.
if nargin < 2, bone = size(A,1)/2+1; end
if nargin < 3, oriMode = 0; end
[cn,tt] = size(A);
out = zeros(bone,tt);
left = 1:bone;
if bone~=cn,
    right = fliplr(setdiff(1:cn,left));
else
    right = [];
end
for i = 1:tt
    leftTune = A(1:bone,i);
    rightTune = leftTune;
    rightTune((end-length(right)):(end-1)) = A(right,i);
    if ~oriMode,
        out(1:bone,i) = nanmean([leftTune,rightTune],2);
    else
        out(1:bone,i) = circ_mean_ori([leftTune,rightTune],[],2);
    end
end



