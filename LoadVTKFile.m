function FileData = LoadVTKFile(FileName)

fid = fopen(FileName);
temp = fgets(fid); % ignores "# vtk DataFile"
temp = fgets(fid); % ignores "vtk output"
temp = fgets(fid); % ignores "ASCII"
temp = fgets(fid); % ignores "Dataset Polydata"
temp = fgets(fid); % ignores "Points float"
allfiledata = textscan(fid,'%f %f %f %d %d %d %d %d %d', 'Delimiter', '\n');
fclose(fid);
X = allfiledata{1,1};
Y = allfiledata{1,2};
Z = allfiledata{1,3};

if length(X) ~= length(Y)
    X(end) = [];
end

FileData = [X, Y, Z]; % pulls the (x,y,z) coordinates for the nodes into a new matrix
end