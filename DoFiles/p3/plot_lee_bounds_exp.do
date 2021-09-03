*PLOT OF BOUNDS

********************************************************************************
************************************2M******************************************
use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3)
qui su date
keep if inrange(date,`r(min)',date(c(current_date) ,"DMY")-70)
			
qui gen telefono_int=telefono_cel*telefono_fijo
matrix results = J(9, 11, .)

********************************************************************************
*Varlist
replace cantidad_ganar_survey=cantidad_ganar_survey/1000

*Trimming
foreach var of varlist cantidad_ganar_survey {
	xtile perc_`var'=`var', nq(100)
	replace `var'=. if perc_`var'>=95
	}

*COMPUTATION OF BOUNDS
local v=1
	foreach t in 2 3 b {
		preserve
		do "$directorio\DoFiles\lee_bounds.do" ///
				cantidad_ganar_survey `t' "no_condition" "" `v'
		restore
		local v=`v'+1
		}
		
		
********************************************************************************
************************************2W******************************************
use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3)
qui su date
keep if inrange(date,date("1/08/2017" ,"DMY"),date(c(current_date) ,"DMY")-21)
			
qui gen telefono_int=telefono_cel*telefono_fijo

********************************************************************************
*Varlist
replace cantidad_ganar_survey=cantidad_ganar_survey/1000

*Trimming
foreach var of varlist cantidad_ganar_survey {
	xtile perc_`var'=`var', nq(100)
	replace `var'=. if perc_`var'>=95
	}
	
*COMPUTATION OF BOUNDS
	foreach t in 2 3 b {
		preserve
		do "$directorio\DoFiles\lee_bounds.do" ///
				cantidad_ganar_survey `t' "no_condition" "" `v'
		restore
		local v=`v'+1
		}
		
********************************************************************************
**********************************BASELINE**************************************
use "$directorio\DB\treatment_data.dta", clear
			
qui gen telefono_int=telefono_cel*telefono_fijo

********************************************************************************
*Varlist
replace cantidad_ganar=cantidad_ganar/1000

*Trimming
foreach var of varlist cantidad_ganar {
	xtile perc_`var'=`var', nq(100)
	replace `var'=. if perc_`var'>=95
	}
	
*COMPUTATION OF BOUNDS
	foreach t in 2 3 b {
		preserve
		do "$directorio\DoFiles\lee_bounds.do" ///
				cantidad_ganar `t' "no_condition" "" `v'
		restore
		local v=`v'+1
		}
		
***
clear
matrix colnames results = "t" "t_lo" "t_hi" ///
						"lb" "lb_lo" "lb_hi"  ///
						"ub" "ub_lo" "ub_hi" ///
 						"mil" "miu"
svmat results, names(col) 

cap drop k
gen k=_n
forvalues i=4(3)9 {
	replace k=k+6 if _n>=`i'
	}
	


twoway  (rcap ub lb k if inlist(k ,1,10,19, 28, 37,46) ,   ///
				msize(huge) lwidth(thick) color(blue) lpattern(dash)) ///
		(rcap ub lb k if inlist(k ,2,11,20, 29, 38,47) ,   ///
				msize(huge) lwidth(thick) color(red) lpattern(solid))  ///
		(rcap ub lb k if inlist(k ,3,12,21, 30, 39,48) ,   ///
				msize(huge) lwidth(thick) color(black) lpattern(dot))  ///		
		(scatter ub k, msize(medlarge) color(black) mfcolor(white) msymbol(circle)) ///	
		(scatter lb k, msize(medlarge) color(black) mfcolor(white) msymbol(circle)) ///	
		(rcap ub_hi ub_lo k, msize(small) color(gs9)) ///
		(rcap lb_hi lb_lo k, msize(small) color(gs9)) ///
		, scheme(s2mono) graphregion(color(white)) ///	
		legend(order (1 "T1/T2" 2 "T1/T3" 3 "A/B") cols(3)  symysize(.1)) ///
		 title("Lee Bounds") subtitle("Amount (thousands)") ytitle("ATE") xtitle("") ///
		 xlabel(2 "2M"	 11 "2W" 20 "Baseline")
