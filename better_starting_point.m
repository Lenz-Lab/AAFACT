function RTs = better_starting_point(accurate_answer,nodes,bone_indx,bone_coord,side_indx,FileName,name,list_bone,list_side,FolderPathName,FolderName,cm_nodes,nodes_original,joint_indx,conlist,conlist_original)
% This function allows the user to choose a better starting point for their
% bone model if the icp alignment isn't working. This is only ran if you
% run a single bone, single ACS and select that it wasn't appropriate.

switch accurate_answer
    case 'Yes'
        % Has the user tell the program which way the bone is facing
        screen_size = get(0, 'ScreenSize');
        fig_width = 800;
        fig_height = 600;
        fig_left = (screen_size(3) - fig_width) / 2;
        fig_bottom = (screen_size(4) - fig_height) / 2;

        % ===== STEP 1: +Y hemisphere (YELLOW), one menu with 6 options =====
        fig3 = figure('Position', [fig_left, fig_bottom+15, fig_width, fig_height], 'Color','w');
        maskY = nodes(:,2) > 0; if ~any(maskY), maskY = nodes(:,2) >= 0; end
        plot3(nodes(~maskY,1),nodes(~maskY,2),nodes(~maskY,3),'.','Color',[0.4 0.4 0.4]); hold on
        plot3(nodes( maskY,1),nodes( maskY,2),nodes( maskY,3),'o','MarkerEdgeColor','none','MarkerFaceColor',[1 1 0],'MarkerSize',5)
        xlabel('X'); ylabel('Y'); zlabel('Z'); axis equal; grid on; rotate3d on
        title('Rotate freely. Highlighted points are +Y (YELLOW).')

        choices6 = {'Anterior','Posterior','Medial','Lateral','Superior','Inferior'};
        selY = menu('Which anatomical direction does the YELLOW (+Y) hemisphere point toward?', choices6{:});
        if selY == 0, error('Selection cancelled.'); end
        ant_selection = choices6{selY};

        delete(fig3);

        % Map +Y answer to same rotations you used before
        switch ant_selection
            case 'Anterior'
                R_yellow = rotz(0);
                nodes_ant = nodes;
            case 'Posterior'
                R_yellow = rotz(180);
                nodes_ant = (R_yellow*nodes')';
            case 'Medial'
                R_yellow = rotz(-90);
                nodes_ant = (R_yellow*nodes')';
            case 'Lateral'
                R_yellow = rotz(90);
                nodes_ant = (R_yellow*nodes')';
            case 'Superior'
                R_yellow = rotz(90);
                nodes_ant = (R_yellow*nodes')';
            case 'Inferior'
                R_yellow = rotz(-90);
                nodes_ant = (R_yellow*nodes')';
        end

        % ===== STEP 2: +X hemisphere (RED), one menu with 4 options =====
        fig8 = figure('Position', [fig_left, fig_bottom+15, fig_width, fig_height], 'Color','w');
        plot3(nodes_ant(:,1),nodes_ant(:,2),nodes_ant(:,3),'k.'); hold on
        maskX = nodes_ant(:,1) > 0; if ~any(maskX), maskX = nodes_ant(:,1) >= 0; end
        plot3(nodes_ant(maskX,1),nodes_ant(maskX,2),nodes_ant(maskX,3),'o','MarkerEdgeColor','none','MarkerFaceColor',[1 0 0],'MarkerSize',5)
        xlabel('X'); ylabel('Y'); zlabel('Z'); axis equal; grid on; rotate3d on
        title('Rotate freely. Highlighted points are +X (RED).')

        choices4 = {'Medial','Lateral','Superior','Inferior'};
        selX = menu('Which anatomical direction does the RED (+X) hemisphere point toward?', choices4{:});
        if selX == 0, error('Selection cancelled.'); end
        med1_selection = choices4{selX};

        delete(fig8);

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

        %% Performs coordinate system calculation
        [Temp_Coordinates, Temp_Nodes] = CoordinateSystem(aligned_nodes, bone_indx, bone_coord,side_indx);

        %% Joint Origin
        if joint_indx > 1
            if isempty(conlist)
                Joint = "Center";
            else
                [Temp_Coordinates, Joint] = JointOrigin(Temp_Coordinates, Temp_Nodes, conlist, bone_indx, joint_indx, side_indx);
            end
        else
            Joint = "Center";
        end

        %% Temporarily Attach Coordinate System
        Temp_Nodes_Coords = [Temp_Nodes; Temp_Coordinates];

        %% Reorient and Translate to Original Input Origin and Orientation
        [~, coords_final, coords_final_unit, Temp_Coordinates_Unit] = reorient(Temp_Nodes_Coords, cm_nodes, side_indx, RTs);

        if bone_indx == 1 && bone_coord == 3 % Additional alignment for talus subtalar ACS
            [aligned_nodes_TST, RTs_TST] = icp_template(bone_indx, nodes_new, 1, better_start);
            [Temp_Coordinates_TST, Temp_Nodes_TST] = CoordinateSystem(aligned_nodes_TST, bone_indx, 1, side_indx);

            if joint_indx > 1
                if isempty(conlist)
                    Joint = "Center";
                else
                    [Temp_Coordinates_TST, Joint] = JointOrigin(Temp_Coordinates_TST, Temp_Nodes_TST, conlist, bone_indx, joint_indx);
                end
            else
                Joint = "Center";
            end

            Temp_Nodes_Coords_TST = [Temp_Nodes_TST; Temp_Coordinates_TST];

            [~, coords_final_TST, coords_final_unit_TST, Temp_Coordinates_Unit_TST] = reorient(Temp_Nodes_Coords_TST, cm_nodes, side_indx, RTs_TST);

            coords_final = [coords_final(1,:); ((coords_final_TST(2,:) + coords_final(2,:)).'/2)'
                coords_final(3,:); ((coords_final_TST(4,:) + coords_final(4,:)).'/2)'
                coords_final(5,:); ((coords_final_TST(6,:) + coords_final(6,:)).'/2)'];

            coords_final_unit = [coords_final_unit(1,:); ((coords_final_unit_TST(2,:) + coords_final_unit(2,:)).'/2)'
                coords_final_unit(3,:); ((coords_final_unit_TST(4,:) + coords_final_unit(4,:)).'/2)'
                coords_final_unit(5,:); ((coords_final_unit_TST(6,:) + coords_final_unit(6,:)).'/2)'];

            Temp_Coordinates_Unit = [Temp_Coordinates_Unit(1,:); ((Temp_Coordinates_Unit_TST(2,:) + Temp_Coordinates_Unit(2,:)).'/2)'
                Temp_Coordinates_Unit(3,:); ((Temp_Coordinates_Unit_TST(4,:) + Temp_Coordinates_Unit(4,:)).'/2)'
                Temp_Coordinates_Unit(5,:); ((Temp_Coordinates_Unit_TST(6,:) + Temp_Coordinates_Unit(6,:)).'/2)'];
        end

        %% Final Plotting
        screen_size = get(0, 'ScreenSize');
        fig_width = 800;
        fig_height = 600;
        fig_left = (screen_size(3) - fig_width) / 2;
        fig_bottom = (screen_size(4) - fig_height) / 2;

        fig10 = figure('Position', [fig_left, fig_bottom+15, fig_width, fig_height]);
        if ~isempty(conlist_original)
            Final_Bone = triangulation(conlist,nodes_original);
            patch('Faces',Final_Bone.ConnectivityList,'Vertices',Final_Bone.Points,...
                'FaceColor', [0.85 0.85 0.85], ...
                'EdgeColor','none',...
                'FaceLighting','gouraud',...
                'AmbientStrength', 0.15);
            view([-15 20])
            camlight HEADLIGHT
            material('dull');
        else
            plot3(nodes_original(:,1),nodes_original(:,2),nodes_original(:,3),'k.')
            view([-15 20])
        end
        hold on
        plot_arrow_quiver(coords_final(1,:),coords_final(2,:),[0 1 0],5,10)
        plot_arrow_quiver(coords_final(3,:),coords_final(4,:),[0 0 1],5,10)
        plot_arrow_quiver(coords_final(5,:),coords_final(6,:),[1 0 0],5,10)
        legend(' Nodal Points',' AP Axis',' SI Axis',' ML Axis')
        title(strcat('Coordinate System of'," ", char(FileName)),'Interpreter','none')
        text(coords_final(2,1),coords_final(2,2),coords_final(2,3),'   Anterior','HorizontalAlignment','left','FontSize',15,'Color','g');
        text(coords_final(4,1),coords_final(4,2),coords_final(4,3),'   Superior','HorizontalAlignment','left','FontSize',15,'Color','b');
        if side_indx == 1
            text(coords_final(6,1),coords_final(6,2),coords_final(6,3),'   Lateral','HorizontalAlignment','left','FontSize',15,'Color','r');
        else
            text(coords_final(6,1),coords_final(6,2),coords_final(6,3),'   Medial','HorizontalAlignment','left','FontSize',15,'Color','r');
        end
        grid off
        axis off
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