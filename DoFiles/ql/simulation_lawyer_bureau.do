/*
Power calculations with moving parts.

Computes power for different sample size, and effect size, and stores them in a
matrix whose columns are the effect size, and the rows the sample size.
Each cell in each matrix stores the statistical power.

A 2SLS (IV) model is considered
	
	X = \alpha_{FS} + \beta_{FS} Z + \epsilon_{FS}				(1)
	Y = \alpha_{IV} + \beta_{IV} \hat{X} + \epsilon_{2sls]		(2)

where \hat{X} are the predicted values from (1), also known as First Stage.

As well as a 2SLS (CF) model
	
	P(X = 1 | Z) = \Phi(z\beta_{FS})  										(1)
	Y = \alpha_{CF} + \beta_{CF} X + 
		\delta_{CF}(X\lambda(z\beta_{FS})-(1-X)\lambda(-z\beta_{FS})
		+ \epsilon_{2sls]													(2)

where \epsilon_{2sls} is noise at the unit level, which in this case is at the day
level (so note that clustered std errors at this level are used).
		
where the first equation denotes a probit model and \lambda(.) is the well-known
inverse Mills ratio ((X\lambda(z\beta_{FS})-(1-X)\lambda(-z\beta_{FS}) is usually
known as a 'generalized error'. As noted by Wooldrige (2015), bootstraped s.e. 
are computed. We need to do this because we are running these as separate
regressions and, in effect, the residual from the first regression is an 
estimated value. 
		

The variables denote the following

	Z - exogenous randomization (treatment variable)
	X - dummy response variable
	Y - dummy dependent variable/continous dependent variable
	
The interpretation is as follows:

Receiving treatment (Z) (with probability `p_treat') increases the probability 
of switching to a good quality lawyer (X) by \beta_{FS} in average from a baseline
probability of `p_good' which in turn increases the probability of 
receiving a positive payment/ increases the payment (Y) by \beta_{IV} (\beta{CF})
in average from a baseline probability of `p_baseline'.

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
*Number of bootstrap replications
local b_reps=500
*Baseline dependent variable (Y)
local p_baseline=0.60
*ICC (intra-cluster-correlation) of (Y) by day 
local icc = 0.22
*Baseline for first stage
local p_good=0.20
*Average number of obs by day (randomization variable)
local obs_day = 10
*ICC (intra-cluster-correlation) of (X) by day (heterogeneity)
local icc_good = 0.17
*Probability of treatment
local p_treat=0.5
*Significance level
local signif=0.050

*Grid for 2SLS effect (ATT)
local beta_2sls "0.05 0.1 0.15 0.2 0.3 0.4"
local length_2sls=6
local sd_2sls=0.05

*Grid for beta_fs (FS)
local beta_fs ".2 .4"
local length_fs=2
local sd_fs=0.06
*Correlation between fs and 2sls
*If exclution restriction is met, then `cor'=0
local cor=0.09


********************************************************************************
********************************************************************************

local np=`length_nn'*`length_2sls'*`length_fs'*`m'
di "--------"
di "Número de procesos:"
di `np'
di "--------"
		
		
local k=0
local pb=0	
qui {	
foreach mu_x in `beta_fs' {
	local k=`k'+1
	*Define matrices in which power is stored 
	matrix pwr_iv_`k'= J(`length_nn',`length_2sls',0)
	matrix pwr_cf_`k'= J(`length_nn',`length_2sls',0)
	
	local j=0
	foreach mu_y in `beta_2sls' {
		local j=`j'+1

		local i=0
		forvalues n = `nn' {
			*Number of days per arms
			local d = round(`n'/(2*`obs_day')) 
			local i=`i'+1

			forvalues t=1/`m' {
				local pb=`pb'+1
				
				clear 
				set obs `n'
				
				 
				*Simulate a multivariate normal from where FS & ATE effects
				* are going to be drawn
				* If exclution restriction is met, then `cor'=0
				matrix C = (1 , `cor'  \ `cor' , 1 )
				matrix m = (`mu_x',`mu_y')
				matrix sd = (`sd_fs',`sd_2sls')
				drawnorm xx yy , n(`n') means(m) sds(sd) corr(C)

				*Exogenous randomization
				gen zz=(uniform()<=`p_treat')

				*Creation of clusters
				gen day=.
				replace day= floor(`d'*runiform()+1) if zz==1
				replace day= floor((2*`d'-`d')*runiform()+`d'+1) if zz==0
				
				*Simulate random noise
				gen epsilon_fs=.
				gen epsilon_y=.
				su day
				forvalues dy=1/`r(max)' {
					local eps_fs=rnormal(0,`icc_good')
					qui replace epsilon_fs=`eps_fs' if day==`dy'
					local eps_y=rnormal(0,`icc')
					qui replace epsilon_y=`eps_y' if day==`dy'
					}				
				
				*Simulate fs
				gen x=.
					*Baseline probability of having good quality lawyer 
				replace x=(uniform()<=`p_good'+epsilon_fs) if zz==0
					*Lawyer choice
					*Note that for Z = 1 probability of having X = 1 increases by xx
					*(following a marginal normal distribution).					
				replace x=(uniform()<=`p_good'+epsilon_fs+xx) if zz==1


				*Simulate dep var
				gen y=.
				
					*Baseline dep var probability
				replace y=(uniform()<=`p_baseline'+epsilon_y) if x==0
					*ATT
				replace y=(uniform()<=`p_baseline'+epsilon_y+yy) if x==1
				
				
								
				*2SLS
					*IV
				/*
				ivregress 2sls y (x=z), r  
				test _b[x]=0
				matrix pwr_iv_`k'[`i',`j']=pwr_iv_`k'[`i',`j']+(`r(p)'<=`signif')
				*/
					*CF
				probit x z, r	
				predict xb, xb
				*Generalized residuals
				gen gen_resid = cond(x == 1, normalden(xb)/normal(xb), -normalden(xb)/(1-normal(xb)))	
				reg y x gen_resid,  /*vce(bootstrap, reps(`b_reps'))*/ r  cluster(day)
				test _b[x]=0
				matrix pwr_cf_`k'[`i',`j']=pwr_cf_`k'[`i',`j']+(`r(p)'<=`signif')
				
								*Progress bar
				noi {
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
				}
			*matrix pwr_iv_`k'[`i',`j']=pwr_iv_`k'[`i',`j']/`m'
			matrix pwr_cf_`k'[`i',`j']=pwr_cf_`k'[`i',`j']/`m'
			}
		
	
		}
	*clear
	* svmat pwr_iv_`k'
	*export delimited using "$directorio\Simulations\pwr_iv_`k'.csv", replace novarnames

	clear
	 svmat pwr_cf_`k'
	export delimited using "$directorio\Simulations\pwr_cf_`k'.csv", replace novarnames
	
	}
	}

