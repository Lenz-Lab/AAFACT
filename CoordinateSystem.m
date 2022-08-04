function [Temp_Coordinates, Temp_Nodes] = CoordinateSystem(aligned_nodes,bone_indx,bone_coord,tibfib_switch)

%% Multiple CS for Talus
if bone_indx == 1 && bone_coord == 2
    nodes_aligned_original = aligned_nodes;
    aligned_nodes = [aligned_nodes(aligned_nodes(:,2)<10,1) aligned_nodes(aligned_nodes(:,2)<10,2) aligned_nodes(aligned_nodes(:,2)<10,3)];
end

%% Tibial Realignment for Medial Malleolus
cutting_plane = min(aligned_nodes(:,3)) + 14; % Temporarily removes the tibial plafond

if bone_indx == 13
    nodes_aligned_original = aligned_nodes;
    aligned_nodes = [aligned_nodes(aligned_nodes(:,3)>cutting_plane,1) aligned_nodes(aligned_nodes(:,3)>cutting_plane,2) aligned_nodes(aligned_nodes(:,3)>cutting_plane,3)];
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
else
    n = 7;
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

if bone_indx == 13
    aligned_nodes_temp = [aligned_nodes(aligned_nodes(:,3)<30,1) aligned_nodes(aligned_nodes(:,3)<30,2) aligned_nodes(aligned_nodes(:,3)<30,3)];
else 
    aligned_nodes_temp = aligned_nodes;
end

negative_x_nth_ROI = aligned_nodes_temp(:,1) <= negative_x_nth;

negative_x_nth_x = nonzeros(aligned_nodes_temp(:,1).*negative_x_nth_ROI);
negative_x_nth_y = nonzeros(aligned_nodes_temp(:,2).*negative_x_nth_ROI);
negative_x_nth_z = nonzeros(aligned_nodes_temp(:,3).*negative_x_nth_ROI);

av_negative_x_nth_x = mean(negative_x_nth_x);
av_negative_x_nth_y = mean(negative_x_nth_y);
av_negative_x_nth_z = mean(negative_x_nth_z);

av_negative_x_nth = [av_negative_x_nth_x,av_negative_x_nth_y,av_negative_x_nth_z];

% figure()
% plot3(aligned_nodes_temp(:,1),aligned_nodes_temp(:,2),aligned_nodes_temp(:,3),'k.')
% hold on
% plot3(negative_x_nth_x,negative_x_nth_y,negative_x_nth_z,'ys')
% plot3(av_negative_x_nth_x,av_negative_x_nth_y,av_negative_x_nth_z,'r.','MarkerSize',50)
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

%% Positive X nth ROI
positive_x_nth = x_max - nth_x;

positive_x_nth_ROI = aligned_nodes_temp(:,1) >= positive_x_nth;

positive_x_nth_x = nonzeros(aligned_nodes_temp(:,1).*positive_x_nth_ROI);
positive_x_nth_y = nonzeros(aligned_nodes_temp(:,2).*positive_x_nth_ROI);
positive_x_nth_z = nonzeros(aligned_nodes_temp(:,3).*positive_x_nth_ROI);

av_positive_x_nth_x = mean(positive_x_nth_x);
av_positive_x_nth_y = mean(positive_x_nth_y);
av_positive_x_nth_z = mean(positive_x_nth_z);

av_positive_x_nth = [av_positive_x_nth_x,av_positive_x_nth_y,av_positive_x_nth_z];

% figure()
% plot3(aligned_nodes_temp(:,1),aligned_nodes_temp(:,2),aligned_nodes_temp(:,3),'k.')
% hold on
% plot3(positive_x_nth_x,positive_x_nth_y,positive_x_nth_z,'ys')
% plot3(av_positive_x_nth_x,av_positive_x_nth_y,av_positive_x_nth_z,'r.','MarkerSize',50)
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

%% MDTA and TT Calculation
if bone_indx == 13
    temp_SI = [0 0 0; (av_positive_z_nth_x - av_negative_z_nth_x),(av_positive_z_nth_y - av_negative_z_nth_y),(av_positive_z_nth_z - av_negative_z_nth_z)];
    temp_ML = [0 0 0; (av_positive_x_nth_x - av_negative_x_nth_x),(av_positive_x_nth_y - av_negative_x_nth_y),(av_positive_x_nth_z - av_negative_x_nth_z)];

