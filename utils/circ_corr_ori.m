function out = circ_corr_ori(ori1,ori2)

s1 = size(ori1);
s2 = size(ori2);
ori1 = deg2rad(ori1*2);
ori2 = deg2rad(ori2*2);

if s1(1) ~= s2(1), ori2 = ori2'; end

out = zeros(1,s1(2));
for r = 1:s1(2)
    out(r) = circ_corrcc(ori1(:,r),ori2);
end

end
