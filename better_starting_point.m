function RTs = better_starting_point(accurate_answer,nodes,bone_indx,bone_coord,side_indx,FileName,name,list_bone,list_side,FolderPathName,FolderName,cm_nodes,nodes_original,joint_indx,conlist,conlist_original)
% This function allows the user to choose a better starting point for their
% bone model if the icp alignment isn't working. This is only ran if you
% run a single bone, single ACS and select that it wasn't appropriate.
%
% The user is shown the bone twice and asked which anatomical direction
% the highlighted half faces. Those answers give a rough rotation that
% puts the bone close to the template orientation (+Y anterior, +X
% medial). icp_template is then run from that single start
% (better_start = 2) and the rest of the Main_CS pipeline is repeated.
% The result overwrites the same sheet of the Excel file.
%
% Most inputs are passed straight through from Main_CS:
%   accurate_answer  'Yes' to run (anything else does nothing)
%   nodes            centered nodes (rights already mirrored to left)
%   nodes_original   the untouched input nodes, used for the final plot
%   cm_nodes         centroid removed from nodes, used by reorient
%   conlist / conlist_original  mesh faces (mirrored / original winding)
%   name, list_bone, list_side, FolderPathName, FolderName  used to name
%                    and write the Excel output
%
% Output:
%   RTs  the transforms from this run, including the manual starting
%        rotation in RTs.yellow (RTs.red is identity)

switch accurate_answer
    case 'Yes'
        % Has the user tell the program which way the bone is facing
        % (figure size/position: 800x600 centered on the screen)
        screen_size = get(0, 'ScreenSize');
        fig_width = 800;
        fig_height = 600;
        fig_left = (screen_size(3) - fig_width) / 2;
        fig_bottom = (screen_size(4) - fig_height) / 2;

        % ===== STEP 1: +Y hemisphere (YELLOW), one menu with 6 options =====
        % Highlight the +Y half of the bone and ask where it points
        fig3 = figure('Position', [fig_left, fig_bottom+15, fig_width, fig_height], 'Color','w');
        % Fall back to >= 0 in the unlikely case no node has y > 0
        maskY = nodes(:,2) > 0; if ~any(maskY), maskY = nodes(:,2) >= 0; end
        plot3(nodes(~maskY,1),nodes(~maskY,2),nodes(~maskY,3),'.','Color',[0.4 0.4 0.4]); hold on
        plot3(nodes( maskY,1),nodes( maskY,2),nodes( maskY,3),'o','MarkerEdgeColor','none','MarkerFaceColor',[1 1 0],'MarkerSize',5)
        xlabel('X'); ylabel('Y'); zlabel('Z'); axis equal; grid on; rotate3d on
        title('Rotate freely. Highlighted points are +Y (YELLOW).')

        % Direction in the template frame (+X medial, +Y anterior,
        % +Z superior) that matches each anatomical answer
        choices6 = {'Anterior','Posterior','Medial','Lateral','Superior','Inferior'};
        template_dirs = [0 1 0; 0 -1 0; 1 0 0; -1 0 0; 0 0 1; 0 0 -1];

        selY = menu('Which anatomical direction does the YELLOW (+Y) hemisphere point toward?', choices6{:});
        if selY == 0, error('Selection cancelled.'); end
        y_dir = template_dirs(selY,:); % where the bone's current +Y belongs

        delete(fig3);

        % ===== STEP 2: +X hemisphere (RED), one menu with 4 options =====
        % Same bone in the same orientation: highlight +X and ask where it
        % points. +X is perpendicular to +Y, so only the four directions
        % perpendicular to the step 1 answer are offered.
        fig8 = figure('Position', [fig_left, fig_bottom+15, fig_width, fig_height], 'Color','w');
        plot3(nodes(:,1),nodes(:,2),nodes(:,3),'k.'); hold on
        maskX = nodes(:,1) > 0; if ~any(maskX), maskX = nodes(:,1) >= 0; end
        plot3(nodes(maskX,1),nodes(maskX,2),nodes(maskX,3),'o','MarkerEdgeColor','none','MarkerFaceColor',[1 0 0],'MarkerSize',5)
        xlabel('X'); ylabel('Y'); zlabel('Z'); axis equal; grid on; rotate3d on
        title('Rotate freely. Highlighted points are +X (RED).')

        perp_indx = find(template_dirs * y_dir' == 0);
        choices4 = choices6(perp_indx);
        selX = menu('Which anatomical direction does the RED (+X) hemisphere point toward?', choices4{:});
        if selX == 0, error('Selection cancelled.'); end
        x_dir = template_dirs(perp_indx(selX),:); % where the bone's current +X belongs

        delete(fig8);

        % The two answers say where the bone's current X and Y axes belong
        % in the template frame, which fixes the rotation completely: its
        % columns are the new directions of the current X, Y and Z axes.
        % (Z = X cross Y keeps it a proper rotation, not a reflection.)
        R_start = [x_dir', y_dir', cross(x_dir, y_dir)'];
        nodes_new = (R_start*nodes')';

        close all
        % Align from the hand-picked orientation only (no rotation search)
        better_start = 2;
        [aligned_nodes, RTs] = icp_template(bone_indx, nodes_new, bone_coord, better_start);
        % Record the manual rotation so reorient can undo it. reorient
        % undoes RTs.red and then RTs.yellow; the whole rotation is stored
        % in RTs.yellow and RTs.red is left as identity.
        RTs.red = eye(3);
        RTs.yellow = R_start;

        % The remaining steps repeat the Main_CS pipeline for this bone

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
            % The ST ACS combines the ACS above with a TN ACS (bone_coord 1),
            % the same way as Main_CS.
            [aligned_nodes_TST, RTs_TST] = icp_template(bone_indx, nodes_new, 1, better_start);
            % This ACS also started from the manually rotated bone, so
            % reorient must undo the same manual rotation
            RTs_TST.red = RTs.red;
            RTs_TST.yellow = RTs.yellow;
            [Temp_Coordinates_TST, Temp_Nodes_TST] = CoordinateSystem(aligned_nodes_TST, bone_indx, 1, side_indx);

            if joint_indx > 1
                if isempty(conlist)
                    Joint = "Center";
                else
                    [Temp_Coordinates_TST, Joint] = JointOrigin(Temp_Coordinates_TST, Temp_Nodes_TST, conlist, bone_indx, joint_indx, side_indx);
                end
            else
                Joint = "Center";
            end

            Temp_Nodes_Coords_TST = [Temp_Nodes_TST; Temp_Coordinates_TST];

            [~, coords_final_TST, coords_final_unit_TST, Temp_Coordinates_Unit_TST] = reorient(Temp_Nodes_Coords_TST, cm_nodes, side_indx, RTs_TST);

            % Average the axis directions of the two ACSs and
            % re-orthogonalize them (origins come from the first ACS)
            coords_final = AverageOrthogonalAxes(coords_final, coords_final_TST);
            coords_final_unit = AverageOrthogonalAxes(coords_final_unit, coords_final_unit_TST);
            Temp_Coordinates_Unit = AverageOrthogonalAxes(Temp_Coordinates_Unit, Temp_Coordinates_Unit_TST);
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
        % AP = green, SI = blue, ML = red
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
        % Same layout as Main_CS (see the comments there); writes to the
        % sheet named "name", replacing the earlier result
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