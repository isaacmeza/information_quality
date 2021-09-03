%%
clear all
close all
clc

%Tolerance level for difference in densities
tol_int=0;
%Initial fee
initial_fee=1.0;
%NPV cutoff
threshold=75;

%%
%Read data
pub = xlsread('npv.xlsx','pub');
pri = xlsread('npv.xlsx','pri');

%Thousand pesos
pub(:,1)=pub(:,1)./1000; pri(:,1)=pri(:,1)./1000; 

%%

%Initialization of percentile-percentage
percentage=0;
percentile=100./(numel(pub(:,1))+numel(pri(:,1)));
     
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
percentile=percentile*(sum(npv_pri<=threshold)+sum(npv_pub<=threshold));
 
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
dif_pdf = chebfun({tol_int+fun_pri,dif_pdf},[m 0 M]);
r=roots(dif_pdf);

%Calculate percentage
if isempty(r)==0
    %Interval up to the first change in sign (note that this
    %interval is always considered as it is when private
    %distribution is negative-only private integral si considered)
    I=[m -eps];
    percentage=percentage+sum(fun_pri,I);
                
    I=[-eps r(1)];
    if dif_pdf(mean(I))>0
        %Integral of PDF over interval I
        percentage=percentage+sum(fun_pri,I);
        percentage=percentage+sum(fun_pub,I);
    end
            
    for i=1:size(r)-1
        I=[r(i) r(i+1)];
        if dif_pdf(mean(I))>0
        percentage=percentage+sum(fun_pub,I);
        percentage=percentage+sum(fun_pri,I);
        end
    end

    I=[r(end) M];
    if dif_pdf(mean(I))>0
        percentage=percentage+sum(fun_pub,I);
        percentage=percentage+sum(fun_pri,I);
    end
            
    percentage=percentage*100/2;
%If there are not root found:
else 
    %If difference of PDF is always positive
    if dif_pdf(mean(0,M))>0
        percentage=100;
        %Only negative part of provate PDF    
    else
        percentage=100*sum(fun_pri, [m-eps,-eps]);
    end
end

%Percentage of people being better of. The integral of the difference of
%the pdfs across all the support in the distribution.
better_off=100*sum(dif_pdf);

%%
%Plots
r=r+eps;
figure;
subplot(2,1,1);
hold on
plot(fun_pub,'LineWidth' , 1.5)
plot(fun_pri, 'LineWidth' , 1.5)
legend('Public','Private','Location','southoutside','Orientation', 'horizontal' );
title('PDF');
hold off
grid on
subplot(2,1,2);
hold on
plot(dif_pdf, 'LineWidth' , 1.5)
plot(r,dif_pdf(r),'.g','MarkerSize',20);
title('Difference in PDFs');
hold off
grid on

%print(gcf, '-dtiff', 'pdf_dif.tiff', '-r100')


%%
%Results
fprintf(' \n');
fprintf(' ----------------------------------------------------------------------- \n');
fprintf('With a cutoff of %4.1f NPV, & an initial fee of %4.2f : \n',threshold,initial_fee);
fprintf(' \n');
fprintf('The percentage of population below the threshold is %4.2f \n',percentile);
fprintf('and the percentage of public lawyers that recover more than private is %4.2f \n',percentage);
fprintf('using a tolerance in difference of PDF of %d .\n',tol_int);
fprintf('Moreover, with a public lawyer they are %4.2f percent better of.\n',better_off);
fprintf(' ----------------------------------------------------------------------- \n');
fprintf(' ----------------------------------------------------------------------- \n');

