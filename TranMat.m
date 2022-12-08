function [TM] = TranMat(RTs,coords_final_unit,side_indx)

Rot = RTs.iR*RTs.iflip; % Initial icp rotation and flipping

if side_indx == 1
    Rot(:,1:2) = Rot(:,1:2)*-1; % Account for flipping right to left
end

Loc = coords_final_unit(1,:)';
TM = [Rot Loc; 0 0 0 1];