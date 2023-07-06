function FileData = LoadDataFile(FileName)
% This function is used to load .k and .vtk files efficiently

FileSplit = split(FileName,".");

FileType = string(FileSplit(2,1));

if FileType == 'xplt'
    fid = fopen(FileName);
    temp = fgets(fid); % ignores "ASCII EXPORT"
    temp = fgets(fid); % ignores "STATE 1"
    temp = fgets(fid); % ignores "TIME_VALUE"
    temp = fgets(fid); % ignores "NODAL_DATA"
    Data = textscan(fid,'%f %f', 'Delimiter',','); % fixes the spacing that happens when you ignore the first two lines and makes a matrix with jus the (x,y,z) coordinates
    fclose(fid);
    FileData = [Data{1,1}, Data{1,2}]; % pulls the (x,y,z) coordinates for the nodes into a new matrix
end

if FileType == 'k'
    fid = fopen(FileName);
    temp = fgets(fid); % ignores "keyword"
    temp = fgets(fid); % ignores "node"
    Data = textscan(fid,'%d %f %f %f', 'Delimiter', '\n');
    fclose(fid);
    FileData = [Data{1,2}, Data{1,3}, Data{1,4}]; % pulls the (x,y,z) coordinates for the nodes into a new matrix
end

if FileType == 'vtk'
    fid = fopen(FileName);
    temp = fgets(fid); % ignores "# vtk DataFile"
    temp = fgets(fid); % ignores "vtk output"
    temp = fgets(fid); % ignores "ASCII"
    temp = fgets(fid); % ignores "Dataset Polydata"
    temp = fgets(fid); % ignores "Points float"
    allfiledata = textscan(fid,'%f %f %f %f %f %f %f %f %f', 'Delimiter', '\n');
    temp = fgets(fid); % ignores "Polygons"
    polfiledata = textscan(fid,'%f %f %f %f', 'Delimiter', '\n');
    fclose(fid);
    
    x = allfiledata{1,1};
    X = {allfiledata{1,1}, allfiledata{1,4}, allfiledata{1,7}};
    Y = {allfiledata{1,2}, allfiledata{1,5}, allfiledata{1,8}};
    Z = {allfiledata{1,3}, allfiledata{1,6}, allfiledata{1,9}};
    
    t = allfiledata{1,1}; 
    t = find(isnan(allfiledata{1,1}) == 1);
    if isempty(t) == 0
        allfiledata{1,1}(t) = [];
    end
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
        
    polydata = [polfiledata{1,2} polfiledata{1,3} polfiledata{1,4}]+1;

    filedata = [x1, y1, z1]; % pulls the (x,y,z) coordinates for the nodes into a new matrix
    FileData = triangulation(polydata,filedata);
end

%%
end