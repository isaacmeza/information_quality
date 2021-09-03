clear all
set more off

********************************************************************************

* a plugin has to be explicitly loaded (unlike an ado file)
* "capture" means that if it's loaded already this line won't give an error

*Directory for .\boost64.dll 
cd "$directorio"
*cd D:\WKDir-Stata
capture program drop boost_plugin
program boost_plugin, plugin using("$directorio\boost64.dll")

set more off
set seed 12345678



********************************************************************************
*Judges Opinion
insheet using "$directorio\Raw\Captura Express Completo.csv", clear
keep junta exp ao totaldictaminador
destring totaldictaminador, replace force
rename ao anio
tempfile temp_dictamen
save `temp_dictamen'

*

import delimited "$directorio\Raw\base_abogados.csv", varnames(1) clear 


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
replace nombre_archivo_abogado = subinstr(nombre_archivo_abogado, " ", "",.)
replace nombre_archivo_abogado = "6_" + ///
	substr(nombre_archivo_abogado,3,length(nombre_archivo_abogado)) ///
		if strpos(nombre_archivo_abogado,"0_")!=0 & ///
		strpos(nombre,"Sergio Cuadra Flores")!=0
replace nombre_archivo_abogado = "8_" + ///
	substr(nombre_archivo_abogado,3,length(nombre_archivo_abogado)) ///
		if strpos(nombre_archivo_abogado,"0_")!=0 & ///
		strpos(nombre,"Miguel Angel")!=0		
		

merge 1:1 nombre_archivo_abogado using "$directorio\Raw\relacion_base_calidad.dta", keep(3) nogen
merge m:1 junta expediente ao using "$directorio\Raw\checklist_500.dta", keep(3) nogen

rename expediente exp
rename ao anio

merge m:1 junta exp anio using "$directorio\DB\lawyer_dataset_predicc.dta", keep(3) nogen
merge m:m junta exp anio using `temp_dictamen', keep(1 3) nogen
duplicates drop nombre_archivo_abogado, force

*Generation of variables of interest
do "$directorio\DoFiles\gen_measures.do"

collapse (mean) preg1calif preg2calif preg3calif preg4calif preg5calif califglobal ///
	perc_pos_rec ratio_win_asked ratio_winpos_asked ///
	derecho_propio_c_clv giro_defendant_c_clv num_demandados_totales ///
	incrementos_sal_c_clv contrato_c_clv lugar_trabajo_c_clv  ///
	horario_inicio_jornada_c_clv horario_fin_jornada_c_clv ///
	especifican_dias_c_clv salario_int_clv periodo_sal_int_clv ///
	fecha_despido_c_clv lugar_despido_c_clv motivo_despido_c_clv ///
	cargo_despide_clv presentado_tiempo_forma_c_clv personalidad_c_clv ///
	firma_trabajador_c_clv, by(junta exp anio)

keep preg1calif preg2calif preg3calif preg4calif preg5calif califglobal ///
	perc_pos_rec ratio_win_asked ratio_winpos_asked ///
	derecho_propio_c_clv giro_defendant_c_clv num_demandados_totales ///
	incrementos_sal_c_clv contrato_c_clv lugar_trabajo_c_clv  ///
	horario_inicio_jornada_c_clv horario_fin_jornada_c_clv ///
	especifican_dias_c_clv salario_int_clv periodo_sal_int_clv ///
	fecha_despido_c_clv lugar_despido_c_clv motivo_despido_c_clv ///
	cargo_despide_clv presentado_tiempo_forma_c_clv personalidad_c_clv ///
	firma_trabajador_c_clv
	
export delimited "$directorio/_aux/pred_scores.csv", replace nolabel
	
********************************************************************************
*RUN R


import delimited "$directorio/_aux/pred_scores1.csv", varnames(1) clear 

********************************************************************************
*Dependent variable
global dep_var califglobal
*Independent variable (not factor variables)
global ind_var derecho_propio_c_clv giro_defendant_c_clv num_demandados_totales ///
	incrementos_sal_c_clv contrato_c_clv lugar_trabajo_c_clv  ///
	horario_inicio_jornada_c_clv horario_fin_jornada_c_clv ///
	especifican_dias_c_clv salario_int_clv periodo_sal_int_clv ///
	fecha_despido_c_clv lugar_despido_c_clv motivo_despido_c_clv ///
	cargo_despide_clv presentado_tiempo_forma_c_clv personalidad_c_clv ///
	firma_trabajador_c_clv


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
	
reg $dep_var  `regressors'  in 1/$trainn, r 
predict reg_pred 

********************************************************************************

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
	boost $dep_var $ind_var , dist(normal) train($trainf) maxiter(`tempiter') ///
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
boost $dep_var $ind_var , dist(normal) train($trainf) maxiter(`miter') bag(0.5) ///
	interaction(`opt_int') shrink(`shrink') pred("boost_pred") influence 

