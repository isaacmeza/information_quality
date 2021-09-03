import delimited "$directorio/_aux/pred_scores1.csv", varnames(1) clear 

tempfile datos_prep
save `datos_prep'

use "$directorio2\DB\survey_data_2m.dta", clear
qui merge 1:1 id_actor using "$directorio2\DB\treatment_data.dta", keep(2 3) nogen
duplicates drop plaintiff_name, force
*tostring colonia, replace
merge 1:m plaintiff_name using "$directorio\DB\check1000.dta", force keep(3)
*replace personalidad_c_clv="." if personalidad_c_clv=="NA"
*destring personalidad_c_clv, replace
*keep derecho_propio_c_clv giro_defendant_c_clv num_demandados_totales incrementos_sal_c_clv ////
*contrato_c_clv lugar_trabajo_c_clv  horario_inicio_jornada_c_clv ////
*horario_fin_jornada_c_clv especifican_dias_c_clv salario_int_clv periodo_sal_int_clv ////
*fecha_despido_c_clv lugar_despido_c_clv motivo_despido_c_clv cargo_despide_clv ////
*presentado_tiempo_forma_c_clv personalidad_c_clv firma_trabajador_c_clv 

append using `datos_prep', gen(source)

*categoria_c_clv
*"categoria_c_clv derecho_propio_c_clv"
local include "derecho_propio_c_clv"

********************************************************************************
*Dependent variable
global dep_var promedio_global_ponderado
*Independent variable (not factor variables)
global ind_var `include' derecho_propio_c_clv giro_defendant_c_clv num_demandados_totales num_demandados_completos ////
num_abogados_proemio num_abogados_proemio_completos incrementos_sal_c_clv contrato_c_clv ////
lugar_trabajo_c_clv horario_inicio_jornada_c_clv horario_fin_jornada_c_clv especifican_dias_c_clv ////
salario_int_clv periodo_sal_int_clv fecha_despido_c_clv lugar_despido_c_clv motivo_despido_c_clv ////
cargo_despide_clv presentado_tiempo_forma_c_clv personalidad_c_clv firma_trabajador_c_clv ///
domicilio_actor domicilio_demandado sal_caidos_c_clv nulidad_clv indem_const_c_clv reinstalacion_c_clv dias20_c_clv ///
antiguedad_c_clv vacaciones_c_clv prima_vac_c_clv aguinaldo_c_clv imss_clv ptu_clv periodo_salario_c_clv  nombre_despide_c_clv horas_extras

*sal_devengados hora_despido

*Train fraction
global trainf=0.80
*Directory for plots
*global plot "$directorio/Figuras/Boost"
	

********************************************************************************

*Drop missing values
foreach var of varlist $ind_var {
	drop if missing(`var')
	}
	
	
replace source = . if source<1
*Randomize order of data set
gen u=uniform()
sort source u
forvalues i=1/2 {
	replace u=uniform()
	sort source u
	}
qui count if source==1
global trainn= round($trainf *`r(N)'+1)	


********************************************************************************

*append using "$directorio\check1000.dta", force

********************************************************
*           Create interaction terms                   *
********************************************************
********************************************************************************
*Regression

capture drop reg_pred 
	
cvlasso $dep_var $ind_var in 1/$trainn ///
	, lopt seed(823) 
*lopt = the lambda that minimizes MSPE.
local lambda_opt=e(lopt)
*Variable selection
lasso2 $dep_var $ind_var in 1/$trainn ///
	, lambda( `lambda_opt'  ) 
predict lasso_pred	
*Variable selection
local vrs=e(selected)
local regressors  `regressors' `vrs'	

global predictors `vrs'

*reg $dep_var `regressors'  in 1/$trainn, r 
reg $dep_var `regressors'  in 1/$trainn, r 
predict reg_pred 

drop if source == 1
save $directorio\DB\preds_c_todo_lasso.dta, replace
/*
keep junta exp anio id_actor reg_pred
save $directorio\DB\800ish.dta, replace */

forvalues i=1/3{
	gen t`i'=[main_treatment==`i']
}

local j=0
forvalues i=1/3{
	foreach var in $predictors{
		local j=`j'+1
		reg `var' t`i'
		local R`i'`j'= e(r2)
	}
}

local j=0
forvalues i=1/3{
	foreach var in $predictors{
		local j=`j'+1
		di `R`i'`j''
	}
}


bysort id_actor: gen unico = _n
keep if unico==1
/*
keep id_actor reg_pred

joinby id_actor using "$directorio\DB\MatchedCasefiles3.dta"

bysort id_actor: gen unico = _n
keep if unico==1
*/

qui gen esample=1  
qui gen nvals=.
local controls mujer antiguedad salario_diario

replace reg_pred=10 if reg_pred>10

eststo clear 
local j=0
local action replace
foreach var in $predictors{
	reg `var' t1 t2 t3 , nocons
	test t1=t2=t3
	outreg2 using "PredictorsAndTreatment.xls", `action' addstat(F test, r(F), p-value, r(p))
	if `j'==0{
		local action "append"
		local j=`j'+1
	}
}

****************************************************************************



local controls mujer antiguedad salario_diario

eststo clear 

	eststo: reg reg_pred i.main_treatment, robust cluster(fecha_alta)  
	estadd scalar Erre=e(r2)
	qui test 2.main_treatment=3.main_treatment
	estadd scalar test_23 = `r(p)'	
	estadd local BVC "YES"
	estadd local Source "2m"
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
	qui sum reg_pred if entablo_demanda==1, meanonly
	estadd local prom = r(mean)
	
	eststo: reg reg_pred i.main_treatment `controls', robust cluster(fecha_alta)  
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
	qui sum reg_pred if entablo_demanda==1, meanonly
	 estadd local prom = r(mean)


	eststo: reg reg_pred i.main_treatment if entablo_demanda ==1, robust cluster(fecha_alta)  
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
	qui sum reg_pred if entablo_demanda==1, meanonly
	 estadd local prom = r(mean)
	
	eststo: reg reg_pred i.main_treatment `controls' if entablo_demanda == 1, robust cluster(fecha_alta)  
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
	qui sum reg_pred if entablo_demanda==1, meanonly
	 estadd local prom = r(mean)
	
	eststo: reg reg_pred i.main_treatment if entablo_demanda ==1 & demando_con_abogado_publico == 0, robust cluster(fecha_alta) 
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
	qui sum reg_pred if entablo_demanda==1 & demando_con_abogado_publico == 0, meanonly
	 estadd local prom = r(mean)
	
	eststo: reg reg_pred i.main_treatment `controls' if entablo_demanda == 1 & demando_con_abogado_publico == 0, robust cluster(fecha_alta) 
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
	qui sum reg_pred if entablo_demanda==1 & demando_con_abogado_publico == 0, meanonly
	 estadd local prom = r(mean)

esttab using "$directorio/Tables/TE_quality_postlassoTry`include'.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) scalars("Erre R-squared"  "test_23 test_23" "BVC BVC" "Source Source" "obs_per_gr Obs per group" "days_per_gr Days per group" "prom Dep. Variable Mean") replace 


