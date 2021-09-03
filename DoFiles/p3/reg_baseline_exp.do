*BASELINE REGRESSIONS


use "$directorio\DB\treatment_data.dta", clear
********************************************************************************

qui gen esample=1	
qui gen nvals=.


*******************************************
*      BASELINE EXPECTATIONS			  *
*******************************************
	
local depvar cantidad_ganar cantidad_coarse prob_ganar prob_coarse
local controls mujer antiguedad salario_diario
eststo clear	
	
foreach var in `depvar'	{
	
	eststo: reg `var' i.main_treatment, robust cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	qui test 2.main_treatment=3.main_treatment
	estadd scalar test_23=`r(p)'	
	estadd local BVC="NO"
	estadd local Source="Baseline"
	forvalues i=1/3 {
		qui count if main_treatment==`i' & e(sample)
		local obs_`i'=r(N)
		}	
	estadd local obs_per_gr="`obs_1'/`obs_2'/`obs_3'"
	
	qui replace esample=(e(sample)==1)
	bysort esample main_treatment fecha_alta : replace nvals = _n == 1  
	forvalues i=1/3 {
		qui count if nvals==1 & main_treatment==`i' & esample==1
		local obs_`i'=r(N)
		}
	estadd local days_per_gr="`obs_1'/`obs_2'/`obs_3'"
	
	*---------------------------------------------------------------
	
	eststo: reg `var' i.main_treatment `controls', robust cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	qui test 2.main_treatment=3.main_treatment
	estadd scalar test_23=`r(p)'	
	estadd local BVC="YES"
	estadd local Source="Baseline"
	forvalues i=1/3 {
		qui count if main_treatment==`i' & e(sample)
		local obs_`i'=r(N)
		}	
	estadd local obs_per_gr="`obs_1'/`obs_2'/`obs_3'"
	
	qui replace esample=(e(sample)==1)
	bysort esample main_treatment fecha_alta : replace nvals = _n == 1  
	forvalues i=1/3 {
		qui count if nvals==1 & main_treatment==`i' & esample==1
		local obs_`i'=r(N)
		}
	estadd local days_per_gr="`obs_1'/`obs_2'/`obs_3'"
	
	}
	
	
	*************************
	esttab using "$directorio/Tables/reg_results/reg_baseline_exp.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "BVC BVC" "Source Source" "obs_per_gr Obs per group" "days_per_gr Days per group" "test_23 T2=T3") replace 
	

***********************************************************
*      BASELINE KNOWLDEGE OF EXPECTATIONS				  *
***********************************************************

local depvar cantidad_num cantidad_coarse prob_num prob_coarse
local controls mujer antiguedad salario_diario
eststo clear	
	

foreach var in `depvar'	{
	
	eststo: reg `var' i.main_treatment, robust cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	qui test 2.main_treatment=3.main_treatment
	estadd scalar test_23=`r(p)'	
	estadd local BVC="NO"
	estadd local Source="Baseline"
	forvalues i=1/3 {
		qui count if main_treatment==`i' & e(sample)
		local obs_`i'=r(N)
		}	
	estadd local obs_per_gr="`obs_1'/`obs_2'/`obs_3'"
	
	qui replace esample=(e(sample)==1)
	bysort esample main_treatment fecha_alta : replace nvals = _n == 1  
	forvalues i=1/3 {
		qui count if nvals==1 & main_treatment==`i' & esample==1
		local obs_`i'=r(N)
		}
	estadd local days_per_gr="`obs_1'/`obs_2'/`obs_3'"
	
	*---------------------------------------------------------------
	
	eststo: reg `var' i.main_treatment `controls', robust cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	qui test 2.main_treatment=3.main_treatment
	estadd scalar test_23=`r(p)'	
	estadd local BVC="YES"
	estadd local Source="Baseline"
	forvalues i=1/3 {
		qui count if main_treatment==`i' & e(sample)
		local obs_`i'=r(N)
		}	
	estadd local obs_per_gr="`obs_1'/`obs_2'/`obs_3'"
	
	qui replace esample=(e(sample)==1)
	bysort esample main_treatment fecha_alta : replace nvals = _n == 1  
	forvalues i=1/3 {
		qui count if nvals==1 & main_treatment==`i' & esample==1
		local obs_`i'=r(N)
		}
	estadd local days_per_gr="`obs_1'/`obs_2'/`obs_3'"
	
	}
	
	
	*************************
	esttab using "$directorio/Tables/reg_results/reg_baseline_knowledge.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "BVC BVC" "Source Source" "obs_per_gr Obs per group" "days_per_gr Days per group" "test_23 T2=T3") replace 
	
