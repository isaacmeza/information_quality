/*
Power calculations with a moving part.

Computes power for different sample size and effect size, and stores them in a
matrix whose columns are the effect size and the rows the sample size.
Each cell in each matrix stores the statistical power.

A 2SLS model is considered
	
	X = \alpha_{FS} + \beta_{FS} Z + \epsilon_{FS}				(1)
	Y = \alpha_{IV} + \beta_{IV} \hat{X} + \epsilon_{IV]		(2)

where \hat{X} are the predicted values from (1), also known as First Stage.

The variables denote the following

	Z - exogenous randomization (treatment variable)
	X - dummy public lawyer
	Y - dummy conciliation
	
The interpretation is as follows:

Receiving treatment (Z) (with probability `p_treat') increases the probability 
of having public lawyer (X) by \beta_{FS} in average from a baseline probability of `p_pl'
which in turn increases the probability of conciliation (Y) by \beta_{IV} in average 
from a baseline probability of `p_conc'.

Within each cell `m' replications are run to estimate the power.

*/


clear all

local user "Moni"

if "`user'"=="Moni" {
	global directorio C:\Users\Monica\Repos\information_settlement\Pilot_3
	}
else {
	global directorio C:\Users\xps-seira\Dropbox\Apps\ShareLaTeX\information_settlement\Pilot_3
	}
timer on 1

*Sample size
local nn "100(50)3000"
local length_nn=59
*Number of replications
local m=1000
*Probability of public lawyer
local p_pl=0.5
*Probability of conciliation
local p_conc=0.4
*Probability of treatment
local p_treat=0.5
*Probability of suing
local p_sue=0.3
*Probability increase of suing for private lawyer
local mu_sue=0.5
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


local np=`length_nn'*`length_iv'*`length_fs'*`m'
di "--------"
di "Número de procesos:"
di `np'
di "--------"
		
		
local k=0
local pb=0

forvalues mu_x = `beta_fs' {
	local k=`k'+1
	*Define matrices in which power is stored 
	mata: pwr_`k'= J(`length_nn',`length_iv',0)
	
	local j=0
	forvalues mu_y = `beta_iv' {
		local j=`j'+1

		local i=0
		forvalues n = `nn' {
			local i=`i'+1

			forvalues t=1/`m' {
				local pb=`pb'+1
				
				clear 
				qui set obs `n'
				
				*Simulate a multivariate normal from where FS & ATE effects and probility of sue
				* are going to be drawn
				matrix C = (1 , 0.3 , 0 \ 0.3 , 1 , 0 \ 0 , 0 , 1)
				matrix m = (`mu_x',`mu_y', `mu_sue')
				matrix sd = (.3,.3,.3)
				qui drawnorm xx yy ww, n(`n') means(m) sds(sd) corr(C)

				*Exogenous randomization
				qui gen zz=(uniform()<=`p_treat')

				*Simulate public lawyer
				qui gen x=.
					*Baseline probability of having public lawyer 
				qui replace x=(uniform()<=`p_pl') if zz==0
					*Lawyer choice
					*Note that for Z = 1 probability of having X = 1 increases by xx (following
					*a marginal normal distribution.					
				qui replace x=(uniform()<=`p_pl'+xx) if zz==1


				*Simulate conciliation
				qui gen y=.
					*Baseline conciliation probability
				qui replace y=(uniform()<=`p_conc') if x==0
					*ATT
				qui replace y=(uniform()<=`p_conc'+yy) if x==1

				*Drop observations that did not sue
					*Public lawyers
				qui replace y=. if  x==1 & (uniform()<=`p_sue')==0
					*Private lawyers
				qui replace y=. if  x==0 & (uniform()<=`p_sue'+ww)==0	
				
				*IVREG
				qui ivreg y (x=z), r  
				qui test _b[x]=0
				mata: pwr_`k'[`i',`j']=pwr_`k'[`i',`j']+(`r(p)'<=`signif')
				
				
								*Progress bar

				if `pb'==1 {
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
				
			mata: pwr_`k'[`i',`j']=pwr_`k'[`i',`j']/`m'
			}
		}
	
	
	clear
	mata: pwr_`k'=pwr_`k' 
	qui getmata (var*) = pwr_`k'
	qui export delimited using "$directorio\Simulations\pwr_`k'.csv", replace novarnames

	}


timer off 1
timer list

