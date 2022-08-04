function [MDTA_2D, TT_2D, TLSA_2D] = MDTATT(aligned_nodes_tibia,aligned_nodes_talus)

%% Multiple CS for Talus
% if bone_indx == 1 && bone_coord == 2
    nodes_aligned_original_talus = aligned_nodes_talus;
    aligned_nodes_talus = [aligned_nodes_talus(aligned_nodes_talus(:,2)<10,1) aligned_nodes_talus(aligned_nodes_talus(:,2)<10,2) aligned_nodes_talus(aligned_nodes_talus(:,2)<10,3)];
% end

%% Tibial Realignment for Medial Malleolus
cutting_plane = min(aligned_nodes_tibia(:,3)) + 14; % Temporarily removes the tibial plafond

% if bone_indx == 13
    nodes_aligned_original_tibia = aligned_nodes_tibia;
    aligned_nodes_tibia = [aligned_nodes_tibia(aligned_nodes_tibia(:,3)>cutting_plane,1) aligned_nodes_tibia(aligned_nodes_tibia(:,3)>cutting_plane,2) aligned_nodes_tibia(aligned_nodes_tibia(:,3)>cutting_plane,3)];
% end

%% Split up the bone into nth sections in all three planes
x_min = min(aligned_nodes_tibia(:,1));
y_min = min(aligned_nodes_tibia(:,2));
z_min = min(aligned_nodes_tibia(:,3));
x_max = max(aligned_nodes_tibia(:,1));
y_max = max(aligned_nodes_tibia(:,2));
z_max = max(aligned_nodes_tibia(:,3));

range_x = x_max - x_min;
range_y = y_max - y_min;
range_z = z_max - z_min;

% % Splits bone up in n sections
% if bone_indx == 1 % Talus
%     n = 3;
% elseif bone_indx == 2 % Calcaneus
%     n = 10;
% elseif bone_indx == 3 % Navicular
%     n = 5;
% elseif bone_indx == 4 % Cuboid
%     n = 5;
% elseif bone_indx >= 5 && bone_indx <= 7 % Cuneiforms
%     n = 3;
% elseif bone_indx >= 8 && bone_indx <= 12 % Metatarsals
%     n = 3;
% elseif bone_indx == 13 || bone_indx == 14 % Tibia or Fibula
%     n = 3;
% else
%     n = 7;
% end

n = 3;

nth_x = range_x/n;
nth_y = range_y/n;
nth_z = range_z/n;

%% Positive Y Nth ROI
positive_y_nth = y_max - nth_y;

aligned_nodes_tibia_temp = [aligned_nodes_tibia(aligned_nodes_tibia(:,3)<30,1) aligned_nodes_tibia(aligned_nodes_tibia(:,3)<30,2) aligned_nodes_tibia(aligned_nodes_tibia(:,3)<30,3)];

positive_y_nth_ROI = aligned_nodes_tibia_temp(:,2) >= positive_y_nth;

positive_y_nth_x = nonzeros(aligned_nodes_tibia_temp(:,1).*positive_y_nth_ROI);
positive_y_nth_y = nonzeros(aligned_nodes_tibia_temp(:,2).*positive_y_nth_ROI);
positive_y_nth_z = nonzeros(aligned_nodes_tibia_temp(:,3).*positive_y_nth_ROI);

av_positive_y_nth_x = mean(positive_y_nth_x);
av_positive_y_nth_y = mean(positive_y_nth_y);
av_positive_y_nth_z = mean(positive_y_nth_z);

av_positive_y_nth = [av_positive_y_nth_x,av_positive_y_nth_y,av_positive_y_nth_z];

% figure()
% plot3(aligned_nodes_tibia(:,1),aligned_nodes_tibia(:,2),aligned_nodes_tibia(:,3),'k.')
% hold on
% plot3(positive_y_nth_x,positive_y_nth_y,positive_y_nth_z,'ys')
% plot3(av_positive_y_nth_x,av_positive_y_nth_y,av_positive_y_nth_z,'r.','MarkerSize',50)
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

%% Negative Y nth ROI
negative_y_nth = y_min + nth_y;

negative_y_nth_ROI = aligned_nodes_tibia_temp(:,2) <= negative_y_nth;

