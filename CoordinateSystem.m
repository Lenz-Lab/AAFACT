function [Temp_Coordinates, Temp_Nodes] = CoordinateSystem(aligned_nodes,bone_indx,bone_coord,side_indx)
% This function produces the coordinate system for the users bone in the
% temporarily aligned orientation.

%% TT CS for Talus
if bone_indx == 1 && bone_coord >= 2
    nodes_aligned_original = aligned_nodes;
    aligned_nodes = [aligned_nodes(aligned_nodes(:,2)<10,1) aligned_nodes(aligned_nodes(:,2)<10,2) aligned_nodes(aligned_nodes(:,2)<10,3)];
end

%% Tibial Realignment for Medial Malleolus
if bone_indx == 13
    nodes_aligned_original = aligned_nodes;
    cutting_plane = min(aligned_nodes(:,3)) + 14; % Temporarily removes the tibial plafond
    cutting_plane2 = min(aligned_nodes(:,3)) + 100; % Temporarily shortens the tibia
    aligned_nodes = [aligned_nodes(aligned_nodes(:,3)>cutting_plane,1) aligned_nodes(aligned_nodes(:,3)>cutting_plane,2) aligned_nodes(aligned_nodes(:,3)>cutting_plane,3)];
    aligned_nodes = [aligned_nodes(aligned_nodes(:,3)<cutting_plane2,1) aligned_nodes(aligned_nodes(:,3)<cutting_plane2,2) aligned_nodes(aligned_nodes(:,3)<cutting_plane2,3)];
end

%% Split up the bone into nth sections in all three planes
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

nth_x = range_x/n;
nth_y = range_y/n;
nth_z = range_z/n;

%% Positive Y Nth ROI
positive_y_nth = y_max - nth_y;

positive_y_nth_ROI = aligned_nodes(:,2) >= positive_y_nth;

positive_y_nth_x = nonzeros(aligned_nodes(:,1).*positive_y_nth_ROI);
positive_y_nth_y = nonzeros(aligned_nodes(:,2).*positive_y_nth_ROI);
positive_y_nth_z = nonzeros(aligned_nodes(:,3).*positive_y_nth_ROI);

av_positive_y_nth_x = mean(positive_y_nth_x);
av_positive_y_nth_y = mean(positive_y_nth_y);
av_positive_y_nth_z = mean(positive_y_nth_z);

av_positive_y_nth = [av_positive_y_nth_x,av_positive_y_nth_y,av_positive_y_nth_z];

% figure()
% plot3(aligned_nodes(:,1),aligned_nodes(:,2),aligned_nodes(:,3),'k.')
% hold on
% plot3(positive_y_nth_x,positive_y_nth_y,positive_y_nth_z,'ys')
% plot3(av_positive_y_nth_x,av_positive_y_nth_y,av_positive_y_nth_z,'r.','MarkerSize',50)
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

%% Negative Y nth ROI
negative_y_nth = y_min + nth_y;

negative_y_nth_ROI = aligned_nodes(:,2) <= negative_y_nth;

negative_y_nth_x = nonzeros(aligned_nodes(:,1).*negative_y_nth_ROI);
negative_y_nth_y = nonzeros(aligned_nodes(:,2).*negative_y_nth_ROI);
negative_y_nth_z = nonzeros(aligned_nodes(:,3).*negative_y_nth_ROI);

av_negative_y_nth_x = mean(negative_y_nth_x);
av_negative_y_nth_y = mean(negative_y_nth_y);
av_negative_y_nth_z = mean(negative_y_nth_z);

av_negative_y_nth = [av_negative_y_nth_x,av_negative_y_nth_y,av_negative_y_nth_z];

% figure()
% plot3(aligned_nodes(:,1),aligned_nodes(:,2),aligned_nodes(:,3),'k.')
% hold on
% plot3(negative_y_nth_x,negative_y_nth_y,negative_y_nth_z,'ys')
% plot3(av_negative_y_nth_x,av_negative_y_nth_y,av_negative_y_nth_z,'r.','MarkerSize',50)
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

%% Positive Z nth ROI
positive_z_nth = z_max - nth_z;

positive_z_nth_ROI = aligned_nodes(:,3) >= positive_z_nth;

