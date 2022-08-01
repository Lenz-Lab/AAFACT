function manual_orientation(accurate_answer,aligned_nodes,bone_indx,bone_coord,side_indx,FileName,name,list_bone,list_side,FolderPathName,FolderName)

switch accurate_answer
    case 'No'
        Fig = figure;
        figure()
        plot3(aligned_nodes(:,1),aligned_nodes(:,2),aligned_nodes(:,3),'k.')
        hold on
        plot3(aligned_nodes(aligned_nodes(:,2) > 0,1),aligned_nodes(aligned_nodes(:,2) > 0,2),aligned_nodes(aligned_nodes(:,2) > 0,3),'yo')
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
                        aligned_nodes_ant = (rotz(180)*aligned_nodes')';
                    case 'Anterior'
                        aligned_nodes_ant = aligned_nodes;
                end
            case 'Medial/Lateral'
                fig = uifigure;
                ant2_selection = uiconfirm(fig,'Is the medial or lateral highlighted yellow?','Manual Alignment',...
                    'Options',{'Medial','Lateral'},'DefaultOption',1);
                delete(Fig)
                delete(fig)
                switch ant2_selection
                    case 'Medial'
                        aligned_nodes_ant = (rotz(-90)*aligned_nodes')';
                    case 'Lateral'
                        aligned_nodes_ant = (rotz(90)*aligned_nodes')';
                end
            case 'Superior/Inferior'
                fig = uifigure;
                ant2_selection = uiconfirm(fig,'Is the superior or inferior highlighted yellow?','Manual Alignment',...
                    'Options',{'Superior','Inferior'},'DefaultOption',1);
                delete(Fig)
                delete(fig)
                switch ant2_selection
                    case 'Superior'
                        aligned_nodes_ant = (rotz(90)*aligned_nodes')';
                    case 'Inferior'
                        aligned_nodes_ant = (rotz(-90)*aligned_nodes')';
                end
        end

        Fig = figure;
        figure()
        plot3(aligned_nodes_ant(:,1),aligned_nodes_ant(:,2),aligned_nodes_ant(:,3),'k.')
        hold on
        plot3(aligned_nodes_ant(aligned_nodes_ant(:,1) > 0,1),aligned_nodes_ant(aligned_nodes_ant(:,1) > 0,2),aligned_nodes_ant(aligned_nodes_ant(:,1) > 0,3),'ro')
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
                aligned_nodes_new = aligned_nodes_ant;
            case 'Lateral'
                aligned_nodes_new = (roty(180)*aligned_nodes_ant')';
            case 'Superior'
                aligned_nodes_new = (roty(-90)*aligned_nodes_ant')';
            case 'Inferior'
                aligned_nodes_new = (roty(90)*aligned_nodes_ant')';
        end

        nodes_new = aligned_nodes_new;

        [aligned_nodes, flip_out, tibfib_switch, Rot, Tra, Rr] = icp_template(bone_indx,nodes_new,bone_coord);

            %% Performs coordinate system calculation
    [Temp_Coordinates, Temp_Nodes] = CoordinateSystem(aligned_nodes,bone_indx,bone_coord,tibfib_switch);
    Temp_Coordinates_Unit = Temp_Coordinates/50; % makes it a unit vector...
    % - multiplying it by 50 in the previous function is simply for coordinate system visualization

     %% Reorient and Translate to Original Input Origin and Orientation
    Temp_Nodes_flip = Temp_Nodes*flip_out; % if bone was flipped during alignment, it will flip back
    Temp_Coords_flip = Temp_Coordinates*flip_out;
    Temp_Coordinates_Unit_flip = Temp_Coordinates_Unit*flip_out;
    if side_indx == 1
        Temp_Nodes_flip = Temp_Nodes_flip.*[1,1,-1]; % Flip back to right if applicable
        Temp_Coords_flip = Temp_Coords_flip.*[1,1,-1]; % Flip back to right if applicable
        Temp_Coordinates_Unit_flip = Temp_Coordinates_Unit_flip.*[1,1,-1]; % Flip back to right if applicable
    end
    %     [R_final,T_final,E] = icp(nodes_original',Temp_Nodes_flip',1000,'Matching','kDtree','WorstRejection',0.1);
    %     nodes_final = (R_final*(Temp_Nodes_flip') + repmat(T_final,1,length(Temp_Nodes_flip')))';
    %     coords_final = (R_final*(Temp_Coords_flip') + repmat(T_final,1,length(Temp_Coords_flip')))';
    %     coords_final_unit = (R_final*(Temp_Coordinates_Unit_flip') + repmat(T_final,1,length(Temp_Coordinates_Unit_flip')))';
    if isempty(Rr) == 0
        nodes_final_tempp = (inv(Rr)*(Temp_Nodes_flip'))';
        nodes_final_temp = (nodes_final_tempp' - repmat(Tra,1,length(nodes_final_tempp')))';
        nodes_final = (inv(Rot)*(nodes_final_temp'))';

        coords_final_tempp = (inv(Rr)*(Temp_Coords_flip'))';
        coords_final_temp = (coords_final_tempp' - repmat(Tra,1,length(coords_final_tempp')))';
        coords_final = (inv(Rot)*(coords_final_temp'))';

        coords_final_unit_tempp = (inv(Rr)*(Temp_Coordinates_Unit_flip'))';
        coords_final_unit_temp = (coords_final_unit_tempp' - repmat(Tra,1,length(coords_final_unit_tempp')))';
        coords_final_unit = (inv(Rot)*(coords_final_unit_temp'))';
    else
        nodes_final_temp = (Temp_Nodes_flip' - repmat(Tra,1,length(Temp_Nodes_flip')))';
        nodes_final = (inv(Rot)*(nodes_final_temp'))';

        coords_final_temp = (Temp_Coords_flip' - repmat(Tra,1,length(Temp_Coords_flip')))';
        coords_final = (inv(Rot)*(coords_final_temp'))';

        coords_final_unit_temp = (Temp_Coordinates_Unit_flip' - repmat(Tra,1,length(Temp_Coordinates_Unit_flip')))';
        coords_final_unit = (inv(Rot)*(coords_final_unit_temp'))';
    end

    %% Final Plotting
    figure()
%     plot3(nodes_final(:,1),nodes_final(:,2),nodes_final(:,3),'k.')
    hold on
    % plot3(Temp_Nodes_flip(:,1),Temp_Nodes_flip(:,2),Temp_Nodes_flip(:,3),'r.')
    plot3(nodes_original(:,1),nodes_original(:,2),nodes_original(:,3),'g.')
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
