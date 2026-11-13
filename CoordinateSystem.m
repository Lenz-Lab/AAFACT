function [Temp_Coordinates, Temp_Nodes] = CoordinateSystem(aligned_nodes,bone_indx,bone_coord,side_indx)
% This function produces the coordinate system for the users bone in the
% temporarily aligned orientation.
%
% Inputs:
%   aligned_nodes  Nx3 bone nodes after icp_template. In this frame +X is
%                  medial, +Y is anterior and +Z is superior (right bones
%                  have already been mirrored to the left).
%   bone_indx      bone index (see list_bone in Main_CS)
%   bone_coord     which ACS option was chosen for this bone
%   side_indx      1 = right, 2 = left; sets the sign of the ML axis
%
% Outputs:
%   Temp_Coordinates  6x3 [AP origin; AP tip; SI origin; SI tip;
%                     ML origin; ML tip] with all origins at (0,0,0) and
%                     each axis 50 mm long
%   Temp_Nodes        nodes the ACS belongs to (passed on to JointOrigin
%                     and reorient)
%
% Method: the bone is cut into n equal slabs along X, Y and Z. The
% centroids of the outermost slab at each end of each axis give six
% landmark points. Two landmarks define the primary axis, a third defines
% the secondary axis (made perpendicular to the primary), and the cross
% product of the two gives the tertiary axis. Which landmarks are used and
% how primary/secondary/tertiary map onto AP/SI/ML depends on the bone.

trouble = 0; % set to 1 to plot every intermediate step for debugging
nodes_aligned_original = aligned_nodes;
% Drop any node with a coordinate of exactly 0. The slab selection below
% uses nonzeros(), which would otherwise drop that coordinate and leave the
% x, y and z lists with different lengths.
aligned_nodes = aligned_nodes(all(aligned_nodes ~= 0, 2),:);

%% TT CS for Talus
% For the TT and ST ACS, keep only nodes behind y = 10 mm so that the
% talar head and neck are excluded and the axes follow the talar body/dome
if bone_indx == 1 && bone_coord >= 2
    nodes_aligned_original = aligned_nodes;
    aligned_nodes = [aligned_nodes(aligned_nodes(:,2)<10,1) aligned_nodes(aligned_nodes(:,2)<10,2) aligned_nodes(aligned_nodes(:,2)<10,3)];
end

%% Tibial Realignment for Medial Malleolus
% Use only the distal shaft (14 to 100 mm above the lowest point) so that
% the plafond and the proximal tibia don't skew the slab centroids
if bone_indx == 13
    nodes_aligned_original = aligned_nodes;
    cutting_plane = min(aligned_nodes(:,3)) + 14; % Temporarily removes the tibial plafond
    cutting_plane2 = min(aligned_nodes(:,3)) + 100; % Temporarily shortens the tibia
    aligned_nodes = [aligned_nodes(aligned_nodes(:,3)>cutting_plane,1) aligned_nodes(aligned_nodes(:,3)>cutting_plane,2) aligned_nodes(aligned_nodes(:,3)>cutting_plane,3)];
    aligned_nodes = [aligned_nodes(aligned_nodes(:,3)<cutting_plane2,1) aligned_nodes(aligned_nodes(:,3)<cutting_plane2,2) aligned_nodes(aligned_nodes(:,3)<cutting_plane2,3)];
end

%% Split up the bone into nth sections in all three planes
% Bounding box of the (possibly trimmed) bone
x_min = min(aligned_nodes(:,1));
y_min = min(aligned_nodes(:,2));
z_min = min(aligned_nodes(:,3));
x_max = max(aligned_nodes(:,1));
y_max = max(aligned_nodes(:,2));
z_max = max(aligned_nodes(:,3));

range_x = x_max - x_min;
range_y = y_max - y_min;
range_z = z_max - z_min;

% Splits bone up in n sections
if bone_indx == 1 % Talus
    n = 3;
elseif bone_indx == 2 % Calcaneus
    n = 10;
elseif bone_indx == 3 % Navicular
    n = 5;
elseif bone_indx == 4 % Cuboid
    n = 5;
elseif bone_indx >= 5 && bone_indx <= 7 % Cuneiforms
    n = 3;
elseif bone_indx >= 8 && bone_indx <= 12 % Metatarsals
    n = 3;
elseif bone_indx == 13 || bone_indx == 14 % Tibia or Fibula
    n = 3;
end

% Thickness of one slab along each axis
nth_x = range_x/n;
nth_y = range_y/n;
nth_z = range_z/n;

