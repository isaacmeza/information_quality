*QUALITY GRAPHS

use "$directorio\DB\lawyer_dataset_collapsed.dta", clear


********************************************************************************
********************************************************************************


***********************************
*        PERCENTAGE GRAPHS        *
***********************************

foreach var of varlist mean_perc_*{

	local vr= substr("`var'",strpos("`var'", "perc_") ,.)

	gsort -mean_`vr'
	cap drop orden
	gen orden=_n	


	twoway (rcap hi_`vr' low_`vr' orden if !missing(mean_`vr'), ///
				lcolor(gs10)) ///
			(line mean_`vr'	orden if !missing(mean_`vr'), lwidth(thick) ///
				lcolor(black) lpattern(solid) xtitle("Rank (increasing order)") ytitle("Percent")) ///					
			, ///
			scheme(s2mono) graphregion(color(white)) ///
			legend(off)
			
	graph export "$directorio\Figuras\quality_`vr'_pres.pdf", replace 

	}

	

***********************************
*           RATIO GRAPHS          *
***********************************

foreach var of varlist mean_ratio_win_minley {

	local vr= substr("`var'",strpos("`var'", "ratio_") ,.)

	gsort -mean_`vr'
	cap drop orden
	gen orden=_n	

		
	qui su mean_`vr'
	local max_y = `r(max)'+1
	local min_y = `r(min)'-1
	twoway (rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & hi_`vr'<=`max_y' & low_`vr'>=`min_y', ///
				lcolor(gs10)) ///
			(line mean_`vr'	orden if !missing(mean_`vr'), lwidth(thick) ///
				lcolor(black) lpattern(solid) xtitle("Rank (increasing order)") ytitle("Ratio")) ///					
			, ///
			scheme(s2mono) graphregion(color(white)) ///		
			legend(off)
			
	graph export "$directorio\Figuras\quality_`vr'_pres.pdf", replace 

	}
	


***********************************
*          OTHER GRAPHS           *
***********************************


*Duration of cases
local vr duration

gsort -mean_`vr'
cap drop orden
gen orden=_n	

	
twoway (rcap hi_`vr' low_`vr' orden if !missing(mean_`vr'), ///
				lcolor(gs10)) ///
			(line mean_`vr'	orden if !missing(mean_`vr'), lwidth(thick) ///
				lcolor(black) lpattern(solid) xtitle("Rank (increasing order)") ytitle("Months")) ///	
			, ///
			scheme(s2mono) graphregion(color(white)) ///	
			legend(off)
graph export "$directorio\Figuras\quality_`vr'_pres.pdf", replace 
		
