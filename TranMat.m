function [TM] = TranMat(coords_final_unit)

A = [0 0 0; 1 0 0; 0 1 0; 0 0 1];
B = [coords_final_unit(1,:); coords_final_unit(6,:); coords_final_unit(2,:); coords_final_unit(4,:)]; % Place in origin,X,Y,Z order

B_center = center(B,2); % center ACS

x_theta = acosd(dot(B_center(2,:),A(2,:))/(norm(B_center(2,:))*norm(A(2,:))));
y_theta = acosd(dot(B_center(3,:),A(3,:))/(norm(B_center(3,:))*norm(A(3,:))));
z_theta = acosd(dot(B_center(4,:),A(4,:))/(norm(B_center(4,:))*norm(A(4,:))));

Rx = rotx(x_theta);
Ry = roty(y_theta);
Rz = rotz(z_theta);

Rt = Rx*Ry*Rz;

TM = [Rt, B(1,:)'; 0 0 0 1];



% B_transformed = TM * B_test;
% 
% B_testoutput = inv(TM) * B_test;
% 
% %%
% I = [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1];
% B = [coords_final_unit(1,:); coords_final_unit(6,:); coords_final_unit(2,:); coords_final_unit(4,:)]; % Place in origin,X,Y,Z order
% 
% B_center = center(B,2); % center ACS
% 
% B_test = [B(1:3, 1:3), B(1,:)'; 0 0 0 1];