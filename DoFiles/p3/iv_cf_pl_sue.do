*Instrumental - Control function regression of sue/settlement against public lawyer.


********************************************************************************
*									2W & 2M							  		   *
********************************************************************************
use "$directorio\DB\survey_data_2w.dta", clear
*2w variables
rename conflicto_arreglado conflicto_arreglado_2w
rename entablo_demanda entablo_demanda_2w

merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(3) nogen force
*2m variables
rename conflicto_arreglado conflicto_arreglado_2m
rename entablo_demanda entablo_demanda_2m

merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3) 

*Imputation for suing when settlement occurs
*replace entablo_demanda_2m=0 if conflicto_arreglado_2w==1

********************************************************************************

local depvar conflicto_arreglado_2w conflicto_arreglado_2m entablo_demanda_2m
local controls mujer antiguedad salario_diario


*******************************
* 			REGRESSIONS		  *
*******************************

eststo clear

foreach var in `depvar' {

	*Second stage (IV)
	eststo: ivregress 2sls `var' `controls' ///
			 (i.cond_hablo_con_publico = i.group), robust cluster(fecha_alta)	 
	estadd local BVC="YES"
	estadd local Source="2w-2m"
	
	*First stage
	eststo: reg cond_hablo_con_publico i.group `controls' ///
		if e(sample), robust cluster(fecha_alta)		 
	estadd local BVC="YES"
	estadd local Source="2w-2m"	

	*************************************************

	*Probit (FS)
	eststo: probit cond_hablo_con_publico i.group `controls' if !missing(`var') ///
		, robust cluster(fecha_alta)
	estadd local BVC="YES"
	estadd local Source="2w-2m"

	cap drop xb
	predict xb, xb
	*Generalized residuals
	cap drop gen_resid_pr
	gen gen_resid_pr = cond(cond_hablo_con_publico == 1, normalden(xb)/normal(xb), -normalden(xb)/(1-normal(xb)))	

	*Second stage (CF)
	* - Interaction
	eststo: reg `var' i.cond_hablo_con_publico `controls' gen_resid_pr, ///
		vce(bootstrap, reps(1000)) cluster(fecha_alta)
	estadd local BVC="YES"
	estadd local Source="2w-2m"

	}

		*************************
		esttab using "$directorio/Tables/reg_results/iv_cf_pl_sue.csv", se r2 star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
		 scalars("BVC BVC" "Source Source") replace

*Contingency table
tab hablo_con_abogado conflicto_arreglado_2m, row matcell(talked_sett)
qui putexcel G5=matrix(talked_sett) using "$directorio\Tables\talked_sett.xlsx", sheet("talked_sett") modify
	
		*************************

		
eststo clear

foreach var in `depvar' {

	*Second stage (IV)
	eststo: ivregress 2sls `var' `controls' ///
			 (i.ha_hablado_con_abogado_publico = i.group), robust cluster(fecha_alta)	 
	estadd local BVC="YES"
	estadd local Source="2w-2m"
	
	*First stage
	eststo: reg ha_hablado_con_abogado_publico i.group `controls' ///
		if e(sample), robust cluster(fecha_alta)		 
	estadd local BVC="YES"
	estadd local Source="2w-2m"	

	*************************************************

	*Probit (FS)
	eststo: probit ha_hablado_con_abogado_publico i.group `controls' if !missing(`var') ///
		, robust cluster(fecha_alta)
	estadd local BVC="YES"
	estadd local Source="2w-2m"

	cap drop xb
	predict xb, xb
	*Generalized residuals
	cap drop gen_resid_pr
	gen gen_resid_pr = cond(ha_hablado_con_abogado_publico == 1, normalden(xb)/normal(xb), -normalden(xb)/(1-normal(xb)))	

	*Second stage (CF)
	* - Interaction
	eststo: reg `var' i.ha_hablado_con_abogado_publico `controls' gen_resid_pr, ///
		vce(bootstrap, reps(1000)) cluster(fecha_alta)
	estadd local BVC="YES"
	estadd local Source="2w-2m"

	}

		*************************
		esttab using "$directorio/Tables/reg_results/iv_cf_plnocond_sue.csv", se r2 star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
		 scalars("BVC BVC" "Source Source") replace
		 
