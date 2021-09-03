*CALCULATOR PREDICTIONS

*Judges Opinion
insheet using "$directorio\Raw\Captura Express Completo.csv", clear
keep junta exp ao totaldictaminador
destring totaldictaminador, replace force
rename ao anio
tempfile temp_dictamen
duplicates drop junta exp anio totaldictaminador, force
collapse (mean) total, by(junta exp anio)
save `temp_dictamen'

use "$directorio\DB\lawyer_dataset.dta", clear 
duplicates drop junta exp anio, force
merge 1:1 junta exp anio using `temp_dictamen', keep( 1 3 ) nogen


*End MODE
gen end_mode=modo_termino

label define end_mode 1 "Settlement" ///
						2 "Drop" ///
						3 "Court ruling zero" ///
						4 "Expiry" ///
						5 "Court ruling positive"
						
replace end_mode = 5 if end_mode==3 &  liq_total_pos==1
label values end_mode end_mode

*Cleaning
for var c_antiguedad c_indem-c_desc_ob c_recsueldo : ///
	capture replace X=0 if X<0 & X~=.
	
*Wizorise all at 99th percentile
for var c_* : capture egen X99 = pctile(X) , p(99)
for var c_* : ///
	capture replace X=X99 if X>X99 & X~=.
drop *99

*Calculator prediction

levelsof end_mode, local(levels) 
foreach l of local levels {
	cap drop end_mode_`l'
	gen  end_mode_`l'=(end_mode==`l')
	}

local regressors = " "

