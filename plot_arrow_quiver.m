function plot_arrow_quiver(p0, p1, col, width, length)
% PLOT_ARROW_QUIVER  Draw a single 3D arrow of fixed display length.
%
%   plot_arrow_quiver(p0, p1, col, width, length)
%
%   p0      1x3 start point of the arrow (e.g. the ACS origin)
%   p1      1x3 point the arrow should aim at (e.g. the axis tip); only
%           its direction from p0 is used
%   col     RGB color, e.g. [1 0 0]
%   width   line width of the arrow shaft
%   length  drawn length of the arrow in model units (mm). Inside this
%           function it shadows MATLAB's built-in length().
%
%   Used for the final ACS plots so that every axis is drawn the same
%   length no matter how long the stored axis is. Draws onto the current
%   axes, so call "hold on" first if needed.

d  = p1 - p0;
L  = norm(d);
if L < eps, return; end % p0 and p1 coincide: no direction to draw
u  = (length/L) * d; % consistent display length
% The 0 scale argument turns off quiver3's automatic scaling so the arrow
% is drawn exactly as long as u.
quiver3(p0(1),p0(2),p0(3), u(1),u(2),u(3), 0, ...
    'LineWidth',width,'MaxHeadSize',0.5,'Color',col);
end
