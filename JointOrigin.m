function [Temp_Coordinates, Temp_Nodes, Temp_Coordinates_Unit, Joint] = JointOrigin(Temp_Coordinates, Temp_Nodes, Temp_Coordinates_Unit, conlist, bone_indx, joint_indx)

if bone_indx == 1 % Talus
    if joint_indx == 2 % TN Joint
        AOI = "Anterior";
        Joint = "Talonavicular Surface";
    elseif joint_indx == 3 % TT Joint
        AOI = "Superior";
        Joint = "Tibiotalar Surface";
    end
elseif bone_indx == 2 % Calcaneus
    if joint_indx == 2 % CC Joint
        AOI = "Anterior";
        Joint = "Calcaneocuboid Surface";
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
        AOI = "None";
        Joint = "Tibiotalar Surface";
    end
elseif bone_indx == 14 % Fibula
    if joint_indx == 2 % TF Joint
        AOI = "None";
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
    current_origin = Temp_Coordinates(5,:);
    axis_direction = Temp_Coordinates(6,:);
elseif AOI == "Lateral"
    current_origin = Temp_Coordinates(5,:);
    axis_direction = -Temp_Coordinates(6,:);
elseif AOI == "None"
    current_origin = Temp_Coordinates(1,:);
end

if AOI ~= "None"
    vert1 = Temp_Nodes(conlist(:,1),:);
    vert2 = Temp_Nodes(conlist(:,2),:);
    vert3 = Temp_Nodes(conlist(:,3),:);
    [~,~,~,~,joint_origin] = TriangleRayIntersection(current_origin, axis_direction, vert1, vert2, vert3);

    joint_origin = ((joint_origin(~isnan(joint_origin))))';
    int_amount = (length(joint_origin)/3);
%     joint_origin = [joint_origin(end-(2*(length(joint_origin)/3))) joint_origin(end-(length(joint_origin)/3)) joint_origin(end)]
    joint_origin = [joint_origin(1) joint_origin(end+1-(2*int_amount)) joint_origin(end+1-int_amount)];
    Temp_Coordinates = joint_origin + Temp_Coordinates;
    Temp_Coordinates_Unit = joint_origin + Temp_Coordinates_Unit;
else
    joint_origin = current_origin;
end

figure()
plot3(Temp_Nodes(:,1),Temp_Nodes(:,2),Temp_Nodes(:,3),'.k')
hold on
plot3(current_origin(:,1),current_origin(:,2),current_origin(:,3),'.g','MarkerSize',25)
plot3(joint_origin(:,1),joint_origin(:,2),joint_origin(:,3),'.r','MarkerSize',25)
% plot3(Temp_Coordinates_test(1:2,1),Temp_Coordinates_test(1:2,2),Temp_Coordinates_test(1:2,3),'r')
% plot3(Temp_Coordinates_test(3:4,1),Temp_Coordinates_test(3:4,2),Temp_Coordinates_test(3:4,3),'g')
% plot3(Temp_Coordinates_test(5:6,1),Temp_Coordinates_test(5:6,2),Temp_Coordinates_test(5:6,3),'b')
plot3(Temp_Coordinates(1:2,1),Temp_Coordinates(1:2,2),Temp_Coordinates(1:2,3),'r')
plot3(Temp_Coordinates(3:4,1),Temp_Coordinates(3:4,2),Temp_Coordinates(3:4,3),'g')
plot3(Temp_Coordinates(5:6,1),Temp_Coordinates(5:6,2),Temp_Coordinates(5:6,3),'b')
axis equal



