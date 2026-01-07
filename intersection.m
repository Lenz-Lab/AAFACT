function [true_intersect, t, u, v, coord_intersect] = intersection(...
    origin, dir, V0, V1, V2, eps)

% Intersection code calculates line and triangle intersection point and
% distance
%
% [true_intersect, t, u, v, coord_interect] = intersection(origin, dir, V0, V1, V2, eps)
%
% Works on two-sided triangles, infinite lines, and Nx3 triangles and N
% lines
%
% Inputs:
%     origin   - Nx3 line origin
%     dir      - Nx3 line direction
%     V0       - Nx3 triangle vertex 0
%     V1       - Nx3 triangle vertex 1
%     V2       - Nx3 triangle vertex 2
%     eps      - (optional) tolerance for parallel test, default 1e-5
%
% Outputs:
%     true_intersect  - Nx1 logical, true where line intersects triangle
%     t               - Nx1 parameter along the line (X = origin + t * dir)
%     u, v            - Nx1 barycentric coords (W = 1 - u - v)
%     coord_intersect - Nx3 intersection coordinates

if nargin < 6 || isempty(eps)
    eps = 1e-5;
end

% Size check
assert(size(V0,2) == 3 && size(V1,2) == 3 && size(V2,2) == 3, ...
    'Triangle vertices must be in Nx3 format.');

% Number of triangles
Ntri = size(V0,1);

% Allow origin and dir to be 1x3 or Nx3
assert(size(origin,2) == 3 && size(dir,2) == 3, ...
    'origin and dir must have 3 columns.');

if size(origin,1) == 1
    origin = repmat(origin, Ntri, 1);
else
    assert(size(origin,1) == Ntri, ...
        'If origin has multiple rows, it must match number of triangles.');
end

if size(dir,1) == 1
    dir = repmat(dir, Ntri, 1);
else
    assert(size(dir,1) == Ntri, ...
        'If dir has multiple rows, it must match number of triangles.');
end

% Initialize outputs
true_intersect = false(Ntri,1);
t = nan(Ntri,1);
u = nan(Ntri,1);
v = nan(Ntri,1);
xcoor = nan(Ntri,3);

% Edges
E1 = V1 - V0;
E2 = V2 - V0;

% Find determinant
pvec = cross(dir, E2, 2);
det  = sum(E1 .* pvec, 2);

% Lines nearly parallel to triangle plane
angleCheck = abs(det) > eps;
if ~any(angleCheck)
    return; % no intersections
end

% Avoid dividing by zero
det(~angleCheck) = NaN;

% Vector from V0 to origin
tvec = origin - V0;

% Barycentric coord u
u_all = sum(tvec .* pvec, 2) ./ det;

% qvec and barycentric coord v
qvec = cross(tvec, E1, 2);
v_all = sum(dir .* qvec, 2) ./ det;

% Parameter t along the line
t_all = sum(E2 .* qvec, 2) ./ det;

% Inside-triangle test (two-sided, infinite line)
inside = angleCheck & (u_all >= 0) & (v_all >= 0) & (u_all + v_all <= 1);

% Fill outputs
true_intersect(inside) = true;
t(inside) = t_all(inside);
u(inside) = u_all(inside);
v(inside) = v_all(inside);

% Compute intersection coordinates
% coord_intersect = origin + t * dir
coord_intersect(inside,:) = origin(inside,:) + dir(inside,:) .* t(inside);

end