timer off 1
timer list



*POWER CALCULATION GRAPHS
forvalues k=1/2 {
	import delimited "$directorio\Simulations\pwr_cf_`k'.csv", clear
	
	
	
	*Power calculation graph
	gen sample_size=(_n-1)*250+1500

	twoway (line v1 sample_size, lwidth(medthick)) ///
		(line v2 sample_size, lwidth(medthick)) ///
		(line v3 sample_size, lwidth(medthick)) ///
		(line v4 sample_size, lwidth(medthick)) ///
		(line v5 sample_size, lwidth(medthick)) ///
		(line v6 sample_size, lwidth(medthick)) ///
			, graphregion(color(white)) xtitle("Sample size") ytitle("Statistical power") ///
			 legend(order(1 "5%" 2 "10%" 3 "15%" 4 "20%" 5 "30%" 6 "40%") rows(2)) ///
			 xlabel(1500(250)4500)
	graph export "$directorio\Simulations\stat_pwr_cf_`k'.pdf", replace
	
	/*
	import delimited "$directorio\Simulations\pwr_iv_`k'.csv", clear
	
	
	
	*Power calculation graph
	gen sample_size=(_n-1)*250+1500


	twoway (line v1 sample_size, lwidth(medthick)) ///
		(line v2 sample_size, lwidth(medthick)) ///
		(line v3 sample_size, lwidth(medthick)) ///
		(line v4 sample_size, lwidth(medthick)) ///
		(line v5 sample_size, lwidth(medthick)) ///
		(line v6 sample_size, lwidth(medthick)) ///
			, graphregion(color(white)) xtitle("Sample size") ytitle("Statistical power") ///
			 legend(order(1 "5%" 2 "10%" 3 "15%" 4 "20%" 5 "30%" 6 "40%") rows(2))  ///
			 xlabel(1500(250)4500)
	graph export "$directorio\Simulations\stat_pwr_iv_`k'.pdf", replace
	*/
	}