%% Positive Y Nth ROI
% The six blocks below all follow the same pattern:
%   1. pick the nodes in the outermost 1/n slab at one end of an axis
%   2. pull out their x, y, z values (multiplying by the logical mask
%      zeroes the other nodes, which nonzeros() then removes)
%   3. average them to get that slab's centroid (a landmark point)
%   4. optionally plot the slab and its centroid when trouble == 1
% +Y = most anterior slab
positive_y_nth = y_max - nth_y;

positive_y_nth_ROI = aligned_nodes(:,2) >= positive_y_nth;

positive_y_nth_x = nonzeros(aligned_nodes(:,1).*positive_y_nth_ROI);
positive_y_nth_y = nonzeros(aligned_nodes(:,2).*positive_y_nth_ROI);
positive_y_nth_z = nonzeros(aligned_nodes(:,3).*positive_y_nth_ROI);

av_positive_y_nth_x = mean(positive_y_nth_x);
av_positive_y_nth_y = mean(positive_y_nth_y);
av_positive_y_nth_z = mean(positive_y_nth_z);

av_positive_y_nth = [av_positive_y_nth_x,av_positive_y_nth_y,av_positive_y_nth_z];

if trouble == 1
    figure()
    plot3(aligned_nodes(:,1),aligned_nodes(:,2),aligned_nodes(:,3),'k.')
    hold on
    plot3(positive_y_nth_x,positive_y_nth_y,positive_y_nth_z,'ys')
    plot3(av_positive_y_nth_x,av_positive_y_nth_y,av_positive_y_nth_z,'r.','MarkerSize',50)
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    axis equal
end

%% Negative Y nth ROI
% -Y = most posterior slab
negative_y_nth = y_min + nth_y;

negative_y_nth_ROI = aligned_nodes(:,2) <= negative_y_nth;

negative_y_nth_x = nonzeros(aligned_nodes(:,1).*negative_y_nth_ROI);
negative_y_nth_y = nonzeros(aligned_nodes(:,2).*negative_y_nth_ROI);
negative_y_nth_z = nonzeros(aligned_nodes(:,3).*negative_y_nth_ROI);

av_negative_y_nth_x = mean(negative_y_nth_x);
av_negative_y_nth_y = mean(negative_y_nth_y);
av_negative_y_nth_z = mean(negative_y_nth_z);

av_negative_y_nth = [av_negative_y_nth_x,av_negative_y_nth_y,av_negative_y_nth_z];

if trouble == 1
    figure()
    plot3(aligned_nodes(:,1),aligned_nodes(:,2),aligned_nodes(:,3),'k.')
    hold on
    plot3(negative_y_nth_x,negative_y_nth_y,negative_y_nth_z,'ys')
    plot3(av_negative_y_nth_x,av_negative_y_nth_y,av_negative_y_nth_z,'r.','MarkerSize',50)
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    axis equal
end

%% Positive Z nth ROI
% +Z = most superior slab
positive_z_nth = z_max - nth_z;

positive_z_nth_ROI = aligned_nodes(:,3) >= positive_z_nth;

positive_z_nth_x = nonzeros(aligned_nodes(:,1).*positive_z_nth_ROI);
positive_z_nth_y = nonzeros(aligned_nodes(:,2).*positive_z_nth_ROI);
positive_z_nth_z = nonzeros(aligned_nodes(:,3).*positive_z_nth_ROI);

av_positive_z_nth_x = mean(positive_z_nth_x);
av_positive_z_nth_y = mean(positive_z_nth_y);
av_positive_z_nth_z = mean(positive_z_nth_z);

av_positive_z_nth = [av_positive_z_nth_x,av_positive_z_nth_y,av_positive_z_nth_z];

if trouble == 1
    figure()
    plot3(aligned_nodes(:,1),aligned_nodes(:,2),aligned_nodes(:,3),'k.')
    hold on
    plot3(positive_z_nth_x,positive_z_nth_y,positive_z_nth_z,'ys')
    plot3(av_positive_z_nth_x,av_positive_z_nth_y,av_positive_z_nth_z,'r.','MarkerSize',50)
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    axis equal
end

%% Negative Z nth ROI
% -Z = most inferior slab
negative_z_nth = z_min + nth_z;

negative_z_nth_ROI = aligned_nodes(:,3) <= negative_z_nth;

negative_z_nth_x = nonzeros(aligned_nodes(:,1).*negative_z_nth_ROI);
negative_z_nth_y = nonzeros(aligned_nodes(:,2).*negative_z_nth_ROI);
negative_z_nth_z = nonzeros(aligned_nodes(:,3).*negative_z_nth_ROI);

av_negative_z_nth_x = mean(negative_z_nth_x);
av_negative_z_nth_y = mean(negative_z_nth_y);
av_negative_z_nth_z = mean(negative_z_nth_z);

