/*Identify the real con-man lawyers by finding lawyers who consistently file 
cases with very low expected outcomes. I think one of our stories has been that
the informal lawyers do this in order to capture the filing fee.*/


*Historical data
use "$directorio\DB\lawyer_dataset.dta", clear

xtile perc_npv = npv, nq(100)
hist npv if perc_npv<=95, percent scheme(s2mono) graphregion(color(white)) ///
	xtitle("NPV")
graph export "$directorio\Figuras\dist_npv.pdf", replace 
	

	
use "$directorio\DB\lawyer_dataset_collapsed.dta", clear	

*NPV
	gsort -mean_ratio_npv
	cap drop orden
	gen orden=_n	

		
	twoway (rcap hi_ratio_npv low_ratio_npv orden if !missing(mean_ratio_npv), ///
					lcolor(gs10)) ///
				(line mean_ratio_npv	orden if !missing(mean_ratio_npv), lwidth(thick) ///
					lcolor(black) lpattern(solid) xtitle("Rank (decreasing order)") ytitle("Amount")) ///	
				, ///
				scheme(s2mono) graphregion(color(white)) ///	
				legend(off)
	graph export "$directorio\Figuras\quality_ratio_npv_pres.pdf", replace 
	
	
	gsort -mean_perc_non_pos_npv
	cap drop orden
	gen orden=_n	

		
	twoway (rcap hi_perc_non_pos_npv low_perc_non_pos_npv orden if !missing(mean_perc_non_pos_npv), ///
					lcolor(gs10)) ///
				(line mean_perc_non_pos_npv	orden if !missing(mean_perc_non_pos_npv), lwidth(thick) ///
					lcolor(black) lpattern(solid) xtitle("Rank (decreasing order)") ytitle("Percent")) ///	
				, ///
				scheme(s2mono) graphregion(color(white)) ///	
				legend(off)
	graph export "$directorio\Figuras\quality_perc_non_pos_npv_pres.pdf", replace 
	
