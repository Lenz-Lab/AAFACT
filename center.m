function [output,cm] = center(input,ncm)
% CENTER  Translate points, coordinate systems or meshes to the origin.
%
%   [output, cm] = center(input, ncm)
%
%   The behaviour depends on the mode flag ncm:
%     ncm == 1  input is an Nx3 array of nodal points. Each column has its
%               mean subtracted, so the centroid of the points lands on
%               (0,0,0). cm is the 1x3 centroid that was removed; add it
%               back to undo the shift.
%     ncm == 2  input is a coordinate system stored as rows of points
%               (e.g. 6x3 [origin; tip; origin; tip; origin; tip]). Every
%               row is shifted by the first row, so the first origin sits
%               at (0,0,0).
%     ncm == 3  input is a triangulation object. Its points are centered
%               as in mode 1 and a new triangulation with the same
%               connectivity is returned.
%
%   Note: cm is only assigned in mode 1, so request it only in that mode.
%
%   The centroid is the plain mean of the vertices, not an area- or
%   volume-weighted center of mass.

if ncm == 1 % center nodal points
    cm_x = mean(input(:,1));
    cm_y = mean(input(:,2));
    cm_z = mean(input(:,3));

    cm = [cm_x cm_y cm_z];

    input_ox = input(:,1) - cm_x;
    input_oy = input(:,2) - cm_y;
    input_oz = input(:,3) - cm_z;

    output = [input_ox input_oy input_oz];
elseif ncm == 2 % center coordinate systems at zero
    output = -input(1,:) + input(:,:); % subtract row 1 from every row
elseif ncm == 3 % center stl
    temp_output = center(input.Points,1); % reuse mode 1 on the vertices
    output = triangulation(input.ConnectivityList,temp_output);
end
