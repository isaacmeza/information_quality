use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)

	*Type of lawyer: 0-Public 1-Private 2-Coyote
gen type_lawyer=demando_con_abogado_privado
replace type_lawyer=2 if coyote==1
	
xtile perc_amt=cantidad_ganar, nq(5)
xtile perc_prob=prob_ganar, nq(5)

	
*******************************
* 			REGRESSIONS		  *
*******************************
eststo clear
			
eststo: reg cantidad_ganar_survey i.type_lawyer cantidad_ganar ///
         mujer antiguedad salario_diario, cluster(fecha_alta)
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"
			
eststo: reg cantidad_ganar_survey i.type_lawyer##i.perc_amt cantidad_ganar ///
         mujer antiguedad salario_diario, cluster(fecha_alta)
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"			
	
eststo: reg cantidad_coarse_survey i.type_lawyer cantidad_coarse ///
         mujer antiguedad salario_diario, cluster(fecha_alta)
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"
	
*-------------------------------------------------------------------------------

eststo: reg prob_ganar_survey i.type_lawyer prob_ganar ///
         mujer antiguedad salario_diario, cluster(fecha_alta)
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"

eststo: reg prob_ganar_survey i.type_lawyer##i.perc_prob prob_ganar ///
         mujer antiguedad salario_diario, cluster(fecha_alta)
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"

eststo: reg prob_coarse_survey i.type_lawyer prob_coarse ///
         mujer antiguedad salario_diario, cluster(fecha_alta)
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"			


foreach var of varlist cantidad_ganar_survey cantidad_ganar {
replace `var'=`var'/1000 
xtile perc_`var'=`var' , nq(100)
replace `var'=. if perc_`var'>=95 
}


*******************************
* 			LPOLY  			  *
*******************************

twoway (lpoly cantidad_ganar_survey cantidad_ganar if type_lawyer==0 , ///
			deg(1) lcolor(red) lpattern(solid)) || ///
		(lpoly cantidad_ganar_survey cantidad_ganar if type_lawyer==1, ///
			deg(1) lcolor(blue) lpattern(solid)) ///
		(lpoly cantidad_ganar_survey cantidad_ganar if type_lawyer==2, ///
			deg(1) lcolor(black) lpattern(solid)) ///	
		, scheme(s2mono) graphregion(color(white)) xtitle("Baseline") ytitle("2M") ///
		title("Amount") legend(order(1 "Public " 2 "Private formal" 3 "Private informal") cols(3)) ///
		name(amt_2m, replace)
graph export "$directorio/Figuras/lpoly_exp_amt_lawyer.pdf", replace 		 

		
twoway 	(lpoly 	prob_ganar_survey prob_ganar if type_lawyer==0 , /// 
			lcolor(red) deg(1) lpattern(solid) ) ///  
		(lpoly 	prob_ganar_survey prob_ganar if type_lawyer==1 , /// 
			lcolor(blue) deg(1) lpattern(solid) ) /// 
		(lpoly 	prob_ganar_survey prob_ganar if type_lawyer==2 , /// 
			lcolor(black) deg(1) lpattern(solid) ) /// 	
		(scatter prob_ganar_survey prob_ganar, msymbol(circle_hollow )) ///		
		, scheme(s2mono) graphregion(color(white)) xtitle("Baseline") ytitle("2M") ///
		title("Probability") legend(order(1 "Public " 2 "Private formal" 3 "Private informal") cols(3)) ///
		name(prob_2m, replace)
graph export "$directorio/Figuras/lpoly_exp_prob_lawyer.pdf", replace 		 


********************************************************************************
			
	*************************
	esttab using "$directorio/Tables/reg_results/exp_lawyer.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "BVC BVC"  "Source Source" ) replace 
			