negative_y_nth_x = nonzeros(aligned_nodes_tibia_temp(:,1).*negative_y_nth_ROI);
negative_y_nth_y = nonzeros(aligned_nodes_tibia_temp(:,2).*negative_y_nth_ROI);
negative_y_nth_z = nonzeros(aligned_nodes_tibia_temp(:,3).*negative_y_nth_ROI);

av_negative_y_nth_x = mean(negative_y_nth_x);
av_negative_y_nth_y = mean(negative_y_nth_y);
av_negative_y_nth_z = mean(negative_y_nth_z);

av_negative_y_nth = [av_negative_y_nth_x,av_negative_y_nth_y,av_negative_y_nth_z];

% figure()
% plot3(aligned_nodes_tibia(:,1),aligned_nodes_tibia(:,2),aligned_nodes_tibia(:,3),'k.')
% hold on
% plot3(negative_y_nth_x,negative_y_nth_y,negative_y_nth_z,'ys')
% plot3(av_negative_y_nth_x,av_negative_y_nth_y,av_negative_y_nth_z,'r.','MarkerSize',50)
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

%% Positive Z nth ROI
positive_z_nth = z_max - nth_z;

positive_z_nth_ROI = aligned_nodes_tibia(:,3) >= positive_z_nth;

positive_z_nth_x = nonzeros(aligned_nodes_tibia(:,1).*positive_z_nth_ROI);
positive_z_nth_y = nonzeros(aligned_nodes_tibia(:,2).*positive_z_nth_ROI);
positive_z_nth_z = nonzeros(aligned_nodes_tibia(:,3).*positive_z_nth_ROI);

av_positive_z_nth_x = mean(positive_z_nth_x);
av_positive_z_nth_y = mean(positive_z_nth_y);
av_positive_z_nth_z = mean(positive_z_nth_z);

av_positive_z_nth = [av_positive_z_nth_x,av_positive_z_nth_y,av_positive_z_nth_z];

% figure()
% plot3(aligned_nodes_tibia(:,1),aligned_nodes_tibia(:,2),aligned_nodes_tibia(:,3),'k.')
% hold on
% plot3(positive_z_nth_x,positive_z_nth_y,positive_z_nth_z,'ys')
% plot3(av_positive_z_nth_x,av_positive_z_nth_y,av_positive_z_nth_z,'r.','MarkerSize',50)
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

%% Negative Z nth ROI
negative_z_nth = z_min + nth_z;

negative_z_nth_ROI = aligned_nodes_tibia(:,3) <= negative_z_nth;

negative_z_nth_x = nonzeros(aligned_nodes_tibia(:,1).*negative_z_nth_ROI);
negative_z_nth_y = nonzeros(aligned_nodes_tibia(:,2).*negative_z_nth_ROI);
negative_z_nth_z = nonzeros(aligned_nodes_tibia(:,3).*negative_z_nth_ROI);

av_negative_z_nth_x = mean(negative_z_nth_x);
av_negative_z_nth_y = mean(negative_z_nth_y);
av_negative_z_nth_z = mean(negative_z_nth_z);

av_negative_z_nth = [av_negative_z_nth_x,av_negative_z_nth_y,av_negative_z_nth_z];

% figure()
% plot3(aligned_nodes_tibia(:,1),aligned_nodes_tibia(:,2),aligned_nodes_tibia(:,3),'k.')
% hold on
% plot3(negative_z_nth_x,negative_z_nth_y,negative_z_nth_z,'ys')
% plot3(av_negative_z_nth_x,av_negative_z_nth_y,av_negative_z_nth_z,'r.','MarkerSize',50)
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

%% Negative X nth ROI
negative_x_nth = x_min + nth_x;

% if bone_indx == 13
    aligned_nodes_tibia_temp = [aligned_nodes_tibia(aligned_nodes_tibia(:,3)<30,1) aligned_nodes_tibia(aligned_nodes_tibia(:,3)<30,2) aligned_nodes_tibia(aligned_nodes_tibia(:,3)<30,3)];
% else 
%     aligned_nodes_tibia_temp = aligned_nodes_tibia;
% end
% 
negative_x_nth_ROI = aligned_nodes_tibia_temp(:,1) <= negative_x_nth;

