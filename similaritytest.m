function max_Z = similaritytest(Temp_Coordinates_Unit, bone_indx, bone_coord)
% SIMILARITYTEST  Check a new ACS against the reference data set.
%
%   max_Z = similaritytest(Temp_Coordinates_Unit, bone_indx, bone_coord)
%
%   Compares the axis directions of a newly computed ACS (in the
%   template-aligned frame) with the mean reference axes for the same bone,
%   and returns the largest Z-score of the three axis angles. Main_CS
%   compares max_Z to 1.645 (one-sided alpha = 0.05) and warns the user if
%   the new ACS looks unusual.
%
%   Inputs:
%     Temp_Coordinates_Unit  6x3 unit-length ACS [AP origin; AP tip;
%                            SI origin; SI tip; ML origin; ML tip]
%     bone_indx              bone index (see list_bone in Main_CS)
%     bone_coord             which ACS option was used for that bone
%
%   Reference data (17 rows each, one per bone/ACS, see row map below):
%     means.mat     mean_AP, mean_SI, mean_ML: mean unit axis directions
%     averages.mat  AP/SI/ML_average and AP/SI/ML_std: mean and standard
%                   deviation of the angle (degrees) between each
%                   reference ACS axis and that mean direction

load averages.mat
load means.mat

% Row of the reference tables to compare against:
%   1 Calcaneus CC, 2 Calcaneus ST, 3 Talus TN, 4 Talus ST, 5 Talus TT,
%   6-17 bone_indx 3-14 (navicular through fibula). Bones other than the
%   talus and calcaneus share one reference row for all ACS options.
if bone_indx == 1 % Talus
    if bone_coord == 1 % TN
        m = 3;
    elseif bone_coord == 2 % TT
        m = 5;
    else % ST
        m = 4;
    end
elseif bone_indx == 2 % Calcaneus
    if bone_coord == 1 % CC
        m = 1;
    else % ST
        m = 2;
    end
else
    m = bone_indx + 3;
end

% Angle (degrees) between each new axis and the mean reference axis.
% atan2d(|a x b|, a . b) is used instead of acosd(a . b) because it stays
% accurate for very small and very large angles.
AP_diff = atan2d(norm(cross(Temp_Coordinates_Unit(2,:),mean_AP(m,:))),dot(Temp_Coordinates_Unit(2,:),mean_AP(m,:)));
SI_diff = atan2d(norm(cross(Temp_Coordinates_Unit(4,:),mean_SI(m,:))),dot(Temp_Coordinates_Unit(4,:),mean_SI(m,:)));
ML_diff = atan2d(norm(cross(Temp_Coordinates_Unit(6,:),mean_ML(m,:))),dot(Temp_Coordinates_Unit(6,:),mean_ML(m,:)));

% The ML axis is compared without regard to its sign, so an ML axis that
% points the opposite way still counts as aligned (180 deg -> 0 deg)
if ML_diff > 90
    ML_diff = 180 - ML_diff;
end

% Absolute Z-score of each angle relative to the reference distribution
AP_Z = abs((AP_diff - AP_average(m)) / AP_std(m));
ML_Z = abs((ML_diff - ML_average(m)) / ML_std(m));
SI_Z = abs((SI_diff - SI_average(m)) / SI_std(m));

% Report the worst of the three axes
max_Z = max([AP_Z,ML_Z,SI_Z]);
