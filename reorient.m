function [nodes_final, coords_final, coords_final_unit, Temp_Coordinates_Unit, MDTA_final, TLSA_final, SVA_final] = reorient(Temp_Nodes_Coords,cm_nodes,side_indx,RTs)
% The function reorients the aligned bone and subsequent coordinate system
% back to the bones original orientation.
% It requires the nodes and coordinate systems, as well as the rotation and
% translation matricies.


Temp_Coordinates_origin = Temp_Nodes_Coords(end-10,:);
Temp_Coordinates_temp = Temp_Nodes_Coords(end-10:end-5,:) - Temp_Coordinates_origin;
Temp_Coordinates_temp = [0 0 0; Temp_Coordinates_temp(2,:)./norm(Temp_Coordinates_temp(2,:));
    0 0 0; Temp_Coordinates_temp(4,:)./norm(Temp_Coordinates_temp(4,:));
    0 0 0; Temp_Coordinates_temp(6,:)./norm(Temp_Coordinates_temp(6,:));];
Temp_Coordinates_Unit = Temp_Coordinates_temp + Temp_Coordinates_origin;

if isempty(RTs.sR_talus) == 0
    nodes_coords_final_i4 = ((RTs.sR_talus)\(Temp_Nodes_Coords'))';
elseif isempty(RTs.sT_tibia) == 0
    nodes_coords_final_i6 = (Temp_Nodes_Coords' - repmat(RTs.sT_tibia,1,length(Temp_Nodes_Coords')))';
    nodes_coords_final_i5 = ((RTs.sR_tibia)\(nodes_coords_final_i6'))';
    nodes_coords_final_i4 = ((nodes_coords_final_i5)/(RTs.sflip));
elseif isempty(RTs.sT_fibula) == 0
    nodes_coords_final_i6 = (Temp_Nodes_Coords' - repmat(RTs.sT_fibula,1,length(Temp_Nodes_Coords')))';
    nodes_coords_final_i5 = ((RTs.sR_fibula)\(nodes_coords_final_i6'))';
    nodes_coords_final_i4 = ((nodes_coords_final_i5)/(RTs.sflip));
elseif isempty(RTs.cm_meta) == 0
    nodes_coords_final_i4 = [Temp_Nodes_Coords(:,1) + RTs.cm_meta(1), Temp_Nodes_Coords(:,2) + RTs.cm_meta(2), Temp_Nodes_Coords(:,3) + RTs.cm_meta(3)];
else
    nodes_coords_final_i4 = Temp_Nodes_Coords;
end

nodes_coords_final_i3 = (nodes_coords_final_i4' - repmat(RTs.iT,1,length(nodes_coords_final_i4')))';
nodes_coords_final_i2 = ((RTs.iR)\(nodes_coords_final_i3'))';
nodes_coords_final_i1 = ((nodes_coords_final_i2)/(RTs.iflip));

if isempty(RTs.red) == 0
    nodes_coords_final_i1_red = ((RTs.red)\(nodes_coords_final_i1'))';
    nodes_coords_final_i1 = ((RTs.yellow)\(nodes_coords_final_i1_red'))';
end

[nodes_coords_final_i1, ~] = center(nodes_coords_final_i1,1);

nodes_coords_final = [nodes_coords_final_i1(:,1) + cm_nodes(1), nodes_coords_final_i1(:,2) + cm_nodes(2), nodes_coords_final_i1(:,3) + cm_nodes(3)];

if side_indx == 1
    nodes_coords_final = nodes_coords_final.*[1,1,-1]; % Flip back to right if applicable
end

MDTA_final = nodes_coords_final(end-4:end-3,:);
TLSA_final = nodes_coords_final(end-2:end-1,:);
SVA_final = nodes_coords_final(end,:);

nodes_coords_final = nodes_coords_final(1:end-5,:);

coods_final_origin = nodes_coords_final(end-1,:);
coords_final_temp = nodes_coords_final(end-5:end,:) - coods_final_origin;
coords_final_temp = [0 0 0; coords_final_temp(2,:)./norm(coords_final_temp(2,:));
    0 0 0; coords_final_temp(4,:)./norm(coords_final_temp(4,:));
    0 0 0; coords_final_temp(6,:)./norm(coords_final_temp(6,:));];
coords_final_unit = coords_final_temp + coods_final_origin;

nodes_final = nodes_coords_final(1:end-6,:);
coords_final = nodes_coords_final(end-5:end,:);

%% Plotting
% figure()
% plot3(nodes_final(:,1),nodes_final(:,2),nodes_final(:,3),'.k')
% hold on
% plot3(coords_final(1:2,1),coords_final(1:2,2),coords_final(1:2,3),'r-')
% plot3(coords_final(3:4,1),coords_final(3:4,2),coords_final(3:4,3),'b-')
% plot3(coords_final(5:6,1),coords_final(5:6,2),coords_final(5:6,3),'g-')
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal