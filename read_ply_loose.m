function [vert, face] = read_ply_loose(fn)
% READ_PLY_LOOSE  Robust PLY reader for vertex/face meshes.
%  [vert, face] = read_ply_loose(filename)
%  - Accepts vertex properties of any numeric type
%  - Accepts face list as "property list <countType> <indexType> vertex_indices"
%  - Ignores extra face properties and extra elements (e.g., patch/material/parameter)
%  - Supports ascii 1.0, binary_{little,big}_endian 1.0

fid = fopen(fn, 'r');
assert(fid~=-1, 'unable to open file');

% ---------- header ----------
line = fgetlc_noncomment(fid);
assert(strcmp(line,'ply'), 'unexpected header line');

line = fgetlc_noncomment(fid);
assert(startsWith(line,'format '), 'unexpected header line');
formatStr = strtrim(extractAfter(line,7)); % e.g. 'ascii 1.0'

% Expect vertex element
line = fgetlc_noncomment(fid);
assert(startsWith(line,'element vertex'), 'unexpected header line');
nvert = str2double(strtrim(extractAfter(line,14)));

% Collect vertex properties
prop = struct('format',{},'name',{});
line = fgetlc_noncomment(fid);
while startsWith(line,'property ')
    tok = strsplit(strtrim(line));
    if strcmp(tok{2},'list')
        % vertex list properties are rare; ignore if present
        % (Extend here if you need them.)
    else
        prop(end+1).format = tok{2};  %#ok<AGROW> e.g. float32
        prop(end  ).name   = tok{3};  %#ok<AGROW> e.g. x
    end
    line = fgetlc_noncomment(fid);
end

% Expect face element (present for meshes)
assert(startsWith(line,'element face'), 'unexpected header line');
nface = str2double(strtrim(extractAfter(line,12)));

% Read face properties; find the vertex_indices list and record types
faceCountType = ''; faceIndexType = ''; % PLY tokens, e.g., uint8, int32
line = fgetlc_noncomment(fid);
while startsWith(line,'property ')
    tok = strsplit(strtrim(line));
    if numel(tok)>=6 && strcmp(tok{2},'list')
        % property list <countType> <indexType> <name>
        name = tok{5};
        if strcmp(name,'vertex_indices') || strcmp(name,'vertex_index')
            faceCountType = tok{3};
            faceIndexType = tok{4};
        end
        % else: extra face property -> ignore
    else
        % scalar face property (e.g., "property int32 patch") -> ignore
    end
    line = fgetlc_noncomment(fid);
end

% There may be more elements (patch/material/parameter). Skip to end_header.
while ~strcmp(line,'end_header')
    line = fgetlc_noncomment(fid);
end

dataOffset = ftell(fid);
fclose(fid);

% ---------- data section ----------
switch formatStr
    case 'ascii 1.0'
        fid = fopen(fn,'rt');
        fseek(fid, dataOffset, 'bof');

        % ----- vertices -----
        dat = fscanf(fid,'%f',[numel(prop), nvert])';
        vert = struct();
        for j=1:numel(prop), vert.(prop(j).name) = dat(:,j); end

        % ----- faces (robust to extra scalars) -----
        facesCell = cell(nface,1);
        maxc = 0;
        for i = 1:nface
            ln = fgetl(fid);
            while ischar(ln) && isempty(strtrim(ln))   % skip blank lines
                ln = fgetl(fid);
            end
            nums = sscanf(ln,'%d');   % whole line to ints
            if isempty(nums)
                error('Failed to read face %d (empty line).', i);
            end
            c = nums(1);
            if numel(nums) < 1 + c
                error('Face %d: expected %d indices, found %d.', i, c, numel(nums)-1);
            end
            idx = nums(2 : 1+c).';
            facesCell{i} = double(idx);
            if c > maxc, maxc = c; end
            % any trailing nums beyond 1+c are extra scalars -> silently ignored
        end
        % pad to rectangular array with NaNs
        face = nan(nface, maxc);
        for i=1:nface
            fi = facesCell{i};
            face(i,1:numel(fi)) = fi;
        end
        fclose(fid);

    case 'binary_little_endian 1.0'
        fid = fopen(fn,'rb','l');  fseek(fid,dataOffset,'bof');
        vert = readVertexBinary(fid, nvert, prop);
        [face,~] = readFaceBinary(fid, nface, faceCountType, faceIndexType, 'l');
        fclose(fid);

    case 'binary_big_endian 1.0'
        fid = fopen(fn,'rb','b');  fseek(fid,dataOffset,'bof');
        vert = readVertexBinary(fid, nvert, prop);
        [face,~] = readFaceBinary(fid, nface, faceCountType, faceIndexType, 'b');
        fclose(fid);

    otherwise
        error('unsupported format: %s', formatStr);
end

% MATLAB is 1-based; PLY indices are 0-based
if ~isempty(face), face = face + 1; end

end % main

% ---------- helpers ----------
function line = fgetlc_noncomment(fid)
line = fgetl(fid);
while ischar(line)
    s = strtrim(line);
    if isempty(s) || strncmpi(s,'comment',7) || strncmpi(s,'obj_info',8)
        line = fgetl(fid);
    else
        break;
    end
end
end

function vert = readVertexBinary(fid, nvert, prop)
vert = struct(); 
for j=1:numel(prop)
    f = mapPlyToFread(prop(j).format); % e.g. 'float32' -> 'float32'
    vert.(prop(j).name) = fread(fid, nvert, ['*' f]);
end
end

function [face, counts] = readFaceBinary(fid, nface, countType, indexType, endian)
assert(~isempty(countType)&&~isempty(indexType), ...
    'Missing vertex_indices list types in face element.');
cf = mapPlyToFread(countType);
if strcmp(endian,'l'), countFmt = ['*' cf]; else, countFmt = ['*' cf]; end
ixf = mapPlyToFread(indexType);

% first pass: read counts to decide max polygon size
pos = ftell(fid);
counts = fread(fid, nface, countFmt);
maxc = max(counts);
% rewind to start of faces
fseek(fid, pos, 'bof');

face = nan(nface, maxc, 'double');
for i=1:nface
    c = fread(fid, 1, countFmt);
    idx = fread(fid, double(c), ['*' ixf])';
    face(i,1:c) = double(idx);
end
end

function f = mapPlyToFread(tok)
% Map PLY type tokens to MATLAB fread precision strings
switch tok
    case {'char','int8'},     f = 'int8';
    case {'uchar','uint8'},   f = 'uint8';
    case {'short','int16'},   f = 'int16';
    case {'ushort','uint16'}, f = 'uint16';
    case {'int','int32'},     f = 'int32';
    case {'uint','uint32'},   f = 'uint32';
    case {'float','float32'}, f = 'single';
    case {'double','float64'},f = 'double';
    otherwise, error('Unsupported PLY type: %s', tok);
end
end
