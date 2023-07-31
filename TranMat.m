function [TM] = TranMat(coords_final_unit, Temp_Coordinates_Unit)

A = [0, 0, 0; Temp_Coordinates_Unit(2,:); Temp_Coordinates_Unit(4,:); Temp_Coordinates_Unit(6,:)];
B = [coords_final_unit(1,:); coords_final_unit(2,:); coords_final_unit(4,:); coords_final_unit(6,:)];

B_new = [B(2:4, 1:3) B(1,:)'; 0 0 0 1];

% Rotation and scaling components
R = A(2:4, 1:3) / B(2:4, 1:3);
det_R = det(R);

% If the determinant is not zero, make it zero by adjusting the scaling components
if det_R ~= 0
    [U, S, V] = svd(R);
    S(end) = 0;
    R = U * S * V';
end

% Translation components
T = A(1, 1:3)' - R * B(1, 1:3)';

% Transformation matrix
TM = eye(4);
TM(1:3, 1:3) = R;
TM(1:3, 4) = T;

% Round all values to 6 significant figures
TM = round(TM, 6);

% % Normalize the rotation matrix rows
% Rot = TM(1:3,1:3);
% normalizedRot = zeros(size(Rot));  % Initialize a matrix to store the normalized rows
% 
% for i = 1:size(Rot, 1)
%     normalizedRot(i, :) = Rot(i, :) / norm(Rot(i, :));
% end
% 
% TM(1:3, 1:3) = normalizedRot;
% 
% TM = round(TM,6);

end




% function [TM] = TranMat(coords_final_unit,Temp_Coordinates_Unit)
% 
% A = [0, 0, 0; Temp_Coordinates_Unit(2,:); Temp_Coordinates_Unit(4,:); Temp_Coordinates_Unit(6,:)];
% B = [coords_final_unit(1,:); coords_final_unit(2,:); coords_final_unit(4,:); coords_final_unit(6,:)];
% 
% B_new = [B(2:4, 1:3) B(1,:)'; 0 0 0 1];
% 
% % Rotation and scaling components
% R = A(2:4, 1:3) / B(2:4, 1:3);
% 
% % Translation components
% T = A(1, 1:3)' - R * B(1, 1:3)';
% 
% % Transformation matrix
% TM = eye(4);
% TM(1:3, 1:3) = R;
% TM(1:3, 4) = T;
% 
% Rot = TM(1:3,1:3);
% 
% normalizedRot = zeros(size(Rot));  % Initialize a matrix to store the normalized rows
% 
% for i = 1:size(Rot, 1)
%     normalizedRot(i, :) = Rot(i, :) / norm(Rot(i, :));
% end
% 
% TM(1:3, 1:3) = normalizedRot;
% 
% test = det(TM)

%%
% % Rotation and scaling components
% R = A(2:4, 1:3) / B(2:4, 1:3);
% 
% normalizedRot = zeros(size(R));  % Initialize a matrix to store the normalized rows
% 
% for i = 1:size(R, 1)
%     normalizedRot(i, :) = R(i, :) / norm(R(i, :));
% end
% 
% R = normalizedRot;
% 
% % Translation components
% T = A(1, 1:3)' - R * B(1, 1:3)';
% 
% % Transformation matrix
% TM = eye(4);
% TM(1:3, 1:3) = R;
% TM(1:3, 4) = T;