positive_z_nth_x = nonzeros(aligned_nodes(:,1).*positive_z_nth_ROI);
positive_z_nth_y = nonzeros(aligned_nodes(:,2).*positive_z_nth_ROI);
positive_z_nth_z = nonzeros(aligned_nodes(:,3).*positive_z_nth_ROI);

av_positive_z_nth_x = mean(positive_z_nth_x);
av_positive_z_nth_y = mean(positive_z_nth_y);
av_positive_z_nth_z = mean(positive_z_nth_z);

av_positive_z_nth = [av_positive_z_nth_x,av_positive_z_nth_y,av_positive_z_nth_z];

% figure()
% plot3(aligned_nodes(:,1),aligned_nodes(:,2),aligned_nodes(:,3),'k.')
% hold on
% plot3(positive_z_nth_x,positive_z_nth_y,positive_z_nth_z,'ys')
% plot3(av_positive_z_nth_x,av_positive_z_nth_y,av_positive_z_nth_z,'r.','MarkerSize',50)
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

%% Negative Z nth ROI
negative_z_nth = z_min + nth_z;

negative_z_nth_ROI = aligned_nodes(:,3) <= negative_z_nth;

negative_z_nth_x = nonzeros(aligned_nodes(:,1).*negative_z_nth_ROI);
negative_z_nth_y = nonzeros(aligned_nodes(:,2).*negative_z_nth_ROI);
negative_z_nth_z = nonzeros(aligned_nodes(:,3).*negative_z_nth_ROI);

av_negative_z_nth_x = mean(negative_z_nth_x);
av_negative_z_nth_y = mean(negative_z_nth_y);
av_negative_z_nth_z = mean(negative_z_nth_z);

av_negative_z_nth = [av_negative_z_nth_x,av_negative_z_nth_y,av_negative_z_nth_z];

% figure()
% plot3(aligned_nodes(:,1),aligned_nodes(:,2),aligned_nodes(:,3),'k.')
% hold on
% plot3(negative_z_nth_x,negative_z_nth_y,negative_z_nth_z,'ys')
% plot3(av_negative_z_nth_x,av_negative_z_nth_y,av_negative_z_nth_z,'r.','MarkerSize',50)
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

%% Negative X nth ROI
negative_x_nth = x_min + nth_x;

negative_x_nth_ROI = aligned_nodes(:,1) <= negative_x_nth;

negative_x_nth_x = nonzeros(aligned_nodes(:,1).*negative_x_nth_ROI);
negative_x_nth_y = nonzeros(aligned_nodes(:,2).*negative_x_nth_ROI);
negative_x_nth_z = nonzeros(aligned_nodes(:,3).*negative_x_nth_ROI);

av_negative_x_nth_x = mean(negative_x_nth_x);
av_negative_x_nth_y = mean(negative_x_nth_y);
av_negative_x_nth_z = mean(negative_x_nth_z);

av_negative_x_nth = [av_negative_x_nth_x,av_negative_x_nth_y,av_negative_x_nth_z];

% figure()
% plot3(aligned_nodes(:,1),aligned_nodes(:,2),aligned_nodes(:,3),'k.')
% hold on
% plot3(negative_x_nth_x,negative_x_nth_y,negative_x_nth_z,'ys')
% plot3(av_negative_x_nth_x,av_negative_x_nth_y,av_negative_x_nth_z,'r.','MarkerSize',50)
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

%% Positive X nth ROI
positive_x_nth = x_max - nth_x;

positive_x_nth_ROI = aligned_nodes(:,1) >= positive_x_nth;

positive_x_nth_x = nonzeros(aligned_nodes(:,1).*positive_x_nth_ROI);
positive_x_nth_y = nonzeros(aligned_nodes(:,2).*positive_x_nth_ROI);
positive_x_nth_z = nonzeros(aligned_nodes(:,3).*positive_x_nth_ROI);

av_positive_x_nth_x = mean(positive_x_nth_x);
av_positive_x_nth_y = mean(positive_x_nth_y);
av_positive_x_nth_z = mean(positive_x_nth_z);

av_positive_x_nth = [av_positive_x_nth_x,av_positive_x_nth_y,av_positive_x_nth_z];

