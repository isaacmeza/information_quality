
***                         UPDATE SURVEY - BASELINE                         ***
********************************************************************************

use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)


*******************************
* 			REGRESSIONS		  *
*******************************
eststo clear
			
xtile perc_amt=cantidad_ganar, nq(5)			
eststo: reg cantidad_ganar_survey i.demando_con_abogado_publico##i.perc_amt cantidad_ganar ///
         mujer antiguedad salario_diario, cluster(fecha_alta)
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"			
			
xtile perc_prob=prob_ganar, nq(5)			
eststo: reg prob_ganar_survey i.demando_con_abogado_publico##i.perc_prob prob_ganar ///
         mujer antiguedad salario_diario, cluster(fecha_alta)
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"			


foreach var of varlist cantidad_ganar_survey cantidad_ganar {
replace `var'=`var'/1000 
xtile perc_`var'=`var' , nq(100)
replace `var'=. if perc_`var'>=95 & perc_`var'<=5
}


*******************************
* 			LPOLY  			  *
*******************************

twoway (lpoly cantidad_ganar_survey cantidad_ganar if demando_con_abogado_publico==1 , ///
			deg(1) lcolor(red) lpattern(solid)) || ///
		(lpoly cantidad_ganar_survey cantidad_ganar if demando_con_abogado_publico==0, ///
			deg(1) lcolor(blue) lpattern(solid)) ///
		, scheme(s2mono) graphregion(color(white)) xtitle("Baseline") ytitle("2M") ///
		legend(order(1 "Public " 2 "Private ")) ///
		name(amt_2m, replace)

		
twoway (fpfitci prob_ganar_survey prob_ganar if demando_con_abogado_publico==1  ///
			& prob_ganar_survey>=0.5 & prob_ganar>=0.5 , acolor(gs13) lcolor(none) lpattern(solid)) || ///
		(fpfitci prob_ganar_survey prob_ganar if demando_con_abogado_publico==0 ///
			& prob_ganar_survey>=0.5 & prob_ganar>=0.5 , acolor(gs15) lcolor(none) lpattern(solid)) || ///
		(lpoly 	prob_ganar_survey prob_ganar if demando_con_abogado_publico==1  /// 
			& prob_ganar_survey>=0.5 & prob_ganar>=0.5 , lcolor(red) deg(1) lpattern(solid) ) ///  
		(lpoly 	prob_ganar_survey prob_ganar if demando_con_abogado_publico==0  /// 
			& prob_ganar_survey>=0.5 & prob_ganar>=0.5 , lcolor(blue) deg(1) lpattern(solid) ) ///  
		(scatter prob_ganar_survey prob_ganar if  prob_ganar_survey>=0.5 & prob_ganar>=0.5, msymbol(circle_hollow )) ///		
		, scheme(s2mono) graphregion(color(white)) xtitle("Baseline") ytitle("2M") ///
		legend(order(5 "Public " 6 "Private ")) ///
		name(prob_2m, replace)

*-------------------------------------------------------------------------------

use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)


*******************************
* 			REGRESSIONS		  *
*******************************
			
xtile perc_amt=cantidad_ganar, nq(5)			
eststo: reg cantidad_ganar_survey i.cond_hablo_con_publico##i.perc_amt cantidad_ganar ///
         mujer antiguedad salario_diario, cluster(fecha_alta)
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"			
			
xtile perc_prob=prob_ganar, nq(5)			
eststo: reg prob_ganar_survey i.cond_hablo_con_publico##i.perc_prob prob_ganar ///
         mujer antiguedad salario_diario, cluster(fecha_alta)
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"


foreach var of varlist cantidad_ganar_survey cantidad_ganar {
replace `var'=`var'/1000 
xtile perc_`var'=`var' , nq(100)
replace `var'=. if perc_`var'>=95 & perc_`var'<=5
}


*******************************
* 			LPOLY  			  *
*******************************

twoway (lpoly cantidad_ganar_survey cantidad_ganar if cond_hablo_con_publico==1 , ///
			deg(1) lcolor(red) lpattern(solid)) || ///
		(lpoly cantidad_ganar_survey cantidad_ganar if cond_hablo_con_publico==0, ///
			deg(1) lcolor(blue) lpattern(solid)) ///
		, scheme(s2mono) graphregion(color(white)) xtitle("Baseline") ytitle("2W") ///
		legend(order(1 "Public " 2 "Private ")) ///
		name(amt_2w, replace)

		
twoway (fpfitci prob_ganar_survey prob_ganar if cond_hablo_con_publico==1  ///
			& prob_ganar_survey>=0.5 & prob_ganar>=0.5 , acolor(gs13) lcolor(none) lpattern(solid)) || ///
		(fpfitci prob_ganar_survey prob_ganar if cond_hablo_con_publico==0 ///
			& prob_ganar_survey>=0.5 & prob_ganar>=0.5 , acolor(gs15) lcolor(none) lpattern(solid)) || ///
		(lpoly 	prob_ganar_survey prob_ganar if cond_hablo_con_publico==1  /// 
			& prob_ganar_survey>=0.5 & prob_ganar>=0.5 , lcolor(red) deg(1) lpattern(solid) ) ///  
		(lpoly 	prob_ganar_survey prob_ganar if cond_hablo_con_publico==0  /// 
			& prob_ganar_survey>=0.5 & prob_ganar>=0.5 , lcolor(blue) deg(1) lpattern(solid) ) ///  
		(scatter prob_ganar_survey prob_ganar if  prob_ganar_survey>=0.5 & prob_ganar>=0.5, msymbol(circle_hollow )) ///		
		, scheme(s2mono) graphregion(color(white)) xtitle("Baseline") ytitle("2W") ///
		legend(order(5 "Public " 6 "Private ")) ///
		name(prob_2w, replace)

			

********************************************************************************
			
graph combine amt_2w amt_2m, xcommon title("") graphregion(color(white)) scheme(s2mono)
graph export "$directorio/Figuras/lpoly_exp_amt.pdf", replace 		 

graph combine prob_2w prob_2m, xcommon title("") graphregion(color(white)) scheme(s2mono)
graph export "$directorio/Figuras/lpoly_exp_prob.pdf", replace 		 
			
			

	*************************
	esttab using "$directorio/Tables/reg_results/exp_pub_pri.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "BVC BVC"  "Source Source" ) replace 
			
