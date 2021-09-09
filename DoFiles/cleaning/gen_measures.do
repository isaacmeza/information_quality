/*
*Generation of variables of interest (from dataset in "PANEL form")
Author :  Isaac Meza
*/


*OUTPUTS
	*Positive recovering
gen perc_pos_rec = liq_total_pos	
	*Positive recovering in court-ruling
gen perc_pos_rec_cr = liq_total_pos if modo_termino==3	
	*Percentage of settlements
gen perc_settlement = (modo_termino==1) if !missing(modo_termino)	
	*Percentage of court ruling
gen perc_cr = (modo_termino==3) if !missing(modo_termino)	
	*Net recovery non-positive	
gen perc_non_pos_npv = (npv<=0)
	*NPV
gen ratio_npv = npv	
	*Ratio win/asked
gen ratio_win_asked = npv/(c_total + c_sal_caidos)
gen ratio_winpos_asked = npv/(c_total + c_sal_caidos) if npv>0
gen ratio_win_asked_cr = npv/(c_total + c_sal_caidos) if modo_termino==3
gen ratio_winpos_asked_cr = npv/(c_total + c_sal_caidos) if npv>0 & modo_termino==3
	*Ratio win/entitlementlaw
gen ratio_win_minley = npv/min_ley
gen ratio_win_minley_cr = npv/min_ley if modo_termino==3	
	*What procu asks
gen c_procu = min_ley + c_sal_caidos	
	*Ratio win/c_procu
gen ratio_win_cprocu = npv/c_procu
	*Duration
gen duration = (fechater - fechadem)/30	

*INPUTS
	*Inflation of wage (exaggerating measure)
gen ratio_wage = salario_diario/salario_base_diario
replace ratio_wage = 1 if missing(ratio_wage)
	*Exaggeration relative to procu
gen ratio_rel_procu = (c_total + c_sal_caidos - c_procu)/c_procu	
	*Exaggeration relative to entitlement
gen ratio_rel_ent = (c_total - min_ley)/min_ley	
	*Exaggeration according to SCIAN
gen ratio_dw_scian = salario_diario/dw_scian	
	*Avg daily_wage by SCIAN codes in procu files
preserve
collapse (mean) dw_giro_procu = salario_diario if office_emp_law=="PROCURADURIA" , by(giro_empresa)
tempfile temp
save `temp'
restore
merge m:1 giro_empresa using `temp', nogen
gen ratio_dw_giro_procu = salario_diario/dw_giro_procu

	*Benefits
foreach var of varlist 	indem sal_caidos prima_antig prima_vac hextra prima_dom ///
	desc_sem desc_ob sarimssinf utilidades nulidad codem reinst {
	gen perc_`var' = `var'
	}
