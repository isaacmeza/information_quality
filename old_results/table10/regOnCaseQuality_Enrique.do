***********************************************
* Compute regressions of treatment on quality *
***********************************************

use $directorio\DB\preds_c_todo_lasso.dta, clear


qui gen esample=1	
qui gen nvals=.
local controls mujer antiguedad salario_diario

eststo clear 

	eststo: reg reg_pred i.main_treatment, robust cluster(fecha_alta)  
	qui sum reg_pred , meanonly
	local mean=r(mean)
	qui test 2.main_treatment=3.main_treatment	
	local F=r(F)
	local p=r(p)
	forvalues i=1/3 {
		qui count if main_treatment==`i' & e(sample)
		local obs_`i'=r(N)
		}	
	qui replace esample=(e(sample)==1)
	bysort esample main_treatment fecha_alta : replace nvals = _n == 1  
	forvalues i=1/3 {
		qui count if nvals==1 & main_treatment==`i' & esample==1
		local days_`i'=r(N)
		}
	outreg2 using "$directorio/Tables/TE_Quality_PostLasso_Enrique.xls", 	addstat(F-stat T2=T3, `F' , p-value, `p', Dep. var mean, `mean') addtext("BVC", "No", "Source", "2m","Obs. per group", "`obs_1'/`obs_2'/`obs_3'", "Days per group", "`days_1'/`days_2'/`days_3'" ) replace
	
	
	
	eststo: reg reg_pred i.main_treatment `controls', robust cluster(fecha_alta)  
	qui sum reg_pred , meanonly
	local mean=r(mean)
	qui test 2.main_treatment=3.main_treatment	
	local F=r(F)
	local p=r(p)
	forvalues i=1/3 {
		qui count if main_treatment==`i' & e(sample)
		local obs_`i'=r(N)
		}	
	qui replace esample=(e(sample)==1)
	bysort esample main_treatment fecha_alta : replace nvals = _n == 1  
	forvalues i=1/3 {
		qui count if nvals==1 & main_treatment==`i' & esample==1
		local days_`i'=r(N)
		}
	outreg2 using "$directorio/Tables/TE_Quality_PostLasso_Enrique.xls", 	addstat(F-stat T2=T3, `F' , p-value, `p', Dep. var mean, `mean') addtext("BVC", "Yes", "Source", "2m","Obs. per group", "`obs_1'/`obs_2'/`obs_3'", "Days per group", "`days_1'/`days_2'/`days_3'" ) append


	eststo: reg reg_pred i.main_treatment if entablo_demanda ==1, robust cluster(fecha_alta)  
	qui sum reg_pred if entablo_demanda==1 , meanonly
	local mean=r(mean)
	qui test 2.main_treatment=3.main_treatment	
	local F=r(F)
	local p=r(p)
	forvalues i=1/3 {
		qui count if main_treatment==`i' & e(sample)
		local obs_`i'=r(N)
		}	
	qui replace esample=(e(sample)==1)
	bysort esample main_treatment fecha_alta : replace nvals = _n == 1  
	forvalues i=1/3 {
		qui count if nvals==1 & main_treatment==`i' & esample==1
		local days_`i'=r(N)
		}
	outreg2 using "$directorio/Tables/TE_Quality_PostLasso_Enrique.xls", 	addstat(F-stat T2=T3, `F' , p-value, `p', Dep. var mean, `mean') addtext("BVC", "No", "Source", "2m","Obs. per group", "`obs_1'/`obs_2'/`obs_3'", "Days per group", "`days_1'/`days_2'/`days_3'" ) append
	
	eststo: reg reg_pred i.main_treatment `controls' if entablo_demanda == 1, robust cluster(fecha_alta)  
	qui sum reg_pred if entablo_demanda==1, meanonly
	local mean=r(mean)
	qui test 2.main_treatment=3.main_treatment	
	local F=r(F)
	local p=r(p)
	forvalues i=1/3 {
		qui count if main_treatment==`i' & e(sample)
		local obs_`i'=r(N)
		}	
	qui replace esample=(e(sample)==1)
	bysort esample main_treatment fecha_alta : replace nvals = _n == 1  
	forvalues i=1/3 {
		qui count if nvals==1 & main_treatment==`i' & esample==1
		local days_`i'=r(N)
		}
	outreg2 using "$directorio/Tables/TE_Quality_PostLasso_Enrique.xls", 	addstat(F-stat T2=T3, `F' , p-value, `p', Dep. var mean, `mean') addtext("BVC", "Yes", "Source", "2m","Obs. per group", "`obs_1'/`obs_2'/`obs_3'", "Days per group", "`days_1'/`days_2'/`days_3'" ) append
	
	eststo: reg reg_pred i.main_treatment if entablo_demanda ==1 & demando_con_abogado_publico == 0, robust cluster(fecha_alta) 
	qui sum reg_pred if entablo_demanda==1 & demando_con_abogado_publico == 0, meanonly
	local mean=r(mean)
	qui test 2.main_treatment=3.main_treatment	
	local F=r(F)
	local p=r(p)
	forvalues i=1/3 {
		qui count if main_treatment==`i' & e(sample)
		local obs_`i'=r(N)
		}	
	qui replace esample=(e(sample)==1)
	bysort esample main_treatment fecha_alta : replace nvals = _n == 1  
	forvalues i=1/3 {
		qui count if nvals==1 & main_treatment==`i' & esample==1
		local days_`i'=r(N)
		}
	outreg2 using "$directorio/Tables/TE_Quality_PostLasso_Enrique.xls", 	addstat(F-stat T2=T3, `F' , p-value, `p', Dep. var mean, `mean') addtext("BVC", "No", "Source", "2m","Obs. per group", "`obs_1'/`obs_2'/`obs_3'", "Days per group", "`days_1'/`days_2'/`days_3'" ) append
	
	eststo: reg reg_pred i.main_treatment `controls' if entablo_demanda == 1 & demando_con_abogado_publico == 0, robust cluster(fecha_alta) 
	qui sum reg_pred  if entablo_demanda==1 & demando_con_abogado_publico == 0, meanonly
	local mean=r(mean)
	qui test 2.main_treatment=3.main_treatment	
	local F=r(F)
	local p=r(p)
	forvalues i=1/3 {
		qui count if main_treatment==`i' & e(sample)
		local obs_`i'=r(N)
		}	
	qui replace esample=(e(sample)==1)
	bysort esample main_treatment fecha_alta : replace nvals = _n == 1  
	forvalues i=1/3 {
		qui count if nvals==1 & main_treatment==`i' & esample==1
		local days_`i'=r(N)
		}
	outreg2 using "$directorio/Tables/TE_Quality_PostLasso_Enrique.xls", 	addstat(F-stat T2=T3, `F' , p-value, `p', Dep. var mean, `mean') addtext("BVC", "Yes", "Source", "2m","Obs. per group", "`obs_1'/`obs_2'/`obs_3'", "Days per group", "`days_1'/`days_2'/`days_3'" ) append
