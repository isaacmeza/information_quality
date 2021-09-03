*QUALITY GRAPHS

use "$directorio\DB\lawyer_dataset_collapsed.dta", clear


********************************************************************************
********************************************************************************


***********************************
*        PERCENTAGE GRAPHS        *
***********************************

foreach var of varlist mean_perc_* {

	local vr= substr("`var'",strpos("`var'", "perc_") ,.)

	gsort -mean_`vr'
	cap drop orden
	gen orden=_n	

	forvalues i=1/10 {
		qui su orden if id==${lista`i'} & !missing(mean_`vr')
		if `r(N)'==0 {
			local tick`i'=.
			}
		else {
			local tick`i'=`r(mean)'
			}
		}

	twoway (rcap hi_`vr' low_`vr' orden if !missing(mean_`vr'), ///
				lcolor(gs10)) ///
			(line mean_`vr'	orden if !missing(mean_`vr'), lwidth(thick) ///
				lcolor(black) lpattern(solid) xtitle("Rank (increasing order)") ytitle("Percent")) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista1) , ///
				color(blue) msymbol(circle)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista2) , ///
				color(yellow) msymbol(circle)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista3) , ///
				color(dkgreen) msymbol(circle)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista4) , ///
				color(purple) msymbol(circle)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista5) , ///
				color(red) msymbol(circle) ) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista6) , ///
				color(ltblue) msymbol(square)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista7) , ///
				color(orange) msymbol(square)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista8) , ///
				color(green) msymbol(square)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista9) , ///
				color(navy) msymbol(square)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista10) , ///
				color(cranberry) msymbol(square) ) ///				
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista1) , ///
				color(blue)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista2) , ///
				color(yellow)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista3) , ///
				color(dkgreen)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista4) , ///
				color(purple)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista5) , ///
				color(red)) ///	
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista6) , ///
				color(ltblue)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista7) , ///
				color(orange)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista8) , ///
				color(green)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista9) , ///
				color(navy)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista10) , ///
				color(cranberry)) ///					
			, ///
			scheme(s2mono) graphregion(color(white)) ///
			xtick(`tick1',  tlcolor(gs4)) ///
			xtick(`tick2', add tlcolor(gs4)) ///
			xtick(`tick3', add tlcolor(gs4)) ///
			xtick(`tick4', add tlcolor(gs4)) ///
			xtick(`tick5', add tlcolor(gs4)) ///
			xtick(`tick6', add tlcolor(gs4)) ///
			xtick(`tick7', add tlcolor(gs4)) ///
			xtick(`tick8', add tlcolor(gs4)) ///
			xtick(`tick9', add tlcolor(gs4)) ///
			xtick(`tick10', add tlcolor(gs4)) ///
			legend(order(3 "$lista1" 4 "$lista2" 5 "$lista3" 6 "$lista4" 7 "$lista5" ///
				8 "$lista6" 9 "$lista7" 10 "$lista8" 11 "$lista9" 12 "$lista10") rows(2))
			
	graph export "$directorio\Figuras\quality_`vr'.pdf", replace 

	}

	

***********************************
*           RATIO GRAPHS          *
***********************************

foreach var of varlist mean_ratio_* {

	local vr= substr("`var'",strpos("`var'", "ratio_") ,.)

	gsort -mean_`vr'
	cap drop orden
	gen orden=_n	

	forvalues i=1/10 {
		qui su orden if id==${lista`i'} & !missing(mean_`vr')
		if `r(N)'==0 {
			local tick`i'=.
			}
		else {
			local tick`i'=`r(mean)'
			}
		}
		
	qui su mean_`vr'
	local max_y = `r(max)'+1
	local min_y = `r(min)'-1
	twoway (rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & hi_`vr'<=`max_y' & low_`vr'>=`min_y', ///
				lcolor(gs10)) ///
			(line mean_`vr'	orden if !missing(mean_`vr'), lwidth(thick) ///
				lcolor(black) lpattern(solid) xtitle("Rank (increasing order)") ytitle("Ratio")) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista1) , ///
				color(blue) msymbol(circle)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista2) , ///
				color(yellow) msymbol(circle)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista3) , ///
				color(dkgreen) msymbol(circle)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista4) , ///
				color(purple) msymbol(circle)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista5) , ///
				color(red) msymbol(circle) ) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista6) , ///
				color(ltblue) msymbol(square)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista7) , ///
				color(orange) msymbol(square)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista8) , ///
				color(green) msymbol(square)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista9) , ///
				color(navy) msymbol(square)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista10) , ///
				color(cranberry) msymbol(square) ) ///					
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista1) & hi_`vr'<=`max_y' & low_`vr'>=`min_y', ///
				color(blue)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista2) & hi_`vr'<=`max_y' & low_`vr'>=`min_y', ///
				color(yellow)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista3) & hi_`vr'<=`max_y' & low_`vr'>=`min_y', ///
				color(dkgreen)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista4) & hi_`vr'<=`max_y' & low_`vr'>=`min_y', ///
				color(purple)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista5) & hi_`vr'<=`max_y' & low_`vr'>=`min_y', ///
				color(red)) ///	
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista6) & hi_`vr'<=`max_y' & low_`vr'>=`min_y', ///
				color(ltblue)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista7) & hi_`vr'<=`max_y' & low_`vr'>=`min_y', ///
				color(orange)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista8) & hi_`vr'<=`max_y' & low_`vr'>=`min_y', ///
				color(green)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista9) & hi_`vr'<=`max_y' & low_`vr'>=`min_y', ///
				color(navy)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista10) & hi_`vr'<=`max_y' & low_`vr'>=`min_y', ///
				color(cranberry)) ///					
			, ///
			scheme(s2mono) graphregion(color(white)) ///
			xtick(`tick1',  tlcolor(gs4)) ///
			xtick(`tick2', add tlcolor(gs4)) ///
			xtick(`tick3', add tlcolor(gs4)) ///
			xtick(`tick4', add tlcolor(gs4)) ///
			xtick(`tick5', add tlcolor(gs4)) ///
			xtick(`tick6', add tlcolor(gs4)) ///
			xtick(`tick7', add tlcolor(gs4)) ///
			xtick(`tick8', add tlcolor(gs4)) ///
			xtick(`tick9', add tlcolor(gs4)) ///
			xtick(`tick10', add tlcolor(gs4)) ///			
			legend(order(3 "$lista1" 4 "$lista2" 5 "$lista3" 6 "$lista4" 7 "$lista5" ///
				8 "$lista6" 9 "$lista7" 10 "$lista8" 11 "$lista9" 12 "$lista10") rows(2))
			
	graph export "$directorio\Figuras\quality_`vr'.pdf", replace 

	}
	


***********************************
*          OTHER GRAPHS           *
***********************************

*Cumulative distribution of casefiles
gsort -num_casefiles
gen cdf_casefiles=sum(num_casefiles)
replace cdf_casefiles=cdf_casefiles/cdf_casefiles[_N]
gen n=_n
twoway (line cdf_casefiles n, sort lwidth(thick) lpattern(solid) color(black)) ///
			(scatter cdf_casefiles n if  inlist(id,$lista1) , ///
				color(blue) msymbol(circle)) ///
			(scatter cdf_casefiles n if  inlist(id,$lista2) , ///
				color(yellow) msymbol(circle)) ///
			(scatter cdf_casefiles n if  inlist(id,$lista3) , ///
				color(dkgreen) msymbol(circle)) ///
			(scatter cdf_casefiles n if  inlist(id,$lista4) , ///
				color(purple) msymbol(circle)) ///
			(scatter cdf_casefiles n if  inlist(id,$lista5) , ///
				color(red) msymbol(circle) ) ///
			(scatter cdf_casefiles n if  inlist(id,$lista6) , ///
				color(blue) msymbol(square)) ///
			(scatter cdf_casefiles n if  inlist(id,$lista7) , ///
				color(yellow) msymbol(square)) ///
			(scatter cdf_casefiles n if  inlist(id,$lista8) , ///
				color(dkgreen) msymbol(square)) ///
			(scatter cdf_casefiles n if  inlist(id,$lista9) , ///
				color(purple) msymbol(square)) ///
			(scatter cdf_casefiles n if  inlist(id,$lista10) , ///
				color(red) msymbol(square) ) ///				
				, ///
		scheme(s2mono) graphregion(color(white)) xtitle("Office (increasing order by #casefile)") ytitle("Percent") ///
		legend(order(2 "$lista1" 3 "$lista2" 4 "$lista3" 5 "$lista4" 6 "$lista5" ///
				7 "$lista6" 8 "$lista7" 9 "$lista8" 10 "$lista9" 11 "$lista10") rows(2)) ///
		title("CDF")
graph export "$directorio\Figuras\cdf_casefiles.pdf", replace 


*Duration of cases
local vr duration

gsort -mean_`vr'
cap drop orden
gen orden=_n	

	forvalues i=1/10 {
		qui su orden if id==${lista`i'} & !missing(mean_`vr')
		if `r(N)'==0 {
			local tick`i'=.
			}
		else {
			local tick`i'=`r(mean)'
			}
		}
	
	twoway (rcap hi_`vr' low_`vr' orden if !missing(mean_`vr'), ///
				lcolor(gs10)) ///
			(line mean_`vr'	orden if !missing(mean_`vr'), lwidth(thick) ///
				lcolor(black) lpattern(solid) xtitle("Rank (increasing order)") ytitle("Months")) ///
(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista1) , ///
				color(blue) msymbol(circle)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista2) , ///
				color(yellow) msymbol(circle)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista3) , ///
				color(dkgreen) msymbol(circle)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista4) , ///
				color(purple) msymbol(circle)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista5) , ///
				color(red) msymbol(circle) ) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista6) , ///
				color(ltblue) msymbol(square)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista7) , ///
				color(orange) msymbol(square)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista8) , ///
				color(green) msymbol(square)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista9) , ///
				color(navy) msymbol(square)) ///
			(scatter mean_`vr' orden if !missing(mean_`vr') & inlist(id,$lista10) , ///
				color(cranberry) msymbol(square) ) ///				
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista1) , ///
				color(blue)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista2) , ///
				color(yellow)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista3) , ///
				color(dkgreen)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista4) , ///
				color(purple)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista5) , ///
				color(red)) ///	
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista6) , ///
				color(ltblue)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista7) , ///
				color(orange)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista8) , ///
				color(green)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista9) , ///
				color(navy)) ///
			(rcap hi_`vr' low_`vr' orden if !missing(mean_`vr') & inlist(id,$lista10) , ///
				color(cranberry)) ///					
			, ///
			scheme(s2mono) graphregion(color(white)) ///
			xtick(`tick1',  tlcolor(gs4)) ///
			xtick(`tick2', add tlcolor(gs4)) ///
			xtick(`tick3', add tlcolor(gs4)) ///
			xtick(`tick4', add tlcolor(gs4)) ///
			xtick(`tick5', add tlcolor(gs4)) ///
			xtick(`tick6', add tlcolor(gs4)) ///
			xtick(`tick7', add tlcolor(gs4)) ///
			xtick(`tick8', add tlcolor(gs4)) ///
			xtick(`tick9', add tlcolor(gs4)) ///
			xtick(`tick10', add tlcolor(gs4)) ///
			legend(order(3 "$lista1" 4 "$lista2" 5 "$lista3" 6 "$lista4" 7 "$lista5" ///
				8 "$lista6" 9 "$lista7" 10 "$lista8" 11 "$lista9" 12 "$lista10") rows(2))
graph export "$directorio\Figuras\quality_`vr'.pdf", replace 
		
