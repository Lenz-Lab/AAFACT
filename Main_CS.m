%% Main Script for Coordinate System Toolbox
clear, clc, close all

% This main code only requires the users bone model input. Select the
% folder where the file is and then select the bone model(s) you wish the
% apply a coordinate system to.

% Ensure that there are no spaces in the folder name, consider replacing 
% spaces with underscores (_).

% Currently, this code works for all bones from the tibia and fibula
% through the metatarsals. It has an option for multiple coordinate
% systems for the talus and calcaneus. I also can place the origin of the
% coordinate system at a joint surface.

% While it's not neccessary, naming your file with the laterality (_L_ or
% _Left_ etc.) and the name of the bone (_Calcaneus) will speed up the
% process. I recommend a file name similar to this for ease:
% group_#_bone_laterality.stl (ex. ABC_01_Tibia_Right.stl)

% Determine the files in the folder selected
FolderPathName = uigetdir('*.*', 'Select folder with your bones');
files = dir(fullfile(FolderPathName, '*.*'));
files = files(~ismember({files.name},{'.','..'}));

temp = strfind(FolderPathName,'\');
FolderName = FolderPathName(temp(end)+1:end); % Extracts the folder name selected

%% Load all files into list
temp = struct2cell(files);
list_files = temp(1,:);

% Select the models that you want a coordinate system of
[files_indx,~] = listdlg('PromptString',{'Select your bone files'}, 'ListString', list_files, 'SelectionMode','multiple');

all_files = list_files(files_indx)'; % stores all files selected

% Lists for detemining bone and side
list_bone = {'Talus', 'Calcaneus', 'Navicular', 'Cuboid', 'Medial_Cuneiform','Intermediate_Cuneiform',...
    'Lateral_Cuneiform','Metatarsal1','Metatarsal2','Metatarsal3','Metatarsal4','Metatarsal5',...
    'Tibia','Fibula'};
list_bone2 = {'Talus', 'Calcaneus', 'Navicular', 'Cuboid', 'Med_Cuneiform','Int_Cuneiform',...
    'Lat_Cuneiform','First_Metatarsal','Second_Metatarsal','Third_Metatarsal','Fourth_Metatarsal','Fifth_Metatarsal',...
    'Tibia','Fibula'};
list_side_folder = {'Right','_R.','_R_','Left','_L.','_L_'};
list_side = {'Right','Left'};

%% Iterate through each model selected
for m = 1:length(all_files)
    clear bone_indx side_folder_indx side_indx

    % Extract the name and file extension from the file
    FileName = char(all_files(m));
    [~,name,ext] = fileparts(FileName);
    disp(name)
    name_original = name;

    % Looks through the folder name for the bone name
    for n = 1:length(list_bone)
        if any(string(extract(lower(FolderName),lower(list_bone(n)))) == lower(string(list_bone(n)))) ||...
                any(string(extract(lower(FolderName),lower(list_bone2(n)))) == lower(string(list_bone2(n))))
            if exist('bone_indx','var') == 0
                bone_indx = n;
            else
                clear bone_indx
            end
        end
    end

    % If the folder doesn't have the bone name, this looks through the file
    % name for the bone name
    if exist('bone_indx','var') == 0
        for n = 1:length(list_bone)
            if any(string(extract(lower(FileName),lower(list_bone(n)))) == lower(string(list_bone(n)))) ||...
                any(string(extract(lower(FileName),lower(list_bone2(n)))) == lower(string(list_bone2(n))))
                if exist('bone_indx','var') == 0
                    bone_indx = n;
                else
                    clear bone_indx
                end
            end
        end
    end

    % If the folder and the file don't have the bone name, the user must select
    % the bone name
    if exist('bone_indx','var') == 0
        [bone_indx,~] = listdlg('PromptString', [{strcat('Select which bone this file is:'," ",string(FileName))} {''}], 'ListString', list_bone,'SelectionMode','single');
    end

    % Looks through the folder name for the bone side
    for n = 1:length(list_side_folder)
        if any(string(extract(lower(FolderName),lower(list_side_folder(n)))) == lower(string(list_side_folder(n))))
                side_folder_indx = n;
        end
    end

    % If the folder doesn't have the bone side, this looks through the file
    % name for the bone side
    if exist('side_folder_indx','var') == 0
        for n = 1:length(list_side_folder)
            if any(string(extract(lower(FileName),lower(list_side_folder(n)))) == lower(string(list_side_folder(n))))
                side_folder_indx = n;
            end
        end
    end

    % If the folder and the file don't have the bone side, the user must select
    % the bone side
    if exist('side_folder_indx','var') && side_folder_indx <= 3
        side_indx = 1;
    elseif exist('side_folder_indx','var') && side_folder_indx >= 4
        side_indx = 2;
    else
        [side_indx,~] = listdlg('PromptString', [{strcat('Select which side this file is:'," ",string(FileName))} {''}], 'ListString', list_side,'SelectionMode','single');
    end

    %% Load in file based on file type

    if ext == ".k"
        nodes = LoadDataFile(strcat(FolderPathName,'\',FileName));
    elseif ext == ".stl"
        TR = stlread(strcat(FolderPathName,'\',FileName));
        nodes = TR.Points;
        conlist = TR.ConnectivityList;
    elseif ext == ".particles"
        nodes = load(strcat(FolderPathName,'\',FileName));
    elseif ext == ".vtk"
        nodes = LoadDataFile(strcat(FolderPathName,'\',FileName));
    elseif ext == ".ply"
        ptCloud = pcread(strcat(FolderPathName,'\',FileName));
        nodes = ptCloud.Location;
    elseif ext == ".obj"
        obj = readObj(strcat(FolderPathName,'\',FileName));
        nodes = obj.v;
        conlist = obj.f.v;
    else
        disp('This is not an acceptable file type at this time, please choose either a ".k", ".stl", ".vtk", ".obj", ".ply" or ".particles" file type.')
        return
    end

    nodes_original = nodes;
    conlist_original = conlist;

    % Lists of different coordinate systems to choose from
    list_talus = {'Talonavicular CS','Tibiotalar CS','Subtalar CS'};
    list_calcaneus = {'Calcaneocuboid CS','Subtalar CS'};

    if bone_indx == 1
        [bone_coord,~] = listdlg('PromptString', {'Select which talar CS.'}, 'ListString', list_talus,'SelectionMode','multiple');
        cs_string = string(list_talus(bone_coord));
    elseif bone_indx == 2
        [bone_coord,~] = listdlg('PromptString', {'Select which calcaneus CS.'}, 'ListString', list_calcaneus,'SelectionMode','multiple');
        cs_string = string(list_calcaneus(bone_coord));
    else
        bone_coord = 1;
        cs_string = "";
    end

    %% Loop for each desired Coordinate System
    for n = 1:length(bone_coord)
        nodes = nodes_original;
        conlist = conlist_original;
        name = name_original;

        if side_indx == 1
            nodes = nodes.*[1,1,-1]; % Flip all rights to left
            conlist = [conlist(:,3) conlist(:,2) conlist(:,1)];
        end

        if bone_indx == 1
            list_joint = {'Center','Talonavicular Surface','Tibiotalar Surface', 'Subtalar Surface'};
        elseif bone_indx == 2
            list_joint = {'Center','Calcaneocuboid Surface', 'Subtalar Surface'};
        elseif bone_indx == 3
            list_joint = {'Center','Talonavicular Surface','Navicular-Cuneiform Surface'};
        elseif bone_indx == 4
            list_joint = {'Center','Calcaneocuboid Surface'};
        elseif bone_indx == 5 || bone_indx == 7
            list_joint = {'Center','Navicular-Cuneiform Surface', 'Cuneiform-Metatarsal Surface', 'Intercuneiform Surface'};
        elseif bone_indx == 6
            list_joint = {'Center','Navicular-Cuneiform Surface', 'Cuneiform-Metatarsal Surface', 'Medial Intercuneiform Surface', 'Lateral Intercuneiform Surface'};
        elseif bone_indx >= 8 && bone_indx <= 12
            list_joint = {'Center','Posterior Metatarsal Surface'};
        elseif bone_indx == 13
            list_joint = {'Center','Tibiotalar Surface'};
        elseif bone_indx == 14
            list_joint = {'Center','Talofibular Surface'};
        end

        [joint_indx,~] = listdlg('PromptString', [{strcat('Where do you want the origin?'," ",cs_string(n))} {''}], 'ListString', list_joint,'SelectionMode','single');

        if (bone_indx == 13 || bone_indx == 14) && length(joint_indx) > 1
            bone_coord = 1:2;
        elseif (bone_indx == 13 || bone_indx == 14) && joint_indx == 1
            bone_coord = 1;
        elseif (bone_indx == 13 || bone_indx == 14) && joint_indx == 2
            bone_coord = 2;
        end

        %% ICP to Template
        % Align users model to the prealigned template model. This orients the
        % model in a fashion that the superior region is in the positive Z
        % direction, the anterior region is in the positive Y direction, and the
        % medial region is in the positive X direction.
        [nodes,cm_nodes] = center(nodes,1);
        better_start = 1;
        [aligned_nodes, RTs] = icp_template(bone_indx, nodes, bone_coord(n), better_start);

        %% Performs coordinate system calculation
        [Temp_Coordinates, Temp_Nodes, MDTA, TLSA, SVA] = CoordinateSystem(aligned_nodes, bone_indx, bone_coord(n),side_indx);

        %% Joint Origin
        if joint_indx > 1
            [Temp_Coordinates, Joint] = JointOrigin(Temp_Coordinates, Temp_Nodes, conlist, bone_indx, joint_indx, side_indx);
        else
            Joint = "Center";
        end

        %% Temporarily Attach Coordinate System
        Temp_Nodes_Coords = [Temp_Nodes; Temp_Coordinates; MDTA; TLSA; SVA];

        %% Reorient and Translate to Original Input Origin and Orientation
        [nodes_final, coords_final, coords_final_unit, Temp_Coordinates_Unit, MDTA_final, TLSA_final, SVA_final] = reorient(Temp_Nodes_Coords, cm_nodes, side_indx, RTs);

        if bone_indx == 1 && bone_coord(n) == 3 % Additional alignment for talus subtalar ACS
            [aligned_nodes_TST, RTs_TST] = icp_template(bone_indx, nodes, 1, better_start);
            [Temp_Coordinates_TST, Temp_Nodes_TST] = CoordinateSystem(aligned_nodes_TST, bone_indx, 1, side_indx);

            if joint_indx > 1
                [Temp_Coordinates_TST, Joint] = JointOrigin(Temp_Coordinates_TST, Temp_Nodes_TST, conlist, bone_indx, joint_indx, side_indx);
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

        %% Similarity
        max_Z = similaritytest(Temp_Coordinates_Unit, bone_indx, bone_coord(n));
        crit_Z = 1.645; % alpha = 0.05

        if max_Z <= crit_Z
            fprintf(strcat('The Coordinate System is SIMILAR to existing data\n'))
        else
            fprintf(strcat('The Coordinate System may be DIFFERENT than existing data, double check figure\n'))
        end

        %% Final Plotting
        screen_size = get(0, 'ScreenSize');
        fig_width = 800;
        fig_height = 600;
        fig_left = (screen_size(3) - fig_width) / 2;
        fig_bottom = (screen_size(4) - fig_height) / 2;

        fig1 = figure('Position', [fig_left, fig_bottom+15, fig_width, fig_height]);
        if ext == ".stl"
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
        arrow(coords_final(1,:),coords_final(2,:),'FaceColor','g','EdgeColor','g','LineWidth',5,'Length',10)
        arrow(coords_final(3,:),coords_final(4,:),'FaceColor','b','EdgeColor','b','LineWidth',5,'Length',10)
        arrow(coords_final(5,:),coords_final(6,:),'FaceColor','r','EdgeColor','r','LineWidth',5,'Length',10)
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

        if bone_indx == 1 && bone_coord(n) == 1
            name = strcat('TN_',name);
        elseif bone_indx == 1 && bone_coord(n) == 2
            name = strcat('TT_',name);
        elseif bone_indx == 1 && bone_coord(n) == 3
            name = strcat('ST_',name);
        elseif bone_indx == 2 && bone_coord(n) == 1
            name = strcat('CC_',name);
        elseif bone_indx == 2 && bone_coord(n) == 2
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


        if bone_indx == 13
            writematrix(MDTA_final,xlfilename,'Sheet',name,'Range','B16');
            writematrix(TLSA_final,xlfilename,'Sheet',name,'Range','B18');
        elseif bone_indx == 2 && bone_coord == 1
            writematrix(SVA_final,xlfilename,'Sheet',name,'Range','B16');
        end

        %% Better Starting Point
        if length(all_files) == 1 && length(bone_coord) == 1
            fig2_pos = [(screen_size(3) - 500) / 2, 50, 500, 175];
            fig2 = uifigure('Position',fig2_pos);
            accurate_answer = uiconfirm(fig2,'Is the coordinate system accurately assigned to the model?',...
                'Coordinate System','Options',{'Yes','No'},'DefaultOption',1);
            delete(fig2)
            better_starting_point(accurate_answer,nodes,bone_indx,bone_coord(n),side_indx,FileName,name,list_bone,list_side,FolderPathName,FolderName,cm_nodes,nodes_original,joint_indx,conlist,ext)
        end

        %% Clear Variables for New Loop
        vars = {'Temp_Nodes', 'Temp_Coordinates', 'Temp_Coordinates_Unit', 'Temp_Nodes_Coords', 'cm_nodes', 'RTs', 'coords_final','coords_final_unit','nodes','aligned_nodes','name','conlist'};
        clear(vars{:})

    end
end
