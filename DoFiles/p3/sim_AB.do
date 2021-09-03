/*
Power calculations with moving parts (3SLS).

Computes power for different sample size and effect size, and stores them in a
matrix whose columns are the effect size and the rows the sample size.
Each cell in each matrix stores the statistical power.

A 2SLS model is considered
	
	X = \alpha_{FS} + \beta_{FS} Z + \epsilon_{FS}				(1)
	Y = \alpha_{IV} + \beta_{IV} \hat{X} + \epsilon_{IV]		(2)
	
where \hat{X} are the predicted values from (1), also known as First Stage.

The variables denote the following

	Z - exogenous randomization (treatment variable)
	X - dummy talked to public lawyer
	Y - dummy sued with public lawyer
	
The interpretation is as follows:

Receiving treatment (Z) (with probability `p_treat') increases the probability 
of talking to public lawyer (X) by \beta_{FS} in average from a baseline 
probability of `p_tpl' which in turn increases the probability of having a public 
lawyer (Y) by \beta_{IV} in average from a baseline probability of `p_pl'. 

It is important to note that as randomization unit is a day `nn', 
we cluster errors by day. Within each day in average `trial' cases 
with probability `p_success' are done. (Giving in average `trial'*`p_success' obs)

Within each cell `m' replications are run to estimate the power.

*/


clear all

local user "Posili"

if "`user'"=="Moni" {
	global directorio C:\Users\Monica\Repos\information_settlement\Pilot_3
	}
else {
	global directorio C:\Users\xps-seira\Dropbox\Apps\ShareLaTeX\information_settlement\Pilot_3
	}
timer on 1

*Sample size (number of randomizations)
local nn "17(1)27"
local length_nn=27
*Trials per day (avg)
local trial=12
*'Variance' of trials
local vr=4
*Probability of success in treatment/survey
local p_success=0.76
*Number of replications
local m=2
*Probability talking to public lawyer
local p_tpl=0.46
*Probability sueing with public lawyer
local p_pl=0.50
*Probability of suing
local p_sue=0.36
*Probability increase of suing for private lawyer
local mu_sue=0.00
*Response rate
local response_rate=0.60
*Significance level
local signif=0.05
*Grid for beta_iv (ATT)
local beta_iv "0(0.05)1"
local length_iv=20
*Grid for beta_fs (FS)
local beta_fs "0.2(0.1)0.7"
local length_fs=6


********************************************************************************
********************************************************************************

*Number of processess
local np=`length_iv'*`length_fs'*`m'*(`length_nn'*(`length_nn'+1)/2-136)
		
local p=0
local pb=0

forvalues mu_x = `beta_fs' {
	local p=`p'+1
	*Define matrices in which power is stored 
	mata: pwr_`p'= J(`length_nn',`length_iv',0)
	
	local j=0
	forvalues mu_y = `beta_iv' {
		local j=`j'+1

		local i=0
		forvalues n = `nn' {
			local i=`i'+1

			forvalues t=1/`m' { 
				
				forvalues k=1/`n' {
					local pb=`pb'+1
					*Set number of observations in whole randomization
					*Each arm A/B will have 2 days (each of wich have in average `trial'*`p_success' obs)
			
					forvalues day=1/4 {
						clear
						local obs=rbinomial(`trial'+round((2*`vr'-1)*runiform()-`vr'+1,1),`p_success')
						qui set obs `obs'
						
						*Exogenous randomization
							*Days
						qui gen date=4*`k'+`day' 
							*Treatment
						if `day'<=2 {
							qui gen zz=1
							}
						else {
							qui gen zz=0
							}
						
						*Simulate a multivariate normal from where FS & ATE effects and probability of sue
						* are going to be drawn
						matrix C = (1 , 0.4 , 0 \ 0.4 , 1 , 0 \ 0 , 0 , 1)
						matrix m = (`mu_x',`mu_y',`mu_sue')
						matrix sd = (.3,.3,.3)
						qui drawnorm xx yy ww, n(`obs') means(m) sds(sd) corr(C)
						
						
						*Simulate public lawyer
						qui gen x=.
							*Baseline probability of talking to public lawyer 
						qui replace x=(uniform()<=`p_tpl') if zz==0
							*Lawyer choice
							*Note that for Z = 1 probability of having X = 1 increases by xx (following
							*a marginal normal distribution.					
						qui replace x=(uniform()<=`p_tpl'+xx) if zz==1

						
						*Simulate sueing with public
						qui gen y=.
							*Baseline sueing probability
						qui replace y=(uniform()<=`p_pl') if x==0
							*ATT
						qui replace y=(uniform()<=`p_pl'+yy) if x==1

						
						*Drop observations that did not sue
							*Public lawyers
						qui replace y=. if  x==1 & (uniform()>=`p_sue')==0
							*Private lawyers
						qui replace y=. if  x==0 & (uniform()>=`p_sue'+ww)==0
						
						
						*Drop according to response rate
						qui replace y=. if (uniform()>=`response_rate')
					
					
						tempfile temp_`day'
						qui save `temp_`day''
						}
				
						
					*Dataset for a single randomization
					use `temp_1', clear
					forvalues r=2/4 {
						qui append using `temp_`r''
						}
						
					tempfile temp_`k'
					qui save `temp_`k''
				
				
				
				    *Progress bar
					if `pb'==1 {
						di "--------"
						di "Número de procesos:"
						di `np'
						di "--------"
						di "Progress"
						di "--------"
						}
					if `pb'==floor(`np'/10) {
						di "10%"
						}
					if `pb'==floor(`np'*2/10) {
						di "20%"
						}
					if `pb'==floor(`np'*3/10) {
						di "30%"
						}
					if `pb'==floor(`np'*4/10) {
						di "40%"
						}
					if `pb'==floor(`np'*5/10) {
						di "50%"
						}
					if `pb'==floor(`np'*6/10) {
						di "60%"
						}
					if `pb'==floor(`np'*7/10) {
						di "70%"
						}
					if `pb'==floor(`np'*8/10) {
						di "80%"
						}
					if `pb'==floor(`np'*9/10) {
						di "90%"
						}
					if `pb'==floor(`np'-10) {
						di "100%"
						di "--------"
						di "        "
						}
				
					}
					
				*Complete dataset
				use `temp_1', clear
				forvalues k=1/`n' {
					qui append using `temp_`k''
					}
				
				*IVREG
				qui ivreg y (x=z),  r cluster(date)  
				qui test _b[x]=0
				mata: pwr_`p'[`i',`j']=pwr_`p'[`i',`j']+(`r(p)'<=`signif')		
				
				}
				
			mata: pwr_`p'[`i',`j']=pwr_`p'[`i',`j']/`m'
			
			}
		}
	
	
	clear
	mata: pwr_`p'=pwr_`p' 
	qui getmata (var*) = pwr_`p'
	qui export delimited using "$directorio\Simulations\pwr_`p'.csv", replace novarnames

	}


timer off 1
timer list

