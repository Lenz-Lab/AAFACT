%% Main Script for Coordinate System Toolbox
clear, clc, close all

% Determine the files in the folder selected
FolderPathName = uigetdir('*.*', 'Select folder with your bones');
addpath(FolderPathName)
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
    'Lateral_Cuneiform','First_Metatarsal','Second_Metatarsal','Third_Metatarsal','Fourth_Metatarsal','Fifth_Metatarsal',...
    'Tibia','Fibula'};
list_side_folder = {'Right','_R','Left','_L'};
list_side = {'Right','Left'};

%% Iterate through each model selected
for m = 1:length(all_files)
    clear bone_indx side_folder_indx side_indx

    % Extract the name and file extension from the file
    FileName = char(all_files(m));
    [~,name,ext] = fileparts(FileName);
    disp(name)

    % Looks through the folder name for the bone name
    for n = 1:length(list_bone)
        if any(string(extract(FolderName,list_bone(n))) == string(list_bone(n))) ||...
                any(string(extract(FolderName,lower(list_bone(n)))) == lower(string(list_bone(n)))) ||...
                any(string(extract(FolderName,upper(list_bone(n)))) == upper(string(list_bone(n))))
            bone_indx = n;
        end
    end

    % If the folder doesn't have the bone name, this looks through the file
    % name for the bone name
    if exist('bone_indx') == 0
        for n = 1:length(list_bone)
            if any(string(extract(FileName,list_bone(n))) == string(list_bone(n))) ||...
                    any(string(extract(FileName,lower(list_bone(n)))) == lower(string(list_bone(n)))) ||...
                    any(string(extract(FileName,upper(list_bone(n)))) == upper(string(list_bone(n))))
                bone_indx = n;
            end
        end
    end

    % If the folder and the file don't have the bone name, the user must select
    % the bone name
    if exist('bone_indx') == 0
        [bone_indx,~] = listdlg('PromptString', {strcat('Select which bone this file is:'," ",string(FileName))}, 'ListString', list_bone,'SelectionMode','single');
    end

    % Looks through the folder name for the bone side
    for n = 1:length(list_side_folder)
        if any(string(extract(FolderName,list_side_folder(n))) == string(list_side_folder(n))) ||...
                any(string(extract(FolderName,lower(list_side_folder(n)))) == lower(string(list_side_folder(n)))) ||...
                any(string(extract(FolderName,upper(list_side_folder(n)))) == upper(string(list_side_folder(n))))
            side_folder_indx = n;
        end
    end

    % If the folder doesn't have the bone side, this looks through the file
    % name for the bone side
    if exist('side_folder_indx') == 0
        for n = 1:length(list_side_folder)
            if any(string(extract(FileName,list_side_folder(n))) == string(list_side_folder(n))) ||...
                    any(string(extract(FileName,lower(list_side_folder(n)))) == lower(string(list_side_folder(n)))) ||...
                    any(string(extract(FileName,upper(list_side_folder(n)))) == upper(string(list_side_folder(n))))
                side_folder_indx = n;
            end
        end
    end

    % If the folder and the file don't have the bone side, the user must select
    % the bone side
    if exist('side_folder_indx') && side_folder_indx <= 2
        side_indx = 1;
    elseif exist('side_folder_indx') && side_folder_indx >= 3
        side_indx = 2;
    else
        [side_indx,~] = listdlg('PromptString', {strcat('Select which side this file is:'," ",string(FileName))}, 'ListString', list_side,'SelectionMode','single');
    end

    %% Load in file based on file type
    if ext == ".k"
        nodes = LoadKFile(FileName);
    elseif ext == ".stl"
        TR = stlread(FileName);
        nodes = TR.Points;
        conlist = TR.ConnectivityList;
    elseif ext == ".particles"
        nodes = load(FileName);
    elseif ext == ".vtk"
        nodes = LoadVTKFile(FileName);
    elseif ext == ".ply"
        ptCloud = pcread(FileName);
        nodes = ptCloud.Location;
    else
        disp('This is not an acceptable file type at this time, please choose either a ".k", ".stl", ".vtk", ".ply" or ".particles" file type.')
        return
    end

    nodes_original = nodes;

    if side_indx == 1
        nodes = nodes.*[1,1,-1]; % Flip all rights to left
    end

    list_talus = {'Talonavicular CS','Tibiotalar/Subtalar CS'};
    list_tibia = {'Center of Mass CS','Center of Tibiotalar Facet CS'};
    list_fibula = {'Center of Mass CS','Center of Talofibular Facet CS'};
    list_yesno = {'Yes','No'};

    if bone_indx == 1
        %         [bone_coord,~] = listdlg('PromptString', {'Select which talar CS.'}, 'ListString', list_talus,'SelectionMode','single');
        bone_coord = 2;
    elseif bone_indx == 13
        [bone_coord,~] = listdlg('PromptString', {'Select which tibia CS.'}, 'ListString', list_tibia,'SelectionMode','single');
        %         bone_coord = 2;
    elseif bone_indx == 14
        [bone_coord,~] = listdlg('PromptString', {'Select which fibula CS.'}, 'ListString', list_fibula,'SelectionMode','single');
        %     bone_coord = 2;
    else
        bone_coord = [];
    end

    %% Plot Original
        figure()
        plot3(nodes(:,1),nodes(:,2),nodes(:,3),'k.')
        hold on
        plot3(nodes_original(:,1),nodes_original(:,2),nodes_original(:,3),'ro')
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal

    %% ICP to Template
    % Align users model to the prealigned template model. This orients the
    % model in a fashion that the superior region is in the positive Z
    % direction, the anterior region is in the positive Y direction, and the
    % medial region is in the positive X direction.
    [aligned_nodes, flip_out, tibfib_switch, Rot, Tra, Rr, cm_nodes] = icp_template(bone_indx,nodes,bone_coord);

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
        nodes_final = [nodes_final_tem(:,1) + cm_nodes(1), nodes_final_tem(:,2) + cm_nodes(2), nodes_final_tem(:,3) + cm_nodes(3)];

        coords_final_tempt = (Temp_Coordinates' - repmat(Tra,1,length(Temp_Coordinates')))';
        coords_final_temp = (inv(Rot)*(coords_final_tempt'))';
        coords_final_tem = ((coords_final_temp)*inv(flip_out));
        coords_final = [coords_final_tem(:,1) + cm_nodes(1), coords_final_tem(:,2) + cm_nodes(2), coords_final_tem(:,3) + cm_nodes(3)];

        coords_final_unit_tempt = (Temp_Coordinates_Unit' - repmat(Tra,1,length(Temp_Coordinates_Unit')))';
        coords_final_unit_temp = (inv(Rot)*(coords_final_unit_tempt'))';
        coords_final_unit_tem = ((coords_final_unit_temp)*inv(flip_out));
        coords_final_unit = [coords_final_unit_tem(:,1) + cm_nodes(1), coords_final_unit_tem(:,2) + cm_nodes(2), coords_final_unit_tem(:,3) + cm_nodes(3)];
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

%% Manual Orientation
if length(all_files) == 1 || any(isnan(coords_final_unit(:,:)))
    accurate_answer = questdlg('Is the coordinate system accurately assigned to the model?',...
        'Coordiante System','Yes','No','Yes');
    manual_orientation(accurate_answer,aligned_nodes,bone_indx,bone_coord,side_indx,FileName,name,list_bone,list_side,FolderPathName,FolderName)
end

