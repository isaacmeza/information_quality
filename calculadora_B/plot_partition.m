clc
close all 

%Read partition/bounds matrix
M_above = csvread('partition_pub_pri_above.csv');
M_below = csvread('partition_pub_pri_below.csv');

%Meshgrid : Wage cutoff - Fee payment
[X,Y] = meshgrid(100:10:1100, 0:100:10000);
%Interpolation grid
[yy, xx] = meshgrid(100:5:1100, 0:50:10000);



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PARTITION ABOVE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot
figure('units','normalized','outerposition',[0 0 1 1])
%3D plot
surfc(xx,yy,interp2(X,Y,M_above,yy,xx))
colorbar('southoutside')
ylabel('Fee payment')
xlabel('Wage cutoff')
zlabel('% Compensation private')
print(gcf, '-dtiff', 'surf_partition_above.tiff', '-r100')


%Plot
figure('units','normalized','outerposition',[0 0 1 1])
%Level curve plot
subplot(1,2,1);
plot(0:100:10000, M_above(:,[13 16 18 21 23]),'LineWidth' , 2)
xlabel('Fee Payment')
ylabel('% Compensation private')
lgd=legend(num2str(X(1,13)),num2str(X(1,16)),num2str(X(1,18)),num2str(X(1,21)),...
num2str(X(1,23)),'Location','southoutside','Orientation', 'horizontal' );
title(lgd,'Wage cutoff')
grid on
%Level curve plot
subplot(1,2,2);
plot(100:10:1100, M_above([6 11 16 21 26],:),'LineWidth' , 2)
xlabel('Wage cutoff')
ylabel('% Compensation private')
lgd=legend(num2str(Y(6,1)),num2str(Y(11,1)),num2str(Y(16,1)),num2str(Y(21,1)),...
num2str(Y(26,1)),'Location','southoutside','Orientation', 'horizontal' );
title(lgd,'Fee payment')
grid on
print(gcf, '-dtiff', 'level_partition_above.tiff', '-r100')

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PARTITION BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot
figure('units','normalized','outerposition',[0 0 1 1])
%3D plot
surfc(xx,yy,interp2(X,Y,M_below,yy,xx))
colorbar('southoutside')
xlabel('Fee payment')
ylabel('Wage cutoff')
zlabel('% Compensation private')
print(gcf, '-dtiff', 'surf_partition_below.tiff', '-r100')


%Plot
figure('units','normalized','outerposition',[0 0 1 1])
%Level curve plot
subplot(1,2,1);
plot(0:100:10000, M_below(:,[13 16 18 21 23]),'LineWidth' , 2)
xlabel('Fee Payment')
ylabel('% Compensation private')
lgd=legend(num2str(X(1,13)),num2str(X(1,16)),num2str(X(1,18)),num2str(X(1,21)),...
num2str(X(1,23)),'Location','southoutside','Orientation', 'horizontal' );
title(lgd,'Wage cutoff')
grid on
%Level curve plot
subplot(1,2,2);
plot(100:10:1100, M_below([6 11 16 21 26],:),'LineWidth' , 2)
xlabel('Wage cutoff')
ylabel('% Compensation private')
lgd=legend(num2str(Y(6,1)),num2str(Y(11,1)),num2str(Y(16,1)),num2str(Y(21,1)),...
num2str(Y(26,1)),'Location','southoutside','Orientation', 'horizontal' );
title(lgd,'Fee payment')
grid on
print(gcf, '-dtiff', 'level_partition_below.tiff', '-r100')

