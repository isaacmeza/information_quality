clear all
set more off

********************************************************************************

* a plugin has to be explicitly loaded (unlike an ado file)
* "capture" means that if it's loaded already this line won't give an error

*Directory for .\boost64.dll 
*global directorio F:\Calidad
*cd "$directorio"
*cd D:\WKDir-Stata
capture program drop boost_plugin
program boost_plugin, plugin using("$directorio\boost64.dll")

set more off
set seed 12345678



********************************************************************************
*Judges Opinion
insheet using "$directorio\Raw\calif\Captura Express Completo.csv", clear
keep junta exp AÑO totaldictaminador
destring totaldictaminador, replace force
rename AÑO anio
tempfile temp_dictamen
save `temp_dictamen'

*

import delimited "$directorio\Raw\calif\base_abogados.csv", varnames(1) clear 


*Cleaning
foreach var of varlist * {
	replace `var' = subinstr(`var', `"""', "",.)
	}

	*Cleaning of time
gen fecha_fin = date(substr(fin,1,11),"YMD")
format fecha_fin %td

	*Duration of evaluation

gen start = substr(inicio,1,11)+" " + substr(inicio,13,8)	
gen start_time=clock(start, "YMDhms")
gen end = substr(fin,1,11)+" " + substr(fin,13,8)	
gen end_time=clock(end, "YMDhms")
format start_time end_time %tc
gen duration_eval = minutes(end_time-start_time)

	*Scores & Prediction
foreach var of varlist preg1calif preg2calif preg3calif preg4calif preg5calif califglobal ///
				predicciona prediccionb prediccionc predicciond prediccione prediccionmonto1 prediccionmonto2 {
	destring `var', replace force
	}	
encode prediccionseleccion1, gen(prediccion_seleccion1)
encode prediccionseleccion2, gen(prediccion_seleccion2)
drop prediccionseleccion*	

foreach var of varlist predicciona prediccionb prediccionc predicciond prediccione {
	replace  `var'=0 if missing(`var')
	}
	
rename numexpediente nombre_archivo_abogado
rename ïnombre nombre
replace nombre_archivo_abogado = subinstr(nombre_archivo_abogado, " ", "",.)
replace nombre_archivo_abogado = "6_" + ///
	substr(nombre_archivo_abogado,3,length(nombre_archivo_abogado)) ///
		if strpos(nombre_archivo_abogado,"0_")!=0 & ///
		strpos(nombre,"Sergio Cuadra Flores")!=0
replace nombre_archivo_abogado = "8_" + ///
	substr(nombre_archivo_abogado,3,length(nombre_archivo_abogado)) ///
		if strpos(nombre_archivo_abogado,"0_")!=0 & ///
		strpos(nombre,"Miguel Angel")!=0		
		
merge 1:1 nombre_archivo_abogado using "$directorio\Raw\calif\relacion_base_calidad.dta", keep(3) nogen
merge m:1 junta expediente ao using "$directorio\Raw\iniciales_dem\checklist_500.dta", keep(3) nogen

rename expediente exp
rename ao anio

