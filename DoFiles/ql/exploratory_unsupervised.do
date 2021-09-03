
use "$directorio\DB\lawyer_dataset_collapsed.dta", clear


*Variable name cleaning
foreach var of varlist mean_perc* {
	local nvar=substr("`var'",11,.)
	rename `var' `nvar'
	}

foreach var of varlist sd_perc* {
	local nvar=substr("`var'",9,.)
	rename `var' sd_`nvar'
	}

foreach var of varlist mean_ratio* {
	local nvar=substr("`var'",12,.)
	rename `var' `nvar'
	}
	
foreach var of varlist sd_ratio* {
	local nvar=substr("`var'",10,.)
	rename `var' sd_`nvar'
	}

foreach var of varlist mean_* {
	local nvar=substr("`var'",6,.)
	rename `var' `nvar'
	}
	
foreach var of varlist sd_* {
	local nvar=substr("`var'",4,.)
	rename `var' sd_`nvar'
	}	
	

********************************************************************************
	

*****************************************
* 				    PCA                 *
*****************************************

*Variables to include in PCA
local input_varlist rel_procu rel_ent dw_scian dw_giro_procu indem  prima_antig ///
	    hextra sarimssinf   ///
	codem reinst
local output_varlist pos_rec settlement cr win_asked  ///
	win_minley win_cprocu duration


*Exclusion SD from varlist
*(we exclude all benefits for the sd)
local exclude= "indem sal_caidos prima_antig prima_vac hextra prima_dom desc_sem desc_ob sarimssinf utilidades nulidad codem reinst"

local sd_varlist = " "
foreach var of varlist `input_varlist' `output_varlist' {
	*Exclude from varlist SD, those in `exclude'
	if strpos("`exclude'", "`var'")==0	{
		local sd_varlist = "`sd_varlist' sd_`var'"
		}
	}	

	
*Label variables 
	
	
*PCA 	
factor `input_varlist' `output_varlist' `sd_varlist', pcf		

*Cronbach’s alpha
alpha `input_varlist' `output_varlist' `sd_varlist'

*Screeplot
screeplot, yline(1)

*Factors to retain
local fc = " "
forvalues i=1/`e(f)' {
	local fc = "`fc' f`i'"
	}
