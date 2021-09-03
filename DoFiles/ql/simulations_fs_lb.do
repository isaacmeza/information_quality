/*
Power calculations with a moving part.

Computes power for different sample size and effect size, and stores them in a
matrix whose columns are the effect size and the rows the sample size.
Each cell in each matrix stores the statistical power.

A first-stage model (also can be interpreted as a reduced-form model) is considered
	
	X = \alpha_{FS} + \beta_{FS} Z + \epsilon_{FS}				(1)

where \epsilon_{FS} is noise at the unit level, which in this case is at the day
level (so note that clustered std errors at this level are used).
	
The variables denote the following

	Z - exogenous randomization (treatment variable)
	X - dummy dependent variable
	
The interpretation is as follows:

Receiving treatment (Z) (with probability `p_treat') increases the probability 
of the dependent variable (X) by \beta_{FS} in average from a baseline 
probability of `p_baseline'.

Within each cell `m' replications are run to estimate the power.

*/


clear all
set more off 
	global directorio C:\Users\xps-seira\Dropbox\Apps\ShareLaTeX\quality_lawyers
	
timer on 1

*Sample size
local nn "1500(250)4500"
local length_nn=13
*Number of replications
local m=900
*Baseline dependent variable
local p_baseline=0.20
*Probability of treatment
local p_treat=0.5
*Average number of obs by day (randomization variable)
local obs_day = 10
*ICC (intra-cluster-correlation) of X by day (heterogeneity)
local icc = 0.17
*Significance level
local signif=0.050
*Grid for beta_fs (FS)
local beta_fs "0.025 .05 .1 .15 .2 .25 .3 .4"
local length_fs=8
local sd_fs=0.06

********************************************************************************
********************************************************************************


local np=`length_nn'*`length_fs'*`m'
di "--------"
di "Número de procesos:"
di `np'
di "--------"
		
		
local k=0
local pb=0


	*Define matrices in which power is stored 
	matrix pwr= J(`length_nn',`length_fs',0)
	
	local j=0
	foreach mu_x in `beta_fs' {
		local j=`j'+1

		local i=0
		forvalues n = `nn' {
			*Number of days per arms
			local d = round(`n'/(2*`obs_day')) 
			local i=`i'+1

			forvalues t=1/`m' {
				local pb=`pb'+1
				
				clear 
				qui set obs `n'
				
				*Simulate a normal dist from where FS is going to be drawn
				qui gen yy=rnormal(`mu_x',`sd_fs')
				
				*Exogenous randomization
				qui gen zz=(uniform()<=`p_treat')
				
				*Creation of clusters
				qui gen day=.
				qui replace day= floor(`d'*runiform()+1) if zz==1
				qui replace day= floor((2*`d'-`d')*runiform()+`d'+1) if zz==0
				
				*Simulate random noise
				qui gen epsilon_icc=.
				qui su day
				forvalues dy=1/`r(max)' {
					local eps=rnormal(0,`icc')
					qui replace epsilon_icc=`eps' if day==`dy'
					}
					
				*Simulate dep var
				qui gen y=.
					*Baseline dep var probability
				qui replace y=(uniform()<=`p_baseline'+epsilon_icc) if zz==0
					*ATT
				qui replace y=(uniform()<=`p_baseline'+epsilon_icc+yy) if zz==1

				
				*REG
				qui reg y zz, r cluster(day) 
				qui test _b[zz]=0
				matrix pwr[`i',`j']=pwr[`i',`j']+(`r(p)'<=`signif')
				
				
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
				
			matrix pwr[`i',`j']=pwr[`i',`j']/`m'
			}
		}
	
	
	clear
	qui svmat pwr
	qui export delimited using "$directorio\Simulations\pwr_fs.csv", replace novarnames

	


timer off 1
timer list




*Power calculation FS graph
gen sample_size=(_n-1)*250+1500

twoway (line pwr1 sample_size, lwidth(medthick)) ///
	(line pwr2 sample_size, lwidth(medthick)) ///
	(line pwr3 sample_size, lwidth(medthick)) ///
	(line pwr4 sample_size, lwidth(medthick)) ///
	(line pwr5 sample_size, lwidth(medthick)) ///
	(line pwr6 sample_size, lwidth(medthick)) ///
	(line pwr7 sample_size, lwidth(medthick)) ///
	(line pwr8 sample_size, lwidth(medthick)) ///	
		, graphregion(color(white)) xtitle("Sample size") ytitle("Statistical power") ///
		legend(order(1 "2.5%" 2 "5%" 3 "10%" 4 "15%" 5 "20%" 6 "25%" ///
					7 "30%" 8 "40%") rows(2))
graph export "$directorio\Simulations\stat_pwr_fs.pdf", replace