graph export "$directorio/Figuras/lee_bounds_exp_amt.pdf", replace 		 
		 
		 


********************************************************************************	



********************************************************************************
************************************2M******************************************
use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3)
qui su date
keep if inrange(date,`r(min)',date(c(current_date) ,"DMY")-70)
			
qui gen telefono_int=telefono_cel*telefono_fijo
matrix results = J(9, 11, .)

********************************************************************************

*COMPUTATION OF BOUNDS
local v=1
	foreach t in 2 3 b {
		preserve
		do "$directorio\DoFiles\lee_bounds.do" ///
				prob_ganar_survey `t' "no_condition" "" `v'
		restore
		local v=`v'+1
		}
		
		
********************************************************************************
************************************2W******************************************
use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3)
qui su date
keep if inrange(date,date("1/08/2017" ,"DMY"),date(c(current_date) ,"DMY")-21)
			
qui gen telefono_int=telefono_cel*telefono_fijo

********************************************************************************

*COMPUTATION OF BOUNDS
	foreach t in 2 3 b {
		preserve
		do "$directorio\DoFiles\lee_bounds.do" ///
				prob_ganar_survey `t' "no_condition" "" `v'
		restore
		local v=`v'+1
		}
		
********************************************************************************
**********************************BASELINE**************************************
use "$directorio\DB\treatment_data.dta", clear
			
qui gen telefono_int=telefono_cel*telefono_fijo

********************************************************************************

*COMPUTATION OF BOUNDS
	foreach t in 2 3 b {
		preserve
		do "$directorio\DoFiles\lee_bounds.do" ///
				prob_ganar `t' "no_condition" "" `v'
		restore
		local v=`v'+1
		}
		
***
clear
matrix colnames results = "t" "t_lo" "t_hi" ///
						"lb" "lb_lo" "lb_hi"  ///
						"ub" "ub_lo" "ub_hi" ///
 						"mil" "miu"
svmat results, names(col) 

cap drop k
gen k=_n
forvalues i=4(3)9 {
	replace k=k+6 if _n>=`i'
	}
	


twoway  (rcap ub lb k if inlist(k ,1,10,19, 28, 37,46) ,   ///
				msize(huge) lwidth(thick) color(blue) lpattern(dash)) ///
		(rcap ub lb k if inlist(k ,2,11,20, 29, 38,47) ,   ///
				msize(huge) lwidth(thick) color(red) lpattern(solid))  ///
		(rcap ub lb k if inlist(k ,3,12,21, 30, 39,48) ,   ///
				msize(huge) lwidth(thick) color(black) lpattern(dot))  ///		
		(scatter ub k, msize(medlarge) color(black) mfcolor(white) msymbol(circle)) ///	
		(scatter lb k, msize(medlarge) color(black) mfcolor(white) msymbol(circle)) ///	
		(rcap ub_hi ub_lo k, msize(small) color(gs9)) ///
		(rcap lb_hi lb_lo k, msize(small) color(gs9)) ///
		, scheme(s2mono) graphregion(color(white)) ///	
		legend(order (1 "T1/T2" 2 "T1/T3" 3 "A/B") cols(3)  symysize(.1)) ///
		 title("Lee Bounds") subtitle("Probability") ytitle("ATE") xtitle("") ///
		 xlabel(2 "2M"	 11 "2W" 20 "Baseline")
graph export "$directorio/Figuras/lee_bounds_exp_prob.pdf", replace 		 
		 
		 


********************************************************************************	



********************************************************************************
************************************2M******************************************
use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3)
qui su date
keep if inrange(date,`r(min)',date(c(current_date) ,"DMY")-70)
			
qui gen telefono_int=telefono_cel*telefono_fijo
matrix results = J(6, 11, .)

********************************************************************************
*Varlist
replace cantidad_ganar_survey=cantidad_ganar_survey/1000
replace cantidad_ganar=cantidad_ganar/1000
gen diff_amt=cantidad_ganar_survey-cantidad_ganar

*Trimming
foreach var of varlist diff_amt {
	xtile perc_`var'=`var', nq(100)
	replace `var'=. if perc_`var'>=95
	}
	
