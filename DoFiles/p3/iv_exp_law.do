use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)

gen esample=.
*******************************
* 			REGRESSIONS		  *
*******************************
eststo clear
	
	
*Second stage
eststo: ivregress  2sls cantidad_ganar_survey  cantidad_ganar ///
         mujer antiguedad salario_diario ///
		 (i.demando_con_abogado_publico = i.group), cluster(fecha_alta)
replace esample=(e(sample))		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"

*Simple regression	
eststo: reg cantidad_ganar_survey i.demando_con_abogado_publico cantidad_ganar ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta) 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"

*Reduced form
eststo: reg cantidad_ganar_survey i.group cantidad_ganar ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta)		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"
		 
*First stage
eststo: reg demando_con_abogado_publico i.group cantidad_ganar ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta)		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"

*-------------------------------------------------------------------------------
	
*Second stage
eststo: ivregress  2sls prob_ganar_survey  prob_ganar ///
         mujer antiguedad salario_diario ///
		 (i.demando_con_abogado_publico = i.group), cluster(fecha_alta)
replace esample=(e(sample))		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"

*Simple regression	
eststo: reg prob_ganar_survey i.demando_con_abogado_publico prob_ganar ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta) 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"

*Reduced form
eststo: reg prob_ganar_survey i.group prob_ganar ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta)		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"
		 
*First stage
eststo: reg demando_con_abogado_publico i.group prob_ganar ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta)		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"
	
	
********************************************************************************


use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)

gen esample=.

*******************************
* 			REGRESSIONS		  *
*******************************
			
*Second stage
eststo: ivregress  2sls cantidad_ganar_survey  cantidad_ganar ///
         mujer antiguedad salario_diario ///
		 (i.cond_hablo_con_publico = i.group), cluster(fecha_alta)
replace esample=(e(sample))		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"

*Simple regression	
eststo: reg cantidad_ganar_survey i.cond_hablo_con_publico cantidad_ganar ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta) 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"

*Reduced form
eststo: reg cantidad_ganar_survey i.group cantidad_ganar ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta)		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"
		 
*First stage
eststo: reg cond_hablo_con_publico i.group cantidad_ganar ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta)		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"

*-------------------------------------------------------------------------------
	
*Second stage
eststo: ivregress  2sls prob_ganar_survey  prob_ganar ///
         mujer antiguedad salario_diario ///
		 (i.cond_hablo_con_publico = i.group), cluster(fecha_alta)
replace esample=(e(sample))		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"

*Simple regression	
eststo: reg prob_ganar_survey i.cond_hablo_con_publico prob_ganar ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta) 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"

*Reduced form
eststo: reg prob_ganar_survey i.group prob_ganar ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta)		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"
		 
*First stage
eststo: reg cond_hablo_con_publico i.group prob_ganar ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta)		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"

		
			

	*************************
	esttab using "$directorio/Tables/reg_results/iv_exp_law.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "BVC BVC"  "Source Source" ) replace 
			
