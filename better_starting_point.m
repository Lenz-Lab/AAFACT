function better_starting_point(accurate_answer,nodes,bone_indx,bone_coord,side_indx,FileName,name,list_bone,list_side,FolderPathName,FolderName,cm_nodes,nodes_original)

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
        [aligned_nodes, flip_out, tibfib_switch, Rot, Tra, Rr] = icp_template(bone_indx,nodes_new,bone_coord,better_start);

        %% Performs coordinate system calculation
        [Temp_Coordinates, Temp_Nodes] = CoordinateSystem(aligned_nodes,bone_indx,bone_coord,tibfib_switch);
        Temp_Coordinates_Unit = Temp_Coordinates/50; % makes it a unit vector...
        % - multiplying it by 50 in the previous function is simply for coordinate system visualization

        %% Reorient and Translate to Original Input Origin and Orientation
        if isempty(Rr) == 0
            nodes_final_temptr = (inv(Rr)*(Temp_Nodes'))';
            nodes_final_tempt = (nodes_final_temptr' - repmat(Tra,1,length(nodes_final_temptr')))';
            nodes_final_temp = (inv(Rot)*(nodes_final_tempt'))';
            nodes_final_tem = ((nodes_final_temp)*inv(flip_out));
            nodes_final = [nodes_final_tem(:,1) + cm_nodes(1), nodes_final_tem(:,2) + cm_nodes(2), nodes_final_tem(:,3) + cm_nodes(3)];

            coords_final_temptr = (inv(Rr)*(Temp_Coordinates'))';
            coords_final_tempt = (coords_final_temptr' - repmat(Tra,1,length(coords_final_temptr')))';
            coords_final_temp = (inv(Rot)*(coords_final_tempt'))';
            coords_final_tem = ((coords_final_temp)*inv(flip_out));
            coords_final = [coords_final_tem(:,1) + cm_nodes(1), coords_final_tem(:,2) + cm_nodes(2), coords_final_tem(:,3) + cm_nodes(3)];

            coords_final_unit_temptr = (inv(Rr)*(Temp_Coordinates_Unit'))';
            coords_final_unit_tempt = (coords_final_unit_temptr' - repmat(Tra,1,length(coords_final_unit_temptr')))';
            coords_final_unit_temp = (inv(Rot)*(coords_final_unit_tempt'))';
            coords_final_unit_tem = ((coords_final_unit_temp)*inv(flip_out));
            coords_final_unit = [coords_final_unit_tem(:,1) + cm_nodes(1), coords_final_unit_tem(:,2) + cm_nodes(2), coords_final_unit_tem(:,3) + cm_nodes(3)];
        else
            nodes_final_tempt = (Temp_Nodes' - repmat(Tra,1,length(Temp_Nodes')))';
            nodes_final_temp = (inv(Rot)*(nodes_final_tempt'))';
            nodes_final_tem = ((nodes_final_temp)*inv(flip_out));
            nodes_final_te = (inv(R_red)*(nodes_final_tem'))';
            nodes_final_t = (inv(R_yellow)*(nodes_final_te'))';
            nodes_final = [nodes_final_t(:,1) + cm_nodes(1), nodes_final_t(:,2) + cm_nodes(2), nodes_final_t(:,3) + cm_nodes(3)];

            coords_final_tempt = (Temp_Coordinates' - repmat(Tra,1,length(Temp_Coordinates')))';
            coords_final_temp = (inv(Rot)*(coords_final_tempt'))';
            coords_final_tem = ((coords_final_temp)*inv(flip_out));
            coords_final_te = (inv(R_red)*(coords_final_tem'))';
            coords_final_t = (inv(R_yellow)*(coords_final_te'))';
            coords_final = [coords_final_t(:,1) + cm_nodes(1), coords_final_t(:,2) + cm_nodes(2), coords_final_t(:,3) + cm_nodes(3)];

            coords_final_unit_tempt = (Temp_Coordinates_Unit' - repmat(Tra,1,length(Temp_Coordinates_Unit')))';
            coords_final_unit_temp = (inv(Rot)*(coords_final_unit_tempt'))';
            coords_final_unit_tem = ((coords_final_unit_temp)*inv(flip_out));
            coords_final_unit_te = (inv(R_red)*(coords_final_unit_tem'))';
            coords_final_unit_t = (inv(R_yellow)*(coords_final_unit_te'))';
            coords_final_unit = [coords_final_unit_t(:,1) + cm_nodes(1), coords_final_unit_t(:,2) + cm_nodes(2), coords_final_unit_t(:,3) + cm_nodes(3)];
        end

        if side_indx == 1
            nodes_final = nodes_final.*[1,1,-1]; % Flip back to right if applicable
            coords_final = coords_final.*[1,1,-1]; % Flip back to right if applicable
            coords_final_unit = coords_final_unit.*[1,1,-1]; % Flip back to right if applicable
        end

        %% Final Plotting
        figure()
        plot3(nodes_original(:,1),nodes_original(:,2),nodes_original(:,3),'k.')
        hold on
        %     plot3(nodes_final_temp(:,1),nodes_final_temp(:,2),nodes_final_temp(:,3),'y.')
        %     plot3(Temp_Nodes_flip(:,1),Temp_Nodes_flip(:,2),Temp_Nodes_flip(:,3),'r.')
        %     plot3(nodes_final(:,1),nodes_final(:,2),nodes_final(:,3),'k.')
        hold on
        arrow(coords_final(1,:),coords_final(2,:),'FaceColor','r','EdgeColor','r','LineWidth',5,'Length',10)
        arrow(coords_final(3,:),coords_final(4,:),'FaceColor','g','EdgeColor','g','LineWidth',5,'Length',10)
        arrow(coords_final(5,:),coords_final(6,:),'FaceColor','b','EdgeColor','b','LineWidth',5,'Length',10)
        legend(' Nodal Points',' AP Axis',' SI Axis',' ML Axis')
        title(strcat('Coordinate System of'," ", char(FileName)),'Interpreter','none')
        text(coords_final(2,1),coords_final(2,2),coords_final(2,3),'   Anterior','HorizontalAlignment','left','FontSize',15,'Color','r');
        text(coords_final(4,1),coords_final(4,2),coords_final(4,3),'   Superior','HorizontalAlignment','left','FontSize',15,'Color','g');
        text(coords_final(6,1),coords_final(6,2),coords_final(6,3),'   Medial','HorizontalAlignment','left','FontSize',15,'Color','b');
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
            "Origin"
            "AP Axis"
            "SI Axis"
            "ML Axis"
            "Coordinate System at (0,0,0)"
            "Origin"
            "AP Axis"
            "SI Axis"
            "ML Axis"];
        D = ["X" "Y" "Z"];

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
end
