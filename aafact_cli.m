function aafact_cli(inputFolder)
%AAFACT_CLI Non-interactive AAFACT entrypoint (compile-friendly)
% Defaults:
%   - All coordinate systems (when multiple exist)
%   - Origin at Center
%   - No plots
%
% Usage (MATLAB):
%   aafact_cli("C:\bones")
%
% Usage (compiled):
%   AAFACT.exe "C:\bones"
%
% Notes:
% - Requires files to include bone name + side in filename or folder:
%   e.g. ABC_01_Tibia_Right.stl

inputFolder  = string(inputFolder);
outputFolder = string(inputFolder);

if ~isfolder(inputFolder)
    error("Input folder not found: %s", inputFolder);
end
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end

% ----- Supported extensions -----
exts = [".stl",".obj",".ply",".vtk",".particles",".k"];

% ----- Find files -----
d = dir(inputFolder);
d = d(~[d.isdir]);
keep = false(size(d));
for i = 1:numel(d)
    [~,~,e] = fileparts(d(i).name);
    keep(i) = any(strcmpi(e, exts));
end
d = d(keep);

if isempty(d)
    error("No supported files found in: %s", inputFolder);
end

% Lists for determining bone and side (same as Main_CS)
list_bone = {'Talus','Calcaneus','Navicular','Cuboid','Medial_Cuneiform','Intermediate_Cuneiform',...
    'Lateral_Cuneiform','Metatarsal1','Metatarsal2','Metatarsal3','Metatarsal4','Metatarsal5',...
    'Tibia','Fibula'};
list_bone2 = {'Talus','Calcaneus','Navicular','Cuboid','Med_Cuneiform','Int_Cuneiform',...
    'Lat_Cuneiform','First_Metatarsal','Second_Metatarsal','Third_Metatarsal','Fourth_Metatarsal','Fifth_Metatarsal',...
    'Tibia','Fibula'};
list_side_folder = {'Right','_R.','_R_','Left','_L.','_L_'};
list_side = {'Right','Left'};

% Output Excel path (cross-platform)
[~, FolderName] = fileparts(char(inputFolder));     % FolderName as char
xlfilename = fullfile(char(outputFolder), sprintf('CoordinateSystem_%s.xlsx', FolderName));

fprintf("AAFACT CLI\n");
fprintf("Input : %s\n", inputFolder);
fprintf("Output: %s\n", outputFolder);
fprintf("Excel : %s\n\n", xlfilename);

