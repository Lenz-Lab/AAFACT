function [Temp_Coordinates, Joint] = JointOrigin(Temp_Coordinates, Temp_Nodes, conlist, bone_indx, joint_indx, side_indx)
%%
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
elseif AOI == "CheckSI"
    current_origin = Temp_Coordinates(3,:);
    axis_direction = -Temp_Coordinates(4,:);
elseif AOI == "CheckML"
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


vert1 = Temp_Nodes(conlist(:,1),:);
vert2 = Temp_Nodes(conlist(:,2),:);
vert3 = Temp_Nodes(conlist(:,3),:);

%% Move the ACS to the desired joint using TriangleRayIntersection
if AOI ~= "None"
    [intersect,~,~,~,joint_origin] = TriangleRayIntersection(current_origin, axis_direction, vert1, vert2, vert3,'lineType','line','fullReturn',1);
    joint_origin = joint_origin(intersect,:);

    if (AOI == "CheckSI" || AOI == "CheckML") && isempty(joint_origin)
        joint_origin = [];
        [intersect,~,~,~,joint_origin] = TriangleRayIntersection(current_origin, -axis_direction, vert1, vert2, vert3,'lineType','line');
        joint_origin = joint_origin(intersect,:);
    end

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
        joint_origin = [0,0,0];
        warning('There may be a joint origin error, please run the bone alone and use the manual better starting point input as you are most likely having an alignment issue.')
    end

    Temp_Coordinates = joint_origin + Temp_Coordinates;
else
    joint_origin = current_origin;
end

%% Plotting
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