negative_x_nth_x = nonzeros(aligned_nodes_tibia_temp(:,1).*negative_x_nth_ROI);
negative_x_nth_y = nonzeros(aligned_nodes_tibia_temp(:,2).*negative_x_nth_ROI);
negative_x_nth_z = nonzeros(aligned_nodes_tibia_temp(:,3).*negative_x_nth_ROI);

av_negative_x_nth_x = mean(negative_x_nth_x);
av_negative_x_nth_y = mean(negative_x_nth_y);
av_negative_x_nth_z = mean(negative_x_nth_z);

av_negative_x_nth = [av_negative_x_nth_x,av_negative_x_nth_y,av_negative_x_nth_z];

% figure()
% plot3(aligned_nodes_tibia_temp(:,1),aligned_nodes_tibia_temp(:,2),aligned_nodes_tibia_temp(:,3),'k.')
% hold on
% plot3(negative_x_nth_x,negative_x_nth_y,negative_x_nth_z,'ys')
% plot3(av_negative_x_nth_x,av_negative_x_nth_y,av_negative_x_nth_z,'r.','MarkerSize',50)
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

%% Positive X nth ROI
positive_x_nth = x_max - nth_x;

positive_x_nth_ROI = aligned_nodes_tibia_temp(:,1) >= positive_x_nth;

positive_x_nth_x = nonzeros(aligned_nodes_tibia_temp(:,1).*positive_x_nth_ROI);
positive_x_nth_y = nonzeros(aligned_nodes_tibia_temp(:,2).*positive_x_nth_ROI);
positive_x_nth_z = nonzeros(aligned_nodes_tibia_temp(:,3).*positive_x_nth_ROI);

av_positive_x_nth_x = mean(positive_x_nth_x);
av_positive_x_nth_y = mean(positive_x_nth_y);
av_positive_x_nth_z = mean(positive_x_nth_z);

av_positive_x_nth = [av_positive_x_nth_x,av_positive_x_nth_y,av_positive_x_nth_z];

% figure()
% plot3(aligned_nodes_tibia_temp(:,1),aligned_nodes_tibia_temp(:,2),aligned_nodes_tibia_temp(:,3),'k.')
% hold on
% plot3(positive_x_nth_x,positive_x_nth_y,positive_x_nth_z,'ys')
% plot3(av_positive_x_nth_x,av_positive_x_nth_y,av_positive_x_nth_z,'r.','MarkerSize',50)
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

%% MDTA & TLSA Calculation
    temp_SI_tib = [0 0 0; (av_positive_z_nth_x - av_negative_z_nth_x),(av_positive_z_nth_y - av_negative_z_nth_y),(av_positive_z_nth_z - av_negative_z_nth_z)];
    temp_ML_tib = [0 0 0; (av_positive_x_nth_x - av_negative_x_nth_x),(av_positive_x_nth_y - av_negative_x_nth_y),(av_positive_x_nth_z - av_negative_x_nth_z)];
    temp_AP_tib = [0 0 0; (av_positive_y_nth_x - av_negative_y_nth_x),(av_positive_y_nth_y - av_negative_y_nth_y),(av_positive_y_nth_z - av_negative_y_nth_z)];


    temp_SI_tib_2D = [0 0 0; (av_positive_z_nth_x - av_negative_z_nth_x),0,(av_positive_z_nth_z - av_negative_z_nth_z)];
    temp_ML_tib_2D = [0 0 0; (av_positive_x_nth_x - av_negative_x_nth_x),0,(av_positive_x_nth_z - av_negative_x_nth_z)];
    temp_AP_tib_2D = [0 0 0; 0,(av_positive_y_nth_y - av_negative_y_nth_y),(av_positive_y_nth_z - av_negative_y_nth_z)];

%     MDTA = acosd(dot(temp_SI_tib(2,:),temp_ML_tib(2,:))/(norm(temp_SI_tib(2,:))*norm(temp_ML_tib(2,:))));
    MDTA_2D = acosd(dot(temp_SI_tib_2D(2,:),temp_ML_tib_2D(2,:))/(norm(temp_SI_tib_2D(2,:))*norm(temp_ML_tib_2D(2,:))));
    TLSA_2D = acosd(dot(temp_SI_tib_2D(2,:),temp_AP_tib_2D(2,:))/(norm(temp_SI_tib_2D(2,:))*norm(temp_AP_tib_2D(2,:))));

    figure()
    plot3(nodes_aligned_original_tibia(:,1),nodes_aligned_original_tibia(:,2),nodes_aligned_original_tibia(:,3),'.k')
    hold on