% ----- Loop all files -----
for m = 1:numel(d)
    FileName = string(d(m).name);
    fullpath = fullfile(inputFolder, FileName);
    [~,name,ext] = fileparts(FileName);

    fprintf("Processing (%d/%d): %s\n", m, numel(d), FileName);

    % --- Detect bone ---
    bone_indx = detectBoneIndex(FileName, FolderName, list_bone, list_bone2);
    if isempty(bone_indx)
        error("Could not detect bone for: %s. Include bone name in filename or folder.", FileName);
    end

    % --- Detect side ---
    side_indx = detectSideIndex(FileName, FolderName, list_side_folder);
    if isempty(side_indx)
        error("Could not detect side for: %s. Include _Left_/_Right_ or similar.", FileName);
    end

    % --- Load mesh ---
    [nodes, conlist] = loadMeshByExtension(fullpath, ext);

    nodes_original   = nodes;
    conlist_original = conlist;
    name_original    = name;

    % --- Choose ALL coordinate systems for this bone type ---
    bone_coord = defaultAllCSForBone(bone_indx);

    % --- Origin at Center ---
    joint_indx = 1;  % Center

    % ----- Loop each desired CS -----
    for n = 1:numel(bone_coord)
        nodes   = nodes_original;
        conlist = conlist_original;
        name    = name_original;

        % Flip rights to left (same as Main_CS)
        if side_indx == 1
            nodes = nodes .* [1,1,-1];
            if ~isempty(conlist)
                conlist = [conlist(:,3) conlist(:,2) conlist(:,1)];
            end
        end

        % ICP to Template
        [nodes,cm_nodes] = center(nodes,1);
        better_start = 1;
        [aligned_nodes, RTs] = icp_template(bone_indx, nodes, bone_coord(n), better_start);

        % Coordinate system calculation
        [Temp_Coordinates, Temp_Nodes] = CoordinateSystem(aligned_nodes, bone_indx, bone_coord(n), side_indx);

        % Joint Origin (Center)
        Joint = "Center";

        % Temporarily attach coordinate system
        Temp_Nodes_Coords = [Temp_Nodes; Temp_Coordinates];

        % Reorient + translate back
        [~, coords_final, coords_final_unit, Temp_Coordinates_Unit] = reorient(Temp_Nodes_Coords, cm_nodes, side_indx, RTs);

        % Special: Talus subtalar ACS adjustment (kept from your script)
        if bone_indx == 1 && bone_coord(n) == 3
            [aligned_nodes_TST, RTs_TST] = icp_template(bone_indx, nodes, 1, better_start);
            [Temp_Coordinates_TST, Temp_Nodes_TST] = CoordinateSystem(aligned_nodes_TST, bone_indx, 1, side_indx);

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

        % Similarity test (kept)
        % max_Z = similaritytest(Temp_Coordinates_Unit, bone_indx, bone_coord(n));
        % crit_Z = 1.645; % alpha = 0.05
        % if max_Z <= crit_Z
        %     fprintf("  Similarity: SIMILAR (Z=%.3f)\n", max_Z);
        % else
        %     fprintf("  Similarity: POSSIBLY DIFFERENT (Z=%.3f)\n", max_Z);
        % end

        % ----- Save to Excel (same layout as your script) -----
        A = ["Subject"; "Bone Model"; "Side"];
        B = [string(name); string(list_bone(bone_indx)); string(list_side(side_indx))];
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

        % Prefix sheet name (same rules)
        sheet = prefixSheetName(string(name), bone_indx, bone_coord(n));
        if strlength(sheet) > 31
            sheet = extractBefore(sheet, 32);
        end

        % Try writing a few times (same strategy)
        for try_index = 1:5
            try
                writematrix(A, xlfilename, 'Sheet', sheet);
                writecell(cellstr(B), xlfilename, 'Sheet', sheet, 'Range', 'B1');
                writematrix(C, xlfilename, 'Sheet', sheet, 'Range', 'A5');
                writematrix(D, xlfilename, 'Sheet', sheet, 'Range', 'B5');
                writematrix(D, xlfilename, 'Sheet', sheet, 'Range', 'B10');
                writematrix(coords_final_unit(1,:), xlfilename, 'Sheet', sheet, 'Range', 'B6');
                writematrix(coords_final_unit(2,:), xlfilename, 'Sheet', sheet, 'Range', 'B7');
                writematrix(coords_final_unit(4,:), xlfilename, 'Sheet', sheet, 'Range', 'B8');
                writematrix(coords_final_unit(6,:), xlfilename, 'Sheet', sheet, 'Range', 'B9');
                writematrix(Temp_Coordinates_Unit(1,:), xlfilename, 'Sheet', sheet, 'Range', 'B11');
                writematrix(Temp_Coordinates_Unit(2,:), xlfilename, 'Sheet', sheet, 'Range', 'B12');
                writematrix(Temp_Coordinates_Unit(4,:), xlfilename, 'Sheet', sheet, 'Range', 'B13');
                writematrix(Temp_Coordinates_Unit(6,:), xlfilename, 'Sheet', sheet, 'Range', 'B14');
                break;
            catch ME
                fprintf("  Excel write failed (attempt %d): %s\n", try_index, ME.message);
                pause(0.2);
            end
        end

    end
end

fprintf("\nDone.\nExcel written to: %s\n", xlfilename);
end


% ===================== Helper functions =====================

