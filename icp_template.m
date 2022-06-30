function [aligned_nodes, flip_out, tibfib_switch] = icp_template(bone_indx,nodes,bone_coord)

if bone_indx == 1 && bone_coord == 1
    TR_template = stlread('Talus_Template.stl');
    nodes_template = TR_template.Points;
    con_temp = TR_template.ConnectivityList;
    a = 2;
elseif bone_indx == 1 && bone_coord == 2
    TR_template = stlread('Talus_Template2.stl');
    nodes_template = TR_template.Points;
    con_temp = TR_template.ConnectivityList;
    a = 2;
elseif bone_indx == 2
    TR_template = stlread('Calcaneus_Template.stl');
    nodes_template = TR_template.Points;
    con_temp = TR_template.ConnectivityList;
    a = 2;
elseif bone_indx == 3
    TR_template = stlread('Navicular_Template.stl');
    nodes_template = TR_template.Points;
    con_temp = TR_template.ConnectivityList;
    a = 1;
elseif bone_indx == 4
    TR_template = stlread('Cuboid_Template.stl');
    nodes_template = TR_template.Points;
    con_temp = TR_template.ConnectivityList;
    a = 2;
elseif bone_indx == 5
    TR_template = stlread('Medial_Cuneiform_Template.stl');
    nodes_template = TR_template.Points;
    con_temp = TR_template.ConnectivityList;
    a = 3;
elseif bone_indx == 6
    TR_template = stlread('Intermediate_Cuneiform_Template.stl');
    nodes_template = TR_template.Points;
    con_temp = TR_template.ConnectivityList;
    a = 3;
elseif bone_indx == 7
    TR_template = stlread('Lateral_Cuneiform_Template.stl');
    nodes_template = TR_template.Points;
    con_temp = TR_template.ConnectivityList;
    a = 3;
elseif bone_indx == 13 && bone_coord == 1
    TR_template = stlread('Tibia_Template.stl');
    nodes_template = TR_template.Points;
    con_temp = TR_template.ConnectivityList;
    a = 3;
elseif bone_indx == 13 && bone_coord == 2
    TR_template = stlread('Tibia_Template_Facet.stl');
    nodes_template = TR_template.Points;
    con_temp = TR_template.ConnectivityList;
    a = 3;
elseif bone_indx == 14 && bone_coord == 1
    TR_template = stlread('Fibula_Template.stl');
    nodes_template = TR_template.Points;
    con_temp = TR_template.ConnectivityList;
    a = 3;
elseif bone_indx == 14 && bone_coord == 2
    TR_template = stlread('Fibula_Template_Facet.stl');
    nodes_template = TR_template.Points;
    con_temp = TR_template.ConnectivityList;
    a = 3;
end

if bone_indx == 13 || bone_indx == 14
    nodes_template_length = (max(nodes_template(:,a)) - min(nodes_template(:,a)));
    max_nodes_length = max([(max(nodes(:,1)) - min(nodes(:,1))) (max(nodes(:,2)) - min(nodes(:,2))) (max(nodes(:,3)) - min(nodes(:,3)))]);
    if nodes_template_length/2 > max_nodes_length
        temp = find(nodes_template(:,3) < (min(nodes_template(:,a)) + max_nodes_length));
        nodes_template = [nodes_template(temp,1) nodes_template(temp,2) nodes_template(temp,3)];
        x = [-20:4:10]';
        y = [-10:4:20]';
        [x y] = meshgrid(x,y);
        z = (min(nodes_template(:,a)) + max_nodes_length) .* ones(length(x(:,1)),1);
        k = 1;
        for n = 1:length(z)
            for m = 1:length(z)
                plane(k,:) = [x(m,n) y(m,n) z(1)];
                k = k + 1;
            end
        end

        figure()
        plot3(nodes_template(:,1),nodes_template(:,2),nodes_template(:,3),'.k')
        hold on
        %         plot3(plane(:,1),plane(:,2),plane(:,3),'.r')
        %         plot3(x,y,z,'.r')
        axis equal
        xlabel('X')

        nodes_template = [nodes_template(:,1) nodes_template(:,2) nodes_template(:,3);
            plane(:,1) plane(:,2) plane(:,3)];

        cm_x = mean(nodes_template(:,1));
        cm_y = mean(nodes_template(:,2));
        cm_z = mean(nodes_template(:,3));

        % cm = [cm_x cm_y cm_z];

        input_ox = nodes_template(:,1) - cm_x;
        input_oy = nodes_template(:,2) - cm_y;
        input_oz = nodes_template(:,3) - cm_z;

        centered_nodes_template = [input_ox input_oy input_oz];
        nodes_template = centered_nodes_template;
        tibfib_switch = 2;

        %         figure()
        %         plot3(centered_nodes_template(:,1),centered_nodes_template(:,2),centered_nodes_template(:,3),'.k')
        %         hold on
        %         %         plot3(plane(:,1),plane(:,2),plane(:,3),'.r')
        %         %         plot3(x,y,z,'.r')
        %         axis equal
        %         xlabel('X')
    else
        [R_temp,T_temp] = icp(nodes_template',nodes',200,'Matching','kDtree');
        nodes = (R_temp*(nodes') + repmat(T_temp,1,length(nodes')))';
        nodes_template = [nodes_template(nodes_template(:,3)<100,1) nodes_template(nodes_template(:,3)<100,2) nodes_template(nodes_template(:,3)<100,3)];
        nodes = [nodes(nodes(:,3)<100,1) nodes(nodes(:,3)<100,2) nodes(nodes(:,3)<100,3)];
        tibfib_switch = 1;
    end
