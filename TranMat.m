function [TM] = TranMat(coords_final_unit)

A = [0 0 0; 1 0 0; 0 1 0; 0 0 1];
B = [coords_final_unit(1,:); coords_final_unit(6,:); coords_final_unit(2,:); coords_final_unit(4,:)]; % Place in origin,X,Y,Z order

Btest = center(B,2); % center ACS

% x_theta = acosd(dot(B(2,:),A(2,:))/(norm(B(2,:))*norm(A(2,:))));
% y_theta = acosd(dot(B(3,:),A(3,:))/(norm(B(3,:))*norm(A(3,:))));
% z_theta = acosd(dot(B(4,:),A(4,:))/(norm(B(4,:))*norm(A(4,:))));

x_theta = acosd(dot(Btest(2,:),A(2,:))/(norm(Btest(2,:))*norm(A(2,:))));
y_theta = acosd(dot(Btest(3,:),A(3,:))/(norm(Btest(3,:))*norm(A(3,:))));
z_theta = acosd(dot(Btest(4,:),A(4,:))/(norm(Btest(4,:))*norm(A(4,:))));

Rx = rotx(x_theta);
Ry = roty(y_theta);
Rz = rotz(z_theta);

Rt = Rx*Ry*Rz;

TM = [Rt, B(1,:)'; 0 0 0 1];