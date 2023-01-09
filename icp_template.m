function [aligned_nodes, RTs] = icp_template(bone_indx,nodes,bone_coord,better_start)
% This function aligned the user input bone to a predefined template bone.
% It requires the bone index bone to identify which bone was chosen
% (bone_indx), the bone nodal points (nodes), the coordinate system chosen
% by the user (bone_coord), and a logical value for the user manually
% choosing a better starting point the icp code doesn't undo the chosen
% position.

%% Read in Template Bone
addpath('Template_Bones')
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
elseif bone_indx == 4
    TR_template = stlread('Cuboid_Template.stl');
    a = 2;
elseif bone_indx == 5
    TR_template = stlread('Medial_Cuneiform_Template.stl');
    a = 3;
elseif bone_indx == 6
    TR_template = stlread('Intermediate_Cuneiform_Template.stl');
    a = 3;
elseif bone_indx == 7
    TR_template = stlread('Lateral_Cuneiform_Template.stl');
    a = 3;
elseif bone_indx == 8
    TR_template = stlread('Metatarsal1_Template.stl');
    a = 2;
elseif bone_indx == 9
    TR_template = stlread('Metatarsal2_Template.stl');
    a = 2;
elseif bone_indx == 10
    TR_template = stlread('Metatarsal3_Template.stl');
    a = 2;
elseif bone_indx == 11
    TR_template = stlread('Metatarsal4_Template.stl');
    a = 2;
elseif bone_indx == 12
    TR_template = stlread('Metatarsal5_Template.stl');
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


%% Adjusting the cropped/smaller models
% Creates similar sized models for cropped tibia or fibula
if bone_indx == 13 || bone_indx == 14
    nodes_template_length = (max(nodes_template(:,a)) - min(nodes_template(:,a)));
    max_nodes_x = (max(nodes(:,1)) - min(nodes(:,1)));
    max_nodes_y = (max(nodes(:,2)) - min(nodes(:,2)));
    max_nodes_z = (max(nodes(:,3)) - min(nodes(:,3)));
    max_nodes_length = max([max_nodes_x  max_nodes_y max_nodes_z]);
    if nodes_template_length/2 > max_nodes_length % Determines if the user's model is half the length of the template model
        temp = find(nodes_template(:,3) < (min(nodes_template(:,a)) + max_nodes_length));
        nodes_template = [nodes_template(temp,1) nodes_template(temp,2) nodes_template(temp,3)];
        x = [-20:4:10]';
        y = [-10:4:20]';
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
    max_nodes_length = max([(max(nodes(:,1)) - min(nodes(:,1))) (max(nodes(:,2)) - min(nodes(:,2))) (max(nodes(:,3)) - min(nodes(:,3)))]);
    if nodes_template_length/1.25 > max_nodes_length
        temp = find(nodes_template(:,2) < (min(nodes_template(:,a)) + max_nodes_length));
        nodes_template = [nodes_template(temp,1) nodes_template(temp,2) nodes_template(temp,3)];
        x = [-10:1:10]';
        z = [-10:1:10]';
        [x z] = meshgrid(x,z);
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
multiplier = (max(nodes_template(:,a)) - min(nodes_template(:,a)))/(max(nodes(:,a)) - min(nodes(:,a)));
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