%     plot3(temp_SI_tib(:,1),temp_SI_tib(:,2),temp_SI_tib(:,3),'r-')
%     plot3(temp_ML_tib(:,1),temp_ML_tib(:,2),temp_ML_tib(:,3),'b-')
    plot3(temp_SI_tib_2D(:,1),temp_SI_tib_2D(:,2),temp_SI_tib_2D(:,3),'g-')
    plot3(temp_ML_tib_2D(:,1),temp_ML_tib_2D(:,2),temp_ML_tib_2D(:,3),'y-')
    plot3(temp_AP_tib_2D(:,1),temp_AP_tib_2D(:,2),temp_AP_tib_2D(:,3),'r-')
    xlabel('x')
    ylabel('y')
    zlabel('z')
    axis equal

%% Split up the bone into nth sections in all three planes
x_min = min(aligned_nodes_talus(:,1));
y_min = min(aligned_nodes_talus(:,2));
z_min = min(aligned_nodes_talus(:,3));
x_max = max(aligned_nodes_talus(:,1));
y_max = max(aligned_nodes_talus(:,2));
z_max = max(aligned_nodes_talus(:,3));

range_x = x_max - x_min;
range_y = y_max - y_min;
range_z = z_max - z_min;

% % Splits bone up in n sections
% if bone_indx == 1 % Talus
%     n = 3;
% elseif bone_indx == 2 % Calcaneus
%     n = 10;
% elseif bone_indx == 3 % Navicular
%     n = 5;
% elseif bone_indx == 4 % Cuboid
%     n = 5;
% elseif bone_indx >= 5 && bone_indx <= 7 % Cuneiforms
%     n = 3;
% elseif bone_indx >= 8 && bone_indx <= 12 % Metatarsals
%     n = 3;
% elseif bone_indx == 13 || bone_indx == 14 % talus or Fibula
%     n = 3;
% else
%     n = 7;
% end

n = 3;

nth_x = range_x/n;
nth_y = range_y/n;
nth_z = range_z/n;

%% Positive Y Nth ROI
positive_y_nth = y_max - nth_y;

positive_y_nth_ROI = aligned_nodes_talus(:,2) >= positive_y_nth;

positive_y_nth_x = nonzeros(aligned_nodes_talus(:,1).*positive_y_nth_ROI);
positive_y_nth_y = nonzeros(aligned_nodes_talus(:,2).*positive_y_nth_ROI);
positive_y_nth_z = nonzeros(aligned_nodes_talus(:,3).*positive_y_nth_ROI);

av_positive_y_nth_x = mean(positive_y_nth_x);
av_positive_y_nth_y = mean(positive_y_nth_y);
av_positive_y_nth_z = mean(positive_y_nth_z);

av_positive_y_nth = [av_positive_y_nth_x,av_positive_y_nth_y,av_positive_y_nth_z];

% figure()
% plot3(aligned_nodes_talus(:,1),aligned_nodes_talus(:,2),aligned_nodes_talus(:,3),'k.')
% hold on
% plot3(positive_y_nth_x,positive_y_nth_y,positive_y_nth_z,'ys')
% plot3(av_positive_y_nth_x,av_positive_y_nth_y,av_positive_y_nth_z,'r.','MarkerSize',50)
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

%% Negative Y nth ROI
negative_y_nth = y_min + nth_y;

negative_y_nth_ROI = aligned_nodes_talus(:,2) <= negative_y_nth;

negative_y_nth_x = nonzeros(aligned_nodes_talus(:,1).*negative_y_nth_ROI);
negative_y_nth_y = nonzeros(aligned_nodes_talus(:,2).*negative_y_nth_ROI);
negative_y_nth_z = nonzeros(aligned_nodes_talus(:,3).*negative_y_nth_ROI);

