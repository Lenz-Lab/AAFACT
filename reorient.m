function [nodes_final, coords_final, coords_final_unit, Temp_Coordinates_Unit] = reorient(Temp_Nodes,Temp_Coordinates,cm_nodes,side_indx,RTs)
% The function reorients the aligned bone and subsequent coordinate system
% back to the bones original orientation.
% It requires the nodes and coordinate systems, as well as the rotation and
% translation matricies.


Temp_Coordinates_origin = Temp_Coordinates(1,:);
Temp_Coordinates_temp = Temp_Coordinates - Temp_Coordinates_origin;
Temp_Coordinates_temp = [0 0 0; Temp_Coordinates_temp(2,:)./norm(Temp_Coordinates_temp(2,:));
    0 0 0; Temp_Coordinates_temp(4,:)./norm(Temp_Coordinates_temp(4,:));
    0 0 0; Temp_Coordinates_temp(6,:)./norm(Temp_Coordinates_temp(6,:));];
Temp_Coordinates_Unit = Temp_Coordinates_temp + Temp_Coordinates_origin;

if side_indx == 1
    axang = [Temp_Coordinates(2,:) pi];
    ML_180 = axang2rotm(axang);

    Temp_Coordinates = [Temp_Coordinates(1:5,:)
        Temp_Coordinates(6,:)*ML_180];
end

if isempty(RTs.sR_talus) == 0
    nodes_final_i4 = (inv(RTs.sR_talus)*(Temp_Nodes'))';
    coords_final_i4 = (inv(RTs.sR_talus)*(Temp_Coordinates'))';
elseif isempty(RTs.sT_tibia) == 0
    nodes_final_i6 = (Temp_Nodes' - repmat(RTs.sT_tibia,1,length(Temp_Nodes')))';
    nodes_final_i5 = (inv(RTs.sR_tibia)*(nodes_final_i6'))';
    nodes_final_i4 = ((nodes_final_i5)*inv(RTs.sflip));

    coords_final_i6 = (Temp_Coordinates' - repmat(RTs.sT_tibia,1,length(Temp_Coordinates')))';
    coords_final_i5 = (inv(RTs.sR_tibia)*(coords_final_i6'))';
    coords_final_i4 = ((coords_final_i5)*inv(RTs.sflip));
elseif isempty(RTs.sT_fibula) == 0
    nodes_final_i6 = (Temp_Nodes' - repmat(RTs.sT_fibula,1,length(Temp_Nodes')))';
    nodes_final_i5 = (inv(RTs.sR_fibula)*(nodes_final_i6'))';
    nodes_final_i4 = ((nodes_final_i5)*inv(RTs.sflip));

    coords_final_i6 = (Temp_Coordinates' - repmat(RTs.sT_fibula,1,length(Temp_Coordinates')))';
    coords_final_i5 = (inv(RTs.sR_fibula)*(coords_final_i6'))';
    coords_final_i4 = ((coords_final_i5)*inv(RTs.sflip));
elseif isempty(RTs.cm_meta) == 0
    nodes_final_i4 = [Temp_Nodes(:,1) + RTs.cm_meta(1), Temp_Nodes(:,2) + RTs.cm_meta(2), Temp_Nodes(:,3) + RTs.cm_meta(3)];
    coords_final_i4 = [Temp_Coordinates(:,1) + RTs.cm_meta(1), Temp_Coordinates(:,2) + RTs.cm_meta(2), Temp_Coordinates(:,3) + RTs.cm_meta(3)];
else
    nodes_final_i4 = Temp_Nodes;
    coords_final_i4 = Temp_Coordinates;
end

nodes_final_i3 = (nodes_final_i4' - repmat(RTs.iT,1,length(nodes_final_i4')))';
nodes_final_i2 = (inv(RTs.iR)*(nodes_final_i3'))';
nodes_final_i1 = ((nodes_final_i2)*inv(RTs.iflip));

coords_final_i3 = (coords_final_i4' - repmat(RTs.iT,1,length(coords_final_i4')))';
coords_final_i2 = (inv(RTs.iR)*(coords_final_i3'))';
coords_final_i1 = ((coords_final_i2)*inv(RTs.iflip));

if isempty(RTs.red) == 0
    nodes_final_i1_red = (inv(RTs.red)*(nodes_final_i1'))';
    nodes_final_i1 = (inv(RTs.yellow)*(nodes_final_i1_red'))';

    coords_final_i1_red = (inv(RTs.red)*(coords_final_i1'))';
    coords_final_i1 = (inv(RTs.yellow)*(coords_final_i1_red'))';
end

nodes_final_i1 = center(nodes_final_i1,1);
coords_final_i1 = center(coords_final_i1,2);

nodes_final = [nodes_final_i1(:,1) + cm_nodes(1), nodes_final_i1(:,2) + cm_nodes(2), nodes_final_i1(:,3) + cm_nodes(3)];
coords_final = cm_nodes + coords_final_i1(:,:);

if side_indx == 1
    nodes_final = nodes_final.*[1,1,-1]; % Flip back to right if applicable
    coords_final = coords_final.*[1,1,-1]; % Flip back to right if applicable
%     conlist = [conlist(:,3) conlist(:,2) conlist(:,1)];
end

coods_final_origin = coords_final(1,:);
coords_final_temp = coords_final - coods_final_origin;
coords_final_temp = [0 0 0; coords_final_temp(2,:)./norm(coords_final_temp(2,:));
    0 0 0; coords_final_temp(4,:)./norm(coords_final_temp(4,:));
    0 0 0; coords_final_temp(6,:)./norm(coords_final_temp(6,:));];
coords_final_unit = coords_final_temp + coods_final_origin;


%%
% figure()
% plot3(nodes_final(:,1),nodes_final(:,2),nodes_final(:,3),'.k')
% hold on
% plot3(nodes_original(:,1),nodes_original(:,2),nodes_original(:,3),'ob')
% plot3(nodes_final_i1(:,1),nodes_final_i1(:,2),nodes_final_i1(:,3),'or')
% plot3(coords_final(1:2,1),coords_final(1:2,2),coords_final(1:2,3),'r-')
% plot3(coords_final(3:4,1),coords_final(3:4,2),coords_final(3:4,3),'b-')
% plot3(coords_final(5:6,1),coords_final(5:6,2),coords_final(5:6,3),'g-')
% plot3(coords_final_i1(1:2,1),coords_final_i1(1:2,2),coords_final_i1(1:2,3),'r-')
% plot3(coords_final_i1(3:4,1),coords_final_i1(3:4,2),coords_final_i1(3:4,3),'b-')
% plot3(coords_final_i1(5:6,1),coords_final_i1(5:6,2),coords_final_i1(5:6,3),'g-')
% plot3(nodes_final_i1(:,1),nodes_final_i1(:,2),nodes_final_i1(:,3),'og')
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal
