function [output,cm] = center(input)

% This function accepts nodal inputs and outputs the bone centered at
% (0,0,0)

cm_x = mean(input(:,1));
cm_y = mean(input(:,2));
cm_z = mean(input(:,3));

cm = [cm_x cm_y cm_z];

input_ox = input(:,1) - cm_x;
input_oy = input(:,2) - cm_y;
input_oz = input(:,3) - cm_z;

output = [input_ox input_oy input_oz];
