use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)

keep if !missing(group)

gen esample=.
xtile perc_amt=cantidad_ganar, nq(3)
forvalues i=2/3 {			
	gen pl_q`i'=demando_con_abogado_publico*`i'.perc_amt
	gen b_q`i'=2.group*`i'.perc_amt
	}
	
xtile perc_prob=prob_ganar, nq(3)			
forvalues i=2/3 {			
	gen pl_p`i'=demando_con_abogado_publico*`i'.perc_prob
	gen b_p`i'=2.group*`i'.perc_prob
	}
	
*******************************
* 			REGRESSIONS		  *
*******************************
eststo clear
	
	
*Second stage
eststo: ivregress  2sls cantidad_ganar_survey  cantidad_ganar i.perc_amt ///
         mujer antiguedad salario_diario ///
		 (i.demando_con_abogado_publico pl_q* = i.group b_q*), cluster(fecha_alta)
replace esample=(e(sample))		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"

*Simple regression	
eststo: reg cantidad_ganar_survey i.demando_con_abogado_publico##i.perc_amt cantidad_ganar ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta) 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"

*First stage
eststo: reg demando_con_abogado_publico i.group b_q* cantidad_ganar i.perc_amt ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta)		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"

*First stage
eststo: reg pl_q2 i.group b_q* cantidad_ganar i.perc_amt ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta)		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"

*First stage
eststo: reg pl_q3 i.group b_q* cantidad_ganar i.perc_amt ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta)		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"

*-------------------------------------------------------------------------------
	
*Second stage
eststo: ivregress  2sls prob_ganar_survey  prob_ganar i.perc_prob ///
         mujer antiguedad salario_diario ///
		 (i.demando_con_abogado_publico pl_p* = i.group b_p*), cluster(fecha_alta)
replace esample=(e(sample))		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"

*Simple regression	
eststo: reg prob_ganar_survey i.demando_con_abogado_publico##i.perc_prob prob_ganar ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta) 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"

*First stage
eststo: reg demando_con_abogado_publico i.group b_p* prob_ganar i.perc_prob ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta)		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"

*First stage
eststo: reg pl_p2 i.group b_p* prob_ganar i.perc_prob ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta)		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"

*First stage
eststo: reg pl_p3 i.group b_p* prob_ganar i.perc_prob ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta)		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"
	
	
********************************************************************************


use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)

keep if !missing(group)

gen esample=.
xtile perc_amt=cantidad_ganar, nq(3)
forvalues i=2/3 {			
	gen pl_q`i'=cond_hablo_con_publico*`i'.perc_amt
	gen b_q`i'=2.group*`i'.perc_amt
	}
	
xtile perc_prob=prob_ganar, nq(3)			
forvalues i=2/3 {			
	gen pl_p`i'=cond_hablo_con_publico*`i'.perc_prob
	gen b_p`i'=2.group*`i'.perc_prob
	}
	

*******************************
* 			REGRESSIONS		  *
*******************************
			
*Second stage
eststo: ivregress  2sls cantidad_ganar_survey  cantidad_ganar i.perc_amt ///
         mujer antiguedad salario_diario ///
		 (i.cond_hablo_con_publico pl_q* = i.group b_q*), cluster(fecha_alta)
replace esample=(e(sample))		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"

*Simple regression	
eststo: reg cantidad_ganar_survey i.cond_hablo_con_publico##i.perc_amt cantidad_ganar ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta) 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"

*First stage
eststo: reg cond_hablo_con_publico i.group b_q* cantidad_ganar i.perc_amt ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta)		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"

*First stage
eststo: reg pl_q2 i.group b_q* cantidad_ganar i.perc_amt ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta)		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"

*First stage
eststo: reg pl_q3 i.group b_q* cantidad_ganar i.perc_amt ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta)		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"

*-------------------------------------------------------------------------------
	
*Second stage
eststo: ivregress  2sls prob_ganar_survey  prob_ganar i.perc_prob ///
         mujer antiguedad salario_diario ///
		 (i.cond_hablo_con_publico pl_p* = i.group b_p*), cluster(fecha_alta)
replace esample=(e(sample))		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"

*Simple regression	
eststo: reg prob_ganar_survey i.cond_hablo_con_publico##i.perc_prob prob_ganar ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta) 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"

*First stage
eststo: reg cond_hablo_con_publico i.group b_p* prob_ganar i.perc_prob ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta)		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"

*First stage
eststo: reg pl_p2 i.group b_p* prob_ganar i.perc_prob ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta)		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"

*First stage
eststo: reg pl_p3 i.group b_p* prob_ganar i.perc_prob ///
         mujer antiguedad salario_diario if esample==1, cluster(fecha_alta)		 
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"

		
			

	*************************
	esttab using "$directorio/Tables/reg_results/iv_exp_law_2.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "BVC BVC"  "Source Source" ) replace 
			
