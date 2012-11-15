
function [long_version] = short_to_long(short_version, r_index, num_points)
long_version = zeros(1, num_points);
r_index = [r_index, num_points + 1];
for i = 1:length(r_index)-1
    long_version(r_index(i):r_index(i+1)-1) = short_version(i);
end
end
