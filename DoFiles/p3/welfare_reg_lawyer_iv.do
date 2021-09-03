use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(3)


local welfare_vars nivel_de_felicidad ultimos_3_meses_ha_dejado_de_pag ultimos_3_meses_le_ha_faltado_di comprado_casa_o_terreno comprado_electrodomestico trabaja_actualmente mejor_trabajo busca_trabajo probabilidad_de_que_encuentre_tr tiempo_arreglar_asunto_imputed
local controls mujer antiguedad salario_diario


*******************************
* 			REGRESSIONS		  *
*******************************

eststo clear
foreach var of varlist `welfare_vars' {
	
	*OLS
	eststo: reg  `var' `controls' i.demando_con_abogado_publico  ///
		, r cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	qui su `var' if e(sample)
	estadd scalar DepVarMean=r(mean)
	estadd local BVC="YES"
	estadd local Source="2m"	
	
	
	*Second stage (IV)
	eststo: ivregress 2sls `var' `controls' (i.demando_con_abogado_publico = i.group) ///
		, r cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	qui su `var' if e(sample)
	estadd scalar DepVarMean=r(mean)
	estadd local BVC="YES"
	estadd local Source="2m"	

	*Probit (FS)
	probit demando_con_abogado_publico i.group `controls' if !missing(`var') ///
		, robust cluster(fecha_alta)
	estadd scalar Erre=e(r2)	
	estadd local BVC="YES"
	estadd local Source="2m"

	cap drop xb
	predict xb, xb
	*Generalized residuals
	cap drop gen_resid_pr
	gen gen_resid_pr = cond(demando_con_abogado_publico == 1, normalden(xb)/normal(xb), -normalden(xb)/(1-normal(xb)))	

	
	*Second stage (CF)
	eststo: reg `var' i.demando_con_abogado_publico `controls' gen_resid_pr, ///
		vce(bootstrap, reps(1000)) cluster(fecha_alta)
	estadd scalar Erre=e(r2)		
	qui su `var' if e(sample)
	estadd scalar DepVarMean=r(mean)	
	estadd local BVC="YES"
	estadd local Source="2m"	
	}
	
	*************************
	esttab using "$directorio/Tables/reg_results/welfare_reg_lawyer_iv.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "DepVarMean DepVarMean" "BVC BVC" "Source Source" ) replace 
	
	