function bone_indx = detectBoneIndex(FileName, FolderName, list_bone, list_bone2)
bone_indx = [];
for n = 1:numel(list_bone)
    if contains(lower(FolderName), lower(list_bone{n})) || contains(lower(FolderName), lower(list_bone2{n}))
        bone_indx = n; return;
    end
end
for n = 1:numel(list_bone)
    if contains(lower(FileName), lower(list_bone{n})) || contains(lower(FileName), lower(list_bone2{n}))
        bone_indx = n; return;
    end
end
end

function side_indx = detectSideIndex(FileName, FolderName, list_side_folder)
side_indx = [];
side_folder_indx = [];
for n = 1:numel(list_side_folder)
    if contains(lower(FolderName), lower(list_side_folder{n}))
        side_folder_indx = n; break;
    end
end
if isempty(side_folder_indx)
    for n = 1:numel(list_side_folder)
        if contains(lower(FileName), lower(list_side_folder{n}))
            side_folder_indx = n; break;
        end
    end
end
if ~isempty(side_folder_indx) && side_folder_indx <= 3
    side_indx = 1; % Right
elseif ~isempty(side_folder_indx) && side_folder_indx >= 4
    side_indx = 2; % Left
end
end

function [nodes, conlist] = loadMeshByExtension(fullpath, ext)
conlist = [];
if strcmpi(ext,'.k')
    nodes = LoadDataFile(fullpath);
    fprintf("  Note: .k file — origin location and plotting limited.\n");
elseif strcmpi(ext,'.stl')
    TR = stlread(fullpath);
    nodes = TR.Points;
    conlist = TR.ConnectivityList;
elseif strcmpi(ext,'.particles')
    nodes = load(fullpath);
    fprintf("  Note: .particles file — origin location and plotting limited.\n");
elseif strcmpi(ext,'.vtk')
    nodes = LoadDataFile(fullpath);
    fprintf("  Note: .vtk file — origin location and plotting limited.\n");
elseif strcmpi(ext,'.ply')
    [nodes, conlist] = read_ply_loose(fullpath);
    nodes = [nodes.x, nodes.y, nodes.z];
elseif strcmpi(ext,'.obj')
    obj = readOBJ(fullpath);
    nodes = obj.V;
    conlist = obj.F;
else
    error("Unsupported file type: %s", ext);
end
end

function bone_coord = defaultAllCSForBone(bone_indx)
% Returns a vector of all coordinate system indices for that bone.
if bone_indx == 1
    bone_coord = 1:3;          % Talus: TN, TT, ST
elseif bone_indx == 2
    bone_coord = 1:2;          % Calcaneus: CC, ST
elseif bone_indx >= 8 && bone_indx <= 12
    bone_coord = 1:2;          % Metatarsals: Vertical, Radial
elseif bone_indx == 4
    bone_coord = 1:2;          % Cuboid: Vertical, Radial
elseif bone_indx == 7
    bone_coord = 1:2;          % Lat cuneiform: Vertical, Radial
else
    bone_coord = 1;            % All others: only one
end
end

function sheet = prefixSheetName(name, bone_indx, bone_coord_n)
sheet = name;
if bone_indx == 1 && bone_coord_n == 1
    sheet = "TN_" + sheet;
elseif bone_indx == 1 && bone_coord_n == 2
    sheet = "TT_" + sheet;
elseif bone_indx == 1 && bone_coord_n == 3
    sheet = "ST_" + sheet;
elseif bone_indx == 2 && bone_coord_n == 1
    sheet = "CC_" + sheet;
elseif bone_indx == 2 && bone_coord_n == 2
    sheet = "ST_" + sheet;
elseif (bone_indx >= 7 && bone_indx <= 12) && bone_coord_n == 1
    sheet = "V_" + sheet;
elseif (bone_indx >= 7 && bone_indx <= 12) && bone_coord_n == 2
    sheet = "R_" + sheet;
elseif bone_indx == 4 && bone_coord_n == 1
    sheet = "V_" + sheet;
elseif bone_indx == 4 && bone_coord_n == 2
    sheet = "R_" + sheet;
end
end