*COMPUTATION OF BOUNDS
local v=1
	foreach t in 2 3 b {
		preserve
		do "$directorio\DoFiles\lee_bounds.do" ///
				diff_amt `t' "no_condition" "" `v'
		restore
		local v=`v'+1
		}
	
		
********************************************************************************
************************************2W******************************************
use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3)
qui su date
keep if inrange(date,date("1/08/2017" ,"DMY"),date(c(current_date) ,"DMY")-21)
			
qui gen telefono_int=telefono_cel*telefono_fijo

********************************************************************************
*Varlist
replace cantidad_ganar_survey=cantidad_ganar_survey/1000
replace cantidad_ganar=cantidad_ganar/1000
gen diff_amt=cantidad_ganar_survey-cantidad_ganar

*Trimming
foreach var of varlist diff_amt {
	xtile perc_`var'=`var', nq(100)
	replace `var'=. if perc_`var'>=95
	}
	
*COMPUTATION OF BOUNDS
	foreach t in 2 3 b {
		preserve
		do "$directorio\DoFiles\lee_bounds.do" ///
				diff_amt `t' "no_condition" "" `v'
		restore
		local v=`v'+1
		}
	

***
clear
matrix colnames results = "t" "t_lo" "t_hi" ///
						"lb" "lb_lo" "lb_hi"  ///
						"ub" "ub_lo" "ub_hi" ///
 						"mil" "miu"
svmat results, names(col) 

cap drop k
gen k=_n
forvalues i=4(3)6 {
	replace k=k+6 if _n>=`i'
	}
	


twoway  (rcap ub lb k if inlist(k ,1,10,19, 28, 37,46) ,   ///
				msize(huge) lwidth(thick) color(blue) lpattern(dash)) ///
		(rcap ub lb k if inlist(k ,2,11,20, 29, 38,47) ,   ///
				msize(huge) lwidth(thick) color(red) lpattern(solid))  ///
		(rcap ub lb k if inlist(k ,3,12,21, 30, 39,48) ,   ///
				msize(huge) lwidth(thick) color(black) lpattern(dot))  ///		
		(scatter ub k, msize(medlarge) color(black) mfcolor(white) msymbol(circle)) ///	
		(scatter lb k, msize(medlarge) color(black) mfcolor(white) msymbol(circle)) ///	
		(rcap ub_hi ub_lo k, msize(small) color(gs9)) ///
		(rcap lb_hi lb_lo k, msize(small) color(gs9)) ///
		, scheme(s2mono) graphregion(color(white)) ///	
		legend(order (1 "T1/T2" 2 "T1/T3" 3 "A/B") cols(3)  symysize(.1)) ///
		 title("Lee Bounds") subtitle("Difference in amount") ytitle("ATE") xtitle("") ///
		 xlabel(2 "2M"	 11 "2W" )
graph export "$directorio/Figuras/lee_bounds_diff_amt.pdf", replace 		 
		 
		 


********************************************************************************	


********************************************************************************
************************************2M******************************************
use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3)
qui su date
keep if inrange(date,`r(min)',date(c(current_date) ,"DMY")-70)
			
qui gen telefono_int=telefono_cel*telefono_fijo
matrix results = J(6, 11, .)

********************************************************************************
*Varlist
gen diff_prob= prob_ganar_survey-prob_ganar

*COMPUTATION OF BOUNDS
local v=1
	foreach t in 2 3 b {
		preserve
		do "$directorio\DoFiles\lee_bounds.do" ///
				diff_prob `t' "no_condition" "" `v'
		restore
		local v=`v'+1
		}
	
		
********************************************************************************
************************************2W******************************************
use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3)
qui su date
keep if inrange(date,date("1/08/2017" ,"DMY"),date(c(current_date) ,"DMY")-21)
			
qui gen telefono_int=telefono_cel*telefono_fijo

********************************************************************************
*Varlist
gen diff_prob= prob_ganar_survey-prob_ganar

*COMPUTATION OF BOUNDS
	foreach t in 2 3 b {
		preserve
		do "$directorio\DoFiles\lee_bounds.do" ///
				diff_prob `t' "no_condition" "" `v'
		restore
		local v=`v'+1
		}
	

***
clear
matrix colnames results = "t" "t_lo" "t_hi" ///
						"lb" "lb_lo" "lb_hi"  ///
						"ub" "ub_lo" "ub_hi" ///
 						"mil" "miu"
svmat results, names(col) 

cap drop k
gen k=_n
forvalues i=4(3)6 {
	replace k=k+6 if _n>=`i'
	}
	


