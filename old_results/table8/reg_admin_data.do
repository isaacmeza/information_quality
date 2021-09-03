*Merge with Sues
use "$directorio\DB\survey_data_2m.dta", clear
qui merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3) nogen
duplicates drop plaintiff_name, force
merge 1:m plaintiff_name using "$directorio\_aux\expedientes_long_LME.dta", keep (1 3)  keepusing(demanda)
rename demanda demanda_exact

merge m:m id_actor using "$directorio\_aux\fuzzy_sue_match.dta", keep (1 3) nogen 


*Match up to admin data date
qui su survey_date
*drop if inrange(survey_date,`r(min)',date("31/06/2019","DMY"))!=1  & (demanda_exact!=1)
replace demanda_exact = 0 if inrange(survey_date,`r(min)',date("31/06/2019","DMY"))!=1  & (demanda_exact!=1)
replace demanda_fuzzy = 0 if inrange(survey_date,`r(min)',date("31/06/2019","DMY"))!=1  & (demanda_exact!=1)

duplicates drop id_actor, force

*Sue based on admin data
gen sue_admin=(demanda_exact==1)
gen sue_fuzzy=(demanda_fuzzy==1)
*Tabulate admin -survey
tab sue_admin entablo_demanda, m matcell(admin_survey) 
putexcel set "$directorio\Tables_Draft\reg_admin.xlsx", sheet("tab_admin_survey") modify
qui putexcel I6=matrix(admin_survey) 
tab sue_fuzzy entablo_demanda, m matcell(admin_fuzzy)
qui putexcel I6=matrix(admin_fuzzy) 


*Balance table 
local balance_all_vlist mujer prob_ganar na_prob prob_mayor na_prob_mayor ///
	cantidad_ganar na_cant  cant_mayor na_cant_mayor sueldo  salario_diario ///
	antiguedad retail outsourcing  mon_tue 
	
gen comparison_admin_survey=.
replace comparison_admin_survey=1 if entablo_demanda==1 & sue_admin==1
replace comparison_admin_survey=2 if entablo_demanda==0 & sue_admin==1
replace comparison_admin_survey=3 if entablo_demanda==1 & sue_admin==0
replace comparison_admin_survey=4 if entablo_demanda==0 & sue_admin==0
	
	
orth_out `balance_all_vlist' , ///
				by(comparison_admin_survey)  vce(robust)   bdec(3)  count
qui putexcel K5=matrix(r(matrix)) 
				
*-------------------------------------------------------------------------------
cap drop esample nvals
qui gen esample=1	
qui gen nvals=.

local depvar sue_admin sue_fuzzy entablo_demanda
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
	estadd local BVC "NO"
	if "`var'"=="sue_admin" {
		estadd local Source="Admin exact"
		}
	else {
		if "`var'"=="sue_fuzzy" {
			estadd local Source="Admin fuzzy"
			}
		else {
			estadd local Source="Survey"
			}
		}	
	forvalues i=1/3 {
		qui count if main_treatment==`i' & e(sample)
		local obs_`i'=r(N)
		}	
	estadd local obs_per_gr="`obs_1'/`obs_2'/`obs_3'"
	qui su `var' if main_treatment==1
	estadd scalar DepVarMean=r(mean)
	
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
	if "`var'"=="sue_admin" {
		estadd local Source="Admin exact"
		}
	else {
		if "`var'"=="sue_fuzzy" {
			estadd local Source="Admin fuzzy"
			}
		else {
			estadd local Source="Survey"
			}
		}
	forvalues i=1/3 {
		qui count if main_treatment==`i' & e(sample)
		local obs_`i'=r(N)
		}	
	estadd local obs_per_gr="`obs_1'/`obs_2'/`obs_3'"
	qui su `var' if main_treatment==1
	estadd scalar DepVarMean=r(mean)
	
	qui replace esample=(e(sample)==1)
	bysort esample main_treatment fecha_alta : replace nvals = _n == 1  
	forvalues i=1/3 {
		qui count if nvals==1 & main_treatment==`i' & esample==1
		local obs_`i'=r(N)
		}
	estadd local days_per_gr="`obs_1'/`obs_2'/`obs_3'"
	}

esttab using "$directorio\Tables_Draft\reg_results/reg_admin_main_arms.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) scalars("Erre R-squared" "BVC BVC" "Source Source" "obs_per_gr Obs per group" "days_per_gr Days per group" "DepVarMean DepVarMean" "test_23 T2=T3") replace 
	
	sum main_treatment
		/*
	
*******************************
* 			   A-B			  *
*******************************
eststo clear	
	
foreach var in `depvar'	{
	
	eststo: reg `var' i.group, robust cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	estadd local BVC="NO"
	qui su `var' if group==1
	estadd scalar DepVarMean=r(mean)
	if "`var'"=="sue_admin" {
		estadd local Source="Admin exact"
		}
	else {
		if "`var'"=="sue_fuzzy" {
			estadd local Source="Admin fuzzy"
			}
		else {
			estadd local Source="Survey"
			}
		}
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
	
	*---------------------------------------------------------------
	
	eststo: reg `var' i.group `controls', robust cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	estadd local BVC="YES"
	qui su `var' if group==1
	estadd scalar DepVarMean=r(mean)
	if "`var'"=="sue_admin" {
		estadd local Source="Admin exact"
		}
	else {
		if "`var'"=="sue_fuzzy" {
			estadd local Source="Admin fuzzy"
			}
		else {
			estadd local Source="Survey"
			}
		}
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
	esttab using "$directorio\Tables_Draft\reg_results/reg_admin_main_arms_ab.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "BVC BVC" "Source Source" "obs_per_gr Obs per group" "days_per_gr Days per group" "DepVarMean DepVarMean" ) replace 
		