av_negative_z_nth = [av_negative_z_nth_x,av_negative_z_nth_y,av_negative_z_nth_z];

if trouble == 1
    figure()
    plot3(aligned_nodes(:,1),aligned_nodes(:,2),aligned_nodes(:,3),'k.')
    hold on
    plot3(negative_z_nth_x,negative_z_nth_y,negative_z_nth_z,'ys')
    plot3(av_negative_z_nth_x,av_negative_z_nth_y,av_negative_z_nth_z,'r.','MarkerSize',50)
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    axis equal
end

%% Negative X nth ROI
% -X = most lateral slab
negative_x_nth = x_min + nth_x;

negative_x_nth_ROI = aligned_nodes(:,1) <= negative_x_nth;

negative_x_nth_x = nonzeros(aligned_nodes(:,1).*negative_x_nth_ROI);
negative_x_nth_y = nonzeros(aligned_nodes(:,2).*negative_x_nth_ROI);
negative_x_nth_z = nonzeros(aligned_nodes(:,3).*negative_x_nth_ROI);

av_negative_x_nth_x = mean(negative_x_nth_x);
av_negative_x_nth_y = mean(negative_x_nth_y);
av_negative_x_nth_z = mean(negative_x_nth_z);

av_negative_x_nth = [av_negative_x_nth_x,av_negative_x_nth_y,av_negative_x_nth_z];

if trouble == 1
    figure()
    plot3(aligned_nodes(:,1),aligned_nodes(:,2),aligned_nodes(:,3),'k.')
    hold on
    plot3(negative_x_nth_x,negative_x_nth_y,negative_x_nth_z,'ys')
    plot3(av_negative_x_nth_x,av_negative_x_nth_y,av_negative_x_nth_z,'r.','MarkerSize',50)
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    axis equal
end

%% Positive X nth ROI
% +X = most medial slab
positive_x_nth = x_max - nth_x;

positive_x_nth_ROI = aligned_nodes(:,1) >= positive_x_nth;

positive_x_nth_x = nonzeros(aligned_nodes(:,1).*positive_x_nth_ROI);
positive_x_nth_y = nonzeros(aligned_nodes(:,2).*positive_x_nth_ROI);
positive_x_nth_z = nonzeros(aligned_nodes(:,3).*positive_x_nth_ROI);

av_positive_x_nth_x = mean(positive_x_nth_x);
av_positive_x_nth_y = mean(positive_x_nth_y);
av_positive_x_nth_z = mean(positive_x_nth_z);

av_positive_x_nth = [av_positive_x_nth_x,av_positive_x_nth_y,av_positive_x_nth_z];

if trouble == 1
    figure()
    plot3(aligned_nodes(:,1),aligned_nodes(:,2),aligned_nodes(:,3),'k.')
    hold on
    plot3(positive_x_nth_x,positive_x_nth_y,positive_x_nth_z,'ys')
    plot3(av_positive_x_nth_x,av_positive_x_nth_y,av_positive_x_nth_z,'r.','MarkerSize',50)
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    axis equal
end

%% Raw Axis Calculation
% Choose the three landmarks for this bone:
%   primary axis   runs from second_point to first_point
%   secondary axis runs from the primary axis toward third_point
if bone_indx == 3 % Navicular
    % Primary = lateral -> medial (the navicular is widest in ML)
    first_point = av_positive_x_nth;
    second_point = av_negative_x_nth;
    third_point = av_positive_z_nth;
elseif bone_indx >= 13 % Tibia, Fibula
    % Primary = inferior -> superior (the long axis of the shaft)
    first_point = av_positive_z_nth;
    second_point = av_negative_z_nth;
    % Secondary aims at the lateral slab. If that landmark sits lower than
    % the inferior landmark, its Z is set to 0 so it doesn't tilt the
    % secondary axis downward.
    if av_negative_z_nth(3) > av_negative_x_nth(3)
        third_point = [av_negative_x_nth(1) av_negative_x_nth(2) 0];
    else
        third_point = av_negative_x_nth;
    end
else % Cuneiforms, Metatarsals, Calcaneus, Cuboid, Talus
    % Primary = posterior -> anterior, secondary aims superior
    first_point = av_positive_y_nth;
    second_point = av_negative_y_nth;
    third_point = av_positive_z_nth;
end

% Every axis is drawn from (0,0,0) of the template frame. icp_template
% places the bone so this is roughly the bone's center (or, for the tibia
% and fibula, the distal joint region). JointOrigin can later move the
% origin to a joint surface.
origin = [0,0,0];