av_negative_y_nth_x = mean(negative_y_nth_x);
av_negative_y_nth_y = mean(negative_y_nth_y);
av_negative_y_nth_z = mean(negative_y_nth_z);

av_negative_y_nth = [av_negative_y_nth_x,av_negative_y_nth_y,av_negative_y_nth_z];

% figure()
% plot3(aligned_nodes_talus(:,1),aligned_nodes_talus(:,2),aligned_nodes_talus(:,3),'k.')
% hold on
% plot3(negative_y_nth_x,negative_y_nth_y,negative_y_nth_z,'ys')
% plot3(av_negative_y_nth_x,av_negative_y_nth_y,av_negative_y_nth_z,'r.','MarkerSize',50)
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

%% Positive Z nth ROI
positive_z_nth = z_max - nth_z;

positive_z_nth_ROI = aligned_nodes_talus(:,3) >= positive_z_nth;

positive_z_nth_x = nonzeros(aligned_nodes_talus(:,1).*positive_z_nth_ROI);
positive_z_nth_y = nonzeros(aligned_nodes_talus(:,2).*positive_z_nth_ROI);
positive_z_nth_z = nonzeros(aligned_nodes_talus(:,3).*positive_z_nth_ROI);

av_positive_z_nth_x = mean(positive_z_nth_x);
av_positive_z_nth_y = mean(positive_z_nth_y);
av_positive_z_nth_z = mean(positive_z_nth_z);

av_positive_z_nth = [av_positive_z_nth_x,av_positive_z_nth_y,av_positive_z_nth_z];

% figure()
% plot3(aligned_nodes_talus(:,1),aligned_nodes_talus(:,2),aligned_nodes_talus(:,3),'k.')
% hold on
% plot3(positive_z_nth_x,positive_z_nth_y,positive_z_nth_z,'ys')
% plot3(av_positive_z_nth_x,av_positive_z_nth_y,av_positive_z_nth_z,'r.','MarkerSize',50)
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

%% Negative Z nth ROI
negative_z_nth = z_min + nth_z;

negative_z_nth_ROI = aligned_nodes_talus(:,3) <= negative_z_nth;

negative_z_nth_x = nonzeros(aligned_nodes_talus(:,1).*negative_z_nth_ROI);
negative_z_nth_y = nonzeros(aligned_nodes_talus(:,2).*negative_z_nth_ROI);
negative_z_nth_z = nonzeros(aligned_nodes_talus(:,3).*negative_z_nth_ROI);

av_negative_z_nth_x = mean(negative_z_nth_x);
av_negative_z_nth_y = mean(negative_z_nth_y);
av_negative_z_nth_z = mean(negative_z_nth_z);

av_negative_z_nth = [av_negative_z_nth_x,av_negative_z_nth_y,av_negative_z_nth_z];

% figure()
% plot3(aligned_nodes_talus(:,1),aligned_nodes_talus(:,2),aligned_nodes_talus(:,3),'k.')
% hold on
% plot3(negative_z_nth_x,negative_z_nth_y,negative_z_nth_z,'ys')
% plot3(av_negative_z_nth_x,av_negative_z_nth_y,av_negative_z_nth_z,'r.','MarkerSize',50)
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

%% Negative X nth ROI
negative_x_nth = x_min + nth_x;

% if bone_indx == 13
%     aligned_nodes_talus_temp = [aligned_nodes_talus(aligned_nodes_talus(:,3)<30,1) aligned_nodes_talus(aligned_nodes_talus(:,3)<30,2) aligned_nodes_talus(aligned_nodes_talus(:,3)<30,3)];
% else 
    aligned_nodes_talus_temp = aligned_nodes_talus;
% end
% 
negative_x_nth_ROI = aligned_nodes_talus_temp(:,1) <= negative_x_nth;

negative_x_nth_x = nonzeros(aligned_nodes_talus_temp(:,1).*negative_x_nth_ROI);
negative_x_nth_y = nonzeros(aligned_nodes_talus_temp(:,2).*negative_x_nth_ROI);
negative_x_nth_z = nonzeros(aligned_nodes_talus_temp(:,3).*negative_x_nth_ROI);