destring salario_diario, replace
destring  salario_base_diario, replace
merge m:1 junta exp anio using "$directorio\DB\lawyer_dataset_predicc.dta", keep(3) nogen
merge m:m junta exp anio using `temp_dictamen', keep(1 3) nogen
duplicates drop nombre_archivo_abogado, force

*Generation of variables of interest
do "$directorio\DoFiles\gen_measures.do"
cap drop id_exp
do "$directorio\DoFiles\create_weights.do"


*keep preg1calif preg2calif preg3calif preg4calif preg5calif califglobal ///
*	perc_pos_rec ratio_win_asked ratio_winpos_asked ///
*	derecho_propio_c_clv giro_defendant_c_clv num_demandados_totales ///
*	incrementos_sal_c_clv contrato_c_clv lugar_trabajo_c_clv  ///
*	horario_inicio_jornada_c_clv horario_fin_jornada_c_clv ///
*	especifican_dias_c_clv salario_int_clv periodo_sal_int_clv ///
*	fecha_despido_c_clv lugar_despido_c_clv motivo_despido_c_clv ///
*	cargo_despide_clv presentado_tiempo_forma_c_clv personalidad_c_clv ///
*	firma_trabajador_c_clv calif_ponderada
*

*keep derecho_propio_c_clv giro_defendant_c_clv num_demandados_totales incrementos_sal_c_clv ////
*contrato_c_clv lugar_trabajo_c_clv  horario_inicio_jornada_c_clv ////
*horario_fin_jornada_c_clv especifican_dias_c_clv salario_int_clv periodo_sal_int_clv ////
*fecha_despido_c_clv lugar_despido_c_clv motivo_despido_c_clv cargo_despide_clv ////
*presentado_tiempo_forma_c_clv personalidad_c_clv firma_trabajador_c_clv promedio_global_ponderado

keep junta exp anio derecho_propio_c_clv giro_defendant_c_clv num_demandados_totales num_demandados_completos ////
num_abogados_proemio num_abogados_proemio_completos incrementos_sal_c_clv contrato_c_clv ////
lugar_trabajo_c_clv horario_inicio_jornada_c_clv horario_fin_jornada_c_clv especifican_dias_c_clv ////
salario_int_clv periodo_sal_int_clv fecha_despido_c_clv lugar_despido_c_clv motivo_despido_c_clv ////
cargo_despide_clv presentado_tiempo_forma_c_clv personalidad_c_clv firma_trabajador_c_clv promedio_global_ponderado ///
domicilio_actor domicilio_demandado categoria_c_clv sal_caidos_c_clv nulidad_clv indem_const_c_clv reinstalacion_c_clv sal_devengados_c_clv dias20_c_clv ///
antiguedad_c_clv vacaciones_c_clv prima_vac_c_clv aguinaldo_c_clv imss_clv ptu_clv periodo_salario_c_clv hora_despido_clv  nombre_despide_c_clv horas_extras
	
duplicates drop	

export delimited "$directorio/_aux/pred_scores.csv", replace nolabel
	
********************************************************************************
*RUN R


import delimited "$directorio/_aux/pred_scores1.csv", varnames(1) clear 

********************************************************************************
*Dependent variable
*categoria_c_clv was removed
global dep_var promedio_global_ponderado
*Independent variable (not factor variables)
global ind_var derecho_propio_c_clv giro_defendant_c_clv num_demandados_totales num_demandados_completos ////
num_abogados_proemio num_abogados_proemio_completos incrementos_sal_c_clv contrato_c_clv ////
lugar_trabajo_c_clv horario_inicio_jornada_c_clv horario_fin_jornada_c_clv especifican_dias_c_clv ////
salario_int_clv periodo_sal_int_clv fecha_despido_c_clv lugar_despido_c_clv motivo_despido_c_clv ////
cargo_despide_clv presentado_tiempo_forma_c_clv personalidad_c_clv firma_trabajador_c_clv ///
domicilio_actor domicilio_demandado sal_caidos_c_clv nulidad_clv indem_const_c_clv reinstalacion_c_clv sal_devengados_c_clv dias20_c_clv ///
antiguedad_c_clv vacaciones_c_clv prima_vac_c_clv aguinaldo_c_clv imss_clv ptu_clv periodo_salario_c_clv hora_despido_clv  nombre_despide_c_clv horas_extras

*Train fraction
global trainf=0.80
*Directory for plots
global plot "$directorio/Figuras/Boost"
	

********************************************************************************

*Drop missing values
foreach var of varlist $ind_var {
	drop if missing(`var')
	}
	
*Randomize order of data set
gen u=uniform()
sort u
forvalues i=1/2 {
	replace u=uniform()
	sort u
	}
qui count
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
	
*reg $dep_var `regressors'  in 1/$trainn, r 
reg $dep_var `regressors'  in 1/$trainn, r 
predict reg_pred 

********************************************************************************
* Train the boosting for number of interactions
********************************************************************************

gen Rsquared=.
gen bestiter=.
gen maxiter=.
gen myinter=.
local i=0
local maxiter=750

