function better_starting_point(accurate_answer,nodes,bone_indx,bone_coord,side_indx,FileName,name,list_bone,list_side,FolderPathName,FolderName,cm_nodes,nodes_original,joint_indx)
% This function allows the user to choose a better starting point for their
% bone model if the icp alignment isn't working. This is only ran if you

switch accurate_answer
    case 'No'
        Fig = figure;
        figure()
        plot3(nodes(:,1),nodes(:,2),nodes(:,3),'k.')
        hold on
        plot3(nodes(nodes(:,2) > 0,1),nodes(nodes(:,2) > 0,2),nodes(nodes(:,2) > 0,3),'yo')
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal
        fig = uifigure;
        ant1_selection = uiconfirm(fig,'What side is highlighted yellow?','Manual Alignment',...
            'Options',{'Anterior/Posterior','Medial/Lateral','Superior/Inferior'},'DefaultOption',1);
        delete(fig)
        switch ant1_selection
            case 'Anterior/Posterior'
                fig = uifigure;
                ant2_selection = uiconfirm(fig,'Is the anterior or posterior highlighted yellow?','Manual Alignment',...
                    'Options',{'Anterior','Posterior'},'DefaultOption',1);
                delete(Fig)
                delete(fig)
                switch ant2_selection
                    case 'Posterior'
                        R_yellow = rotz(180);
                        nodes_ant = (R_yellow*nodes')';
                    case 'Anterior'
                        R_yellow = rotz(0);
                        nodes_ant = nodes;
                end
            case 'Medial/Lateral'
                fig = uifigure;
                ant2_selection = uiconfirm(fig,'Is the medial or lateral highlighted yellow?','Manual Alignment',...
                    'Options',{'Medial','Lateral'},'DefaultOption',1);
                delete(Fig)
                delete(fig)
                switch ant2_selection
                    case 'Medial'
                        R_yellow = rotz(-90);
                        nodes_ant = (R_yellow*nodes')';
                    case 'Lateral'
                        R_yellow = rotz(90);
                        nodes_ant = (R_yellow*nodes')';
                end
            case 'Superior/Inferior'
                fig = uifigure;
                ant2_selection = uiconfirm(fig,'Is the superior or inferior highlighted yellow?','Manual Alignment',...
                    'Options',{'Superior','Inferior'},'DefaultOption',1);
                delete(Fig)
                delete(fig)
                switch ant2_selection
                    case 'Superior'
                        R_yellow = rotz(90);
                        nodes_ant = (R_yellow*nodes')';
                    case 'Inferior'
                        R_yellow = rotz(-90);
                        nodes_ant = (R_yellow*nodes')';
                end
        end

        Fig = figure;
        figure()
        plot3(nodes_ant(:,1),nodes_ant(:,2),nodes_ant(:,3),'k.')
        hold on
        plot3(nodes_ant(nodes_ant(:,1) > 0,1),nodes_ant(nodes_ant(:,1) > 0,2),nodes_ant(nodes_ant(:,1) > 0,3),'ro')
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal
        fig = uifigure;
        med1_selection = uiconfirm(fig,'What side is highlighted red?','Manual Alignment',...
            'Options',{'Medial','Lateral','Superior','Inferior'},'DefaultOption',1);
        delete(fig)
        delete(Fig)
        switch med1_selection
            case 'Medial'
                R_red = rotz(0);
                nodes_new = nodes_ant;
            case 'Lateral'
                R_red = roty(180);
                nodes_new = (R_red*nodes_ant')';
            case 'Superior'
                R_red = roty(-90);
                nodes_new = (R_red*nodes_ant')';
            case 'Inferior'
                R_red = roty(90);
                nodes_new = (R_red*nodes_ant')';
        end

        close all
        better_start = 2;
        [aligned_nodes, RTs] = icp_template(bone_indx, nodes_new, bone_coord, better_start);
        RTs.red = R_red;
        RTs.yellow = R_yellow;

        %         figure()
        %         plot3(nodes_new(:,1),nodes_new(:,2),nodes_new(:,3),'r.')
        %         hold on
        %         plot3(nodes_original(:,1),nodes_original(:,2),nodes_original(:,3),'.k')
        % plot3(nodes_template(:,1),nodes_template(:,2),nodes_template(:,3),'.b')
        %
        %         xlabel('X')
        %         ylabel('Y')
        %         zlabel('Z')
        %         axis equal

        %% Performs coordinate system calculation
        [Temp_Coordinates, Temp_Nodes] = CoordinateSystem(aligned_nodes, bone_indx, bone_coord);

        if bone_indx == 1 && bone_coord == 3 % Secondary CS for Talus Subtalar
            [Temp_Coordinates_temp, Temp_Nodes_temp] = CoordinateSystem(aligned_nodes, 1, 2);

            Temp_Coordinates = [0 0 0; ((Temp_Coordinates(2,:) + Temp_Coordinates_temp(2,:)).'/2)'
                0 0 0; ((Temp_Coordinates(4,:) + Temp_Coordinates_temp(4,:)).'/2)'
                0 0 0; ((Temp_Coordinates(6,:) + Temp_Coordinates_temp(6,:)).'/2)'];
        end

        %% Joint Origin
        if joint_indx > 1
            [Temp_Coordinates, Temp_Nodes, Joint] = JointOrigin(Temp_Coordinates, Temp_Nodes, conlist, bone_indx, joint_indx);

        else
            Joint = "Center";
        end

        %% Reorient and Translate to Original Input Origin and Orientation
        [nodes_final, coords_final, coords_final_unit, Temp_Coordinates_Unit] = reorient(Temp_Nodes, Temp_Coordinates, cm_nodes, side_indx, RTs);

        %% Transformation Matrix
        TM = TranMat(RTs,coords_final_unit,side_indx);

        %% Final Plotting
        figure()
        plot3(nodes_original(:,1),nodes_original(:,2),nodes_original(:,3),'k.')
        hold on
        arrow(coords_final(1,:),coords_final(2,:),'FaceColor','g','EdgeColor','g','LineWidth',5,'Length',10)
        arrow(coords_final(3,:),coords_final(4,:),'FaceColor','b','EdgeColor','b','LineWidth',5,'Length',10)
        arrow(coords_final(5,:),coords_final(6,:),'FaceColor','r','EdgeColor','r','LineWidth',5,'Length',10)
        legend(' Nodal Points',' AP Axis',' SI Axis',' ML Axis')
        title(strcat('Coordinate System of'," ", char(FileName)),'Interpreter','none')
        text(coords_final(2,1),coords_final(2,2),coords_final(2,3),'   Anterior','HorizontalAlignment','left','FontSize',15,'Color','g');
        text(coords_final(4,1),coords_final(4,2),coords_final(4,3),'   Superior','HorizontalAlignment','left','FontSize',15,'Color','b');
        if side_indx == 1
            text(coords_final(6,1),coords_final(6,2),coords_final(6,3),'   Lateral','HorizontalAlignment','left','FontSize',15,'Color','r');
        elseif side_indx == 2
            text(coords_final(6,1),coords_final(6,2),coords_final(6,3),'   Medial','HorizontalAlignment','left','FontSize',15,'Color','r');
        end
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal

        %% Save both coordinate systems to spreadsheet
        A = ["Subject"
            "Bone Model"
            "Side"];
        B = [name
            list_bone(bone_indx)
            list_side(side_indx)];
        C = ["Coordinate System at Original Orientation"
            strcat(string(Joint)," Origin")
            "AP Axis"
            "SI Axis"
            "ML Axis"
            "Coordinate System at (0,0,0)"
            strcat(string(Joint)," Origin")
            "AP Axis"
            "SI Axis"
            "ML Axis"];
        D = ["X" "Y" "Z"];

        if bone_indx == 1 && bone_coord == 1
            name = strcat('TN_',name);
        elseif bone_indx == 1 && bone_coord == 2
            name = strcat('TT_',name);
        elseif bone_indx == 1 && bone_coord == 3
            name = strcat('ST_',name);
        elseif bone_indx == 2 && bone_coord == 1
            name = strcat('CC_',name);
        elseif bone_indx == 2 && bone_coord == 2
            name = strcat('ST_',name);
        end

        if length(name) > 31
            name = name(1:31);
        end

        xlfilename = strcat(FolderPathName,'\CoordinateSystem_',FolderName,'.xlsx');
        writematrix(A,xlfilename,'Sheet',name);
        writecell(B,xlfilename,'Sheet',name,'Range','B1');
        writematrix(C,xlfilename,'Sheet',name,'Range','A5');
        writematrix(D,xlfilename,'Sheet',name,'Range','B5')
        writematrix(D,xlfilename,'Sheet',name,'Range','B10')
        writematrix(coords_final_unit(1,:),xlfilename,'Sheet',name,'Range','B6');
        writematrix(coords_final_unit(2,:),xlfilename,'Sheet',name,'Range','B7');
        writematrix(coords_final_unit(4,:),xlfilename,'Sheet',name,'Range','B8');
        writematrix(coords_final_unit(6,:),xlfilename,'Sheet',name,'Range','B9');
        writematrix(Temp_Coordinates_Unit(1,:),xlfilename,'Sheet',name,'Range','B11');
        writematrix(Temp_Coordinates_Unit(2,:),xlfilename,'Sheet',name,'Range','B12');
        writematrix(Temp_Coordinates_Unit(4,:),xlfilename,'Sheet',name,'Range','B13');
        writematrix(Temp_Coordinates_Unit(6,:),xlfilename,'Sheet',name,'Range','B14');
        writematrix(TM(:,:),xlfilename,'Sheet',name,'Range','B16');
end