function coords_avg = AverageOrthogonalAxes(coords_A, coords_B)
% Combines two independently-computed orthogonal 3-axis coordinate
% systems into a single orthogonal coordinate system. Each is a 6x3
% matrix of [axis1_origin; axis1_tip; axis2_origin; axis2_tip;
% axis3_origin; axis3_tip]. The axis directions are averaged and then
% replaced with the closest orthogonal triad (via SVD), so the result is
% guaranteed orthogonal rather than only approximately so. The origin and
% axis length of each axis are taken from coords_A.

R_A = zeros(3);
R_B = zeros(3);
axis_len = zeros(1,3);
origin = coords_A(1:2:end,:);

for k = 1:3
    o_A = coords_A(2*k-1,:);
    t_A = coords_A(2*k,:);
    o_B = coords_B(2*k-1,:);
    t_B = coords_B(2*k,:);

    v_A = t_A - o_A;
    axis_len(k) = norm(v_A);
    R_A(:,k) = v_A' / norm(v_A);

    v_B = t_B - o_B;
    R_B(:,k) = v_B' / norm(v_B);
end

M = (R_A + R_B) / 2;
[U,~,V] = svd(M);
R_avg = U*V';
if det(R_avg) < 0 % Guard against a reflection instead of a rotation
    U(:,end) = -U(:,end);
    R_avg = U*V';
end

coords_avg = zeros(6,3);
for k = 1:3
    coords_avg(2*k-1,:) = origin(k,:);
    coords_avg(2*k,:) = origin(k,:) + axis_len(k) * R_avg(:,k)';
end

end
