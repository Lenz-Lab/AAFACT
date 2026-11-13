function FileData = LoadDataFile(FileName)
% This function is used to load .k and .vtk files efficiently
%
%   FileData = LoadDataFile(FileName)
%
%   Supported formats and what is returned:
%     .xplt  ASCII FEBio export: Nx2 array of the two nodal data columns
%     .k     LS-DYNA keyword file (*NODE block): Nx3 array of node x,y,z
%     .vtk   ASCII legacy VTK polydata: a triangulation object
%
%   The readers assume the fixed header layouts noted below; files with
%   extra header lines will not parse correctly.

% The file type is taken from the text after the first "." in FileName,
% so the path itself must not contain any other periods.
FileSplit = split(FileName,".");

FileType = string(FileSplit(2,1));

if FileType == 'xplt' % FEBio ASCII export
    fid = fopen(FileName);
    temp = fgets(fid); % ignores "ASCII EXPORT"
    temp = fgets(fid); % ignores "STATE 1"
    temp = fgets(fid); % ignores "TIME_VALUE"
    temp = fgets(fid); % ignores "NODAL_DATA"
    % Reads two comma-separated numbers per line. Which fields these are
    % depends on what was chosen when exporting from FEBio. This format is
    % not used by Main_CS or aafact_cli.
    Data = textscan(fid,'%f %f', 'Delimiter',',');
    fclose(fid);
    FileData = [Data{1,1}, Data{1,2}]; % N x 2 matrix of the two columns
end

if FileType == 'k' % LS-DYNA keyword file
    fid = fopen(FileName);
    temp = fgets(fid); % ignores "keyword"
    temp = fgets(fid); % ignores "node"
    Data = textscan(fid,'%d %f %f %f', 'Delimiter', '\n'); % node ID, x, y, z (stops at the first line that doesn't match)
    fclose(fid);
    FileData = [Data{1,2}, Data{1,3}, Data{1,4}]; % pulls the (x,y,z) coordinates for the nodes into a new matrix
end

if FileType == 'vtk' % ASCII legacy VTK polydata
    fid = fopen(FileName);
    temp = fgets(fid); % ignores "# vtk DataFile"
    temp = fgets(fid); % ignores "vtk output"
    temp = fgets(fid); % ignores "ASCII"
    temp = fgets(fid); % ignores "Dataset Polydata"
    temp = fgets(fid); % ignores "Points float"
    % VTK writes up to 3 points per line (x1 y1 z1 x2 y2 z2 x3 y3 z3), so
    % the points are read as 9 columns. Column 1/4/7 hold x, 2/5/8 hold y
    % and 3/6/9 hold z for the 1st/2nd/3rd point on each line.
    allfiledata = textscan(fid,'%f %f %f %f %f %f %f %f %f', 'Delimiter', '\n');
    temp = fgets(fid); % ignores "Polygons"
    polfiledata = textscan(fid,'%f %f %f %f', 'Delimiter', '\n'); % "3 i j k" per triangle
    fclose(fid);

    x = allfiledata{1,1};
    % Group the columns by coordinate so they can be re-interleaved below
    % back into the original point order.
    X = {allfiledata{1,1}, allfiledata{1,4}, allfiledata{1,7}};
    Y = {allfiledata{1,2}, allfiledata{1,5}, allfiledata{1,8}};
    Z = {allfiledata{1,3}, allfiledata{1,6}, allfiledata{1,9}};
    
    % Drop NaN padding textscan adds to column 1
    t = allfiledata{1,1};
    t = find(isnan(allfiledata{1,1}) == 1);
    if isempty(t) == 0
        allfiledata{1,1}(t) = [];
    end

    % Re-interleave the columns line by line (point 1, 2, 3 of line 1, then
    % line 2, ...). The length checks skip the missing entries when the
    % last line holds fewer than 3 points. The same loop is repeated for
    % y and z.
    x1 = [];
    k = 1;
    for n = 1:length(X{1})
        for m = 1:3
            if n <= length(allfiledata{1,1}) && m == 1
                x1(k,:) = X{m}(n);
            end
            if n <= length(allfiledata{1,4}) && m == 2
                x1(k,:) = X{m}(n);
            end
            if n <= length(allfiledata{1,7}) && m == 3
                x1(k,:) = X{m}(n);
            end
            k = k + 1;
        end
    end
    
    y1 = [];
    k = 1;
    for n = 1:length(Y{1})
        for m = 1:3
            if n <= length(allfiledata{1,2}) && m == 1
                y1(k,:) = Y{m}(n);
            end
            if n <= length(allfiledata{1,5}) && m == 2
                y1(k,:) = Y{m}(n);
            end
            if n <= length(allfiledata{1,8}) && m == 3
                y1(k,:) = Y{m}(n);
            end
            k = k + 1;
        end
    end 
    
    z1 = [];
    k = 1;
    for n = 1:length(Z{1})
        for m = 1:3
            if n <= length(allfiledata{1,3}) && m == 1
                z1(k,:) = Z{m}(n);
            end
            if n <= length(allfiledata{1,6}) && m == 2
                z1(k,:) = Z{m}(n);
            end
            if n <= length(allfiledata{1,9}) && m == 3
                z1(k,:) = Z{m}(n);
            end
            k = k + 1;
        end
    end    
        
    % Drop the leading vertex count (always 3) and convert VTK's 0-based
    % indices to MATLAB's 1-based indices
    polydata = [polfiledata{1,2} polfiledata{1,3} polfiledata{1,4}]+1;

    filedata = [x1, y1, z1]; % pulls the (x,y,z) coordinates for the nodes into a new matrix
    FileData = triangulation(polydata,filedata);
end

%%
end