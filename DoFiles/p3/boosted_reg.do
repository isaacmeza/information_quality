*Boosted Regression


********************************************************************************

program boosted_reg 

args ind_var dep_var trainf  

********************************************************************************

preserve

*Drop missing values
foreach var of varlist `ind_var' `dep_var'	{
	drop if missing(`var')
	}


********************************************************************************

gen Rsquared_train=.
gen Rsquared_test=.
gen bestiter=.
gen maxiter=.
gen myinter=.
local i=0
local maxiter=750
capture profiler clear 
profiler on
local tempiter=`maxiter'
foreach inter of numlist 1/6 8 10 15 20 {
	local i=`i'+1
    replace myinter= `inter' in `i'
	boost `ind_var' `dep_var' , dist(logistic) train(`trainf') maxiter(`tempiter') ///
		bag(0.5) interaction(`inter') shrink(0.1) 
	local maxiter=e(bestiter) 
	replace maxiter=`tempiter' in `i'
	replace bestiter=e(bestiter) in `i' 
	replace Rsquared_test=e(test_R2) in `i'
	replace Rsquared_train=e(train_R2) in `i'
	* as the number of interactions increase the best number of iterations will decrease
	* to be safe I am allowing an extra 20% of iterations and in case maxiter equals bestiter we double the number of iter
	* when the number of interactions is large this can save a lot of time
	if ( maxiter[`i']-bestiter[`i']<60) {
		local tempiter= round(maxiter[`i']*2)+10
		}
	else {
		local tempiter=round( e(bestiter) * 1.2 )+10
		}
	}
profiler off 


********************************************************************************


********************************************************************************
*Boosting 

qui egen maxrsq=max(Rsquared_test)
qui gen iden=_n if Rsquared_test==maxrsq
qui su iden

local opt_int=round(`r(mean)')		/*Optimum interaction according to previous process*/

if ( maxiter[`r(mean)']-bestiter[`r(mean)']<60) {
	local miter= round(maxiter[`r(mean)']*2.2+10)
	}
else {
	local miter=bestiter[`r(mean)']+120
	}
							/*Maximum number of iterations-if bestiter is closed to maxiter, 
							increase the number of max iter as the maximum likelihood 
							iteration may be larger*/
							
local shrink=0.05       	/*Lower shrinkage values usually improve the test R2 but 
							they increase the running time dramatically. 
							Shrinkage can be thought of as a step size*/						
						
capture drop boost_pred 
capture profiler clear
profiler on
boost `ind_var' `dep_var' , dist(logistic) train(`trainf') maxiter(`miter') bag(0.5) ///
	interaction(`opt_int') shrink(`shrink') influence 
profiler off

	
********************************************************************************
*Influence plot
matrix influence = e(influence)
svmat influence
gen id=_n
replace id=. if missing(influence)

qui su Rsquared_test
local test=round(`r(max)',.02)
qui su Rsquared_train
local train=round(`r(max)',.02)

graph bar (mean) influence, over(id) ytitle("Percentage Influence") ///
	scheme(s2mono) graphregion(color(white)) ///
	note("R-squared Test: `test'	|	 R-squared Train: `train'")
	
restore
	
end