else
    tibfib_switch = 1;
end



multiplier = (max(nodes_template(:,a)) - min(nodes_template(:,a)))/(max(nodes(:,a)) - min(nodes(:,a)));
if multiplier > 1
    nodes = nodes*multiplier;
end

[R1,T1,ER1] = icp(nodes_template',nodes',200,'Matching','kDtree');
temp_nodes = (R1*(nodes') + repmat(T1,1,length(nodes')))';
nodesz = temp_nodes*[-1 0 0; 0 -1 0; 0 0 1];
[R2,T2,ER2] = icp(nodes_template',nodesz',200,'Matching','kDtree');
nodesy = temp_nodes*[-1 0 0; 0 1 0; 0 0 -1];
[R3,T3,ER3] = icp(nodes_template',nodesy',200,'Matching','kDtree');
nodesx = temp_nodes*[1 0 0; 0 -1 0; 0 0 -1];
[R4,T4,ER4] = icp(nodes_template',nodesx',200,'Matching','kDtree');

if exist('ER4','var') && ER4(end,:) < ER3(end,:) && ER4(end,:) < ER2(end,:) && ER4(end,:) < ER1(end,:)
    aligned_nodes = (R4*(nodesx') + repmat(T4,1,length(nodesx')))';
    flip_out = [1 0 0; 0 -1 0; 0 0 -1];
elseif exist('ER3','var') && ER3(end,:) < ER2(end,:) && ER3(end,:) < ER1(end,:)
    aligned_nodes = (R3*(nodesy') + repmat(T3,1,length(nodesy')))';
    flip_out = [-1 0 0; 0 -1 0; 0 0 1];
elseif exist('ER2','var') && ER2(end,:) < ER1(end,:)
    aligned_nodes = (R2*(nodesz') + repmat(T2,1,length(nodesz')))';
    flip_out = [-1 0 0; 0 -1 0; 0 0 1];
else
    aligned_nodes = temp_nodes;
    flip_out = [1 0 0; 0 1 0; 0 0 1];
end

if multiplier > 1
    aligned_nodes = aligned_nodes/multiplier;
end

figure()
plot3(nodes_template(:,1),nodes_template(:,2),nodes_template(:,3),'.k')
hold on
plot3(aligned_nodes(:,1),aligned_nodes(:,2),aligned_nodes(:,3),'og')
% % plot3(nodes(:,1),nodes(:,2),nodes(:,3),'.r')
% % plot3(aligned_nodes(:,1),aligned_nodes(:,2),aligned_nodes(:,3),'.g')
% % plot3(aligned_nodes(anterior_point,1),aligned_nodes(anterior_point,2),aligned_nodes(anterior_point,3),'r.','MarkerSize',100)
% % plot3(aligned_nodes(medial_point,1),aligned_nodes(medial_point,2),aligned_nodes(medial_point,3),'g.','MarkerSize',100)
% % plot3(aligned_nodes(superior_point,1),aligned_nodes(superior_point,2),aligned_nodes(superior_point,3),'b.','MarkerSize',100)
% legend('template','new nodes','anterior','medial','superior')
xlabel('X')
ylabel('Y')
zlabel('Z')
axis equal