twoway  (rcap ub lb k if inlist(k ,1,10,19, 28, 37,46) ,   ///
				msize(huge) lwidth(thick) color(blue) lpattern(dash)) ///
		(rcap ub lb k if inlist(k ,2,11,20, 29, 38,47) ,   ///
				msize(huge) lwidth(thick) color(red) lpattern(solid))  ///
		(rcap ub lb k if inlist(k ,3,12,21, 30, 39,48) ,   ///
				msize(huge) lwidth(thick) color(black) lpattern(dot))  ///		
		(scatter ub k, msize(medlarge) color(black) mfcolor(white) msymbol(circle)) ///	
		(scatter lb k, msize(medlarge) color(black) mfcolor(white) msymbol(circle)) ///	
		(rcap ub_hi ub_lo k, msize(small) color(gs9)) ///
		(rcap lb_hi lb_lo k, msize(small) color(gs9)) ///
		, scheme(s2mono) graphregion(color(white)) ///	
		legend(order (1 "T1/T2" 2 "T1/T3" 3 "A/B") cols(3)  symysize(.1)) ///
		 title("Lee Bounds") subtitle("Difference in prob") ytitle("ATE") xtitle("") ///
		 xlabel(2 "2M"	 11 "2W" )
graph export "$directorio/Figuras/lee_bounds_diff_prob.pdf", replace 		 
		 		 
		 


********************************************************************************


********************************************************************************
************************************2M******************************************
use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3)
qui su date
keep if inrange(date,`r(min)',date(c(current_date) ,"DMY")-70)
			
qui gen telefono_int=telefono_cel*telefono_fijo
matrix results = J(6, 11, .)

********************************************************************************
*Trimming
foreach var of varlist update_comp_survey {
	xtile perc_`var'=`var', nq(100)
	replace `var'=. if inrange(perc_`var', 3, 97)!=1
	}
	
*COMPUTATION OF BOUNDS
local v=1
	foreach t in 2 3 b {
		preserve
		do "$directorio\DoFiles\lee_bounds.do" ///
				update_comp_survey `t' "no_condition" "" `v'
		restore
		local v=`v'+1
		}
	
		
********************************************************************************
************************************2W******************************************
use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3)
qui su date
keep if inrange(date,date("1/08/2017" ,"DMY"),date(c(current_date) ,"DMY")-21)
			
qui gen telefono_int=telefono_cel*telefono_fijo

********************************************************************************
*Trimming
foreach var of varlist update_comp_survey {
	xtile perc_`var'=`var', nq(100)
	replace `var'=. if inrange(perc_`var', 3, 97)!=1
	}
	
*COMPUTATION OF BOUNDS
	foreach t in 2 3 b {
		preserve
		do "$directorio\DoFiles\lee_bounds.do" ///
				update_comp_survey `t' "no_condition" "" `v'
		restore
		local v=`v'+1
		}
	

***
clear
matrix colnames results = "t" "t_lo" "t_hi" ///
						"lb" "lb_lo" "lb_hi"  ///
						"ub" "ub_lo" "ub_hi" ///
 						"mil" "miu"
svmat results, names(col) 

cap drop k
gen k=_n
forvalues i=4(3)6 {
	replace k=k+6 if _n>=`i'
	}
	