predict `fc'

*Loadingplot
graph matrix f*
loadingplot, fac(4) combined
 
********************************************************************************

 
*****************************************
* 				   CLUSTER              *
***************************************** 
 
 
*Exploratory cluster analysis. This will assess the number of lcuster we will take 
	*Hierarchical clustering
cluster completelinkage f*, name(L2clnk)
	*Dendogram 
cluster dendrogram L2clnk,  xlabel(,angle(90) labsize(*.75)) cutnumber(10) ///
	scheme(s2mono) graphregion(color(white))



cap drop g3
*Initialization of group centers (we take the 1st factor median/terciles to cluster around)
cap drop ini_g3
xtile ini_g3=f1, nq(3)
cluster k f*, k(3) name(g3)  mea(abs) start(group(ini_g3))

twoway (scatter f1 f2  if g3==1,  mlabpos(0) msymbol(circle)  color(cranberry)) ///
		(scatter f1 f2  if g3==2,  mlabpos(0) msymbol(square) color(ltblue)) ///
		(scatter f1 f2  if g3==3,  mlabpos(0) msymbol(triangle) color(green)) ///
		(scatter f1 f2  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///
						, scheme(s2mono) ///
			graphregion(color(white)) legend(off) name(m1, replace)
		
twoway (scatter f1 f3  if g3==1,  mlabpos(0) msymbol(circle) color(cranberry)) ///
		(scatter f1 f3  if g3==2,  mlabpos(0) msymbol(square) color(ltblue)) ///
		(scatter f1 f3  if g3==3,  mlabpos(0) msymbol(triangle) color(green)) ///
		(scatter f1 f3  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///
						, scheme(s2mono) ///
			graphregion(color(white)) legend(off) name(m2, replace)
		
twoway (scatter f1 f4  if g3==1,  mlabpos(0) msymbol(circle) color(cranberry)) ///
		(scatter f1 f4  if g3==2,  mlabpos(0) msymbol(square) color(ltblue)) ///
		(scatter f1 f4  if g3==3,  mlabpos(0) msymbol(triangle) color(green)) ///
		(scatter f1 f4  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///
						, scheme(s2mono) ///
			graphregion(color(white)) legend(off) name(m3, replace)
		
twoway (scatter f2 f3  if g3==1,  mlabpos(0) msymbol(circle) color(cranberry)) ///
		(scatter f2 f3  if g3==2,  mlabpos(0) msymbol(square) color(ltblue)) ///
		(scatter f2 f3  if g3==3,  mlabpos(0) msymbol(triangle) color(green)) ///
		(scatter f2 f3  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///
						, scheme(s2mono) ///
			graphregion(color(white)) legend(off) name(m4, replace)
		
twoway (scatter f2 f4  if g3==1,  mlabpos(0) msymbol(circle) color(cranberry)) ///
		(scatter f2 f4  if g3==2,  mlabpos(0) msymbol(square) color(ltblue)) ///
		(scatter f2 f4  if g3==3,  mlabpos(0) msymbol(triangle) color(green)) ///
		(scatter f2 f4  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///
						, scheme(s2mono) ///
			graphregion(color(white)) legend(off) name(m5, replace)
		
twoway (scatter f3 f4  if g3==1,  mlabpos(0) msymbol(circle) color(cranberry)) ///
		(scatter f3 f4  if g3==2,  mlabpos(0) msymbol(square) color(ltblue)) ///
		(scatter f3 f4  if g3==3,  mlabpos(0) msymbol(triangle) color(green)) ///
		(scatter f3 f4  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///
						, scheme(s2mono) ///
			graphregion(color(white)) legend(off) name(m6, replace)
		
	
	
graph combine m1 m2 m3 m4 m5 m6	, name(tres, replace) scheme(s2mono) graphregion(color(white))
graph export "$directorio\Figuras\cluster_3.pdf", replace


****************


cap drop g2
cap drop ini_g2
xtile ini_g2=f1, nq(2)
cluster k f*, k(2) name(g2)  mea(abs) start(group(ini_g2))



twoway (scatter f1 f2  if g2==1,  mlabpos(0) msymbol(circle) color(cranberry)) ///
		(scatter f1 f2  if g2==2,  mlabpos(0) msymbol(square) color(ltblue)) ///
		(scatter f1 f2  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///			
		, scheme(s2mono) graphregion(color(white)) legend(off) name(m1, replace)
		
twoway (scatter f1 f3  if g2==1,  mlabpos(0) color(cranberry)) ///
		(scatter f1 f3  if g2==2,  mlabpos(0) color(ltblue)) ///
		(scatter f1 f3  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///	
		, scheme(s2mono) graphregion(color(white)) legend(off) name(m2, replace)
		
twoway (scatter f1 f4  if g2==1,  mlabpos(0) color(cranberry)) ///
		(scatter f1 f4  if g2==2,  mlabpos(0) color(ltblue)) ///
		(scatter f1 f4  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///				
		, scheme(s2mono) graphregion(color(white)) legend(off) name(m3, replace)
		
twoway (scatter f2 f3  if g2==1,  mlabpos(0) color(cranberry)) ///
		(scatter f2 f3  if g2==2,  mlabpos(0) color(ltblue)) ///
		(scatter f2 f3  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///				
		, scheme(s2mono) graphregion(color(white)) legend(off) name(m4, replace)
		
twoway (scatter f2 f4  if g2==1,  mlabpos(0) color(cranberry)) ///
		(scatter f2 f4  if g2==2,  mlabpos(0) color(ltblue)) ///
		(scatter f2 f4  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///				
		, scheme(s2mono) graphregion(color(white)) legend(off) name(m5, replace)
		
twoway (scatter f3 f4  if g2==1,  mlabpos(0) color(cranberry)) ///
		(scatter f3 f4  if g2==2,  mlabpos(0) color(ltblue)) ///
		(scatter f3 f4  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///				
		, scheme(s2mono) graphregion(color(white)) legend(off) name(m6, replace)
		
	
	
graph combine m1 m2 m3 m4 m5 m6, name(dos, replace) scheme(s2mono) graphregion(color(white))
graph export "$directorio\Figuras\cluster_2.pdf", replace

*Correlation between clustering
tab g2 g3


 
********************************************************************************

 
*****************************************
* 				  REGRESSION            *
*****************************************

eststo clear

foreach varj of varlist $output_varlist $sd_varlist_output {
	eststo : reg `varj' $input_varlist $sd_varlist_input , r
	estadd scalar Erre=e(r2)
	qui su `varj' if e(sample)
	estadd scalar DepVarMean=r(mean)
	estadd scalar F_stat=e(F)

	}
	
gen bueno=(g2==1) if !missing(g2)

eststo : reg bueno $input_varlist $sd_varlist_input , r
estadd scalar Erre=e(r2)
qui su bueno if e(sample)
estadd scalar DepVarMean=r(mean)
estadd scalar F_stat=e(F)


**********
esttab using "$directorio/Tables/reg_results/reg_output_input.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
scalars("Erre R-squared"  "DepVarMean DepVarMean"  "F_stat F_stat") replace 
 
 

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


eststo clear		
	
foreach varj of varlist $output_varlist $sd_output_varlist  {
	eststo : reg `varj' $input_varlist $sd_input_varlist $bvc, r
	estadd scalar Erre=e(r2)
	qui su `varj' if e(sample)
	estadd scalar DepVarMean=r(mean)
	estadd scalar F_stat=e(F)
	*wrt procu
	eststo : reg `varj' $input_varlist $sd_input_varlist $bvc _Iid_1-_Iid_`=${lista1}-1' _Iid_`=${lista1}+1'-_Iid_138, r
	estadd scalar Erre=e(r2)
	qui su `varj' if e(sample)
	estadd scalar DepVarMean=r(mean)
	estadd scalar F_stat=e(F)
	*offices F-test
	testparm _Iid_1-_Iid_`=${lista1}-1' _Iid_`=${lista1}+1'-_Iid_138
	estadd scalar p_office=r(p)
	
	
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
		(scatter beta orden if k==$lista1, color(blue) msymbol(circle)) 
		(rcap rcap_hi rcap_lo orden if k==$lista1, color(blue) lwidth(thin))
		(scatter beta orden if k==$lista2, color(yellow) msymbol(circle)) 
		(rcap rcap_hi rcap_lo orden if k==$lista2, color(yellow) lwidth(thin))
		(scatter beta orden if k==$lista3, color(dkgreen) msymbol(circle)) 
		(rcap rcap_hi rcap_lo orden if k==$lista3, color(dkgreen) lwidth(thin))
		(scatter beta orden if k==$lista4, color(purple) msymbol(circle)) 
		(rcap rcap_hi rcap_lo orden if k==$lista4, color(purple) lwidth(thin))
		(scatter beta orden if k==$lista5, color(red) msymbol(circle)) 
		(rcap rcap_hi rcap_lo orden if k==$lista5, color(red) lwidth(thin))
		(scatter beta orden if k==$lista6, color(ltblue) msymbol(square)) 
		(rcap rcap_hi rcap_lo orden if k==$lista6, color(ltblue) lwidth(thin))
		(scatter beta orden if k==$lista7, color(orange) msymbol(square)) 
		(rcap rcap_hi rcap_lo orden if k==$lista7, color(orange) lwidth(thin))
		(scatter beta orden if k==$lista8, color(green) msymbol(square)) 
		(rcap rcap_hi rcap_lo orden if k==$lista8, color(green) lwidth(thin))
		(scatter beta orden if k==$lista9, color(navy) msymbol(square)) 
		(rcap rcap_hi rcap_lo orden if k==$lista9, color(navy) lwidth(thin))
		(scatter beta orden if k==$lista10, color(cranberry) msymbol(square)) 
		(rcap rcap_hi rcap_lo orden if k==$lista10, color(cranberry) lwidth(thin))		
		, 
		title(" ", `title_options')
		ylabel(, `ylabel_options') 
		yline(0, `manual_axis')
		xtitle("Office", `xtitle_options')
		xscale(range(`min_xaxis' `max_xaxis'))
		xline(`procu', `T_line_options')
		xscale(noline) /* because manual axis at 0 with yline above) */
		`plotregion' `graphregion'
		legend(order(7 "$lista1" 9 "$lista2" 11 "$lista3" 13 "$lista4" 15 "$lista5" 
				17 "$lista6" 19 "$lista7" 21 "$lista8" 23 "$lista9" 25 "$lista10") rows(2))  
	;
	
	#delimit cr
	graph export "$directorio\Figuras\betas_fe_`varj'.pdf", replace
	restore
	}




**********
esttab using "$directorio/Tables/reg_results/reg_output_input_panel.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
scalars("Erre R-squared"  "DepVarMean DepVarMean"  "F_stat F_stat" "p_office p_office") replace 
 