iterations = 200;
[R1,T1,ER1] = icp(nodes_template',nodes', iterations,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
[R1_0,T1_0,ER1_0] = icp(nodes_template',nodes', iterations,'Matching','kDtree','WorstRejection',0.1);

if better_start == 1
    
    % The users model is rotated about the z axis and realigned
    nodesz90 = nodes*rotz(90);
    nodesz180 = nodes*rotz(180);
    nodesz270 = nodes*rotz(270);

    [Rz90,Tz90,ERz90] = icp(nodes_template',nodesz90', iterations,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
    [Rz90_wr,Tz90_wr,ERz90_wr] = icp(nodes_template',nodesz90', iterations,'Matching','kDtree','WorstRejection',0.1);
    [Rz180,Tz180,ERz180] = icp(nodes_template',nodesz180', iterations,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
    [Rz180_wr,Tz180_wr,ERz180_wr] = icp(nodes_template',nodesz180', iterations,'Matching','kDtree','WorstRejection',0.1);
    [Rz270,Tz270,ERz270] = icp(nodes_template',nodesz270', iterations,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
    [Rz270_wr,Tz270_wr,ERz270_wr] = icp(nodes_template',nodesz270', iterations,'Matching','kDtree','WorstRejection',0.1);

    % The users model is rotated about the y axis and realigned
    nodesy90 = nodes*roty(90);
    nodesy180 = nodes*roty(180);
    nodesy270 = nodes*roty(270);

    [Ry90,Ty90,ERy90] = icp(nodes_template',nodesy90', iterations,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
    [Ry90_wr,Ty90_wr,ERy90_wr] = icp(nodes_template',nodesy90', iterations,'Matching','kDtree','WorstRejection',0.1);
    [Ry180,Ty180,ERy180] = icp(nodes_template',nodesy180', iterations,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
    [Ry180_wr,Ty180_wr,ERy180_wr] = icp(nodes_template',nodesy180', iterations,'Matching','kDtree','WorstRejection',0.1);
    [Ry270,Ty270,ERy270] = icp(nodes_template',nodesy270', iterations,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
    [Ry270_wr,Ty270_wr,ERy270_wr] = icp(nodes_template',nodesy270', iterations,'Matching','kDtree','WorstRejection',0.1);

    % The users model is rotated about the x axis and realigned
    nodesx90 = nodes*rotx(90);
    nodesx180 = nodes*rotx(180);
    nodesx270 = nodes*rotx(270);

    [Rx90,Tx90,ERx90] = icp(nodes_template',nodesx90', iterations,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
    [Rx90_wr,Tx90_wr,ERx90_wr] = icp(nodes_template',nodesx90', iterations,'Matching','kDtree','WorstRejection',0.1);
    [Rx180,Tx180,ERx180] = icp(nodes_template',nodesx180', iterations,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
    [Rx180_wr,Tx180_wr,ERx180_wr] = icp(nodes_template',nodesx180', iterations,'Matching','kDtree','WorstRejection',0.1);
    [Rx270,Tx270,ERx270] = icp(nodes_template',nodesx270', iterations,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
    [Rx270_wr,Tx270_wr,ERx270_wr] = icp(nodes_template',nodesx270', iterations,'Matching','kDtree','WorstRejection',0.1);

    % All errors are stored in this matrix
    ER_all = [ER1(end),ER1_0(end),ERz90(end),ERz90_wr(end),ERz180(end),ERz180_wr(end),ERz270(end),ERz270_wr(end),...
        ERy90(end),ERy90_wr(end),ERy180(end),ERy180_wr(end),ERy270(end),ERy270_wr(end),...
        ERx90(end),ERx90_wr(end),ERx180(end),ERx180_wr(end),ERx270(end),ERx270_wr(end)];
else
    ER_all = [ER1(end),ER1_0(end)];
end

format long g
ER_min = min(ER_all);

% The minimum error out of all of the alignment steps is used moving
% forward to determine the most accurately aligned model.
if ER1(end) == ER_min
    aligned_nodes = (R1*(nodes') + repmat(T1,1,length(nodes')))';
    iflip = [1 0 0; 0 1 0; 0 0 1];
    iR = R1; 
    iT= T1;
elseif ER1_0(end) == ER_min
    aligned_nodes = (R1_0*(nodes') + repmat(T1_0,1,length(nodes')))';
    iflip = [1 0 0; 0 1 0; 0 0 1];
    iR = R1_0;
    iT= T1_0;
elseif ERz90(end) == ER_min
    aligned_nodes = (Rz90*(nodesz90') + repmat(Tz90,1,length(nodesz90')))';
    iflip = rotz(90);
    iR = Rz90;
    iT= Tz90;
elseif ERz90_wr(end) == ER_min
    aligned_nodes = (Rz90_wr*(nodesz90') + repmat(Tz90_wr,1,length(nodesz90')))';
    iflip = rotz(90);
    iR = Rz90_wr;
    iT= Tz90_wr;
elseif ERz180(end) == ER_min
    aligned_nodes = (Rz180*(nodesz180') + repmat(Tz180,1,length(nodesz180')))';
    iflip = rotz(180);
    iR = Rz180;
    iT= Tz180;
elseif ERz180_wr(end) == ER_min
    aligned_nodes = (Rz180_wr*(nodesz180') + repmat(Tz180_wr,1,length(nodesz180')))';
    iflip = rotz(180);
    iR = Rz180_wr;
    iT= Tz180_wr;
elseif ERz270(end) == ER_min
    aligned_nodes = (Rz270*(nodesz270') + repmat(Tz270,1,length(nodesz270')))';
    iflip = rotz(270);
    iR = Rz270;
    iT= Tz270;
elseif ERz270_wr(end) == ER_min
    aligned_nodes = (Rz270_wr*(nodesz270') + repmat(Tz270_wr,1,length(nodesz270')))';
    iflip = rotz(270);
    iR = Rz270_wr;
    iT= Tz270_wr;
elseif ERy90(end) == ER_min
    aligned_nodes = (Ry90*(nodesy90') + repmat(Ty90,1,length(nodesy90')))';
    iflip = roty(90);
    iR = Ry90;
    iT= Ty90;
elseif ERy90_wr(end) == ER_min
    aligned_nodes = (Ry90_wr*(nodesy90') + repmat(Ty90_wr,1,length(nodesy90')))';
    iflip = roty(90);
    iR = Ry90_wr;
    iT= Ty90_wr;
