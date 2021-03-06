*Impact of the update in expectations in the settlement rate

*						2m settlement vs. Inmediate exp - Baseline             *
********************************************************************************

		 
use "$directorio/DB/treatment_data.dta", clear
merge 1:1 id_actor using "$directorio/DB/survey_data_2m.dta", keep(3)


*****************************      PROBABILITY      ****************************

*Independent dummy variable
gen bajo_inm_prob_d=prob_ganar_treat<prob_ganar if  !missing(prob_ganar) & !missing(prob_ganar_treat)
replace bajo_inm_prob_d=0 if main_treatment==1 & !missing(prob_ganar)

gen bajo_inm_prob=prob_ganar_treat-prob_ganar if !missing(prob_ganar) & !missing(prob_ganar_treat)
replace bajo_inm_prob=0 if main_treatment==1 & !missing(prob_ganar)

gen bajo_inm_quant_d=cantidad_ganar_treat<cantidad_ganar if  !missing(cantidad_ganar) & !missing(cantidad_ganar_treat)
replace bajo_inm_quant_d=0 if main_treatment==1 & !missing(cantidad_ganar)

gen bajo_inm_quant=cantidad_ganar_treat-cantidad_ganar if !missing(cantidad_ganar) & !missing(cantidad_ganar_treat)
replace bajo_inm_quant=0 if main_treatment==1 & !missing(cantidad_ganar)

gen bajo_inm_quant=cantidad_ganar_treat-cantidad_ganar if !missing(cantidad_ganar) & !missing(cantidad_ganar_treat)
replace bajo_inm_quant=0 if main_treatment==1 & !missing(cantidad_ganar)

qui gen esample=1	
qui gen nvals=.

local depvar bajo_inm_prob_d  bajo_inm_prob bajo_inm_quant_d bajo_inm_quant
local controls mujer antiguedad salario_diario



*****************************
*       REGRESSIONS         *
*****************************

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
	esttab using "$directorio/Tables/te_updating.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "BVC BVC" "Source Source" "obs_per_gr Obs per group" "days_per_gr Days per group" "test_23 T2=T3") replace 
	
	
