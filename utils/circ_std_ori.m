function out = circ_std_ori(ori)

if size(ori,1) == 1, ori = ori'; end
out = rad2deg(circ_std(deg2rad(ori.*2)))./2;

end
