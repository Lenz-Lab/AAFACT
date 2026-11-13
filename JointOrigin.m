function [Temp_Coordinates, Joint] = JointOrigin(Temp_Coordinates, Temp_Nodes, conlist, bone_indx, joint_indx, side_indx)
% JOINTORIGIN  Move the ACS origin from the bone center to a joint surface.
%
%   [Temp_Coordinates, Joint] = JointOrigin(Temp_Coordinates, Temp_Nodes,
%                                conlist, bone_indx, joint_indx, side_indx)
%
%   A ray is cast from the current origin along one ACS axis (the "axis of
%   interest", AOI). Where it hits the bone surface becomes the new origin,
%   and the whole ACS is translated there. Axis directions do not change.
%
%   Inputs:
%     Temp_Coordinates  6x3 ACS from CoordinateSystem (origins at 0,0,0)
%     Temp_Nodes        Nx3 template-aligned bone nodes
%     conlist           Mx3 triangle connectivity for Temp_Nodes (a surface
%                       mesh is required, so .k/.vtk/.particles inputs
%                       skip this step in Main_CS)
%     bone_indx         bone index (see list_bone in Main_CS)
%     joint_indx        index into that bone's list_joint in Main_CS
%                       (1 = Center, so this function is only called for 2+)
%     side_indx         1 = right, 2 = left
%
%   Outputs:
%     Temp_Coordinates  the ACS translated to the joint surface
%     Joint             name of the chosen surface (used in the Excel sheet)

%% Choose the axis of interest for this bone and joint
% AOI is the direction (in the aligned frame) from the bone center toward
% the requested joint surface. "CheckSI"/"CheckML" mean the ray is tried in
% one direction first and, if it misses, in the opposite direction.
if bone_indx == 1 % Talus
    if joint_indx == 2 % TN Joint
        AOI = "Anterior";
        Joint = "Talonavicular Surface";
    elseif joint_indx == 3 % TT Joint
        AOI = "Superior";
        Joint = "Tibiotalar Surface";
    elseif joint_indx == 4 % ST Joint
        AOI = "Inferior";
        Joint = "Subtalar Surface";
    end
elseif bone_indx == 2 % Calcaneus
    if joint_indx == 2 % CC Joint
        AOI = "Anterior";
        Joint = "Calcaneocuboid Surface";
    elseif joint_indx == 3 % ST Joint
        AOI = "Anterior";
        Joint = "Subtalar Surface";
    end
elseif bone_indx == 3 % Navicular
    if joint_indx == 2 % TN Joint
        AOI = "Posterior";
        Joint = "Talonavicular Surface";
    elseif joint_indx == 3 % NC Joint
        AOI = "Anterior";
        Joint = "Navicular-Cuneiform Surface";
    end
elseif bone_indx == 4 % Cuboid
    if joint_indx == 2 % CC Joint
        AOI = "Posterior";
        Joint = "Calcaneocuboid Surface";
    end
elseif bone_indx == 5 || bone_indx == 7 % Medial or Lateral Cuneiform
    if joint_indx == 2 % NC Joint
        AOI = "Posterior";
        Joint = "Navicular-Cuneiform Surface";
    elseif joint_indx == 3 % CM Joint
        AOI = "Anterior";
        Joint = "Cuneiform-Metatarsal Surface";
    elseif joint_indx == 4 % Intercuneiform Joint
        % Both border the intermediate cuneiform, so look toward it
        if bone_indx == 5
            AOI = "Lateral";
        elseif bone_indx == 7
            AOI = "Medial";
        end
        Joint = "Intercuneiform Surface";
    end
elseif bone_indx == 6 % Intermediate Cuneiform
    if joint_indx == 2 % NC Joint
        AOI = "Posterior";
        Joint = "Navicular-Cuneiform Surface";
    elseif joint_indx == 3 % CM Joint
        AOI = "Anterior";
        Joint = "Cuneiform-Metatarsal Surface";
    elseif joint_indx == 4 % Med-Int Joint
        AOI = "Medial";
        Joint = "Medial Intercuneiform Surface";
    elseif joint_indx == 5 % Lat-Int Joint
        AOI = "Lateral";
        Joint = "Lateral Intercuneiform Surface";
    end
elseif bone_indx >= 8 && bone_indx <= 12 % Metatarsals
    if joint_indx == 2 % Post Meta Joint
        AOI = "Posterior";
        Joint = "Posterior Metatarsal Surface";
    end
elseif bone_indx == 13 % Tibia
    if joint_indx == 2 % TT Joint
        AOI = "CheckSI";
        Joint = "Tibiotalar Surface";
    end
elseif bone_indx == 14 % Fibula
    if joint_indx == 2 % TF Joint
        AOI = "CheckML";
        Joint = "Talofibular Surface";
    end
end

%% Convert the AOI into a ray (start point and direction)
% Rows 2, 4 and 6 of Temp_Coordinates are the AP, SI and ML tips. Because
% the origin is still (0,0,0), a tip point is also a direction vector, so
% it is used directly as the ray direction (negated for the opposite side).
% The ML tip points medial on a left bone and lateral on a right bone (see
% CoordinateSystem), which is why Medial/Lateral swap sign with side_indx.
if AOI == "Anterior"
    current_origin = Temp_Coordinates(1,:);
    axis_direction = Temp_Coordinates(2,:);
elseif AOI == "Posterior"
    current_origin = Temp_Coordinates(1,:);
    axis_direction = -Temp_Coordinates(2,:);
elseif AOI == "Superior"
    current_origin = Temp_Coordinates(3,:);
    axis_direction = Temp_Coordinates(4,:);
elseif AOI == "Inferior"
    current_origin = Temp_Coordinates(3,:);
    axis_direction = -Temp_Coordinates(4,:);
elseif AOI == "Medial"
    if side_indx == 1
        current_origin = Temp_Coordinates(5,:);
        axis_direction = -Temp_Coordinates(6,:);
    else
        current_origin = Temp_Coordinates(5,:);
        axis_direction = Temp_Coordinates(6,:);
    end
elseif AOI == "Lateral"
    if side_indx == 1
        current_origin = Temp_Coordinates(5,:);
        axis_direction = Temp_Coordinates(6,:);
    else
        current_origin = Temp_Coordinates(5,:);
        axis_direction = -Temp_Coordinates(6,:);
    end
elseif AOI == "CheckSI" % tibia: look inferior first (toward the plafond)
    current_origin = Temp_Coordinates(3,:);
    axis_direction = -Temp_Coordinates(4,:);
elseif AOI == "CheckML" % fibula: look medial first (toward the talus)
    if side_indx == 1
        current_origin = Temp_Coordinates(5,:);
        axis_direction = -Temp_Coordinates(6,:);
    else
        current_origin = Temp_Coordinates(5,:);
        axis_direction = Temp_Coordinates(6,:);
    end
elseif AOI == "None"
    current_origin = Temp_Coordinates(1,:);
end


% Corner vertices of every triangle in the mesh, one row per triangle
vert1 = Temp_Nodes(conlist(:,1),:);
vert2 = Temp_Nodes(conlist(:,2),:);
vert3 = Temp_Nodes(conlist(:,3),:);

%% Move the ACS to the desired joint using intersection.m
if AOI ~= "None"
    % Test the ray against every triangle. intersection() treats the ray
    % as an infinite line, so it can return hits on both sides of the bone.
    % MATLAB's eps (~2.2e-16) is passed as the parallel-ray tolerance.
    [intersect,~,~,~,joint_origin] = intersection(current_origin, axis_direction, vert1, vert2, vert3, eps);
    joint_origin = joint_origin(intersect,:);

    % Tibia/fibula only: if nothing was hit, try the opposite direction
    if (AOI == "CheckSI" || AOI == "CheckML") && isempty(joint_origin)
        joint_origin = [];
        [intersect,~,~,~,joint_origin] = intersection(current_origin, -axis_direction, vert1, vert2, vert3, eps);
        joint_origin = joint_origin(intersect,:);
    end

    % Of all hits, keep the one nearest the axis tip (50 mm out along the
    % requested direction). This picks the surface on the requested side
    % of the bone rather than the one behind the origin.
    comp = 10000;
    for nt = 1:length(joint_origin(:,1))
        tempt = norm(axis_direction - joint_origin(nt,:));
        if tempt < comp
            comp = tempt;
            mt = nt;
        end
    end

    if exist("mt")
        joint_origin = joint_origin(mt,:);
    else
        % No intersection at all: usually means the bone was poorly aligned
        joint_origin = [0,0,0];
        warning('There may be a joint origin error, please run the bone alone and use the manual better starting point input as you are most likely having an alignment issue.')
    end

    % Translate all six ACS points (origins and tips) to the joint surface
    Temp_Coordinates = joint_origin + Temp_Coordinates;
else
    joint_origin = current_origin;
end

%% Plotting
% Uncomment to check the ray hit: green = old origin, red = joint origin
% figure()
% plot3(Temp_Nodes(:,1),Temp_Nodes(:,2),Temp_Nodes(:,3),'.k')
% hold on
% plot3(current_origin(:,1),current_origin(:,2),current_origin(:,3),'.g','MarkerSize',25)
% plot3(joint_origin(:,1),joint_origin(:,2),joint_origin(:,3),'.r','MarkerSize',25)
% % plot3(Temp_Coordinates_test(1:2,1),Temp_Coordinates_test(1:2,2),Temp_Coordinates_test(1:2,3),'r')
% % plot3(Temp_Coordinates_test(3:4,1),Temp_Coordinates_test(3:4,2),Temp_Coordinates_test(3:4,3),'g')
% % plot3(Temp_Coordinates_test(5:6,1),Temp_Coordinates_test(5:6,2),Temp_Coordinates_test(5:6,3),'b')
% plot3(Temp_Coordinates(1:2,1),Temp_Coordinates(1:2,2),Temp_Coordinates(1:2,3),'r')
% plot3(Temp_Coordinates(3:4,1),Temp_Coordinates(3:4,2),Temp_Coordinates(3:4,3),'g')
% plot3(Temp_Coordinates(5:6,1),Temp_Coordinates(5:6,2),Temp_Coordinates(5:6,3),'b')
% % plot3(Temp_Coordinates_Unit(1:2,1),Temp_Coordinates_Unit(1:2,2),Temp_Coordinates_Unit(1:2,3),'m')
% % plot3(Temp_Coordinates_Unit(3:4,1),Temp_Coordinates_Unit(3:4,2),Temp_Coordinates_Unit(3:4,3),'m')
% % plot3(Temp_Coordinates_Unit(5:6,1),Temp_Coordinates_Unit(5:6,2),Temp_Coordinates_Unit(5:6,3),'m')
% axis equal
