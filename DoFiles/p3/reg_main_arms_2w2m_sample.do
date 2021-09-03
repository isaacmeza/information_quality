use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3) nogen

foreach var of varlist conflicto_arreglado coyote {
	rename `var' `var'_2w
	}
keep id_actor conflicto_arreglado_2w coyote_2w hablo_con_abogado cond_hablo_con_publico main_treatment ///
	fecha_alta mujer antiguedad salario_diario
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(3)


qui gen esample=1	
qui gen nvals=.

local depvar conflicto_arreglado_2w conflicto_arreglado hablo_con_abogado cond_hablo_con_publico coyote_2w coyote entablo_demanda demando_con_abogado_publico
local controls mujer antiguedad salario_diario


*******************************
* 			MAIN ARMS		  *
*******************************
eststo clear	
	
foreach var in `depvar'	{
	
	eststo: reg `var' i.main_treatment, robust cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	qui test 2.main_treatment=3.main_treatment
	estadd scalar test_23=`r(p)'	
	estadd local BVC="NO"
	estadd local Source="2w-2m"
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
	estadd local Source="2w-2m"
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
	esttab using "$directorio/Tables/reg_results/reg_main_arms_2w2m_sample.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "BVC BVC" "Source Source" "obs_per_gr Obs per group" "days_per_gr Days per group" "test_23 T2=T3") replace 
	
	