forvalues l=1/5 {
	*Cross-validation LASSO
	cvlasso end_mode_`l' gen horas_sem salario_diario abogado_pub c_antiguedad trabajador_base indem sal_caidos prima_antig prima_vac hextra prima_dom desc_sem desc_ob sarimssinf utilidades nulidad codem reinst c_indem c_prima_antig c_rec20 c_ag c_vac c_hextra c_prima_vac c_prima_dom c_desc_sem c_desc_ob c_utilidades c_recsueldo c_total  min_ley dw_scian giro_empresa i.junta ///
		, lopt seed(823) 
	*lopt = the lambda that minimizes MSPE.
	local lambda_opt=e(lopt)
	*Variable selection
	lasso2 end_mode_`l' gen horas_sem salario_diario abogado_pub c_antiguedad trabajador_base indem sal_caidos prima_antig prima_vac hextra prima_dom desc_sem desc_ob sarimssinf utilidades nulidad codem reinst c_indem c_prima_antig c_rec20 c_ag c_vac c_hextra c_prima_vac c_prima_dom c_desc_sem c_desc_ob c_utilidades c_recsueldo c_total  min_ley dw_scian giro_empresa i.junta ///
		, lambda( `lambda_opt'  ) 
	*Variable selection
	local vrs=e(selected)
	local regressors  `regressors' `vrs'
	di "`regressors'"	
	}

	
forvalues l=1/5 {
	*LOGIT MODEL 
	logit end_mode_`l'  `regressors' 
	*PREDICTED PROBABILITIES
	predict pr_em_`l'
	}

egen nor=rowtotal(pr_em_*)

forvalues l=1/5 {
	*Normalization
	replace pr_em_`l'=pr_em_`l'/nor
	}

	
*Prediction of winning court ruling according to judge
gen winning_judge=(!missing(totaldictaminador)) if modo_termino==3

*Cross-validation LASSO
	cvlasso winning_judge gen horas_sem salario_diario abogado_pub c_antiguedad trabajador_base indem sal_caidos prima_antig prima_vac hextra prima_dom desc_sem desc_ob sarimssinf utilidades nulidad codem reinst c_indem c_prima_antig c_rec20 c_ag c_vac c_hextra c_prima_vac c_prima_dom c_desc_sem c_desc_ob c_utilidades c_recsueldo c_total  min_ley dw_scian giro_empresa i.junta ///
		, lopt seed(823) 
	*lopt = the lambda that minimizes MSPE.
	local lambda_opt=e(lopt)
	*Variable selection
	lasso2 winning_judge gen horas_sem salario_diario abogado_pub c_antiguedad trabajador_base indem sal_caidos prima_antig prima_vac hextra prima_dom desc_sem desc_ob sarimssinf utilidades nulidad codem reinst c_indem c_prima_antig c_rec20 c_ag c_vac c_hextra c_prima_vac c_prima_dom c_desc_sem c_desc_ob c_utilidades c_recsueldo c_total  min_ley dw_scian giro_empresa i.junta ///
		, lambda( `lambda_opt'  ) 
	*Variable selection
	local regressors=e(selected)
	di "`regressors'"	
	
	*LOGIT MODEL 
	logit winning_judge  `regressors' 
	*PREDICTED PROBABILITIES
	predict pr_winning_judge
	
*Prediction of recovering positive amount

*Cross-validation LASSO
	cvlasso liq_total_pos gen horas_sem salario_diario abogado_pub c_antiguedad trabajador_base indem sal_caidos prima_antig prima_vac hextra prima_dom desc_sem desc_ob sarimssinf utilidades nulidad codem reinst c_indem c_prima_antig c_rec20 c_ag c_vac c_hextra c_prima_vac c_prima_dom c_desc_sem c_desc_ob c_utilidades c_recsueldo c_total  min_ley dw_scian giro_empresa i.junta ///
		, lopt seed(823) 
	*lopt = the lambda that minimizes MSPE.
	local lambda_opt=e(lopt)
	*Variable selection
	lasso2 liq_total_pos gen horas_sem salario_diario abogado_pub c_antiguedad trabajador_base indem sal_caidos prima_antig prima_vac hextra prima_dom desc_sem desc_ob sarimssinf utilidades nulidad codem reinst c_indem c_prima_antig c_rec20 c_ag c_vac c_hextra c_prima_vac c_prima_dom c_desc_sem c_desc_ob c_utilidades c_recsueldo c_total  min_ley dw_scian giro_empresa i.junta ///
		, lambda( `lambda_opt'  ) 
	*Variable selection
	local regressors=e(selected)
	di "`regressors'"	
	
	*LOGIT MODEL 
	logit liq_total_pos  `regressors' 
	*PREDICTED PROBABILITIES
	predict pr_pos_rec	
	
	
*Prediction of court ruling - settlement amount
xtile perc_liq=liq_total_tope, nq(100)
	
*Cross-validation LASSO
	cvlasso liq_total_tope gen horas_sem salario_diario abogado_pub c_antiguedad trabajador_base indem sal_caidos prima_antig prima_vac hextra prima_dom desc_sem desc_ob sarimssinf utilidades nulidad codem reinst c_indem c_prima_antig c_rec20 c_ag c_vac c_hextra c_prima_vac c_prima_dom c_desc_sem c_desc_ob c_utilidades c_recsueldo c_total  min_ley dw_scian giro_empresa i.junta ///
		, lopt seed(823) 
	*lopt = the lambda that minimizes MSPE.
	local lambda_opt=e(lopt)
	*Variable selection (LASSO)
	lasso2 liq_total gen horas_sem salario_diario abogado_pub c_antiguedad trabajador_base indem sal_caidos prima_antig prima_vac hextra prima_dom desc_sem desc_ob sarimssinf utilidades nulidad codem reinst c_indem c_prima_antig c_rec20 c_ag c_vac c_hextra c_prima_vac c_prima_dom c_desc_sem c_desc_ob c_utilidades c_recsueldo c_total  min_ley dw_scian giro_empresa i.junta ///
		if perc_liq>=0 & perc_liq<=95, lambda( `lambda_opt'  ) 
	predict pr_liq_total_lasso	
	*Variable selection
	local regressors=e(selected)
	di "`regressors'"	
	

	*OLS MODEL 
	reg liq_total_tope  `regressors' if inrange(perc_liq,0,95)
	*PREDICTED PROBABILITIES
	predict pr_liq_total_ols
	
	*KRLS MODEL 
	krls liq_total_tope  `regressors' if inrange(perc_liq,0,95)
	*PREDICTED PROBABILITIES
	predict pr_liq_total_krls	
	
	
	
save "$directorio\DB\lawyer_dataset_predicc.dta", replace
********************************************************************************
********************************************************************************
********************************************************************************