% %% Transpose inputs if needed
% if (size(origin ,1)==3 && size(origin ,2)~=3), origin =origin' ; end
% if (size(dir  ,1)==3 && size(dir  ,2)~=3), dir  =dir'  ; end
% if (size(V0,1)==3 && size(V0,2)~=3), V0=V0'; end
% if (size(V1,1)==3 && size(V1,2)~=3), V1=V1'; end
% if (size(V2,1)==3 && size(V2,2)~=3), V2=V2'; end
% %% In case of single points clone them to the same size as the rest
% N = max([size(origin,1), size(dir,1), size(V0,1), size(V1,1), size(V2,1)]);
% if (size(origin ,1)==1 && N>1 && size(origin ,2)==3), origin  = repmat(origin , N, 1); end
% if (size(dir  ,1)==1 && N>1 && size(dir  ,2)==3), dir   = repmat(dir  , N, 1); end
% if (size(V0,1)==1 && N>1 && size(V0,2)==3), V0 = repmat(V0, N, 1); end
% if (size(V1,1)==1 && N>1 && size(V1,2)==3), V1 = repmat(V1, N, 1); end
% if (size(V2,1)==1 && N>1 && size(V2,2)==3), V2 = repmat(V2, N, 1); end
% %% Check if all the sizes match
% SameSize = (any(size(origin)==size(V0)) && ...
%   any(size(origin)==size(V1)) && ...
%   any(size(origin)==size(V2)) && ...
%   any(size(origin)==size(dir  )) );
% assert(SameSize && size(origin,2)==3, ...
%   'All input vectors have to be in Nx3 format.');
% %% Read user preferences
% eps        = 1e-5;
% planeType  = 'two sided';
% lineType   = 'ray';
% border     = 'normal';
% fullReturn = false;
% nVarargs   = length(varargin);
% k = 1;
% if nVarargs>0 && isstruct(varargin{1})
%   % This section is provided for backward compability only
%   options = varargin{1};
%   if (isfield(options, 'eps'     )), eps      = options.eps;      end
%   if (isfield(options, 'triangle')), planeType= options.triangle; end
%   if (isfield(options, 'ray'     )), lineType = options.ray;      end
%   if (isfield(options, 'border'  )), border   = options.border;   end
% else
%   while (k<=nVarargs)
%     assert(ischar(varargin{k}), 'Incorrect input parameters')
%     switch lower(varargin{k})
%       case 'eps'
%         eps = abs(varargin{k+1});
%         k = k+1;
%       case 'planetype'
%         planeType = lower(strtrim(varargin{k+1}));
%         k = k+1;
%       case 'border'
%         border = lower(strtrim(varargin{k+1}));
%         k = k+1;
%       case 'linetype'
%         lineType = lower(strtrim(varargin{k+1}));
%         k = k+1;
%       case 'fullreturn'
%         fullReturn = (double(varargin{k+1})~=0);
%         k = k+1;
%     end
%     k = k+1;
%   end
% end
% %% Set up border parameter
% switch border
%   case 'normal'
%     zero=0.0;
%   case 'inclusive'
%     zero=eps;
%   case 'exclusive'
%     zero=-eps;
%   otherwise
%     error('Border parameter must be either "normal", "inclusive" or "exclusive"')
% end
% %% initialize default output
% true_intersect = false(size(origin,1),1); % by default there are no intersections
% t = inf+zeros(size(origin,1),1); u=t; v=t;
% corrd_intersect = nan+zeros(size(origin));
% %% Find faces parallel to the ray
% edge1 = V1-V0;          % find vectors for two edges sharing vert0
% edge2 = V2-V0;
% tvec  = origin -V0;          % vector from vert0 to ray origin
% pvec  = cross(dir, edge2,2);  % begin calculating determinant - also used to calculate U parameter
% det   = sum(edge1.*pvec,2);   % determinant of the matrix M = dot(edge1,pvec)
% switch planeType
%   case 'two sided'            % treats triangles as two sided
%     angleOK = (abs(det)>eps); % if determinant is near zero then ray lies in the plane of the triangle
%   case 'one sided'            % treats triangles as one sided
%     angleOK = (det>eps);
%   otherwise
%     error('Triangle parameter must be either "one sided" or "two sided"');
% end
% if all(~angleOK), return; end % if all parallel than no intersections
% %% Different behavior depending on one or two sided triangles
% det(~angleOK) = nan;              % change to avoid division by zero
% u    = sum(tvec.*pvec,2)./det;    % 1st barycentric coordinate
% if fullReturn
%   % calculate all variables for all line/triangle pairs
%   qvec = cross(tvec, edge1,2);    % prepare to test V parameter
%   v    = sum(dir  .*qvec,2)./det; % 2nd barycentric coordinate
%   t    = sum(edge2.*qvec,2)./det; % 'position on the line' coordinate
%   % test if line/plane intersection is within the triangle
%   ok   = (angleOK & u>=-zero & v>=-zero & u+v<=1.0+zero);
% else
%   % limit some calculations only to line/triangle pairs where it makes
%   % a difference. It is tempting to try to push this concept of
%   % limiting the number of calculations to only the necessary to "u"
%   % and "t" but that produces slower code
%   v = nan+zeros(size(u)); t=v;
%   ok = (angleOK & u>=-zero & u<=1.0+zero); % mask
%   % if all line/plane intersections are outside the triangle than no intersections
%   if ~any(ok), true_intersect = ok; return; end
%   qvec = cross(tvec(ok,:), edge1(ok,:),2); % prepare to test V parameter
%   v(ok,:) = sum(dir(ok,:).*qvec,2) ./ det(ok,:); % 2nd barycentric coordinate
%   if (~strcmpi(lineType,'line')) % 'position on the line' coordinate
%     t(ok,:) = sum(edge2(ok,:).*qvec,2)./det(ok,:);
%   end
%   % test if line/plane intersection is within the triangle
%   ok = (ok & v>=-zero & u+v<=1.0+zero);
% end
% %% Test where along the line the line/plane intersection occurs
% switch lineType
%   case 'line'      % infinite line
%     true_intersect = ok;
%   case 'ray'       % ray is bound on one side
%     true_intersect = (ok & t>=-zero); % intersection on the correct side of the origin
%   case 'segment'   % segment is bound on two sides
%     true_intersect = (ok & t>=-zero & t<=1.0+zero); % intersection between origin and destination
%   otherwise
%     error('lineType parameter must be either "line", "ray" or "segment"');
% end
% %% calculate intersection coordinates if requested
% if (nargout>4)
%   ok = true_intersect | fullReturn;
%   corrd_intersect(ok,:) = V0(ok,:) ...
%     + edge1(ok,:).*repmat(u(ok,1),1,3) ...
%     + edge2(ok,:).*repmat(v(ok,1),1,3);
% end