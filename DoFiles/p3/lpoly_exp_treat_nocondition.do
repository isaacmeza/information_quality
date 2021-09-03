***                      UPDATE : INMEDIATE - BASELINE                       ***
********************************************************************************
use "$directorio\DB\treatment_data.dta", clear


foreach var of varlist cantidad_ganar_treat cantidad_ganar {
replace `var'=`var'/salario_diario
xtile perc_`var'=`var', nq(100)
replace `var'=. if perc_`var'>95
}


*******************************
* 			LPOLY  			  *
*******************************

twoway (lpoly cantidad_ganar_treat cantidad_ganar if main_treat==2  ///
			 , deg(1) lcolor(red) lpattern(solid)) || ///
		(lpoly cantidad_ganar_treat cantidad_ganar if main_treat==3 ///
			 , deg(1) lcolor(blue) lpattern(solid)) ///
		(lpoly cantidad_ganar_treat cantidad_ganar_treat ///
			 , deg(1) lcolor(black) lpattern(solid)) ///	 
		(scatter cantidad_ganar_treat cantidad_ganar , msymbol(circle_hollow )) ///		 
		, scheme(s2mono) graphregion(color(white)) xtitle("Baseline") ytitle("Inmediate exp") ///
		legend(order(1 "T2" 2 "T3")) 
graph export "$directorio/Figuras/imm_exp_amt_nocond.pdf", replace 
		
		
twoway (fpfitci prob_ganar_treat prob_ganar if main_treat==2  ///
			 , acolor(gs13) lcolor(none) lpattern(solid)) || ///
		(fpfitci prob_ganar_treat prob_ganar if main_treat==3 ///
			, acolor(gs15) lcolor(none) lpattern(solid)) || ///
		(lpoly 	prob_ganar_treat prob_ganar if main_treat==2  /// 
			 , lcolor(red) deg(1) lpattern(solid) ) ///  
		(lpoly 	prob_ganar_treat prob_ganar if main_treat==3  /// 
			 , lcolor(blue) deg(1) lpattern(solid) ) /// 
		(lpoly 	prob_ganar_treat prob_ganar_treat  /// 
			 , lcolor(black) deg(1) lpattern(solid) ) /// 			 
		(scatter prob_ganar_treat prob_ganar , msymbol(circle_hollow )) ///		
		, scheme(s2mono) graphregion(color(white)) xtitle("Baseline") ytitle("Immediate exp") ///
		legend(order(5 "T2 " 6 "T3")) 
graph export "$directorio/Figuras/imm_exp_prob_nocond.pdf", replace 



***                         UPDATE : 2W - BASELINE                           ***
********************************************************************************
use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)


foreach var of varlist cantidad_ganar_survey cantidad_ganar {
replace `var'=`var'/salario_diario
xtile perc_`var'=`var', nq(100)
replace `var'=. if perc_`var'>95
}


*******************************
* 			LPOLY  			  *
*******************************

twoway (lpoly cantidad_ganar_survey cantidad_ganar if main_treat==2  ///
			 , deg(1) lcolor(red) lpattern(solid)) || ///
		(lpoly cantidad_ganar_survey cantidad_ganar if main_treat==3 ///
			 , deg(1) lcolor(blue) lpattern(solid)) ///
		(lpoly cantidad_ganar_survey cantidad_ganar_survey  ///
			 , deg(1) lcolor(black) lpattern(solid)) ///			 
		(scatter cantidad_ganar_survey cantidad_ganar , msymbol(circle_hollow )) ///	 
		, scheme(s2mono) graphregion(color(white)) xtitle("Baseline") ytitle("2W") ///
		legend(order(1 "T2" 2 "T3"))
graph export "$directorio/Figuras/2w_exp_amt_nocond.pdf", replace 
		
		
twoway (fpfitci prob_ganar_survey prob_ganar if main_treat==2  ///
			 , acolor(gs13) lcolor(none) lpattern(solid)) || ///
		(fpfitci prob_ganar_survey prob_ganar if main_treat==3 ///
			, acolor(gs15) lcolor(none) lpattern(solid)) || ///
		(lpoly 	prob_ganar_survey prob_ganar if main_treat==2  /// 
			 , lcolor(red) deg(1) lpattern(solid) ) ///  
		(lpoly 	prob_ganar_survey prob_ganar if main_treat==3  /// 
			 , lcolor(blue) deg(1) lpattern(solid) ) ///  
		(lpoly 	prob_ganar_survey prob_ganar_survey  /// 
			 , lcolor(black) deg(1) lpattern(solid) ) /// 			 
		(scatter prob_ganar_survey prob_ganar , msymbol(circle_hollow )) ///		
		, scheme(s2mono) graphregion(color(white)) xtitle("Baseline") ytitle("2W") ///
		legend(order(5 "T2 " 6 "T3"))
graph export "$directorio/Figuras/2w_exp_prob_nocond.pdf", replace 



***                         UPDATE : 2M - BASELINE                           ***
********************************************************************************
use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)


