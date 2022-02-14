
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	February. 14, 2021
* Last date of modification:   
* Modifications:		
* Files used:     
		- treatment_data.dta
		- survey_data_2w.dta
		- survey_data_2m.dta
* Files created:  

* Purpose: The calculator + letter treatment thus produced a similar shiftin the composition of lawyers filing cases,  away from informal lawyers and public lawyersand toward formal private lawyers

*******************************************************************************/
*/


********************************************************************************
*									2W								  		   *
********************************************************************************
use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)

********************************************************************************

gen private_formal = ha_hablado_con_abogado_privado
replace private_formal = 0 if coyote==1 & !missing(ha_hablado_con_abogado_privado)
gen private_informal = 1 - private_formal


qui gen esample = 1	
qui gen nvals = .

*******************************
* 			MAIN ARMS		  *
*******************************
eststo clear	
	
foreach var in ha_hablado_con_abogado_publico private_formal private_informal   {
	
	eststo : reg `var' i.main_treatment ${controls}, robust cluster(fecha_alta)
	qui test 2.main_treatment = 3.main_treatment
	estadd scalar test_23 = `r(p)'	
	estadd local BVC  "YES" 
	estadd local Source  "2w"
	su `var' if e(sample) & main_treatment==1
	estadd local ContrMean  `r(mean)' 	
	forvalues i = 1/3 {
		qui count if main_treatment==`i' & e(sample)
		local obs_`i' = r(N)
		}	
	estadd local obs_per_gr  "`obs_1'/`obs_2'/`obs_3'" 
	
	qui replace esample = (e(sample)==1)
	bysort esample main_treatment fecha_alta : replace nvals = _n == 1  
	forvalues i = 1/3 {
		qui count if nvals==1 & main_treatment==`i' & esample==1
		local obs_`i' = r(N)
		}
	estadd local days_per_gr "`obs_1'/`obs_2'/`obs_3'" 
	
}
	

********************************************************************************
*									2M								  		   *
********************************************************************************
use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)

********************************************************************************

replace demando_con_abogado_privado = 0 if entablo_demanda==0
replace demando_con_abogado_publico = 0 if entablo_demanda==0

gen private_formal = demando_con_abogado_privado
replace private_formal = 0 if coyote==1 & !missing(demando_con_abogado_privado)
gen private_informal = 1 - private_formal


qui gen esample=1	
qui gen nvals=.

*******************************
* 			MAIN ARMS		  *
*******************************

	
foreach var in demando_con_abogado_publico private_formal private_informal {
	
	eststo : reg `var' i.main_treatment ${controls}, robust cluster(fecha_alta)
	qui test 2.main_treatment = 3.main_treatment
	estadd scalar test_23 = `r(p)'	
	estadd local BVC  "YES" 
	estadd local Source  "2m" 
	su `var' if e(sample) & main_treatment==1
	estadd local ContrMean  `r(mean)' 
	forvalues i = 1/3 {
		qui count if main_treatment==`i' & e(sample)
		local obs_`i' = r(N)
		}	
	estadd local obs_per_gr  "`obs_1'/`obs_2'/`obs_3'" 
	
	qui replace esample = (e(sample)==1)
	bysort esample main_treatment fecha_alta : replace nvals = _n == 1  
	forvalues i = 1/3 {
		qui count if nvals==1 & main_treatment==`i' & esample==1
		local obs_`i' = r(N)
		}
	estadd local days_per_gr "`obs_1'/`obs_2'/`obs_3'" 
	
	}
	
	
	*************************
esttab using "$directorio/Tables/reg_results/effects_on_suing.csv", se r2 ${star} b(a2) label ///
	scalars("Source Source" "BVC BVC" "obs_per_gr Obs per group" "days_per_gr Days per group" "ContrMean Control Mean" "test_23 T2 = T3") replace 
	
	
		