av_negative_x_nth_x = mean(negative_x_nth_x);
av_negative_x_nth_y = mean(negative_x_nth_y);
av_negative_x_nth_z = mean(negative_x_nth_z);

av_negative_x_nth = [av_negative_x_nth_x,av_negative_x_nth_y,av_negative_x_nth_z];

% figure()
% plot3(aligned_nodes_talus_temp(:,1),aligned_nodes_talus_temp(:,2),aligned_nodes_talus_temp(:,3),'k.')
% hold on
% plot3(negative_x_nth_x,negative_x_nth_y,negative_x_nth_z,'ys')
% plot3(av_negative_x_nth_x,av_negative_x_nth_y,av_negative_x_nth_z,'r.','MarkerSize',50)
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

%% Positive X nth ROI
positive_x_nth = x_max - nth_x;

positive_x_nth_ROI = aligned_nodes_talus_temp(:,1) >= positive_x_nth;

positive_x_nth_x = nonzeros(aligned_nodes_talus_temp(:,1).*positive_x_nth_ROI);
positive_x_nth_y = nonzeros(aligned_nodes_talus_temp(:,2).*positive_x_nth_ROI);
positive_x_nth_z = nonzeros(aligned_nodes_talus_temp(:,3).*positive_x_nth_ROI);

av_positive_x_nth_x = mean(positive_x_nth_x);
av_positive_x_nth_y = mean(positive_x_nth_y);
av_positive_x_nth_z = mean(positive_x_nth_z);

av_positive_x_nth = [av_positive_x_nth_x,av_positive_x_nth_y,av_positive_x_nth_z];

% figure()
% plot3(aligned_nodes_talus_temp(:,1),aligned_nodes_talus_temp(:,2),aligned_nodes_talus_temp(:,3),'k.')
% hold on
% plot3(positive_x_nth_x,positive_x_nth_y,positive_x_nth_z,'ys')
% plot3(av_positive_x_nth_x,av_positive_x_nth_y,av_positive_x_nth_z,'r.','MarkerSize',50)
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal

%% TT Calculation
%     temp_SI_tal = [0 0 0; (av_positive_z_nth_x - av_negative_z_nth_x),(av_positive_z_nth_y - av_negative_z_nth_y),(av_positive_z_nth_z - av_negative_z_nth_z)];
    temp_ML_tal = [0 0 0; (av_positive_x_nth_x - av_negative_x_nth_x),(av_positive_x_nth_y - av_negative_x_nth_y),(av_positive_x_nth_z - av_negative_x_nth_z)];

%     temp_SI_2D = [0 0 0; (av_positive_z_nth_x - av_negative_z_nth_x),0,(av_positive_z_nth_z - av_negative_z_nth_z)];
    temp_ML_tal_2D = [0 0 0; (av_positive_x_nth_x - av_negative_x_nth_x),0,(av_positive_x_nth_z - av_negative_x_nth_z)];


    TT = acosd(dot(temp_ML_tal(2,:),temp_ML_tib(2,:))/(norm(temp_ML_tal(2,:))*norm(temp_ML_tib(2,:))));
    TT_2D = acosd(dot(temp_ML_tib_2D(2,:),temp_ML_tal_2D(2,:))/(norm(temp_ML_tib_2D(2,:))*norm(temp_ML_tal_2D(2,:))));

    figure()
%     plot3(nodes_aligned_original_talus(:,1),nodes_aligned_original_talus(:,2),nodes_aligned_original_talus(:,3),'.k')
    hold on
        plot3(nodes_aligned_original_tibia(:,1),nodes_aligned_original_tibia(:,2),nodes_aligned_original_tibia(:,3),'.k')
%     plot3(temp_ML_tal(:,1),temp_ML_tal(:,2),temp_ML_tal(:,3),'r-')
%     plot3(temp_ML_tib(:,1),temp_ML_tib(:,2),temp_ML_tib(:,3),'b-')
    plot3(temp_ML_tib_2D(:,1),temp_ML_tib_2D(:,2),temp_ML_tib_2D(:,3),'r-')
    plot3(temp_ML_tal_2D(:,1),temp_ML_tal_2D(:,2),temp_ML_tal_2D(:,3),'b-')
    xlabel('x')
    ylabel('y')
    zlabel('z')
    axis equal
