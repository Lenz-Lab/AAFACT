mean_calc = stlread('L:\Project_Data\Swiss_WBCT\Healthy\10_TNCC_MultiDomain\Joint_Analysis_new\Subtalar\Mean\Mean_Calcaneus_Left.stl');
mean_tal =  stlread('L:\Project_Data\Swiss_WBCT\Healthy\10_TNCC_MultiDomain\Joint_Analysis_new\Subtalar\Mean\Mean_Talus_Left.stl');
mean_nav = stlread('L:\Project_Data\Swiss_WBCT\Healthy\10_TNCC_MultiDomain\Joint_Analysis_new\Talonavicular\Mean\Mean_Navicular_Left.stl');
mean_cub = stlread('L:\Project_Data\Swiss_WBCT\Healthy\10_TNCC_MultiDomain\Joint_Analysis_new\Calcaneocuboid\Mean\Mean_Cuboid_Left.stl');
temp_calc = stlread('C:\Users\arcanine\Github\AutoCoordinateSystem\Template_Bones\Calcaneus_Template.stl');
temp_calc2 = stlread('C:\Users\arcanine\Github\AutoCoordinateSystem\Template_Bones\Calcaneus_Template2.stl');
temp_tal = stlread('C:\Users\arcanine\Github\AutoCoordinateSystem\Template_Bones\Talus_Template.stl');
temp_tal2 = stlread('C:\Users\arcanine\Github\AutoCoordinateSystem\Template_Bones\Talus_Template2.stl');
temp_nav = stlread('C:\Users\arcanine\Github\AutoCoordinateSystem\Template_Bones\Navicular_Template.stl');
mean_navNC = stlread('L:\Project_Data\Swiss_WBCT\Healthy\09_NC_Project\02_Joint Measurements\Navicular_Medial_Joint_Updated\Mean\Mean_Navicular.stl');
mean_med = stlread('L:\Project_Data\Swiss_WBCT\Healthy\09_NC_Project\02_Joint Measurements\Navicular_Medial_Joint_Updated\Mean\Mean_Medial.stl');
mean_lat = stlread('L:\Project_Data\Swiss_WBCT\Healthy\09_NC_Project\02_Joint Measurements\Navicular_Lateral_Joint_Updated\Mean\Mean_Lateral.stl');
mean_int = stlread('L:\Project_Data\Swiss_WBCT\Healthy\09_NC_Project\02_Joint Measurements\Navicular_Intermediate_Joint_Updated\Mean\Mean_Intermediate.stl');
temp_med = stlread('C:\Users\arcanine\Github\AutoCoordinateSystem\Template_Bones\Medial_Cuneiform_Template.stl');

mean_navNC_Points = mean_navNC.Points.*[1,1,-1];
mean_med_Points = mean_med.Points.*[1,1,-1];
mean_med_CL = [mean_med.ConnectivityList(:,3) mean_med.ConnectivityList(:,2) mean_med.ConnectivityList(:,1)];
mean_lat_Points = mean_lat.Points.*[1,1,-1];
mean_lat_CL = [mean_lat.ConnectivityList(:,3) mean_lat.ConnectivityList(:,2) mean_lat.ConnectivityList(:,1)];
mean_int_Points = mean_int.Points.*[1,1,-1];
mean_int_CL = [mean_int.ConnectivityList(:,3) mean_int.ConnectivityList(:,2) mean_int.ConnectivityList(:,1)];

