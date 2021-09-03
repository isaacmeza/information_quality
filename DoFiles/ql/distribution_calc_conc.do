*Historical data
use "$directorio\DB\lawyer_dataset.dta", clear

*Amount conciliator would calculate
gen conciliator_amt=min_ley-45*salario_diario

*Ratio
gen ratio_calc_p1=comp_esp_p1/conciliator_amt
gen ratio_calc_p2=comp_esp_p1/conciliator_amt

*Difference
gen difference_calc_p1=comp_esp_p1-conciliator_amt
gen difference_calc_p2=comp_esp_p2-conciliator_amt


xtile perc_ratio_calc_p1 = ratio_calc_p1, nq(100)
hist ratio_calc_p1 if inrange(perc_ratio_calc_p1,5,95) , percent scheme(s2mono) graphregion(color(white)) ///
	title("Ratio - P1") xtitle("Calc/Conciliator") name(ratio_p1, replace)
xtile perc_difference_calc_p1 = difference_calc_p1, nq(100)
hist difference_calc_p1 if inrange(perc_difference_calc_p1,5,95) , percent scheme(s2mono) graphregion(color(white)) ///
	title("Difference - P1") xtitle("Calc-Conciliator") name(diff_p1, replace)
graph combine ratio_p1 diff_p1, scheme(s2mono) graphregion(color(white)) ycommon cols(2)	
graph export "$directorio\Figuras\dist_calc_conc_p1.pdf", replace 

	
xtile perc_ratio_calc_p2 = ratio_calc_p2, nq(100)
hist ratio_calc_p2 if inrange(perc_ratio_calc_p2,5,95) , percent scheme(s2mono) graphregion(color(white)) ///
	title("Ratio - P2") xtitle("Calc/Conciliator") name(ratio_p2, replace)		
xtile perc_difference_calc_p2 = difference_calc_p2, nq(100)
hist difference_calc_p2 if inrange(perc_difference_calc_p2,5,95) , percent scheme(s2mono) graphregion(color(white)) ///
	title("Difference - P2") xtitle("Calc-Conciliator") name(diff_p2, replace)
graph combine ratio_p2 diff_p2, scheme(s2mono) graphregion(color(white)) ycommon cols(2)	
graph export "$directorio\Figuras\dist_calc_conc_p2.pdf", replace 
	
	
	