local tempiter=`maxiter'
foreach inter of numlist 1/6 8 10 15 20 {
	local i=`i'+1
    replace myinter= `inter' in `i'
	boost $dep_var $ind_var, dist(normal) train($trainf) maxiter(`tempiter') ///
		bag(0.5) interaction(`inter') shrink(0.1) 
	local maxiter=e(bestiter) 
	replace maxiter=`tempiter' in `i'
	replace bestiter=e(bestiter) in `i' 
	replace Rsquared=e(test_R2) in `i'
	* as the number of interactions increase the best number of iterations will decrease
	* to be safe I am allowing an extra 20% of iterations and in case maxiter equals bestiter we double the number of iter
	* when the number of interactions is large this can save a lot of time
	if ( maxiter[`i']-bestiter[`i']<60) {
		local tempiter= round(maxiter[`i']*2)+10
		}
	else {
		local tempiter=round( e(bestiter) * 1.2 )+10
		}
	}

rename myinter interaction
twoway connected Rsquared inter, xtitle("Number of interactions") ///
	ytitle("R-squared") scheme(s2mono) graphregion(color(white)) 
graph export "$plot\boost_Rsquared.png", replace	width(1500)


********************************************************************************


********************************************************************************
*Boosting 

qui egen maxrsq=max(Rsquared)
qui gen iden=_n if Rsquared==maxrsq
qui su iden

local opt_int=`r(mean)'		/*Optimum interaction according to previous process*/

if ( maxiter[`r(mean)']-bestiter[`r(mean)']<60) {
	local miter= round(maxiter[`r(mean)']*2.2+10)
	}
else {
	local miter=bestiter[`r(mean)']+120
	}
							/*Maximum number of iterations-if bestiter is closed to maxiter, 
							increase the number of max iter as the maximum likelihood 
							iteration may be larger*/
							
local shrink=0.05       	/*Lower shrinkage values usually improve the test R2 but 
							they increase the running time dramatically. 
							Shrinkage can be thought of as a step size*/						
						
capture drop boost_pred 
boost $dep_var $ind_var, dist(normal) train($trainf) maxiter(`miter') bag(0.5) ///
	interaction(`opt_int') shrink(`shrink') pred("boost_pred") influence 

matrix influence = e(influence)

********************************************************************************
*PCA reg
pca $ind_var in 1/$trainn
predict comp1 comp2 comp3 comp4 comp5 comp6 comp7 comp8 comp9 comp10
reg $dep_var comp1 comp2 comp3 comp4 comp5 comp6 comp7 comp8 comp9 comp10 in 1/$trainn
predict pca_reg_pred


********************************************************************************

*Difference in l1 of probabilities (predicted values)
qui gen error_boost=abs(boost_pred-	$dep_var) 
	su error_boost if _n>$trainn
qui gen error_reg=abs(reg_pred-	$dep_var) 
	su error_reg if _n>$trainn
qui gen error_rf=abs(rf_pred-	$dep_var) 
	su error_rf if _n>$trainn
qui gen lasso_rf=abs(lasso_pred-	$dep_var) 
	su lasso_rf if _n>$trainn
qui gen error_pcareg = abs(pca_reg_pred - $dep_var)
	su error_pcareg

*Correlation
corr $dep_var boost_pred reg_pred rf_pred lasso_pred if _n>$trainn

********************************************************************************


********************************************************************************
*Compare the R^2 of boosted and linear models on test data

preserve
* compute Rsquared on test data - reg
qui {
gen regress_eps=$dep_var-reg_pred 
gen regress_eps2= regress_eps*regress_eps 
replace regress_eps2=0 if _n<=$trainn  
gen regress_ss=sum(regress_eps2)
local mse=regress_ss[_N] / (_N-$trainn)
sum $dep_var if _n>$trainn
local var=r(Var)
local regress_r2= (`var'-`mse')/`var'
}
di " "
di "Regression : mse=" `mse' " var=" `var'  " regress r2="  `regress_r2'



* compute Rsquared on test data - boosting
qui {
gen boost_eps=$dep_var-boost_pred 
gen boost_eps2= boost_eps*boost_eps 
replace boost_eps2=0 if _n<=$trainn  
gen boost_ss=sum(boost_eps2)
local mse=boost_ss[_N] / (_N-$trainn)
sum $dep_var if _n>$trainn
local var=r(Var)
local boost_r2= (`var'-`mse')/`var'
}
di " "
di "Boosting:  mse=" `mse' " var=" `var'  " boost r2="  `boost_r2'


* compute Rsquared on test data - rf
qui {
gen rf_eps=$dep_var-rf_pred 
gen rf_eps2= rf_eps*rf_eps 
replace rf_eps2=0 if _n<=$trainn  
gen rf_ss=sum(rf_eps2)
local mse=rf_ss[_N] / (_N-$trainn)
sum $dep_var if _n>$trainn
local var=r(Var)
local rf_r2= (`var'-`mse')/`var'
}
di " "
di "Random Forest:  mse=" `mse' " var=" `var'  " rf r2="  `rf_r2'

* compute Rsquared on test data - lasso
qui {
gen lasso_eps=$dep_var-lasso_pred 
gen lasso_eps2= lasso_eps*lasso_eps 
replace lasso_eps2=0 if _n<=$trainn  
gen lasso_ss=sum(lasso_eps2)
local mse=lasso_ss[_N] / (_N-$trainn)
sum $dep_var if _n>$trainn
local var=r(Var)
local lasso_r2= (`var'-`mse')/`var'
}
di " "
di "Lasso:  mse=" `mse' " var=" `var'  " lasso r2="  `lasso_r2'

* compute Rsquared on test data - pca

qui {
gen pca_eps=$dep_var-pca_reg_pred 
gen pca_eps2= pca_eps*pca_eps 
replace pca_eps2=0 if _n<=$trainn  
gen pca_ss=sum(pca_eps2)
local mse=pca_ss[_N] / (_N-$trainn)
sum $dep_var if _n>$trainn
local var=r(Var)
local lasso_r2= (`var'-`mse')/`var'
}
di " "
di "PCA-reg:  mse=" `mse' " var=" `var'  " lasso r2="  `lasso_r2'

restore

********************************************************************************
* 							 Vamos a generar los pesos	   					   *
********************************************************************************

matrix stats = J(4,5,.)

local i = 1 
local j = 1
foreach var in reg_pred lasso_pred  rf_pred boost_pred pca_reg_pred{
corr $dep_var `var'
local correlacion = r(rho)
matrix stats[`i',`j'] = `correlacion'
local ++i
gen `var'_e=$dep_var-`var' 
gen `var'_e2= `var'_e*`var'_e 
gen `var'_ss=sum(`var'_e2) 
local mse=`var'_ss[_N] / (_N) 
local sqrt_mse = sqrt(`mse') 
matrix stats[`i',`j'] = `sqrt_mse' 
local ++i
sum $dep_var
local varianza = r(Var)
local r2 = (`varianza'-`mse')/`varianza'
matrix stats[`i',`j'] = `r2'
local ++i
sum `var' 
local obs = r(N)
matrix stats[`i',`j'] = `obs'
local i = 1
local ++j
} 


 

putexcel set "$directorio\Tables\fit_table.xlsx", sheet(table1) modify
putexcel C3 = ("post-LASSO")
putexcel D3 = ("LASSO")
putexcel E3 = ("Random Forest")
putexcel F3 = ("Boosting")
putexcel G3 = ("PCA Regression")
putexcel B4 = ("Corr")
putexcel B5 = ("MSE") 
putexcel B6 = ("R2")
putexcel B7 = ("N")
putexcel K4 = matrix(stats)

drop reg_pred_e reg_pred_e2 reg_pred_ss lasso_pred_e lasso_pred_e2 lasso_pred_ss rf_pred_e rf_pred_e2 rf_pred_ss boost_pred_e boost_pred_e2 boost_pred_ss pca_reg_pred_e pca_reg_pred_e2 pca_reg_pred_ss
