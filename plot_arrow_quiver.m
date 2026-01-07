function plot_arrow_quiver(p0, p1, col, width, length)
d  = p1 - p0;
L  = norm(d);
if L < eps, return; end
u  = (length/L) * d; % consistent display length
quiver3(p0(1),p0(2),p0(3), u(1),u(2),u(3), 0, ...
    'LineWidth',width,'MaxHeadSize',0.5,'Color',col);
end