% Define the primary axis based on first_point and second_point
primary_axis_vector = first_point - second_point;
primary_axis_unit = primary_axis_vector / norm(primary_axis_vector); % Normalize

% Project the third_point onto the primary axis to find the closest point
projection_length = dot(third_point - second_point, primary_axis_unit);
closest_point_on_primary = second_point + projection_length * primary_axis_unit;

% Define the secondary axis
secondary_axis_vector = third_point - closest_point_on_primary;
secondary_axis_unit = secondary_axis_vector / norm(secondary_axis_vector); % Normalize

% Define the tertiary axis as cross product of primary and secondary axes
tertiary_axis_vector = cross(primary_axis_unit, secondary_axis_unit);
tertiary_axis_unit = tertiary_axis_vector / norm(tertiary_axis_vector); % Normalize

% Sign for the ML axis. Rights were mirrored to the left, so flipping the
% ML axis for them makes +ML point toward the subject's right on both sides
% (medial on a left bone, lateral on a right bone).
if side_indx == 1
    ml = -1;
else
    ml = 1;
end

% Adjust axes based on bone index and side index
% Each axis is stored as two points, [origin; origin + 50*unit vector].
% The leading signs make AP point anterior, SI superior and ML follow the
% side convention above. For the navicular and tibia/fibula a negative sign
% on the whole [origin; tip] pair just flips the tip, since origin is 0.
if bone_indx == 3 % Navicular
    ML_vector_points = ml*[origin; origin + 50 * primary_axis_unit];
    SI_vector_points = [origin; origin + 50 * secondary_axis_unit];
    AP_vector_points = -[origin; origin + 50 * tertiary_axis_unit];
elseif bone_indx == 13 || bone_indx == 14 % Tibia, Fibula
    SI_vector_points = [origin; origin + 50 * primary_axis_unit];
    ML_vector_points = -ml*[origin; origin + 50 * secondary_axis_unit];
    AP_vector_points = -[origin; origin + 50 * tertiary_axis_unit];
else % Cuneiforms, Metatarsals, Calcaneus, Cuboid, Talus
    AP_vector_points = [origin; origin + 50 * primary_axis_unit];
    SI_vector_points = [origin; origin + 50 * secondary_axis_unit];
    ML_vector_points = ml*[origin; origin + 50 * tertiary_axis_unit];
end

if trouble == 1
    figure()
    plot3(aligned_nodes(:,1),aligned_nodes(:,2),aligned_nodes(:,3),'k.')
    % plot3(nodes_aligned_original(:,1),nodes_aligned_original(:,2),nodes_aligned_original(:,3),'.k')
    hold on
    plot3(AP_vector_points(:,1),AP_vector_points(:,2),AP_vector_points(:,3),'r')
    plot3(SI_vector_points(:,1),SI_vector_points(:,2),SI_vector_points(:,3),'g')
    plot3(ML_vector_points(:,1),ML_vector_points(:,2),ML_vector_points(:,3),'b')
    plot3(0,0,0,'ys')
    plot3(first_point(:,1),first_point(:,2),first_point(:,3),'rs','MarkerSize',20)
    plot3(second_point(:,1),second_point(:,2),second_point(:,3),'bs','MarkerSize',20)
    plot3(third_point(:,1),third_point(:,2),third_point(:,3),'gs','MarkerSize',20)
    legend('Nodal Points','AP Axis','SI Axis','ML Axis')
    text(AP_vector_points(2,1),AP_vector_points(2,2),AP_vector_points(2,3),'Anterior','HorizontalAlignment','left','FontSize',10,'Color','r');
    text(SI_vector_points(2,1),SI_vector_points(2,2),SI_vector_points(2,3),'Superior','HorizontalAlignment','left','FontSize',10,'Color','g');
    if side_indx == 1
        text(ML_vector_points(2,1),ML_vector_points(2,2),ML_vector_points(2,3),'Lateral','HorizontalAlignment','left','FontSize',10,'Color','b');
    else
        text(ML_vector_points(2,1),ML_vector_points(2,2),ML_vector_points(2,3),'Medial','HorizontalAlignment','left','FontSize',10,'Color','b');
    end
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    axis equal
end

%% Output Axes and Rotation Index
% Rows: 1-2 AP, 3-4 SI, 5-6 ML (origin then tip for each axis)
Temp_Coordinates = [AP_vector_points([1,2],:)
    SI_vector_points([1,2],:)
    ML_vector_points([1,2],:)];

% Return the nodes before the talus/tibia trimming above, so the joint
% surface search and the final reorientation use the full bone
if exist("nodes_aligned_original")
    Temp_Nodes = nodes_aligned_original;
else
    Temp_Nodes = aligned_nodes;
end
