*Measures of updating against type of lawyer

local controls mujer antiguedad salario_diario
eststo clear

********************************************************************************
************************************2M******************************************
use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3)
qui su date
keep if inrange(date,`r(min)',date(c(current_date) ,"DMY")-70)

*Lawyers
gen lawyer=.
replace lawyer=demando_con_abogado_publico 
replace lawyer=2 if demando_con_abogado_privado==1 & coyote==0
replace lawyer=3 if demando_con_abogado_privado==1 & coyote==1
drop if lawyer==0
********************************************************************************
*Varlist
replace cantidad_ganar_survey=cantidad_ganar_survey/1000
replace cantidad_ganar=cantidad_ganar/1000
gen diff_amt=cantidad_ganar_survey-cantidad_ganar
gen diff_prob= prob_ganar_survey-prob_ganar


*Trimming
foreach var of varlist cantidad_ganar_survey  diff_amt  {
	xtile perc_`var'=`var', nq(100)
	replace `var'=. if perc_`var'>=95
	}
	xtile perc_update_comp_survey=update_comp_survey, nq(100)	
	replace update_comp_survey=. if inrange(perc_update_comp_survey, 3, 97)!=1
	
*Amount
foreach var of varlist 	cantidad_ganar cantidad_ganar_survey diff_amt update_comp_survey {
	eststo: reg `var' i.lawyer `controls', r cluster(fecha_alta)
	qui test 2.lawyer=3.lawyer
	estadd local test_23=round(`r(p)',.01)
	qui su `var' if e(sample)
	estadd local DepVarMean=round(`r(mean)',.01)
	estadd local BVC="YES"
	estadd local Source="2m"
	}
	
*Probability	
foreach var of varlist 	prob_ganar prob_ganar_survey diff_prob update_prob_survey {
	eststo: reg `var' i.lawyer `controls', r cluster(fecha_alta)
	qui test 2.lawyer=3.lawyer
	estadd local test_23=round(`r(p)',.01)
	qui su `var' if e(sample)
	estadd local DepVarMean=round(`r(mean)',.01)
	estadd local BVC="YES"
	estadd local Source="2m"
	}
	
	
********************************************************************************
************************************2W******************************************
use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3)
qui su date
keep if inrange(date,date("1/08/2017" ,"DMY"),date(c(current_date) ,"DMY")-21)
			
*Lawyers
gen lawyer=.
replace lawyer=cond_hablo_con_publico 
replace lawyer=2 if cond_hablo_con_privado==1 & coyote==0
replace lawyer=3 if cond_hablo_con_privado==1 & coyote==1
drop if lawyer==0
********************************************************************************
*Varlist
replace cantidad_ganar_survey=cantidad_ganar_survey/1000
replace cantidad_ganar=cantidad_ganar/1000
gen diff_amt=cantidad_ganar_survey-cantidad_ganar
gen diff_prob= prob_ganar_survey-prob_ganar


*Trimming
foreach var of varlist cantidad_ganar_survey  diff_amt  {
	xtile perc_`var'=`var', nq(100)
	replace `var'=. if perc_`var'>=95
	}
	xtile perc_update_comp_survey=update_comp_survey, nq(100)	
	replace update_comp_survey=. if inrange(perc_update_comp_survey, 3, 97)!=1
	
	
*Amount
foreach var of varlist 	 cantidad_ganar_survey diff_amt update_comp_survey {
	eststo: reg `var' i.lawyer `controls', r cluster(fecha_alta)
	qui test 2.lawyer=3.lawyer
	estadd local test_23=round(`r(p)',.01)
	qui su `var' if e(sample)
	estadd local DepVarMean=round(`r(mean)',.01)
	estadd local BVC="YES"
	estadd local Source="2w"
	}
	
*Probability	
foreach var of varlist 	 prob_ganar_survey diff_prob update_prob_survey {
	eststo: reg `var' i.lawyer `controls', r cluster(fecha_alta)
	qui test 2.lawyer=3.lawyer
	estadd local test_23=round(`r(p)',.01)
	qui su `var' if e(sample)
	estadd local DepVarMean=round(`r(mean)',.01)
	estadd local BVC="YES"
	estadd local Source="2w"
	}

	
	

		*************************
		esttab using "$directorio/Tables/reg_results/update_type_law.csv", se r2 star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
		 scalars("test_23 For=Inf" "DepVarMean DepVarMean" "BVC BVC" "Source Source") replace
		 
	