% figure()
% plot3(aligned_nodes(:,1),aligned_nodes(:,2),aligned_nodes(:,3),'k.')
% hold on
% plot3(positive_x_nth_x,positive_x_nth_y,positive_x_nth_z,'ys')
% plot3(av_positive_x_nth_x,av_positive_x_nth_y,av_positive_x_nth_z,'r.','MarkerSize',50)
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

%% Raw Axis Calculation
if bone_indx == 3 % Navicular
    first_point = av_positive_x_nth;
    second_point = av_negative_x_nth;
    third_point = av_positive_z_nth;
elseif bone_indx >= 13 % Tibia, Fibula
    first_point = av_positive_z_nth;
    second_point = av_negative_z_nth;
    if av_negative_z_nth(3) > av_negative_x_nth(3)
        third_point = [av_negative_x_nth(1) av_negative_x_nth(2) 0];
    else
        third_point = av_negative_x_nth;
    end
else % Cuneiforms, Metatarsals, Calcaneus, Cuboid, Talus
    first_point = av_positive_y_nth;
    second_point = av_negative_y_nth;
    third_point = av_positive_z_nth;
end

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

if side_indx == 1
    ml = -1;
else
    ml = 1;
end

% Adjust axes based on bone index and side index
if bone_indx == 3 % Navicular
    ML_vector_points = ml*[origin; origin + 50 * primary_axis_unit];
    SI_vector_points = [origin; origin + 50 * secondary_axis_unit];
    AP_vector_points = -ml*[origin; origin + 50 * tertiary_axis_unit];
elseif bone_indx == 13 || bone_indx == 14 % Tibia, Fibula
    SI_vector_points = [origin; origin + 50 * primary_axis_unit];
    ML_vector_points = -ml*[origin; origin + 50 * secondary_axis_unit];
    AP_vector_points = -ml*[origin; origin + 50 * tertiary_axis_unit];
else % Cuneiforms, Metatarsals, Calcaneus, Cuboid, Talus
    AP_vector_points = [origin; origin + 50 * primary_axis_unit];
    SI_vector_points = [origin; origin + 50 * secondary_axis_unit];
    ML_vector_points = ml*[origin; origin + 50 * tertiary_axis_unit];
end

% figure()
% plot3(aligned_nodes(:,1),aligned_nodes(:,2),aligned_nodes(:,3),'k.')
% % plot3(nodes_aligned_original(:,1),nodes_aligned_original(:,2),nodes_aligned_original(:,3),'.k')
% hold on
% plot3(AP_vector_points(:,1),AP_vector_points(:,2),AP_vector_points(:,3),'r')
% plot3(SI_vector_points(:,1),SI_vector_points(:,2),SI_vector_points(:,3),'g')
% plot3(ML_vector_points(:,1),ML_vector_points(:,2),ML_vector_points(:,3),'b')
% plot3(0,0,0,'ys')
% plot3(first_point(:,1),first_point(:,2),first_point(:,3),'rs','MarkerSize',20)
% plot3(second_point(:,1),second_point(:,2),second_point(:,3),'bs','MarkerSize',20)
% plot3(third_point(:,1),third_point(:,2),third_point(:,3),'gs','MarkerSize',20)
% legend('Nodal Points','AP Axis','SI Axis','ML Axis')
% text(AP_vector_points(2,1),AP_vector_points(2,2),AP_vector_points(2,3),'Anterior','HorizontalAlignment','left','FontSize',10,'Color','r');
% text(SI_vector_points(2,1),SI_vector_points(2,2),SI_vector_points(2,3),'Superior','HorizontalAlignment','left','FontSize',10,'Color','g');
% if side_indx == 1
%     text(ML_vector_points(2,1),ML_vector_points(2,2),ML_vector_points(2,3),'Lateral','HorizontalAlignment','left','FontSize',10,'Color','b');
% else
%     text(ML_vector_points(2,1),ML_vector_points(2,2),ML_vector_points(2,3),'Medial','HorizontalAlignment','left','FontSize',10,'Color','b');
% end
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

%% Output Axes and Rotation Index
Temp_Coordinates = [AP_vector_points([1,2],:)
    SI_vector_points([1,2],:)
    ML_vector_points([1,2],:)];

if (bone_indx == 1 && bone_coord >= 2) || bone_indx == 13
    Temp_Nodes = nodes_aligned_original;
else
    Temp_Nodes = aligned_nodes;
end