%     temp_SI_2D = [0 0 0; (av_positive_z_nth_x - av_negative_z_nth_x),0,(av_positive_z_nth_z - av_negative_z_nth_z)];
%     temp_ML_2D = [0 0 0; (av_positive_x_nth_x - av_negative_x_nth_x),0,(av_positive_x_nth_z - av_negative_x_nth_z)];


    MDTA = acosd(dot(temp_SI(2,:),temp_ML(2,:))/(norm(temp_SI(2,:))*norm(temp_ML(2,:))))
%     MDTA_2D = acosd(dot(temp_SI_2D(2,:),temp_ML_2D(2,:))/(norm(temp_SI_2D(2,:))*norm(temp_ML_2D(2,:))))

    figure()
    plot3(nodes_aligned_original(:,1),nodes_aligned_original(:,2),nodes_aligned_original(:,3),'.k')
    hold on
    plot3(temp_SI(:,1),temp_SI(:,2),temp_SI(:,3),'r-')
    plot3(temp_ML(:,1),temp_ML(:,2),temp_ML(:,3),'b-')
%     plot3(temp_SI_2D(:,1),temp_SI_2D(:,2),temp_SI_2D(:,3),'r-')
%     plot3(temp_ML_2D(:,1),temp_ML_2D(:,2),temp_ML_2D(:,3),'b-')
    xlabel('x')
    ylabel('y')
    zlabel('z')
    axis equal
end

%% Raw Axis Calculation
if bone_indx == 3 % Navicular
    first_point = av_positive_x_nth;
    second_point = av_negative_x_nth;
    third_point = av_positive_z_nth;
elseif bone_indx == 1 && bone_coord == 2 % Talus
    first_point = av_positive_x_nth;
    second_point = av_negative_x_nth;
    third_point = av_positive_z_nth;
elseif bone_indx > 4 && bone_indx < 8 % Cuneiforms
    first_point = av_positive_y_nth;
    second_point = av_negative_y_nth;
    third_point = av_positive_z_nth;
elseif bone_indx >= 8 && bone_indx <= 12 % Metatarsals
    first_point = av_positive_y_nth;
    second_point = av_negative_y_nth;
    third_point = av_positive_z_nth;
elseif bone_indx == 13 % tibia
    first_point = av_positive_z_nth;
    second_point = av_negative_z_nth;
    third_point = av_negative_x_nth;
elseif bone_indx == 14 % fibula
    first_point = av_positive_z_nth;
    second_point = av_negative_z_nth;
    third_point = av_positive_y_nth;
else % Calcaneus, Cuboid
    first_point = av_positive_y_nth;
    second_point = av_negative_y_nth;
    third_point = av_positive_z_nth;
end

long_axis_slope = first_point - second_point; % slope of long axis
discretize = (0:0.0000001:1)';
long_axis_points = second_point + discretize*long_axis_slope; % points along the long axis

total_distance = zeros([length(discretize),1]);
for i = 1:length(long_axis_points)
    total_distance(i,:) = norm(third_point - long_axis_points(i,:)); % find the distances between the third point and the long axis
end

close_dist = (total_distance == min(total_distance)); % closest point between third point and the long axis
origin = [0 0 0];
temp_origin = long_axis_points(close_dist,:); % 90 degree intersecting point between long axis and third point

% figure()
% plot3(aligned_nodes(:,1),aligned_nodes(:,2),aligned_nodes(:,3),'k.')
% hold on
% plot3(first_point(:,1),first_point(:,2),first_point(:,3),'ys')
% plot3(second_point(:,1),second_point(:,2),second_point(:,3),'rs')
% plot3(third_point(:,1),third_point(:,2),third_point(:,3),'bs')
% plot3(temp_origin(:,1),temp_origin(:,2),temp_origin(:,3),'og')
% plot3(0,0,0,'gs')
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

if bone_indx == 3
    ML_vector_points = [origin; ((first_point - temp_origin)/norm(first_point - temp_origin))*50];
    SI_vector_points = [origin; ((third_point - temp_origin)/norm(third_point - temp_origin))*50];
    normal_vector = cross(ML_vector_points(2,:), SI_vector_points(2,:));
    AP_vector_points = -[origin; ((normal_vector - temp_origin)/norm(normal_vector - temp_origin))*50];
elseif bone_indx == 1 && bone_coord == 2
    ML_vector_points = [origin; ((first_point - temp_origin)/norm(first_point - temp_origin))*50];
    SI_vector_points = [origin; ((third_point - temp_origin)/norm(third_point - temp_origin))*50];
    normal_vector = cross(ML_vector_points(2,:), SI_vector_points(2,:));
    AP_vector_points = -[origin; ((normal_vector - temp_origin)/norm(normal_vector - temp_origin))*50];
elseif bone_indx > 4 && bone_indx < 8
    AP_vector_points = [origin; ((first_point - temp_origin)/norm(first_point - temp_origin))*50];
    SI_vector_points = [origin; ((third_point - temp_origin)/norm(third_point - temp_origin))*50];
    normal_vector = cross(AP_vector_points(2,:), SI_vector_points(2,:));
    ML_vector_points = [origin; ((normal_vector - temp_origin)/norm(normal_vector - temp_origin))*50];
elseif bone_indx >= 8 && bone_indx <= 12
    AP_vector_points = [origin; ((first_point - temp_origin)/norm(first_point - temp_origin))*50];
    SI_vector_points = [origin; ((third_point - temp_origin)/norm(third_point - temp_origin))*50];
    normal_vector = cross(AP_vector_points(2,:), SI_vector_points(2,:));
    ML_vector_points = [origin; ((normal_vector - temp_origin)/norm(normal_vector - temp_origin))*50];
elseif bone_indx == 13
    SI_vector_points = [origin; ((first_point - temp_origin)/norm(first_point - temp_origin))*50];
    ML_vector_points = -[origin; ((third_point - temp_origin)/norm(third_point - temp_origin))*50];
    normal_vector = cross(ML_vector_points(2,:), SI_vector_points(2,:));
    AP_vector_points = -[origin; ((normal_vector - temp_origin)/norm(normal_vector - temp_origin))*50];
elseif bone_indx == 14
    SI_vector_points = [origin; ((first_point - temp_origin)/norm(first_point - temp_origin))*50];
    AP_vector_points = [origin; ((third_point - temp_origin)/norm(third_point - temp_origin))*50];
    normal_vector = cross(AP_vector_points(2,:), SI_vector_points(2,:));
    ML_vector_points = [origin; ((normal_vector - temp_origin)/norm(normal_vector - temp_origin))*50];
else
    AP_vector_points = [origin; ((first_point - temp_origin)/norm(first_point - temp_origin))*50];
    SI_vector_points = [origin; ((third_point - temp_origin)/norm(third_point - temp_origin))*50];
    normal_vector = cross(AP_vector_points(2,:), SI_vector_points(2,:));
    ML_vector_points = [origin; ((normal_vector - temp_origin)/norm(normal_vector - temp_origin))*50];
end

% figure()
% plot3(aligned_nodes(:,1),aligned_nodes(:,2),aligned_nodes(:,3),'k.')
% hold on
% plot3(AP_vector_points(:,1),AP_vector_points(:,2),AP_vector_points(:,3),'r')
% plot3(SI_vector_points(:,1),SI_vector_points(:,2),SI_vector_points(:,3),'g')
% plot3(ML_vector_points(:,1),ML_vector_points(:,2),ML_vector_points(:,3),'b')
% plot3(0,0,0,'ys')
% plot3(first_point(:,1),first_point(:,2),first_point(:,3),'rs')
% plot3(second_point(:,1),second_point(:,2),second_point(:,3),'rs')
% plot3(third_point(:,1),third_point(:,2),third_point(:,3),'rs')
% legend('Nodal Points','AP Axis','SI Axis','ML Axis')
% text(AP_vector_points(2,1),AP_vector_points(2,2),AP_vector_points(2,3),'Anterior','HorizontalAlignment','left','FontSize',10,'Color','r');
% text(SI_vector_points(2,1),SI_vector_points(2,2),SI_vector_points(2,3),'Superior','HorizontalAlignment','left','FontSize',10,'Color','g');
% text(ML_vector_points(2,1),ML_vector_points(2,2),ML_vector_points(2,3),'Medial','HorizontalAlignment','left','FontSize',10,'Color','b');
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

%% Output Axes and Rotation Index
Temp_Coordinates = [AP_vector_points([1,2],:)
    SI_vector_points([1,2],:)
    ML_vector_points([1,2],:)];

if bone_indx == 1 && bone_coord == 2
    Temp_Nodes = nodes_aligned_original;
else
    Temp_Nodes = aligned_nodes;
end