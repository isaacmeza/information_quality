%%
clear all
close all
clc

%Tolerance level for difference in densities
tol_int=0;
%Vector of initial fees
ini_f=0:.5:2;

%%
%Read data
pub = xlsread('npv.xlsx','pub');
pri = xlsread('npv.xlsx','pri');

%Thousand pesos
pub(:,1)=pub(:,1)./1000; pri(:,1)=pri(:,1)./1000; 

%%

%Upper bound for threshold
MM=round(max(max(pub(:,1)),max(pri(:,1))),-1);

%Array of percentage and the percentile given the density cut-threshold
percentage=zeros(MM,5);
percentile=100*ones(MM,1)./(numel(pub(:,1))+numel(pri(:,1)));


for initial_fee=ini_f
    for threshold=1:1:MM
        
        %NPV
        npv_pub = pub(:,1); npv_pri = pri(:,1);
        %Substract initial fee for private
        npv_pri=npv_pri-initial_fee;
        %Npv at constant prices (June 2011)
        npv_pub=(npv_pub./pub(:,2)).*118.901; 
        npv_pri=(npv_pri./pri(:,2)).*118.901;
        %Restrict distribution up to `threshold'
        npv_pub(npv_pub>threshold)=NaN;
        npv_pri(npv_pri>threshold)=NaN;

        %Calculate CDF of percentage of people below threshold
        if initial_fee==0
            percentile(threshold)=percentile(threshold)...
                *(sum(npv_pri<=threshold)+sum(npv_pub<=threshold));
        end
        
        %NPV distribution for public is always positive
        npv_pub=npv_pub+eps;

        %Support of PDF
        m=min(npv_pri)-1; M=threshold+1; pts = (m:(M-m)/1000:M);
        
        %Kernel Density Smoothing 
        [f_pub,xi] = ksdensity(npv_pub, pts, 'Kernel','epanechnikov');
        [f_pri,~] = ksdensity(npv_pri, pts, 'Kernel','epanechnikov');

        %Normalize density (so that they integrate to 1)
        f_pub=f_pub./sum((f_pub(1:end-1)+f_pub(2:end)).*(diff(xi)/2));
        f_pri=f_pri./sum((f_pri(1:end-1)+f_pri(2:end)).*(diff(xi)/2));
        
        %Chebyshev fun
        fun_pub=chebfun(f_pub',[m M],'equi');
        fun_pri=chebfun(f_pri',[m M],'equi');

        %Difference function of public and private PDF (we look for roots
        %only in the positive part of the support)
        dif_pdf=(fun_pub-fun_pri)-tol_int;
        dif_pdf = chebfun({tol_int+1,dif_pdf},[m 0 M]);
        r=roots(dif_pdf);

        %Calculate percentage
        if isempty(r)==0
            %Interval up to the first change in sign (note that this
            %interval is always considered as it is when private
            %distribution is negative-only private integral si considered)
            I=[m -eps];
            percentage(threshold,initial_fee*2+1)=...
                    percentage(threshold,initial_fee*2+1)+sum(fun_pri,I);
                
            I=[-eps r(1)];
            if dif_pdf(mean(I))>0
                %Integral of PDF over interval I
                percentage(threshold,initial_fee*2+1)=...
                    percentage(threshold,initial_fee*2+1)+sum(fun_pri,I);
                percentage(threshold,initial_fee*2+1)=...
                    percentage(threshold,initial_fee*2+1)+sum(fun_pub,I);
            end
            
            for i=1:size(r)-1
                I=[r(i) r(i+1)];
                if dif_pdf(mean(I))>0
                    percentage(threshold,initial_fee*2+1)=...
                        percentage(threshold,initial_fee*2+1)+sum(fun_pub,I);
                    percentage(threshold,initial_fee*2+1)=...
                        percentage(threshold,initial_fee*2+1)+sum(fun_pri,I);
                end
            end

            I=[r(end) M];
            if dif_pdf(mean(I))>0
                percentage(threshold,initial_fee*2+1)=...
                    percentage(threshold,initial_fee*2+1)+sum(fun_pub,I);
                percentage(threshold,initial_fee*2+1)=...
                    percentage(threshold,initial_fee*2+1)+sum(fun_pri,I);
            end
            
            percentage(threshold,initial_fee*2+1)=...
                percentage(threshold,initial_fee*2+1)*100/2;
        %If there are not root found:
        else 
            %If difference of PDF is always positive
            if dif_pdf(mean(0,M))>0
                percentage(threshold,initial_fee*2+1)=100;
            %Only negative part of provate PDF    
            else
            percentage(threshold,initial_fee*2+1)=100*sum(fun_pri, [m-eps,-eps]);
            end
        end
    end
end
%%
close all
figure
hold on
plot(1:MM,percentage(:,:), 'LineWidth' , 2)
plot(1:MM,percentile,'Color', 'black', 'LineStyle','--')
lgd=legend(num2str(ini_f(1)),num2str(ini_f(2)),num2str(ini_f(3)),num2str(ini_f(4)), ...
    num2str(ini_f(5)),'Location','southoutside','Orientation', 'horizontal' );
title(lgd,'Initial fee')
title('% Public Lawyer is better off');
hold off
grid on

print(gcf, '-dtiff', 'percentage_lines_calcb.tiff', '-r300')