foreach var of varlist cantidad_ganar_survey cantidad_ganar {
replace `var'=`var'/salario_diario
xtile perc_`var'=`var', nq(100)
replace `var'=. if perc_`var'>95
}


*******************************
* 			LPOLY  			  *
*******************************

twoway (lpoly cantidad_ganar_survey cantidad_ganar if main_treat==2  ///
			 , deg(1) lcolor(red) lpattern(solid)) || ///
		(lpoly cantidad_ganar_survey cantidad_ganar if main_treat==3 ///
			 , deg(1) lcolor(blue) lpattern(solid)) ///
		(lpoly cantidad_ganar_survey cantidad_ganar_survey  ///
			 , deg(1) lcolor(black) lpattern(solid)) ///			 
		(scatter cantidad_ganar_survey cantidad_ganar , msymbol(circle_hollow )) ///	 
		, scheme(s2mono) graphregion(color(white)) xtitle("Baseline") ytitle("2M") ///
		legend(order(1 "T2" 2 "T3")) 
graph export "$directorio/Figuras/2m_exp_amt_nocond.pdf", replace 
		
		
twoway (fpfitci prob_ganar_survey prob_ganar if main_treat==2  ///
			 , acolor(gs13) lcolor(none) lpattern(solid)) || ///
		(fpfitci prob_ganar_survey prob_ganar if main_treat==3 ///
			, acolor(gs15) lcolor(none) lpattern(solid)) || ///
		(lpoly 	prob_ganar_survey prob_ganar if main_treat==2  /// 
			 , lcolor(red) deg(1) lpattern(solid) ) ///  
		(lpoly 	prob_ganar_survey prob_ganar if main_treat==3  /// 
			 , lcolor(blue) deg(1) lpattern(solid) ) /// 
		(lpoly 	prob_ganar_survey prob_ganar_survey  /// 
			 , lcolor(black) deg(1) lpattern(solid) ) /// 			 
		(scatter prob_ganar_survey prob_ganar , msymbol(circle_hollow )) ///		
		, scheme(s2mono) graphregion(color(white)) xtitle("Baseline") ytitle("2M") ///
		legend(order(5 "T2 " 6 "T3")) 
graph export "$directorio/Figuras/2m_exp_prob_nocond.pdf", replace 



***                          UPDATE : 2M - 2W                                ***
********************************************************************************
use "$directorio\DB\survey_data_2w.dta", clear
keep id_actor prob_ganar_survey cantidad_ganar_survey
*Comparison is now with 2w expectations
rename prob_ganar_survey prob_ganar
rename cantidad_ganar_survey cantidad_ganar
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(3) nogen
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3) keepusing(main_treat salario_diario)


foreach var of varlist cantidad_ganar_survey cantidad_ganar {
replace `var'=`var'/salario_diario
xtile perc_`var'=`var', nq(100)
replace `var'=. if perc_`var'>95
}


*******************************
* 			LPOLY  			  *
*******************************

twoway (lpoly cantidad_ganar_survey cantidad_ganar if main_treat==2  ///
			 , deg(1) lcolor(red) lpattern(solid)) || ///
		(lpoly cantidad_ganar_survey cantidad_ganar if main_treat==3 ///
			 , deg(1) lcolor(blue) lpattern(solid)) ///
		(lpoly cantidad_ganar_survey cantidad_ganar_survey  ///
			 , deg(1) lcolor(black) lpattern(solid)) ///	 
		(scatter cantidad_ganar_survey cantidad_ganar , msymbol(circle_hollow )) ///	 
		, scheme(s2mono) graphregion(color(white)) xtitle("2W") ytitle("2M") ///
		legend(order(1 "T2" 2 "T3"))
graph export "$directorio/Figuras/2m2w_exp_amt_nocond.pdf", replace 
		
		
twoway (fpfitci prob_ganar_survey prob_ganar if main_treat==2  ///
			 , acolor(gs13) lcolor(none) lpattern(solid)) || ///
		(fpfitci prob_ganar_survey prob_ganar if main_treat==3 ///
			, acolor(gs15) lcolor(none) lpattern(solid)) || ///
		(lpoly 	prob_ganar_survey prob_ganar if main_treat==2  /// 
			 , lcolor(red) deg(1) lpattern(solid) ) ///  
		(lpoly 	prob_ganar_survey prob_ganar if main_treat==3  /// 
			 , lcolor(blue) deg(1) lpattern(solid) ) ///  
		(lpoly 	prob_ganar_survey prob_ganar_survey   /// 
			 , lcolor(black) deg(1) lpattern(solid) ) ///  	 
		(scatter prob_ganar_survey prob_ganar , msymbol(circle_hollow )) ///		
		, scheme(s2mono) graphregion(color(white)) xtitle("2W") ytitle("2M") ///
		legend(order(5 "T2 " 6 "T3")) 
graph export "$directorio/Figuras/2m2w_exp_prob_nocond.pdf", replace 
