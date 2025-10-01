function [aligned_nodes, RTs] = icp_template(bone_indx,nodes,bone_coord,better_start)
% This function aligned the user input bone to a predefined template bone.
% It requires the bone index bone to identify which bone was chosen
% (bone_indx), the bone nodal points (nodes), the coordinate system chosen
% by the user (bone_coord), and a logical value for the user manually
% choosing a better starting point the icp code doesn't undo the chosen
% position.

addpath('Template_Bones\')
%% Read in Template Bone
if bone_indx == 1 && bone_coord == 1 % TN
    TR_template = stlread('Talus_Template.stl');
    a = 2;
elseif bone_indx == 1 && bone_coord >= 2 % TT & ST
    TR_template2 = stlread('Talus_Template2.stl');
    TR_template = stlread('Talus_Template.stl');
    nodes_template2 = TR_template2.Points;
    a = 2;
elseif bone_indx == 2 && bone_coord == 1
    TR_template = stlread('Calcaneus_Template.stl');
    a = 2;
elseif bone_indx == 2 && bone_coord == 2
    TR_template = stlread('Calcaneus_Template2.stl');
    a = 2;
elseif bone_indx == 3
    TR_template = stlread('Navicular_Template.stl');
    a = 1;
elseif bone_indx == 4 && bone_coord == 1
    TR_template = stlread('Cuboid_Template.stl');
    a = 2;
elseif bone_indx == 4 && bone_coord == 2
    TR_template = stlread('Cuboid_Template2.stl');
    a = 2;
elseif bone_indx == 5
    TR_template = stlread('Medial_Cuneiform_Template.stl');
    a = 3;
elseif bone_indx == 6
    TR_template = stlread('Intermediate_Cuneiform_Template.stl');
    a = 3;
elseif bone_indx == 7 && bone_coord == 1
    TR_template = stlread('Lateral_Cuneiform_Template.stl');
    a = 3;
elseif bone_indx == 7 && bone_coord == 2
    TR_template = stlread('Lateral_Cuneiform_Template2.stl');
    a = 3;
elseif bone_indx == 8 && bone_coord == 1
    TR_template = stlread('Metatarsal1_Template.stl');
    a = 2;
elseif bone_indx == 8 && bone_coord == 2
    TR_template = stlread('Metatarsal1_Template2.stl');
    a = 2;
elseif bone_indx == 9 && bone_coord == 1
    TR_template = stlread('Metatarsal2_Template.stl');
    a = 2;
elseif bone_indx == 9 && bone_coord == 2
    TR_template = stlread('Metatarsal2_Template2.stl');
    a = 2;
elseif bone_indx == 10 && bone_coord == 1
    TR_template = stlread('Metatarsal3_Template.stl');
    a = 2;
elseif bone_indx == 10 && bone_coord == 2
    TR_template = stlread('Metatarsal3_Template2.stl');
    a = 2;
elseif bone_indx == 11 && bone_coord == 1
    TR_template = stlread('Metatarsal4_Template.stl');
    a = 2;
elseif bone_indx == 11 && bone_coord == 2
    TR_template = stlread('Metatarsal4_Template2.stl');
    a = 2;
elseif bone_indx == 12 && bone_coord == 1
    TR_template = stlread('Metatarsal5_Template.stl');
    a = 2;
elseif bone_indx == 12 && bone_coord == 2
    TR_template = stlread('Metatarsal5_Template2.stl');
    a = 2;
elseif bone_indx == 13 && bone_coord == 1
    TR_template = stlread('Tibia_Template.stl');
    a = 3;
elseif bone_indx == 13 && bone_coord == 2
    TR_template = stlread('Tibia_Template_Facet.stl');
    a = 3;
elseif bone_indx == 14 && bone_coord == 1
    TR_template = stlread('Fibula_Template.stl');
    a = 3;
elseif bone_indx == 14 && bone_coord == 2
    TR_template = stlread('Fibula_Template_Facet.stl');
    a = 3;
end

nodes_template = TR_template.Points;
con_temp = TR_template.ConnectivityList;

max_nodes_x = (max(nodes(:,1)) - min(nodes(:,1)));
max_nodes_y = (max(nodes(:,2)) - min(nodes(:,2)));
max_nodes_z = (max(nodes(:,3)) - min(nodes(:,3)));
max_nodes_length = max([max_nodes_x  max_nodes_y max_nodes_z]);

if max_nodes_x == max_nodes_length
    b = 1;
elseif max_nodes_y == max_nodes_length
    b = 2;
elseif max_nodes_z == max_nodes_length
    b = 3;
end

%% Adjusting the cropped/smaller models
% Creates similar sized models for cropped tibia or fibula
if bone_indx == 13 || bone_indx == 14
    nodes_template_length = (max(nodes_template(:,a)) - min(nodes_template(:,a)));
    if nodes_template_length/1.5 > max_nodes_length % Determines if the user's model is 2/3 the length of the template model
        temp = find(nodes_template(:,3) < (min(nodes_template(:,a)) + max_nodes_length));
        nodes_template = [nodes_template(temp,1) nodes_template(temp,2) nodes_template(temp,3)];
        x = (-20:4:10)';
        y = (-10:4:20)';
        [x, y] = meshgrid(x,y);
        z = (min(nodes_template(:,a)) + max_nodes_length) .* ones(length(x(:,1)),1);
        k = 1;
        % Creates a temporary plane for icp alignment accuracy
        for n = 1:length(z)
            for m = 1:length(z)
                plane(k,:) = [x(m,n) y(m,n) z(1)];
                k = k + 1;
            end
        end

        nodes_template = [nodes_template(:,1) nodes_template(:,2) nodes_template(:,3);
            plane(:,1) plane(:,2) plane(:,3)];

        if bone_coord == 1
            nodes_template = center(nodes_template,1);
        end

        if nodes_template_length/5 > max_nodes_length
            tibfib_switch = 2; % under 1/5 tibia/fibula is available
            warning('Input bone is shorter than recommended.')
        else
            tibfib_switch = 1;
        end
    else
        tibfib_switch = 1; % over 1/5 tibia/fibula is available
    end
else
    tibfib_switch = 1; % over 1/5 tibia/fibula is available
end

% Similar process as above for cropped metatarsals
if bone_indx >= 8 && bone_indx <= 12
    nodes_template_length = (max(nodes_template(:,a)) - min(nodes_template(:,a)));
    if nodes_template_length/1.25 > max_nodes_length
        temp = find(nodes_template(:,2) < (min(nodes_template(:,a)) + max_nodes_length));
        nodes_template = [nodes_template(temp,1) nodes_template(temp,2) nodes_template(temp,3)];
        x = (-10:1:10)';
        z = (-10:1:10)';
        [x, z] = meshgrid(x,z);
        y = (min(nodes_template(:,a)) + max_nodes_length) .* ones(length(x(:,1)),1);
        k = 1;
        for n = 1:length(y)
            for m = 1:length(y)
                plane(k,:) = [x(m,n) y(1) z(m,n)];
                k = k + 1;
            end
        end

        nodes_template = [nodes_template(:,1) nodes_template(:,2) nodes_template(:,3);
            plane(:,1) plane(:,2) plane(:,3)];
    end
end

% Determines maximum axis of bone model and compares it to the template
multiplier = (max(nodes_template(:,a)) - min(nodes_template(:,a)))/(max(nodes(:,b)) - min(nodes(:,b)));
parttib_multiplier = (max(nodes_template(:,1)) - min(nodes_template(:,1)))/(max(nodes(:,1)) - min(nodes(:,1)));

% If the users model is smaller than the template, then this temporarly
% makes it a similar size to the template, for icp alignment accuracy
if multiplier > 1
    nodes = nodes*multiplier;
elseif parttib_multiplier > 1 && tibfib_switch == 2 && bone_indx >= 13
    nodes = nodes*parttib_multiplier;
end

%% Performing ICP alignment
% This is the initial alignment with no rotation. 
% Two different icp approaches are used, the first includeds the faces and
% the second is just the points.

format long g
iterations = 200;

% Rotations
r.r0 = eye(3);
% r.r0 = rotz(-40) * rotx(-20) *roty(-10);
r.rx = rotx(90);
r.rxx = rotx(180);
r.rxxx = rotx(270);
r.ry = roty(90);
r.ryy = roty(180);
r.ryyy = roty(270);
r.rz = rotz(90);
r.rzz = rotz(180);
r.rzzz = rotz(270);

r.rxy = rotx(90) * roty(90);
r.rxyy = rotx(90) * roty(180);
r.rxyyy = rotx(90) * roty(270);

r.rxxy = rotx(180) * roty(90);
r.rxxyy = rotx(180) * roty(180);
r.rxxyyy = rotx(180) * roty(270);

r.rxxxy = rotx(270) * roty(90);
r.rxxxyy = rotx(270) * roty(180);
r.rxxxyyy = rotx(270) * roty(270);

r.rxz = rotx(90) * rotz(90);
r.rxzz = rotx(90) * rotz(180);
r.rxzzz = rotx(90) * rotz(270);

r.rxxz = rotx(180) * rotz(90);
r.rxxzz = rotx(180) * rotz(180);
r.rxxzzz = rotx(180) * rotz(270);

r.rxxxz = rotx(270) * rotz(90);
r.rxxxzz = rotx(270) * rotz(180);
r.rxxxzzz = rotx(270) * rotz(270);

r.ryx = roty(90) * rotx(90);
r.ryxx = roty(90) * rotx(180);
r.ryxxx = roty(90) * rotx(270);

r.ryyx = roty(180) * rotx(90);
r.ryyxx = roty(180) * rotx(180);
r.ryyxxx = roty(180) * rotx(270);

r.ryyyx = roty(270) * rotx(90);
r.ryyyxx = roty(270) * rotx(180);
r.ryyyxxx = roty(270) * rotx(270);

r.ryz = roty(90) * rotz(90);
r.ryzz = roty(90) * rotz(180);
r.ryzzz = roty(90) * rotz(270);

r.ryyz = roty(180) * rotz(90);
r.ryyzz = roty(180) * rotz(180);
r.ryyzzz = roty(180) * rotz(270);

r.ryyyz = roty(270) * rotz(90);
r.ryyyzz = roty(270) * rotz(180);
r.ryyyzzz = roty(270) * rotz(270);

r.rzx = rotz(90) * rotx(90);
r.rzxx = rotz(90) * rotx(180);
r.rzxxx = rotz(90) * rotx(270);

r.rzzx = rotz(180) * rotx(90);
r.rzzxx = rotz(180) * rotx(180);
r.rzzxxx = rotz(180) * rotx(270);

r.rzzzx = rotz(270) * rotx(90);
r.rzzzxx = rotz(270) * rotx(180);
r.rzzzxxx = rotz(270) * rotx(270);

r.rzy = rotz(90) * roty(90);
r.rzyy = rotz(90) * roty(180);
r.rzyyy = rotz(90) * roty(270);

r.rzzy = rotz(180) * roty(90);
r.rzzyy = rotz(180) * roty(180);
r.rzzyyy = rotz(180) * roty(270);

r.rzzzy = rotz(270) * roty(90);
r.rzzzyy = rotz(270) * roty(180);
r.rzzzyyy = rotz(270) * roty(270);

fields = fieldnames(r);

if better_start == 2
    field_name = fields{1};
    [R_temp,T_temp,E_temp] = icp(nodes_template',nodes', iterations,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
    [Rwr_temp,Twr_temp,Ewr_temp] = icp(nodes_template',nodes', iterations,'Matching','kDtree','WorstRejection',0.1);
    if E_temp(end) < Ewr_temp(end)
        R.(field_name) = R_temp;
        T.(field_name) = T_temp;
        E.(field_name) = E_temp(end);
    else
        R.(field_name) = Rwr_temp;
        T.(field_name) = Twr_temp;
        E.(field_name) = Ewr_temp(end);
    end
end

if better_start == 1
    iterations_temp = 3;
    for n = 1:numel(fields)
        rot = r.(fields{n}); % Access each rotation matrix using the field name
        rotnodes = nodes*rot; % Multiple nodes by rotation matrix
        [~,~,error_temp] = icp(nodes_template',rotnodes', iterations_temp,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp); % Perform small ICP
        E_short.(fields{n}) = error_temp(end); % Save the lowest error
    end

    % Convert the structure 'E' to a cell array for easier sorting
    E_short_fields = fieldnames(E_short);
    E_short_values = struct2array(E_short);

    % Find the indices of the 5 smallest error values
    [~, idx_smallest] = mink(E_short_values, 5);

    % Get the 5 corresponding field names (rotation matrices)
    smallest_fields = E_short_fields(idx_smallest);

    % Rerun the loop with 200 iterations on the 5 smallest error rotations

    for i = 1:numel(smallest_fields)
        field_name = smallest_fields{i};  % Get the field name of the current rotation
        rot = r.(field_name);  % Access the corresponding rotation matrix
        rotnodes = nodes * rot;  % Multiply nodes by the rotation matrix
        [R_temp,T_temp,E_temp] = icp(nodes_template',rotnodes', iterations,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
        [Rwr_temp,Twr_temp,Ewr_temp] = icp(nodes_template',rotnodes', iterations,'Matching','kDtree','WorstRejection',0.1);
        if E_temp(end) < Ewr_temp(end)
            R.(field_name) = R_temp;
            T.(field_name) = T_temp;
            E.(field_name) = E_temp(end);
        else
            R.(field_name) = Rwr_temp;
            T.(field_name) = Twr_temp;
            E.(field_name) = Ewr_temp(end);
        end
    end
end

% Find the smallest error value and corresponding field name
E_values = struct2array(E);  % Convert the structure 'E' to a regular array of error values
E_fields = fieldnames(E);    % Get the list of field names from 'E'
[~, idx_smallest] = min(E_values);  % Find the index of the smallest error value
smallest_field = E_fields{idx_smallest};  % Get the corresponding field name

% Retrieve the corresponding R, T, and rotation matrix
best_R = R.(smallest_field);  % The best R matrix
best_T = T.(smallest_field);  % The best T vector
best_rotation_matrix = r.(smallest_field);  % The rotation matrix from the original structure

% Perform the final alignment calculation
aligned_nodes = (best_R * ((nodes*best_rotation_matrix)') + repmat(best_T, 1, length(nodes')))';  % Align the nodes

% Store the results for the final transformation
iflip = best_rotation_matrix;  % The rotation matrix used for alignment
iR = best_R;  % The best R matrix
iT = best_T;  % The best T vector

%% Additional alignments and adjustments
% This loop performs an alignment for the TT CS of the talus
if bone_indx == 1 && bone_coord >= 2
    [sR_talus,~,~] = icp(nodes_template2',nodes_template',25,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
    aligned_nodes = (sR_talus*(aligned_nodes'))';
else
    sR_talus = [];
end

% This undoes the enlargening of the users model
if multiplier > 1
    aligned_nodes = aligned_nodes/multiplier;
elseif parttib_multiplier > 1 && tibfib_switch == 2 && bone_indx >= 13
    aligned_nodes = aligned_nodes/parttib_multiplier;
end

% This ensures the tibial coordinate system is at the center of the tibial
% plafond
if (tibfib_switch == 1 && bone_indx == 13) || (tibfib_switch == 1 && bone_indx == 14)
    temp = find(aligned_nodes(:,3) < 150);
    nodes_test = [aligned_nodes(temp,1) aligned_nodes(temp,2) aligned_nodes(temp,3)];
    x = (-20:4:20)';
    y = (-20:4:20)';
    [x, y] = meshgrid(x,y);
    z = (max(nodes_test(:,3))) .* ones(length(x(:,1)),1);
    k = 1;
    for n = 1:length(z)
        for m = 1:length(z)
            plane(k,:) = [x(m,n) y(m,n) z(1)];
            k = k + 1;
        end
    end

    nodes_test1 = [nodes_test(:,1) nodes_test(:,2) nodes_test(:,3);
        plane(:,1) plane(:,2) plane(:,3)];

    nodes_test2 = nodes_test1*rotz(90);
    nodes_test3 = nodes_test1*rotz(180);
    nodes_test4 = nodes_test1*rotz(270);

    [Rtw1,Ttw1,Etw1] = icp(nodes_template',nodes_test1', iterations,'Matching','kDtree','WorstRejection',0.1);

    if better_start == 1
        [Rtw2,Ttw2,Etw2] = icp(nodes_template',nodes_test2', iterations,'Matching','kDtree','WorstRejection',0.1);
        [Rtw3,Ttw3,Etw3] = icp(nodes_template',nodes_test3', iterations,'Matching','kDtree','WorstRejection',0.1);
        [Rtw4,Ttw4,Etw4] = icp(nodes_template',nodes_test4', iterations,'Matching','kDtree','WorstRejection',0.1);
        Etw = min([Etw1(end),Etw2(end),Etw3(end),Etw4(end)]);
    else
        Etw = min([Etw1(end)]);
    end

    if Etw == Etw1(end)
        if better_start == 1
            sflip = [1 0 0; 0 1 0; 0 0 1];
            aligned_nodes = (Rtw1*(aligned_nodes') + repmat(Ttw1,1,length(aligned_nodes')))';
            sR_tibia= Rtw1;
            sT_tibia = Ttw1;
        else
            sflip = [1 0 0; 0 1 0; 0 0 1];
            aligned_nodes = (aligned_nodes' + repmat(Ttw1,1,length(aligned_nodes')))';
            sR_tibia= Rtw1;
            sT_tibia = Ttw1;
        end
    elseif Etw == Etw2(end)
        sflip = rotz(90);
        aligned_nodes = aligned_nodes*rotz(90);
        aligned_nodes = (Rtw2*(aligned_nodes') + repmat(Ttw2,1,length(aligned_nodes')))';
        sR_tibia= Rtw2;
        sT_tibia= Ttw2;
    elseif Etw == Etw3(end)
        sflip = rotz(180);
        aligned_nodes = aligned_nodes*rotz(180);
        aligned_nodes = (Rtw3*(aligned_nodes') + repmat(Ttw3,1,length(aligned_nodes')))';
        sR_tibia= Rtw3;
        sT_tibia= Ttw3;
    elseif Etw == Etw4(end)
        sflip = rotz(270);
        aligned_nodes = aligned_nodes*rotz(270);
        aligned_nodes = (Rtw4*(aligned_nodes') + repmat(Ttw4,1,length(aligned_nodes')))';
        sR_tibia= Rtw4;
        sT_tibia= Ttw4;
    end