twoway  (rcap ub lb k if inlist(k ,1,10,19, 28, 37,46) ,   ///
				msize(huge) lwidth(thick) color(blue) lpattern(dash)) ///
		(rcap ub lb k if inlist(k ,2,11,20, 29, 38,47) ,   ///
				msize(huge) lwidth(thick) color(red) lpattern(solid))  ///
		(rcap ub lb k if inlist(k ,3,12,21, 30, 39,48) ,   ///
				msize(huge) lwidth(thick) color(black) lpattern(dot))  ///		
		(scatter ub k, msize(medlarge) color(black) mfcolor(white) msymbol(circle)) ///	
		(scatter lb k, msize(medlarge) color(black) mfcolor(white) msymbol(circle)) ///	
		(rcap ub_hi ub_lo k, msize(small) color(gs9)) ///
		(rcap lb_hi lb_lo k, msize(small) color(gs9)) ///
		, scheme(s2mono) graphregion(color(white)) ///	
		legend(order (1 "T1/T2" 2 "T1/T3" 3 "A/B") cols(3)  symysize(.1)) ///
		 title("Lee Bounds") subtitle("Ratio update amount") ytitle("ATE") xtitle("") ///
		 xlabel(2 "2M"	 11 "2W" )
graph export "$directorio/Figuras/lee_bounds_ratio_amt.pdf", replace 		 
		 
		 


********************************************************************************	


********************************************************************************
************************************2M******************************************
use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3)
qui su date
keep if inrange(date,`r(min)',date(c(current_date) ,"DMY")-70)
			
qui gen telefono_int=telefono_cel*telefono_fijo
matrix results = J(6, 11, .)

********************************************************************************

*COMPUTATION OF BOUNDS
local v=1
	foreach t in 2 3 b {
		preserve
		do "$directorio\DoFiles\lee_bounds.do" ///
				update_prob_survey `t' "no_condition" "" `v'
		restore
		local v=`v'+1
		}
	
		
********************************************************************************
************************************2W******************************************
use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3)
qui su date
keep if inrange(date,date("1/08/2017" ,"DMY"),date(c(current_date) ,"DMY")-21)
			
qui gen telefono_int=telefono_cel*telefono_fijo

********************************************************************************

*COMPUTATION OF BOUNDS
	foreach t in 2 3 b {
		preserve
		do "$directorio\DoFiles\lee_bounds.do" ///
				update_prob_survey `t' "no_condition" "" `v'
		restore
		local v=`v'+1
		}
	

***
clear
matrix colnames results = "t" "t_lo" "t_hi" ///
						"lb" "lb_lo" "lb_hi"  ///
						"ub" "ub_lo" "ub_hi" ///
 						"mil" "miu"
svmat results, names(col) 

cap drop k
gen k=_n
forvalues i=4(3)6 {
	replace k=k+6 if _n>=`i'
	}
	


twoway  (rcap ub lb k if inlist(k ,1,10,19, 28, 37,46) ,   ///
				msize(huge) lwidth(thick) color(blue) lpattern(dash)) ///
		(rcap ub lb k if inlist(k ,2,11,20, 29, 38,47) ,   ///
				msize(huge) lwidth(thick) color(red) lpattern(solid))  ///
		(rcap ub lb k if inlist(k ,3,12,21, 30, 39,48) ,   ///
				msize(huge) lwidth(thick) color(black) lpattern(dot))  ///		
		(scatter ub k, msize(medlarge) color(black) mfcolor(white) msymbol(circle)) ///	
		(scatter lb k, msize(medlarge) color(black) mfcolor(white) msymbol(circle)) ///	
		(rcap ub_hi ub_lo k, msize(small) color(gs9)) ///
		(rcap lb_hi lb_lo k, msize(small) color(gs9)) ///
		, scheme(s2mono) graphregion(color(white)) ///	
		legend(order (1 "T1/T2" 2 "T1/T3" 3 "A/B") cols(3)  symysize(.1)) ///
		 title("Lee Bounds") subtitle("Ratio update in prob") ytitle("ATE") xtitle("") ///
		 xlabel(2 "2M"	 11 "2W" )
graph export "$directorio/Figuras/lee_bounds_ratio_prob.pdf", replace 		 
		 		 
		 


********************************************************************************