elseif ERy180(end) == ER_min
    aligned_nodes = (Ry180*(nodesy180') + repmat(Ty180,1,length(nodesy180')))';
    iflip = roty(180);
    iR = Ry180;
    iT= Ty180;
elseif ERy180_wr(end) == ER_min
    aligned_nodes = (Ry180_wr*(nodesy180') + repmat(Ty180_wr,1,length(nodesy180')))';
    iflip = roty(180);
    iR = Ry180_wr;
    iT= Ty180_wr;
elseif ERy270(end) == ER_min
    aligned_nodes = (Ry270*(nodesy270') + repmat(Ty270,1,length(nodesy270')))';
    iflip = roty(270);
    iR = Ry270;
    iT= Ty270;
elseif ERy270_wr(end) == ER_min
    aligned_nodes = (Ry270_wr*(nodesy270') + repmat(Ty270_wr,1,length(nodesy270')))';
    iflip = roty(270);
    iR = Ry270_wr;
    iT= Ty270_wr;
elseif ERx90(end) == ER_min
    aligned_nodes = (Rx90*(nodesx90') + repmat(Tx90,1,length(nodesx90')))';
    iflip = rotx(90);
    iR = Rx90;
    iT= Tx90;
elseif ERx90_wr(end) == ER_min
    aligned_nodes = (Rx90_wr*(nodesx90') + repmat(Tx90_wr,1,length(nodesx90')))';
    iflip = rotx(90);
    iR = Rx90_wr;
    iT= Tx90_wr;
elseif ERx180(end) == ER_min
    aligned_nodes = (Rx180*(nodesx180') + repmat(Tx180,1,length(nodesx180')))';
    iflip = rotx(180);
    iR = Rx180;
    iT= Tx180;
elseif ERx180_wr(end) == ER_min
    aligned_nodes = (Rx180_wr*(nodesx180') + repmat(Tx180_wr,1,length(nodesx180')))';
    iflip = rotx(180);
    iR = Rx180_wr;
    iT= Tx180_wr;
elseif ERx270(end) == ER_min
    aligned_nodes = (Rx270*(nodesx270') + repmat(Tx270,1,length(nodesx270')))';
    iflip = rotx(270);
    iR = Rx270;
    iT= Tx270;
elseif ERx270_wr(end) == ER_min
    aligned_nodes = (Rx270_wr*(nodesx270') + repmat(Tx270_wr,1,length(nodesx270')))';
    iflip = rotx(270);
    iR = Rx270_wr;
    iT= Tx270_wr;
end

% This loop performs an alignment for the TT CS of the talus
if bone_indx == 1 && bone_coord == 2
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
    x = [-20:4:20]';
    y = [-20:4:20]';
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
    [Rtw2,Ttw2,Etw2] = icp(nodes_template',nodes_test2', iterations,'Matching','kDtree','WorstRejection',0.1);
    [Rtw3,Ttw3,Etw3] = icp(nodes_template',nodes_test3', iterations,'Matching','kDtree','WorstRejection',0.1);
    [Rtw4,Ttw4,Etw4] = icp(nodes_template',nodes_test4', iterations,'Matching','kDtree','WorstRejection',0.1);

    Etw = min([Etw1(end),Etw2(end),Etw3(end),Etw4(end)]);

    if Etw == Etw1(end)
        sflip = [1 0 0; 0 1 0; 0 0 1];
        aligned_nodes = (Rtw1*(aligned_nodes') + repmat(Ttw1,1,length(aligned_nodes')))';
        sR_tibia= Rtw1;
        sT_tibia = Ttw1;
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
% plot3(aligned_nodes(:,1),aligned_nodes(:,2),aligned_nodes(:,3),'.g')
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