else
    sR_tibia= [];
    sT_tibia= [];
    sflip = [];
end

if bone_indx == 14
    sR_fibula = sR_tibia;
    sT_fibula = sT_tibia;
    sR_tibia= [];
    sT_tibia= [];
else
    sR_fibula = [];
    sT_fibula = [];
end

if bone_indx >= 8 && bone_indx <= 12
    [aligned_nodes,cm_meta] = center(aligned_nodes,1);
else
    cm_meta = [];
end

%% Combine all rotation and translation matricies
RTs.iflip = iflip; % initial flip flip_out
RTs.sflip = sflip; % secondary flip (for tibia) tib_flip
RTs.iR = iR; % initial rotation Rot
RTs.iT = iT; %initial translation Tra
RTs.sR_talus = sR_talus; % secondary rotation (for talus) Rr
RTs.sR_tibia = sR_tibia; % secondary rotation (for tibia) Rtw
RTs.sT_tibia = sT_tibia; % secondary translation (for tibia) Ttw
RTs.sR_fibula = sR_fibula; % secondary rotation (for fibula) Rtw
RTs.sT_fibula = sT_fibula; % secondary translation (for fibula) Ttw
RTs.cm_meta = cm_meta; % centering metatarsals cm_meta
RTs.red = [];
RTs.yellow = [];

%% Visualize proper alignment
% figure()
% if bone_indx == 1 && bone_coord >= 2
%     plot3(nodes_template2(:,1),nodes_template2(:,2),nodes_template2(:,3),'.k')
% else
%     plot3(nodes_template(:,1),nodes_template(:,2),nodes_template(:,3),'.k')
% end
% hold on
% plot3(aligned_nodes(:,1),aligned_nodes(:,2),aligned_nodes(:,3),'.b')
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal
