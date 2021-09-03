
use "$directorio\DB\lawyer_dataset.dta", clear

*Generation of variables of interest
do "$directorio\DoFiles\gen_measures.do"


*Variable name cleaning
foreach var of varlist perc* {
	local nvar=substr("`var'",6,.)
	cap rename `var' `nvar'
	}

foreach var of varlist ratio* {
	local nvar=substr("`var'",7,.)
	cap rename `var' `nvar'
	}

********************************************************************************	
bysort gp_office : gen num_casefiles=_N
drop if num_casefiles<=4
xtile quintile_size=num_casefiles, nq(5)
********************************************************************************

// GRAPH FORMATTING
// For graphs:
local labsize medlarge
local bigger_labsize large
local ylabel_options nogrid notick labsize(`labsize') angle(horizontal)
local xlabel_options nogrid notick labsize(`labsize')
local xtitle_options size(`labsize') margin(top)
local title_options size(`bigger_labsize') margin(bottom) color(black)
local manual_axis lwidth(thin) lcolor(black) lpattern(solid)
local plotregion plotregion(margin(sides) fcolor(white) lstyle(none) lcolor(white)) 
local graphregion graphregion(fcolor(white) lstyle(none) lcolor(white)) 
local T_line_options lwidth(thin) lcolor(gray) lpattern(dash)
// To show significance: hollow gray (gs7) will be insignificant from 0,
//  filled-in gray significant at 10%
//  filled-in black significant at 5%
local estimate_options_0  mcolor(gs7)   msymbol(Oh) msize(medlarge)
local estimate_options_90 mcolor(gs7)   msymbol(O)  msize(medlarge)
local estimate_options_95 mcolor(black) msymbol(O)  msize(medlarge)
local rcap_options_0  lcolor(gs7)   lwidth(thin)
local rcap_options_90 lcolor(gs7)   lwidth(thin)
local rcap_options_95 lcolor(black) lwidth(thin)


*									Public Lawyer							   *
********************************************************************************
********************************************************************************
********************************************************************************


matrix results = J(3, 4, .) // empty matrix for results
//  4 cols are: (1) var, (2) beta, (3) std error, (4) pvalue
local row = 1	
foreach varj of varlist pos_rec win_minley duration  {
	
	reg `varj' i.junta $bvc , r
	
	local df = e(df_r)

	matrix results[`row',1] = `row'
	// Beta 
	matrix results[`row',2] = _b[abogado_pub]
	// Standard error
	matrix results[`row',3] = _se[abogado_pub]
	// P-value
	matrix results[`row',4] = 2*ttail(`df', abs(_b[abogado_pub]/_se[abogado_pub]))
	
	local row = `row'+1
	}
	
	matrix colnames results = "k" "beta" "se" "p"
	matlist results
	
	preserve
	clear
	svmat results, names(col) 
	// Confidence intervals (95%)
	local alpha = .05 // for 95% confidence intervals
	gen rcap_lo = beta - invttail(`df',`=`alpha'/2')*se
	gen rcap_hi = beta + invttail(`df',`=`alpha'/2')*se
	gen zero=0
	

		// GRAPH
	#delimit ;
	graph twoway 
		(scatter beta k if p<0.05 & k!=3 ,  yaxis(1)         `estimate_options_95') 
		(scatter beta k if p>=0.05 & p<0.10 & k!=3 ,  yaxis(1) `estimate_options_90') 
		(scatter beta k if p>=0.10 & k!=3 ,  yaxis(1)          `estimate_options_0' ) 
		(rcap rcap_hi rcap_lo k if p<0.05 & k!=3 ,  yaxis(1)           `rcap_options_95')
		(rcap rcap_hi rcap_lo k if p>=0.05 & p<0.10 & k!=3 ,  yaxis(1) `rcap_options_90')
		(rcap rcap_hi rcap_lo k if p>=0.10 & k!=3 ,  yaxis(1)          `rcap_options_0' )		
		(scatter beta k if p<0.05 & k==3 ,  yaxis(2)         `estimate_options_95') 
		(scatter beta k if p>=0.05 & p<0.10 & k==3 ,  yaxis(2)  `estimate_options_90') 
		(scatter beta k if p>=0.10 & k==3 ,  yaxis(2)           `estimate_options_0' ) 
		(rcap rcap_hi rcap_lo k if p<0.05 & k==3 ,  yaxis(2)            `rcap_options_95')
		(rcap rcap_hi rcap_lo k if p>=0.05 & p<0.10 & k==3 ,  yaxis(2)  `rcap_options_90')
		(rcap rcap_hi rcap_lo k if p>=0.10 & k==3 ,  yaxis(2)           `rcap_options_0' )		
		(function y=0, range(1 2.5) yaxis(1) lcolor(black)) (function y=0, range(2.5 3) yaxis(2) lcolor(black))
		, 
		title(" ", `title_options')
		ylabel(, axis(1 2) `ylabel_options') 
		xlabel(1 "Positive recovery" 2 "Win/Entitlement" 3 "Duration", angle(vertical))
		xline(2.5, `T_line_options')
		xtitle("")
		xscale(range(`min_xaxis' `max_xaxis'))
		xscale(noline) /* because manual axis at 0 with yline above) */
		`plotregion' `graphregion'
		legend(off)  
	;
	
	#delimit cr
	graph export "$directorio\Figuras\betas_abogado_pub.pdf", replace
	restore	
	

*						Public-Private-Informal Lawyer						   *	
********************************************************************************
********************************************************************************
********************************************************************************



*									Size of Lawyer							   *	
********************************************************************************
********************************************************************************
********************************************************************************


matrix results = J(9, 4, .) // empty matrix for results
//  4 cols are: (1) var, (2) beta, (3) std error, (4) pvalue
local r = 1	
	
foreach varj of varlist pos_rec win_minley duration  {
	
	reg `varj' i.junta $bvc i.quintile_size, r
	
	local df = e(df_r)
	local rr = 2
	forvalues row =`r'/`=2+`r'' {
		matrix results[`row',1] = `row' + `r'
		// Beta 
		matrix results[`row',2] = _b[`rr'.quintile_size]
		// Standard error
		matrix results[`row',3] = _se[`rr'.quintile_size]
		// P-value
		matrix results[`row',4] = 2*ttail(`df', abs(_b[`rr'.quintile_size]/_se[`rr'.quintile_size]))
		local ++rr
		}
	local r = `r'+3
	}
	
	matrix colnames results = "k" "beta" "se" "p"
	matlist results
	
	preserve
	clear
	svmat results, names(col) 
	// Confidence intervals (95%)
	local alpha = .05 // for 95% confidence intervals
	gen rcap_lo = beta - invttail(`df',`=`alpha'/2')*se
	gen rcap_hi = beta + invttail(`df',`=`alpha'/2')*se

	

		// GRAPH
	#delimit ;
	graph twoway 
		(scatter beta k if p<0.05 & k<14 ,  yaxis(1) xaxis(1 2)        `estimate_options_95') 
		(scatter beta k if p>=0.05 & p<0.10 & k<14 ,  yaxis(1) `estimate_options_90') 
		(scatter beta k if p>=0.10 & k<14 ,  yaxis(1)          `estimate_options_0' ) 
		(rcap rcap_hi rcap_lo k if p<0.05 & k<14 ,  yaxis(1)           `rcap_options_95')
		(rcap rcap_hi rcap_lo k if p>=0.05 & p<0.10 & k<14 ,  yaxis(1) `rcap_options_90')
		(rcap rcap_hi rcap_lo k if p>=0.10 & k<14 ,  yaxis(1)          `rcap_options_0' )		
		(scatter beta k if p<0.05 & k>=14 ,  yaxis(2)         `estimate_options_95') 
		(scatter beta k if p>=0.05 & p<0.10 & k>=14 ,  yaxis(2)  `estimate_options_90') 
		(scatter beta k if p>=0.10 & k>=14 ,  yaxis(2)           `estimate_options_0' ) 
		(rcap rcap_hi rcap_lo k if p<0.05 & k>=14 ,  yaxis(2)            `rcap_options_95')
		(rcap rcap_hi rcap_lo k if p>=0.05 & p<0.10 & k>=14 ,  yaxis(2)  `rcap_options_90')
		(rcap rcap_hi rcap_lo k if p>=0.10 & k>=14 ,  yaxis(2)           `rcap_options_0' )		
		(function y=0, range(2 12) yaxis(1) lcolor(black)) (function y=0, range(12 16) yaxis(2) lcolor(black))
			, 
		title(" ", `title_options')
		ylabel(, `ylabel_options') 
		xlabel(3 "Positive recovery" 9 "Win/Entitlement" 15 "Duration", angle(vertical) axis(2))
		xlabel(2 "Small" 3 "Medium" 4 "Big", axis(1) angle(rvertical))
		yline(0, `manual_axis')
		xline(12, `T_line_options')
		xtitle("")
		xscale(range(`min_xaxis' `max_xaxis'))
		xscale(noline) /* because manual axis at 0 with yline above) */
		`plotregion' `graphregion'
		legend(off)  
	;
	
	#delimit cr
	graph export "$directorio\Figuras\betas_size.pdf", replace
	restore	
	
