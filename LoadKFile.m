function FileData = LoadKFile(FileName)

fid = fopen(FileName);
temp = fgets(fid); % ignores "keyword"
temp = fgets(fid); % ignores "node"
allfiledata = textscan(fid,'%d %f %f %f', 'Delimiter', '\n');
fclose(fid);
FileData = [allfiledata{1,2}, allfiledata{1,3}, allfiledata{1,4}]; % pulls the (x,y,z) coordinates for the nodes into a new matrix
end