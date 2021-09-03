*Boosted Regression


********************************************************************************

program boost_reg 

args ind_var dep_var pred_name dist t

********************************************************************************


*Drop missing values
local NA=""

local j=0
foreach var of varlist `ind_var' `dep_var'	{
	local ++j
	}
local numv=`j'
	local j=1
foreach var of varlist `ind_var' `dep_var'	{

	if `j'!=`numv' {
		local NA="`NA' !missing(`var') & "
		}
	else {
		local NA="`NA' !missing(`var')"
		}
	local ++j	
	}


********************************************************************************

cap drop Rsquared_train
gen Rsquared_train=.
cap drop Rsquared_test
gen Rsquared_test=.
cap drop bestiter
gen bestiter=.
cap drop maxiter
gen maxiter=.
cap drop myinter
gen myinter=.
local i=0
local maxiter=20000
capture profiler clear 
profiler on
local tempiter=`maxiter'
foreach inter of numlist 1/6 8 10 15 20 {
	local i=`i'+1
    replace myinter= `inter' in `i'
	cap boost `ind_var' `dep_var' if `NA' & tratamiento==`t', dist(`dist') train(0.75) maxiter(`tempiter') ///
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
cap drop maxrsq
qui egen maxrsq=max(Rsquared_test)
cap drop iden
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
							
local shrink=0.006       	/*Lower shrinkage values usually improve the test R2 but 
							they increase the running time dramatically. 
							Shrinkage can be thought of as a step size*/						

							
capture drop `pred_name' 
capture profiler clear
profiler on
boost `ind_var' `dep_var' if `NA' & tratamiento==`t', dist(`dist') train(0.75) maxiter(`miter') bag(0.5) ///
	interaction(`opt_int') shrink(`shrink') influence predict(`pred_name')
profiler off


********************************************************************************

end
