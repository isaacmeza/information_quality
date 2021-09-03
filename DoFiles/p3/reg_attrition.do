*DIFFERENTIAL ATTRITION REGRESSIONS


********************************************************************************
*									2W - 2M							  		   *
********************************************************************************
use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2w.dta", keep(1 3) keepusing(id_actor status_encuesta)

*Attrition rate
qui su date
gen attrition_2w=(_merge==1) if inrange(date,date("1/08/2017" ,"DMY"),date(c(current_date) ,"DMY")-21)
replace attrition_2w=1 if attrition_2w==0 & status_encuesta!=1

drop _merge
keep attrition_2w id_actor
tempfile temp2w
save `temp2w'

use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(1 3) keepusing(id_actor status_encuesta)
merge 1:1 id_actor using `temp2w', nogen

*Attrition rate
qui su date 
gen attrition_2m=(_merge==1) if inrange(date,`r(min)',date(c(current_date) ,"DMY")-70)
replace attrition_2m=1 if attrition_2m==0 & status_encuesta!=1


********************************************************************************
eststo clear

qui gen esample=1	
qui gen nvals=.


*Regression 2w
eststo : reg attrition_2w i.main_treatment , robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui test 2.main_treatment=3.main_treatment
estadd scalar test_23=`r(p)'
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
	


*Regression 2m
eststo : reg attrition_2m i.main_treatment, robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui test 2.main_treatment=3.main_treatment
estadd scalar test_23=`r(p)'
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
			
	


********************************************************************************
*									2W & 2M							  		   *
********************************************************************************
use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2w.dta", keep(3) keepusing(id_actor)
qui su date
keep if inrange(date,date("1/08/2017" ,"DMY"),date(c(current_date) ,"DMY")-21)

drop _merge
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(1 3) keepusing(id_actor status_encuesta)

*Attrition rate
qui su date 
gen attrition_2w2m=(_merge==1) if inrange(date,`r(min)',date(c(current_date) ,"DMY")-70)
replace attrition_2w2m=1 if attrition_2w2m==0 & status_encuesta!=1


********************************************************************************

qui gen esample=1	
qui gen nvals=.


*Regression 2w2m
eststo : reg attrition_2w2m i.main_treatment, robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui test 2.main_treatment=3.main_treatment
estadd scalar test_23=`r(p)'
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
	
	
	*************************
	esttab using "$directorio/Tables/reg_results/reg_attrition.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "obs_per_gr Obs per group" "days_per_gr Days per group" "test_23 T2=T3") replace 
		
