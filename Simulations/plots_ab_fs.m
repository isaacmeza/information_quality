%%
    %Meshgrid Size effect - Sample size
    [X,Y] = meshgrid(0:-0.02:-0.26,200:50:1000);
    %Read statistical power matrix
    M = csvread(['pwr_',num2str(1) ,'.csv']);
    %Interpolation grid
    [yy, xx] = meshgrid(0:-0.02:-0.26,200:50:1000);

    %Plot
    figure('units','normalized','outerposition',[0 0 1 1])
        %3D plot
    subplot(1,2,1);
    surfc(xx,yy,interp2(X,Y,M,yy,xx))
    colorbar('southoutside')
    xlabel('Sample size')
    ylabel('ATT size')
    zlabel('Statistical power')
        %Level curve plot
    subplot(1,2,2);
    plot(200:50:1000, M(:,[2,5,7,10,12,14]),'LineWidth' , 2)
    xlabel('Sample size')
    ylabel('Statistical power')
    lgd=legend(num2str(X(1,2)),num2str(X(1,5)),num2str(X(1,7)),num2str(X(1,10)),...
        num2str(X(1,12)),num2str(X(1,14)),'Location','southoutside','Orientation', 'horizontal' );
    title(lgd,'ATT size')
    grid on
    
    print(gcf, '-dtiff', ['pwr_AB_FS_',num2str(1) ,'.png'], '-r100')
    
%%
    %Meshgrid Size effect - Sample size
    [X,Y] = meshgrid(0.15:0.01:0.29,200:50:1000);
    %Read statistical power matrix
    M = csvread(['pwr_',num2str(2) ,'.csv']);
    %Interpolation grid
    [yy, xx] = meshgrid(0.15:0.01:0.29,200:50:1000);

    %Plot
    figure('units','normalized','outerposition',[0 0 1 1])
        %3D plot
    subplot(1,2,1);
    surfc(xx,yy,interp2(X,Y,M,yy,xx))
    colorbar('southoutside')
    xlabel('Sample size')
    ylabel('ATT size')
    zlabel('Statistical power')
        %Level curve plot
    subplot(1,2,2);
    plot(200:50:1000, M(:,[2,5,7,10,12,14]),'LineWidth' , 2)
    xlabel('Sample size')
    ylabel('Statistical power')
    lgd=legend(num2str(X(1,2)),num2str(X(1,5)),num2str(X(1,7)),num2str(X(1,10)),...
        num2str(X(1,12)),num2str(X(1,14)),'Location','southoutside','Orientation', 'horizontal' );
    title(lgd,'ATT size')
    grid on
    
    print(gcf, '-dtiff', ['pwr_AB_FS_',num2str(2) ,'.png'], '-r100')

 %%
    %Meshgrid Size effect - Sample size
    [X,Y] = meshgrid(0:0.02:0.26,200:50:1000);
    %Read statistical power matrix
    M = csvread(['pwr_',num2str(3) ,'.csv']);
    %Interpolation grid
    [yy, xx] = meshgrid(0:0.02:0.26,200:50:1000);

    %Plot
    figure('units','normalized','outerposition',[0 0 1 1])
        %3D plot
    subplot(1,2,1);
    surfc(xx,yy,interp2(X,Y,M,yy,xx))
    colorbar('southoutside')
    xlabel('Sample size')
    ylabel('ATT size')
    zlabel('Statistical power')
        %Level curve plot
    subplot(1,2,2);
    plot(200:50:1000, M(:,[2,5,7,10,12,14]),'LineWidth' , 2)
    xlabel('Sample size')
    ylabel('Statistical power')
    lgd=legend(num2str(X(1,2)),num2str(X(1,5)),num2str(X(1,7)),num2str(X(1,10)),...
        num2str(X(1,12)),num2str(X(1,14)),'Location','southoutside','Orientation', 'horizontal' );
    title(lgd,'ATT size')
    grid on
    
    print(gcf, '-dtiff', ['pwr_AB_FS_',num2str(3) ,'.png'], '-r100')
    
%%
    %Meshgrid Size effect - Sample size
    [X,Y] = meshgrid(0.1:0.02:0.38,200:50:1000);
    %Read statistical power matrix
    M = csvread(['pwr_',num2str(4) ,'.csv']);
    %Interpolation grid
    [yy, xx] = meshgrid(0.1:0.02:0.38,200:50:1000);

    %Plot
    figure('units','normalized','outerposition',[0 0 1 1])
        %3D plot
    subplot(1,2,1);
    surfc(xx,yy,interp2(X,Y,M,yy,xx))
    colorbar('southoutside')
    xlabel('Sample size')
    ylabel('ATT size')
    zlabel('Statistical power')
        %Level curve plot
    subplot(1,2,2);
    plot(200:50:1000, M(:,[2,5,7,10,12,14]),'LineWidth' , 2)
    xlabel('Sample size')
    ylabel('Statistical power')
    lgd=legend(num2str(X(1,2)),num2str(X(1,5)),num2str(X(1,7)),num2str(X(1,10)),...
        num2str(X(1,12)),num2str(X(1,14)),'Location','southoutside','Orientation', 'horizontal' );
    title(lgd,'ATT size')
    grid on
    
    print(gcf, '-dtiff', ['pwr_AB_FS_',num2str(4) ,'.png'], '-r100')
   


