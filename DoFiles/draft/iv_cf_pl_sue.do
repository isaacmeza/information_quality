
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	May. 02, 2022
* Last date of modification:   
* Modifications:		
* Files used:     
* Files created:  

* Purpose: Instrumental - Control function regression of sue/settlement against public lawyer.

*******************************************************************************/
*/

use "$directorio\DB\iniciales_dem.dta" , clear
merge m:1 junta exp anio using  "$directorio\DB\seguimiento_dem.dta", nogen
keep junta exp anio id_actor modo_termino modo_termino_ofirec modo_termino_exp fecha_termino_ofirec cantidad_ofirec cantidad_inegi cantidad_otorgada convenio_pagado_completo cantidad_pagada sueldo_estadistico periodicidad_sueldo_estadistic 
*Keep unique id_actor
duplicates drop
drop if missing(id_actor)
*CAUTION (review)
duplicates drop junta exp anio id_actor, force
duplicates tag id_actor, gen(tg)
drop if tg>0


********************************************************************************
*									2W & 2M							  		   *
********************************************************************************
merge 1:1 id_actor using "$directorio\DB\survey_data_2w.dta", keep(2 3) nogen 
*2w variables
rename conflicto_arreglado conflicto_arreglado_2w
rename entablo_demanda entablo_demanda_2w

merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(3) nogen force
*2m variables
rename conflicto_arreglado conflicto_arreglado_2m
rename entablo_demanda entablo_demanda_2m

merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3) nogen

********************************************************************************

*Update settlements with follow-ups

gen conflicto_arreglado = conflicto_arreglado_2m
replace conflicto_arreglado = 1 if modo_termino==2 & conflicto_arreglado==0
replace conflicto_arreglado = 1 if modo_termino_ofirec==3 & conflicto_arreglado==0
replace conflicto_arreglado = 1 if modo_termino_exp==3 & conflicto_arreglado==0 


local depvar conflicto_arreglado_2w conflicto_arreglado_2m conflicto_arreglado entablo_demanda_2m
local controls mujer antiguedad salario_diario

*******************************
* 			REGRESSIONS		  *
*******************************

eststo clear

foreach var in `depvar' {

	*Second stage (IV)
	eststo: ivregress 2sls `var' `controls' ///
			 (i.cond_hablo_con_publico = i.ab_treatment), robust cluster(fecha_alta)	 
	estadd local BVC="YES"
	estadd local Source="2w-2m"
	
	*First stage
	eststo: reg cond_hablo_con_publico i.ab_treatment `controls' ///
		if e(sample), robust cluster(fecha_alta)		 
	estadd local BVC="YES"
	estadd local Source="2w-2m"	

	*************************************************

	*Probit (FS)
	eststo: probit cond_hablo_con_publico i.ab_treatment `controls' if !missing(`var') ///
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

		*************************

		
eststo clear

foreach var in `depvar' {

	*Second stage (IV)
	eststo: ivregress 2sls `var' `controls' ///
			 (i.ha_hablado_con_abogado_publico = i.ab_treatment), robust cluster(fecha_alta)	 
	estadd local BVC="YES"
	estadd local Source="2w-2m"
	
	*First stage
	eststo: reg ha_hablado_con_abogado_publico i.ab_treatment `controls' ///
		if e(sample), robust cluster(fecha_alta)		 
	estadd local BVC="YES"
	estadd local Source="2w-2m"	

	*************************************************

	*Probit (FS)
	eststo: probit ha_hablado_con_abogado_publico i.ab_treatment `controls' if !missing(`var') ///
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
		 
