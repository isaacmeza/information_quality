*TREATMENT EFFECTS REGRESSIONS



********************************************************************************
*									2W								  		   *
********************************************************************************
use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)

********************************************************************************

qui gen esample=1	
qui gen nvals=.

local depvar hablo_con_abogado conflicto_arreglado 
local controls mujer antiguedad salario_diario


*******************************
* 			MAIN ARMS		  *
*******************************
eststo clear	
	
foreach var in `depvar'	{
	
	eststo: reg `var' i.main_treatment `controls', robust cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	qui test 2.main_treatment=3.main_treatment
	estadd scalar test_23=`r(p)'	
	estadd local BVC="YES"
	estadd local Source="2w"
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
	esttab using "$directorio/Tables_Draft/reg_results/te123_2w_actions.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "BVC BVC" "Source Source" "obs_per_gr Obs per group" "days_per_gr Days per group" "test_23 T2=T3") replace 
	
	
	
*******************************
* 			   A-B			  *
*******************************
eststo clear	
	
foreach var in `depvar'	{
	
	eststo: reg `var' i.group `controls', robust cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	estadd local BVC="YES"
	estadd local Source="2w"
	forvalues i=1/2 {
		qui count if group==`i' & e(sample)
		local obs_`i'=r(N)
		}	
	estadd local obs_per_gr="`obs_1'/`obs_2'"
	
	qui replace esample=(e(sample)==1)
	bysort esample group fecha_alta : replace nvals = _n == 1  
	forvalues i=1/2 {
		qui count if nvals==1 & group==`i' & esample==1
		local obs_`i'=r(N)
		}
	estadd local days_per_gr="`obs_1'/`obs_2'"
	
	}
	
	
	*************************
	esttab using "$directorio/Tables_Draft/reg_results/teAB_2w_actions.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "BVC BVC" "Source Source" "obs_per_gr Obs per group" "days_per_gr Days per group") replace 
	
	
	

	
	

********************************************************************************
*									2M								  		   *
********************************************************************************
use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)

********************************************************************************

qui gen esample=1	
qui gen nvals=.

local depvar conflicto_arreglado entablo_demanda 
local controls mujer antiguedad salario_diario


*******************************
* 			MAIN ARMS		  *
*******************************
eststo clear	
	
foreach var in `depvar'	{
	
	eststo: reg `var' i.main_treatment `controls', robust cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	qui test 2.main_treatment=3.main_treatment
	estadd scalar test_23=`r(p)'	
	estadd local BVC="YES"
	estadd local Source="2m"
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
	esttab using "$directorio/Tables_Draft/reg_results/te123_2w_actions.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "BVC BVC" "Source Source" "obs_per_gr Obs per group" "days_per_gr Days per group" "test_23 T2=T3") append 
	
	
	
*******************************
* 			   A-B			  *
*******************************
eststo clear	
	
foreach var in `depvar'	{
	
	eststo: reg `var' i.group `controls', robust cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	estadd local BVC="YES"
	estadd local Source="2m"
	forvalues i=1/2 {
		qui count if group==`i' & e(sample)
		local obs_`i'=r(N)
		}	
	estadd local obs_per_gr="`obs_1'/`obs_2'"
	
	qui replace esample=(e(sample)==1)
	bysort esample group fecha_alta : replace nvals = _n == 1  
	forvalues i=1/2 {
		qui count if nvals==1 & group==`i' & esample==1
		local obs_`i'=r(N)
		}
	estadd local days_per_gr="`obs_1'/`obs_2'"
	
	}
	
	
	*************************
	esttab using "$directorio/Tables_Draft/reg_results/teAB_2w_actions.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "BVC BVC" "Source Source" "obs_per_gr Obs per group" "days_per_gr Days per group") append 
	
