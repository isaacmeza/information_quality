********************************************************************************

use "$directorio\DB\checklist_db.dta", clear
merge 1:m junta exp anio using "$directorio\DB\lawyer_dataset.dta", keep(1 3) nogen

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

	
*****************************************
* 				  REGRESSION            *
*****************************************
	

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
	
foreach varj of varlist $output_varlist c_obj c_sub  {
	eststo : reg `varj' $varlist_checklist $bvc, r
	estadd scalar Erre=e(r2)
	qui su `varj' if e(sample)
	estadd scalar DepVarMean=r(mean)
	estadd scalar F_stat=e(F)
	*wrt procu
	eststo : reg `varj' $varlist_checklist $bvc ///
		_Iid_${lista2} ///
		_Iid_${lista3} ///
		_Iid_${lista4} ///
		_Iid_${lista5} ///
		_Iid_${lista6} ///
		_Iid_${lista7} ///
		_Iid_${lista8} ///
		_Iid_${lista9} ///
		_Iid_${lista10}, r
	estadd scalar Erre=e(r2)
	qui su `varj' if e(sample)
	estadd scalar DepVarMean=r(mean)
	estadd scalar F_stat=e(F)
	*offices F-test
	testparm _Iid_${lista2} ///
		_Iid_${lista3} ///
		_Iid_${lista4} ///
		_Iid_${lista5} ///
		_Iid_${lista6} ///
		_Iid_${lista7} ///
		_Iid_${lista8} ///
		_Iid_${lista9} ///
		_Iid_${lista10}
	estadd scalar p_office=r(p)
	
	
	local df = e(df_r)


matrix results = J(9, 4, .) // empty matrix for results
//  4 cols are: (1) office, (2) beta, (3) std error, (4) pvalue
local row=1
foreach of in ${lista2} ${lista3} ${lista4} ${lista5} ${lista6} ///
	${lista7} ${lista8} ${lista9} ${lista10}  {
	matrix results[`row',1] = `of'
	// Beta 
	matrix results[`row',2] = _b[_Iid_`of']
	// Standard error
	matrix results[`row',3] = _se[_Iid_`of']
	// P-value
	matrix results[`row',4] = 2*ttail(`df', abs(_b[_Iid_`of']/_se[_Iid_`of']))
	local ++row
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


		// GRAPH
	#delimit ;
	graph twoway 
		(scatter beta orden if p<0.05,           `estimate_options_95') 
		(scatter beta orden if p>=0.05 & p<0.10, `estimate_options_90') 
		(scatter beta orden if p>=0.10,          `estimate_options_0' ) 
		(rcap rcap_hi rcap_lo orden if p<0.05,           `rcap_options_95')
		(rcap rcap_hi rcap_lo orden if p>=0.05 & p<0.10, `rcap_options_90')
		(rcap rcap_hi rcap_lo orden if p>=0.10,          `rcap_options_0' )
		(scatter beta orden if k==$lista2, color(yellow) msymbol(circle)) 
		(rcap rcap_hi rcap_lo orden if k==$lista2, color(yellow) lwidth(thin))
		(scatter beta orden if k==$lista3, color(dkgreen) msymbol(circle)) 
		(rcap rcap_hi rcap_lo orden if k==$lista3, color(d) lwidth(thin))
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
		xscale(noline) /* because manual axis at 0 with yline above) */
		`plotregion' `graphregion'
		legend(order(7 "$lista1" 9 "$lista2" 11 "$lista3" 13 "$lista4" 15 "$lista5" 
				17 "$lista6" 19 "$lista7" 21 "$lista8" 23 "$lista9" 25 "$lista10") rows(2))  
	;
	
	#delimit cr
	graph export "$directorio\Figuras\betas_fe_checklist_`varj'.pdf", replace
	restore
	}




**********
esttab using "$directorio/Tables/reg_results/reg_panel_checklist.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
scalars("Erre R-squared"  "DepVarMean DepVarMean"  "F_stat F_stat" "p_office p_office") replace 
 

 
********************************************************************************
use "$directorio\DB\checklist_db.dta", clear

 
*****************************************
* 				    PCA                 *
*****************************************
duplicates drop junta exp anio, force 
 
*PCA 	
factor $varlist_checklist c_obj c_sub , pcf		

*Cronbach’s alpha
alpha $varlist_checklist

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
 
*Factor loadings
qui putexcel B5= matrix(e(L))  using "$directorio/Tables/factor_loadings.xlsx", ///
		sheet("factor") modify	
 
 
********************************************************************************

 
*****************************************
* 				   CLUSTER              *
***************************************** 
 


cap drop g3
*Initialization of group centers (we take the 1st factor median/terciles to cluster around)
cap drop ini_g3
xtile ini_g3=f1, nq(3)
cluster k f*, k(3) name(g3)  mea(abs) start(group(ini_g3))

twoway (scatter f1 f2  if g3==1,  mlabpos(0) msymbol(circle)  color(cranberry)) ///
		(scatter f1 f2  if g3==2,  mlabpos(0) msymbol(square) color(ltblue)) ///
		(scatter f1 f2  if g3==3,  mlabpos(0) msymbol(triangle) color(green)),  ///						
						 scheme(s2mono) ///
			graphregion(color(white)) legend(off) name(m1, replace)
		
twoway (scatter f1 f3  if g3==1,  mlabpos(0) msymbol(circle) color(cranberry)) ///
		(scatter f1 f3  if g3==2,  mlabpos(0) msymbol(square) color(ltblue)) ///
		(scatter f1 f3  if g3==3,  mlabpos(0) msymbol(triangle) color(green)),  ///						
						 scheme(s2mono) ///
			graphregion(color(white)) legend(off) name(m2, replace)
		
twoway (scatter f1 f4  if g3==1,  mlabpos(0) msymbol(circle) color(cranberry)) ///
		(scatter f1 f4  if g3==2,  mlabpos(0) msymbol(square) color(ltblue)) ///
		(scatter f1 f4  if g3==3,  mlabpos(0) msymbol(triangle) color(green)),  ///						
						 scheme(s2mono) ///
			graphregion(color(white)) legend(off) name(m3, replace)
		
twoway (scatter f2 f3  if g3==1,  mlabpos(0) msymbol(circle) color(cranberry)) ///
		(scatter f2 f3  if g3==2,  mlabpos(0) msymbol(square) color(ltblue)) ///
		(scatter f2 f3  if g3==3,  mlabpos(0) msymbol(triangle) color(green)),  ///						
						 scheme(s2mono) ///
			graphregion(color(white)) legend(off) name(m4, replace)
		
twoway (scatter f2 f4  if g3==1,  mlabpos(0) msymbol(circle) color(cranberry)) ///
		(scatter f2 f4  if g3==2,  mlabpos(0) msymbol(square) color(ltblue)) ///
		(scatter f2 f4  if g3==3,  mlabpos(0) msymbol(triangle) color(green)) ,  ///						
						 scheme(s2mono) ///
			graphregion(color(white)) legend(off) name(m5, replace)
		
twoway (scatter f3 f4  if g3==1,  mlabpos(0) msymbol(circle) color(cranberry)) ///
		(scatter f3 f4  if g3==2,  mlabpos(0) msymbol(square) color(ltblue)) ///
		(scatter f3 f4  if g3==3,  mlabpos(0) msymbol(triangle) color(green)) ,  ///						
						 scheme(s2mono) ///
			graphregion(color(white)) legend(off) name(m6, replace)
		
	
	
graph combine m1 m2 m3 m4 m5 m6	, name(tres, replace) scheme(s2mono) graphregion(color(white))
graph export "$directorio\Figuras\cluster_3_checklist.pdf", replace

****************


cap drop g2
cap drop ini_g2
xtile ini_g2=f1, nq(2)
cluster k f*, k(2) name(g2)  mea(abs) start(group(ini_g2))



twoway (scatter f1 f2  if g2==1,  mlabpos(0) msymbol(circle) color(cranberry)) ///
		(scatter f1 f2  if g2==2,  mlabpos(0) msymbol(square) color(ltblue)),  ///							
		 scheme(s2mono) graphregion(color(white)) legend(off) name(m1, replace)
		
twoway (scatter f1 f3  if g2==1,  mlabpos(0) color(cranberry)) ///
		(scatter f1 f3  if g2==2,  mlabpos(0) color(ltblue)) ,  ///					
		 scheme(s2mono) graphregion(color(white)) legend(off) name(m2, replace)
		
twoway (scatter f1 f4  if g2==1,  mlabpos(0) color(cranberry)) ///
		(scatter f1 f4  if g2==2,  mlabpos(0) color(ltblue)) ,  ///								
		 scheme(s2mono) graphregion(color(white)) legend(off) name(m3, replace)
		
twoway (scatter f2 f3  if g2==1,  mlabpos(0) color(cranberry)) ///
		(scatter f2 f3  if g2==2,  mlabpos(0) color(ltblue)),  ///										
		 scheme(s2mono) graphregion(color(white)) legend(off) name(m4, replace)
		
twoway (scatter f2 f4  if g2==1,  mlabpos(0) color(cranberry)) ///
		(scatter f2 f4  if g2==2,  mlabpos(0) color(ltblue)) ,  ///										
		 scheme(s2mono) graphregion(color(white)) legend(off) name(m5, replace)
		
twoway (scatter f3 f4  if g2==1,  mlabpos(0) color(cranberry)) ///
		(scatter f3 f4  if g2==2,  mlabpos(0) color(ltblue)) ,  ///										
		 scheme(s2mono) graphregion(color(white)) legend(off) name(m6, replace)
		
	
	
graph combine m1 m2 m3 m4 m5 m6, name(dos, replace) scheme(s2mono) graphregion(color(white))
graph export "$directorio\Figuras\cluster_2_checklist.pdf", replace
 

*Grade vs Factor 
lpoly c_obj f1, msymbol( Oh ) scheme(s2mono) graphregion(color(white)) ///
	ytitle("Objective grade") xtitle("Factor 1") note("")
graph export "$directorio\Figuras\scatter_obj_f1.pdf", replace   

 
lpoly c_sub f1, msymbol( Oh ) scheme(s2mono) graphregion(color(white)) ///
	ytitle("Subjective grade") xtitle("Factor 1") note("")
graph export "$directorio\Figuras\scatter_sub_f1.pdf", replace   
