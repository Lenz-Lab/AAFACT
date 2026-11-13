function [nodes_final, coords_final, coords_final_unit, Temp_Coordinates_Unit] = reorient(Temp_Nodes_Coords,cm_nodes,side_indx,RTs)
% The function reorients the aligned bone and subsequent coordinate system
% back to the bones original orientation.
% It requires the nodes and coordinate systems, as well as the rotation and
% translation matricies.
%
% Inputs:
%   Temp_Nodes_Coords  (N+6)x3 array: the template-aligned bone nodes with
%                      the 6 ACS points appended as the last six rows
%                      [AP origin; AP tip; SI origin; SI tip; ML origin;
%                      ML tip]. Carrying the ACS along with the nodes means
%                      every inverse transform below moves both together.
%   cm_nodes           1x3 centroid removed by center() before alignment
%   side_indx          1 = right, 2 = left (rights were mirrored to left)
%   RTs                struct of transforms recorded by icp_template (and
%                      by better_starting_point for RTs.red/RTs.yellow)
%
% Outputs:
%   nodes_final            bone nodes back in the original input frame
%   coords_final           6x3 ACS in the original frame, full axis length
%   coords_final_unit      same ACS with each axis scaled to unit length
%   Temp_Coordinates_Unit  unit-length ACS in the template-aligned frame
%
% The forward alignment was applied in this order:
%   center -> manual start rotations (yellow, red; optional) -> initial
%   flip (iflip) -> ICP rotation/translation (iR, iT) -> bone-specific
%   secondary step (talus, tibia, fibula or metatarsal)
% so it is undone here in the reverse order.

% Build a unit-length copy of the ACS in the aligned frame. All three axes
% share one origin, so the ML origin (row end-1) is used for all of them.
Temp_Coordinates_origin = Temp_Nodes_Coords(end-1,:);
Temp_Coordinates_temp = Temp_Nodes_Coords(end-5:end,:) - Temp_Coordinates_origin;
Temp_Coordinates_temp = [0 0 0; Temp_Coordinates_temp(2,:)./norm(Temp_Coordinates_temp(2,:));
    0 0 0; Temp_Coordinates_temp(4,:)./norm(Temp_Coordinates_temp(4,:));
    0 0 0; Temp_Coordinates_temp(6,:)./norm(Temp_Coordinates_temp(6,:));];
Temp_Coordinates_Unit = Temp_Coordinates_temp + Temp_Coordinates_origin;

% Step 1: undo the bone-specific secondary alignment. At most one of these
% fields is non-empty for a given bone, so only one branch runs.
% Points are stored as rows, so "R\(P')" applies the inverse of R and
% "P/R" undoes a right-multiplication P*R.
if isempty(RTs.sR_talus) == 0 % talus TT/ST: extra rotation only
    nodes_coords_final_i4 = ((RTs.sR_talus)\(Temp_Nodes_Coords'))';
elseif isempty(RTs.sT_tibia) == 0 % tibia: remove translation, rotation, then the 90-degree flip
    nodes_coords_final_i6 = (Temp_Nodes_Coords' - repmat(RTs.sT_tibia,1,length(Temp_Nodes_Coords')))';
    nodes_coords_final_i5 = ((RTs.sR_tibia)\(nodes_coords_final_i6'))';
    nodes_coords_final_i4 = ((nodes_coords_final_i5)/(RTs.sflip));
elseif isempty(RTs.sT_fibula) == 0 % fibula: same pattern as the tibia (sflip is identity)
    nodes_coords_final_i6 = (Temp_Nodes_Coords' - repmat(RTs.sT_fibula,1,length(Temp_Nodes_Coords')))';
    nodes_coords_final_i5 = ((RTs.sR_fibula)\(nodes_coords_final_i6'))';
    nodes_coords_final_i4 = ((nodes_coords_final_i5)/(RTs.sflip));
elseif isempty(RTs.cm_meta) == 0 % metatarsals: add back the centroid removed after ICP
    nodes_coords_final_i4 = [Temp_Nodes_Coords(:,1) + RTs.cm_meta(1), Temp_Nodes_Coords(:,2) + RTs.cm_meta(2), Temp_Nodes_Coords(:,3) + RTs.cm_meta(3)];
else % no secondary alignment for this bone
    nodes_coords_final_i4 = Temp_Nodes_Coords;
end

% Step 2: undo the main ICP alignment (translation, then rotation), then
% the coarse starting rotation (iflip) that ICP was started from.
nodes_coords_final_i3 = (nodes_coords_final_i4' - repmat(RTs.iT,1,length(nodes_coords_final_i4')))';
nodes_coords_final_i2 = ((RTs.iR)\(nodes_coords_final_i3'))';
nodes_coords_final_i1 = ((nodes_coords_final_i2)/(RTs.iflip));

% Step 3: undo the manual starting rotation from better_starting_point
% (only set when the user troubleshoots alignment). Red is removed first,
% then yellow; better_starting_point currently stores the whole rotation
% in yellow and leaves red as identity.
if isempty(RTs.red) == 0
    nodes_coords_final_i1_red = ((RTs.red)\(nodes_coords_final_i1'))';
    nodes_coords_final_i1 = ((RTs.yellow)\(nodes_coords_final_i1_red'))';
end

% Step 4: re-center to remove any leftover translation from ICP, then move
% back to the original centroid of the input. The template scaling done
% in icp_template was already undone there.
[nodes_coords_final_i1, ~] = center(nodes_coords_final_i1,1);

nodes_coords_final = [nodes_coords_final_i1(:,1) + cm_nodes(1), nodes_coords_final_i1(:,2) + cm_nodes(2), nodes_coords_final_i1(:,3) + cm_nodes(3)];

if side_indx == 1
    nodes_coords_final = nodes_coords_final.*[1,1,-1]; % Flip back to right if applicable
end

% Unit-length copy of the ACS in the original frame (same approach as the
% aligned-frame copy at the top of this function)
coods_final_origin = nodes_coords_final(end-1,:);
coords_final_temp = nodes_coords_final(end-5:end,:) - coods_final_origin;
coords_final_temp = [0 0 0; coords_final_temp(2,:)./norm(coords_final_temp(2,:));
    0 0 0; coords_final_temp(4,:)./norm(coords_final_temp(4,:));
    0 0 0; coords_final_temp(6,:)./norm(coords_final_temp(6,:));];
coords_final_unit = coords_final_temp + coods_final_origin;

% Split the appended ACS rows back off the bone nodes
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