%%
% mean_nav_center = center(mean_nav.Points,1);
% mean_navNC_center = center(mean_navNC_Points,1);
% 
% figure()
% plot3(mean_nav_center(:,1),mean_nav_center(:,2),mean_nav_center(:,3),'.k')
% hold on
% plot3(mean_navNC_center(:,1),mean_navNC_center(:,2),mean_navNC_center(:,3),'.r')
% axis equal
%%
[R1_cc,T1_cc,ER1_cc] = icp(temp_calc.Points',(mean_calc.Points*rotz(180))', 1000,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',temp_calc.ConnectivityList);
new_calc = center((R1_cc*((mean_calc.Points*rotz(180))') + repmat(T1_cc,1,length((mean_calc.Points*rotz(180))')))',1);
new_cub = center((R1_cc*((mean_cub.Points*rotz(180))') + repmat(T1_cc,1,length((mean_cub.Points*rotz(180))')))',1);

[R2_cc,T2_cc,ER2_cc] = icp(temp_calc2.Points',new_calc', 1000,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',temp_calc2.ConnectivityList);
new_calc2 = center((R2_cc*(new_calc') + repmat(T2_cc,1,length(new_calc')))',1);

figure()
% plot3(mean_calc.Points(:,1),mean_calc.Points(:,2),mean_calc.Points(:,3),'.k')
hold on
% plot3(temp_calc.Points(:,1),temp_calc.Points(:,2),temp_calc.Points(:,3),'.b')
% plot3(new_calc(:,1),new_calc(:,2),new_calc(:,3),'.r')
% plot3(new_cub(:,1),new_cub(:,2),new_cub(:,3),'.k')
plot3(new_calc2(:,1),new_calc2(:,2),new_calc2(:,3),'.r')
plot3(temp_calc2.Points(:,1),temp_calc2.Points(:,2),temp_calc2.Points(:,3),'.b')
% plot3(mean_tal.Points(:,1),mean_tal.Points(:,2),mean_tal.Points(:,3),'.k')
% plot3(mean_nav.Points(:,1),mean_nav.Points(:,2),mean_nav.Points(:,3),'.k')
% plot3(mean_cub.Points(:,1),mean_cub.Points(:,2),mean_cub.Points(:,3),'.k')
axis equal

%%
[R1_tn,T1_tn,ER1_tn] = icp(temp_tal.Points',(mean_tal.Points*rotz(180))', 1000,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',temp_tal.ConnectivityList);
new_tal = center((R1_tn*((mean_tal.Points*rotz(180))') + repmat(T1_tn,1,length((mean_tal.Points*rotz(180))')))',1);
new_nav = center((R1_tn*((mean_nav.Points*rotz(180))') + repmat(T1_tn,1,length((mean_nav.Points*rotz(180))')))',1);

[R2_tn,T2_tn,ER2_tn] = icp(temp_tal2.Points',new_tal', 1000,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',temp_tal2.ConnectivityList);
new_tal2 = center((R2_tn*(new_tal') + repmat(T2_tn,1,length(new_tal')))',1);

figure()
% plot3(mean_tal.Points(:,1),mean_tal.Points(:,2),mean_tal.Points(:,3),'.k')
hold on
% plot3(temp_tal.Points(:,1),temp_tal.Points(:,2),temp_tal.Points(:,3),'.b')
% plot3(temp_nav.Points(:,1),temp_nav.Points(:,2),temp_nav.Points(:,3),'.b')
% plot3(new_tal(:,1),new_tal(:,2),new_tal(:,3),'.r')
% plot3(new_nav(:,1),new_nav(:,2),new_nav(:,3),'.k')
plot3(new_tal2(:,1),new_tal2(:,2),new_tal2(:,3),'.r')
plot3(temp_tal2.Points(:,1),temp_tal2.Points(:,2),temp_tal2.Points(:,3),'.b')
axis equal

%%
[R1_nc,T1_nc,ER1_nc] = icp(new_nav',(mean_navNC_Points*rotx(180))', 1000,'Matching','kDtree','EdgeRejection',logical(1));

new_temp_nav = (R1_nc*((mean_navNC_Points*rotx(180))') + repmat(T1_nc,1,length((mean_navNC_Points*rotx(180))')))';
% new_temp_nav = new_temp_nav*rotx(180);
new_med = center((R1_nc*((mean_med_Points*rotx(180))') + repmat(T1_nc,1,length((mean_med_Points*rotx(180))')))',1);
new_lat = center((R1_nc*((mean_lat_Points*rotx(180))') + repmat(T1_nc,1,length((mean_lat_Points*rotx(180))')))',1);
new_int = center((R1_nc*((mean_int_Points*rotx(180))') + repmat(T1_nc,1,length((mean_int_Points*rotx(180))')))',1);

figure()
plot3(new_med(:,1),new_med(:,2),new_med(:,3),'.k')
hold on
% plot3(new_temp_nav(:,1),new_temp_nav(:,2),new_temp_nav(:,3),'.k')
plot3(new_lat(:,1),new_lat(:,2),new_lat(:,3),'.k')
plot3(new_int(:,1),new_int(:,2),new_int(:,3),'.k')
% plot3(temp_med.Points(:,1),temp_med.Points(:,2),temp_med.Points(:,3),'.r')
% plot3(new_nav(:,1),new_nav(:,2),new_nav(:,3),'.r')
xlabel('x')
ylabel('y')
zlabel('z')
axis equal

% NEED TO SAVE ALL THESE STL FILES

%%
TR_new_calc = triangulation(mean_calc.ConnectivityList,new_calc);
TR_new_cub = triangulation(mean_cub.ConnectivityList,new_cub);
TR_new_calc2 = triangulation(mean_calc.ConnectivityList,new_calc2);
TR_new_tal = triangulation(mean_tal.ConnectivityList,new_tal);
TR_new_tal2 = triangulation(mean_tal.ConnectivityList,new_tal2);
TR_new_nav = triangulation(mean_nav.ConnectivityList,new_nav);
TR_new_med = triangulation(mean_med_CL,new_med);
TR_new_int = triangulation(mean_int_CL,new_int);
TR_new_lat = triangulation(mean_lat_CL,new_lat);

stlwrite(TR_new_calc,'C:\Users\arcanine\Github\AutoCoordinateSystem\Template_Bones\Calcaneus_Template.stl');
stlwrite(TR_new_cub,'C:\Users\arcanine\Github\AutoCoordinateSystem\Template_Bones\Cuboid_Template.stl');
stlwrite(TR_new_calc2,'C:\Users\arcanine\Github\AutoCoordinateSystem\Template_Bones\Calcaneus_Template2.stl');
stlwrite(TR_new_tal,'C:\Users\arcanine\Github\AutoCoordinateSystem\Template_Bones\Talus_Template.stl');
stlwrite(TR_new_tal2,'C:\Users\arcanine\Github\AutoCoordinateSystem\Template_Bones\Talus_Template2.stl');
stlwrite(TR_new_nav,'C:\Users\arcanine\Github\AutoCoordinateSystem\Template_Bones\Navicular_Template.stl');
stlwrite(TR_new_med,'C:\Users\arcanine\Github\AutoCoordinateSystem\Template_Bones\Medial_Cuneiform_Template.stl');
stlwrite(TR_new_int,'C:\Users\arcanine\Github\AutoCoordinateSystem\Template_Bones\Intermediate_Cuneiform_Template.stl');
stlwrite(TR_new_lat,'C:\Users\arcanine\Github\AutoCoordinateSystem\Template_Bones\Lateral_Cuneiform_Template.stl');