matrix influence = e(influence)

********************************************************************************




********************************************************************************
/*
foreach var of varlist *_pred {
	replace `var' = round(`var')
	}
*/

*Difference in l1 of probabilities (predicted values)
qui gen error_boost=abs(boost_pred-	$dep_var) 
	su error_boost if _n>$trainn
qui gen error_reg=abs(reg_pred-	$dep_var) 
	su error_reg if _n>$trainn
qui gen error_rf=abs(rf_pred-	$dep_var) 
	su error_rf if _n>$trainn
qui gen lasso_rf=abs(lasso_pred-	$dep_var) 
	su lasso_rf if _n>$trainn


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
restore


********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************


* compute Rsquared on all data - reg
qui {
gen regress_eps=$dep_var-reg_pred 
gen regress_eps2= regress_eps*regress_eps 
gen regress_ss=sum(regress_eps2)
local mse=regress_ss[_N] / (_N)
sum $dep_var if _n>$trainn
local var=r(Var)
local regress_r2= (`var'-`mse')/`var'
}
di " "
di "Regression : mse=" `mse' " var=" `var'  " regress r2="  `regress_r2'



* compute Rsquared on all data - boosting
qui {
gen boost_eps=$dep_var-boost_pred 
gen boost_eps2= boost_eps*boost_eps   
gen boost_ss=sum(boost_eps2)
local mse=boost_ss[_N] / (_N)
sum $dep_var if _n>$trainn
local var=r(Var)
local boost_r2= (`var'-`mse')/`var'
}
di " "
di "Boosting:  mse=" `mse' " var=" `var'  " boost r2="  `boost_r2'


* compute Rsquared on all data - rf
qui {
gen rf_eps=$dep_var-rf_pred 
gen rf_eps2= rf_eps*rf_eps 
gen rf_ss=sum(rf_eps2)
local mse=rf_ss[_N] / (_N)
sum $dep_var if _n>$trainn
local var=r(Var)
local rf_r2= (`var'-`mse')/`var'
}
di " "
di "Random Forest:  mse=" `mse' " var=" `var'  " rf r2="  `rf_r2'

* compute Rsquared on all data - lasso
qui {
gen lasso_eps=$dep_var-lasso_pred 
gen lasso_eps2= lasso_eps*lasso_eps 
gen lasso_ss=sum(lasso_eps2)
local mse=lasso_ss[_N] / (_N)
sum $dep_var if _n>$trainn
local var=r(Var)
local lasso_r2= (`var'-`mse')/`var'
}
di " "
di "Lasso:  mse=" `mse' " var=" `var'  " lasso r2="  `lasso_r2'


********************************************************************************
* Calibration plot
* scatter plot of predicted versus actual values of $dep_var
* a straight line would indicate a perfect fit
local trainm1=$trainn +1
qui count
gen straight=.
replace straight=$dep_var
twoway  (lowess $dep_var  reg_pred  in 1/$trainn, bwidth(0.2) clpattern(dot)) ///
		(lowess $dep_var boost_pred in 1/$trainn , bwidth(0.2) clpattern(dash) color(blue)) ///
		(lowess $dep_var lasso_pred in 1/$trainn , bwidth(0.2) clpattern(dash) color(red)) ///
		(lfit straight $dep_var)  , xtitle("Fitted Values") ///
		legend(label(1 "Regression") label(2 "Boosting") label(3 "Lasso") ///
		label(4 "Fitted Values=Actual Values") )  graphregion(color(white))
graph export "$plot\boost_calibration_insample.png", replace	width(1500)		

local trainm1=$trainn +1
qui count		
twoway  (lowess $dep_var  reg_pred  in `trainm1'/`r(N)', bwidth(0.2) clpattern(dot)) ///
        (lowess $dep_var boost_pred in `trainm1'/`r(N)' , bwidth(0.2) clpattern(dash) color(blue)) ///
		(lowess $dep_var lasso_pred in `trainm1'/`r(N)' , bwidth(0.2) clpattern(dash) color(red)) ///
		(lfit straight $dep_var)  , xtitle("Fitted Values") ///
		legend(label(1 "Regression") label(2 "Boosting")  label(3 "Lasso") ///
		label(4 "Fitted Values=Actual Values") )  graphregion(color(white))
graph export "$plot\boost_calibration_outsample.png", replace	width(1500)
********************************************************************************



********************************************************************************
*Influence plot
svmat influence
gen id=_n
replace id=. if missing(influence)


graph bar (mean) influence, over(id) ytitle(Percentage Influence) ///
	scheme(s2mono) graphregion(color(white))
graph export "$plot\boost_influence.png", replace	width(1500)

********************************************************************************


