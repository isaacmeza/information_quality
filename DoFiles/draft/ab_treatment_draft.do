/*
Treatment effect regressions on main outcome variables
Author :  Isaac Meza
*/



********************************************************************************
*									2W								  		   *
********************************************************************************
use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)

********************************************************************************

qui gen esample = 1	
qui gen nvals = .

*******************************
* 			MAIN ARMS		  *
*******************************
eststo clear	
	
foreach var in conflicto_arreglado  hablo_con_abogado {
	
	eststo : reg `var' i.ab_treatment ${controls}, robust cluster(fecha_alta)
	estadd local BVC  "YES" 
	estadd local Source  "2w" 
	forvalues i = 1/2 {
		qui count if ab_treatment==`i' & e(sample)
		local obs_`i' = r(N)
		}	
	estadd local obs_per_gr  "`obs_1'/`obs_2'" 
	
	qui replace esample = (e(sample)==1)
	bysort esample ab_treatment fecha_alta : replace nvals = _n == 1  
	forvalues i = 1/2 {
		qui count if nvals==1 & ab_treatment==`i' & esample==1
		local obs_`i' = r(N)
		}
	estadd local days_per_gr "`obs_1'/`obs_2'" 
	
}
	
	

********************************************************************************
*									2M								  		   *
********************************************************************************
use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)

********************************************************************************

qui gen esample=1	
qui gen nvals=.

*******************************
* 			MAIN ARMS		  *
*******************************

	
foreach var in conflicto_arreglado entablo_demanda {
	
	eststo : reg `var' i.ab_treatment ${controls}, robust cluster(fecha_alta)
	estadd local BVC  "YES" 
	estadd local Source  "2m" 
	forvalues i = 1/2 {
		qui count if ab_treatment==`i' & e(sample)
		local obs_`i' = r(N)
		}	
	estadd local obs_per_gr  "`obs_1'/`obs_2'" 
	
	qui replace esample = (e(sample)==1)
	bysort esample ab_treatment fecha_alta : replace nvals = _n == 1  
	forvalues i = 1/2 {
		qui count if nvals==1 & ab_treatment==`i' & esample==1
		local obs_`i' = r(N)
		}
	estadd local days_per_gr "`obs_1'/`obs_2'" 
	
	}
	
	
	*************************
esttab using "$directorio/Tables/reg_results/te_a_b.csv", se r2 ${star} b(a2) label ///
	scalars("Source Source" "BVC BVC" "obs_per_gr Obs per group" "days_per_gr Days per group") replace 
	
	
	
