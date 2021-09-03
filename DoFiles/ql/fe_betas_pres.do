
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

bysort gp_office : gen num_casefiles=_N
drop if num_casefiles<=4
sort gp_office
egen id=group(gp_office)
*FE Office	
xi i.id, noomit


	
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

	
foreach varj of varlist pos_rec duration win_minley {
	*wrt procu
	qui reg `varj' $input_varlist $sd_input_varlist $bvc _Iid_1-_Iid_`=${lista1}-1' _Iid_`=${lista1}+1'-_Iid_138 if _Iid_60!=1 & _Iid_138!=1, r
	
	local df = e(df_r)


matrix results = J(138, 4, .) // empty matrix for results
//  4 cols are: (1) office, (2) beta, (3) std error, (4) pvalue
forval row = 1/138 {
	matrix results[`row',1] = `row'
	*Omited office
	if `row'!=$lista1 { 
	// Beta 
	matrix results[`row',2] = _b[_Iid_`row']
	// Standard error
	matrix results[`row',3] = _se[_Iid_`row']
	// P-value
	matrix results[`row',4] = 2*ttail(`df', abs(_b[_Iid_`row']/_se[_Iid_`row']))
		}
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

	replace beta=0 if missing(beta)
	sort beta 
	gen orden=_n
	qui su orden if k==$lista1
	local procu=`r(mean)'

		// GRAPH
	#delimit ;
	graph twoway 
		(scatter beta orden if p<0.05,           `estimate_options_95') 
		(scatter beta orden if p>=0.05 & p<0.10, `estimate_options_90') 
		(scatter beta orden if p>=0.10,          `estimate_options_0' ) 
		(rcap rcap_hi rcap_lo orden if p<0.05,           `rcap_options_95')
		(rcap rcap_hi rcap_lo orden if p>=0.05 & p<0.10, `rcap_options_90')
		(rcap rcap_hi rcap_lo orden if p>=0.10,          `rcap_options_0' )		
		, 
		title(" ", `title_options')
		ylabel(, `ylabel_options') 
		yline(0, `manual_axis')
		xtitle("Office", `xtitle_options')
		xscale(range(`min_xaxis' `max_xaxis'))
		xline(`procu', `T_line_options')
		xscale(noline) /* because manual axis at 0 with yline above) */
		`plotregion' `graphregion'
		legend(off)  
	;
	
	#delimit cr
	graph export "$directorio\Figuras\betas_`varj'.pdf", replace
	restore
	}
