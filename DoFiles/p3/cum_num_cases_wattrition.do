*CUMULATIVE NUMBER OF CASEFILES WITHOUT ATTRITION


use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)


********************************************************************************


preserve
*Cumulative files
collapse (count) dow , by(date group)
sort group date
by group: gen cum=sum(dow)
tsset group date 

twoway (tsline cum if group==1,  graphregion(color(none)) ///
	xtitle("Date") ytitle("#") lwidth(thick) lcolor(red)) ///
	(tsline cum if group==2,  graphregion(color(none)) ///
	xtitle("Date") ytitle("#") lwidth(thick) lcolor(navy)) ///
	, title("2W") scheme(s2mono) legend(order(1 "A" 2 "B") rows(1)) name(ab_sw, replace)
	
	
	
restore	
*Cumulative files
collapse (count) dow , by(date main_treatment)
sort main_treatment date
by main_treatment: gen cum=sum(dow)
tsset main_treatment date 

twoway (tsline cum if main_treatment==1,  graphregion(color(none)) ///
	xtitle("Date") ytitle("#") lwidth(thick) lcolor(red)) ///
	(tsline cum if main_treatment==2,  graphregion(color(none)) ///
	xtitle("Date") ytitle("#") lwidth(thick) lcolor(navy)) ///
	(tsline cum if main_treatment==3,  graphregion(color(none)) ///
	xtitle("Date") ytitle("#") lwidth(thick) lcolor(dkgreen)) ///
	, title("2W") scheme(s2mono) legend(order(1 "1" 2 "2" 3 "3") rows(1)) name(tr_sw, replace)

collapse (sum) dow, by(date)
gen cum=sum(dow)

tsline cum, scheme(s2mono) graphregion(color(white)) ///
	xtitle("Date") ytitle("#") title("2W") lwidth(thick) name(tot_sw, replace)



	
********************************************************************************



use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)


********************************************************************************

preserve
*Cumulative files
collapse (count) dow , by(date group)
sort group date
by group: gen cum=sum(dow)
tsset group date 

twoway (tsline cum if group==1,  graphregion(color(none)) ///
	xtitle("Date") ytitle("#") lwidth(thick) lcolor(red)) ///
	(tsline cum if group==2,  graphregion(color(none)) ///
	xtitle("Date") ytitle("#") lwidth(thick) lcolor(navy)) ///
	, title("2M") scheme(s2mono) legend(order(1 "A" 2 "B") rows(1)) name(ab_sm, replace)
	
	
	
restore	
*Cumulative files
collapse (count) dow , by(date main_treatment)
sort main_treatment date
by main_treatment: gen cum=sum(dow)
tsset main_treatment date 

twoway (tsline cum if main_treatment==1,  graphregion(color(none)) ///
	xtitle("Date") ytitle("#") lwidth(thick) lcolor(red)) ///
	(tsline cum if main_treatment==2,  graphregion(color(none)) ///
	xtitle("Date") ytitle("#") lwidth(thick) lcolor(navy)) ///
	(tsline cum if main_treatment==3,  graphregion(color(none)) ///
	xtitle("Date") ytitle("#") lwidth(thick) lcolor(dkgreen)) ///
	, title("2M") scheme(s2mono) legend(order(1 "1" 2 "2" 3 "3") rows(1)) name(tr_sm, replace)

collapse (sum) dow, by(date)
gen cum=sum(dow)

tsline cum, scheme(s2mono) graphregion(color(white)) ///
	xtitle("Date") ytitle("#") title("2M") lwidth(thick) name(tot_sm, replace)
	
	
	
*-------------------------------------------------------------------------------	

graph combine tr_sw tr_sm ab_sw ab_sm, xcommon cols(2) scheme(s2mono) graphregion(color(white))
graph export "$directorio/Figuras/cum_num_cases_tr_survey.pdf", replace 

graph combine tot_sw tot_sm, xcommon cols(1) scheme(s2mono) graphregion(color(white))
graph export "$directorio/Figuras/cum_num_cases_survey.pdf", replace 
	

	
