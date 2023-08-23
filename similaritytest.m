function max_Z = similaritytest(Temp_Coordinates_Unit, bone_indx, bone_coord)

load averages.mat 
load means.mat

if bone_indx == 1
    if bone_coord == 1
        m = 3;
    elseif bone_coord == 2
        m = 5;
    else 
        m = 4;
    end
elseif bone_indx == 2
    if bone_coord == 1
        m = 1;
    else
        m = 2;
    end
else
    m = bone_indx + 3;
end

AP_diff = atan2d(norm(cross(Temp_Coordinates_Unit(2,:),mean_AP(m,:))),dot(Temp_Coordinates_Unit(2,:),mean_AP(m,:)));
SI_diff = atan2d(norm(cross(Temp_Coordinates_Unit(4,:),mean_SI(m,:))),dot(Temp_Coordinates_Unit(4,:),mean_SI(m,:)));
ML_diff = atan2d(norm(cross(Temp_Coordinates_Unit(6,:),mean_ML(m,:))),dot(Temp_Coordinates_Unit(6,:),mean_ML(m,:)));

if ML_diff > 90
    ML_diff = 180 - ML_diff;
end

AP_Z = abs((AP_diff - AP_average(m)) / AP_std(m));
ML_Z = abs((ML_diff - ML_average(m)) / ML_std(m));
SI_Z = abs((SI_diff - SI_average(m)) / SI_std(m));

max_Z = max([AP_Z,ML_Z,SI_Z]);
