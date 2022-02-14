/*
********************
version 17.0
********************
 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	January. 25, 2021
* Last date of modification:   
* Modifications:		
* Files used:     
		- lawyer_scores_p3.dta
* Files created:  

* Purpose: Analysis of lawyer scores. 

*******************************************************************************/
*/

use "$directorio\DB\lawyer_scores_p3.dta", clear
encode abogado, gen(abogado_id)
egen id_casefile = group(junta exp anio)

*******************************************************************************/
*Histogram of scores 
*******************************************************************************/
foreach var of varlist total calif* {
	hist `var', discrete percent scheme(s2mono) graphregion(color(white)) xtitle("Score")
	graph export "$directorio\Figuras\hist_`var'.pdf", replace
}

*******************************************************************************/
*Correlation scores
*******************************************************************************/
pwcorr total calif*, star(0.05) sig
putexcel set "$directorio\Tables\scores_cor.xlsx", sheet("scores_cor") modify
putexcel C4 =  matrix(r(C)), names
putexcel K4 =  matrix(r(sig)), names

*******************************************************************************/
*Boxplot of grades from different lawyers
*******************************************************************************/
foreach var of varlist total calif* {
	graph hbox `var' , over(abogado_id, nolabel)  nooutsides medtype(marker) medmarker(msize(small)) ytitle("Score") graphregion(color(white)) note("")
	graph export "$directorio\Figuras\boxplot_`var'.pdf", replace
}

*******************************************************************************/
*ICC
*******************************************************************************/
duplicates tag id_case abogado_id, gen(tg)
bysort id_casefile abogado_id : gen l1 = (_n==1) if tg==1

*Laura's consistency
icc total id_casefile l1, mixed absolute

collapse total calif*, by(id_casefile abogado_id)

foreach var in total calif_rubro_proemio calif_prestaciones calif_hechos calif_derechos calif_puntos_petitorios {
	matrix icc_i = J(14, 14, .)
	matrix icc_a = J(14, 14, .)
	forvalues j = 1/13 {
		forvalues i = `=`j'+1'/14 {
			cap icc `var' id_casefile abogado_id if inlist(abogado_id, `j',`i'), mixed absolute
			if _rc == 0 {
			matrix icc_i[`i',`j'] = r(icc_i)
			matrix icc_a[`i',`j'] = r(icc_avg)
			}
		}
	}
	putexcel set "$directorio\Tables\scores_cor.xlsx", sheet("`var'_cor") modify
	putexcel V23 = matrix(icc_i)
	putexcel V44 = matrix(icc_a)	
}	

*******************************************************************************/
*Bland-Altman
*******************************************************************************/
sort id_casefile abogado_id
*Identify cases with 4 ratings and keep only Laura's as third rating 
by id_casefile : gen flag = (_N==4)
by id_casefile : drop if flag==1 & _n==1

*Reshape
by id_casefile : gen i = _n
*Keep rater 3 ONLY as Laura
drop if i==3 & abogado_id!=14
drop abogado_id flag
reshape wide total calif*, i(id_casefile) j(i)

*Correlation
foreach var in total calif_rubro_proemio calif_prestaciones calif_hechos calif_derechos calif_puntos_petitorios {
	pwcorr `var'*, sig star(0.05)
	putexcel set "$directorio\Tables\scores_cor.xlsx", sheet("`var'_cor") modify
	putexcel C4 =  matrix(r(C)), names
}

gen nrow = _n
*Bland-Altman plots
foreach var in total calif_rubro_proemio calif_prestaciones calif_hechos calif_derechos calif_puntos_petitorios {
	
		*Difference
	cap drop dif_12 dif_13 dif_23
	gen dif_12 = `var'1-`var'2
	gen dif_13 = `var'1-`var'3
	gen dif_23 = `var'2-`var'3
		*Mean
	cap drop mn_12 mn_13 mn_23
	gen mn_12 = (`var'1+`var'2)/2	
	gen mn_13 = (`var'1+`var'3)/2	
	gen mn_23 = (`var'2+`var'3)/2	

		
	foreach comb in 12 13 23 {

		*Aux to graph
		preserve
		cap drop dif_`comb'r
		gen dif_`comb'r = dif_`comb'
		collapse (percent) dif_`comb'p = dif_`comb', by(dif_`comb'r)
		gen nrow = _n
		tempfile temp
		save `temp'
		restore
		merge 1:1 nrow using `temp', nogen

		su dif_`comb'
		local hi = `r(mean)'+1.96*`r(sd)'
		local lo = `r(mean)'-1.96*`r(sd)'


		twoway (bar dif_`comb'p dif_`comb'r, color(navy%40) xaxis(2) horizontal  yline(`r(mean)', lpattern(solid)) xtitle("Percent", axis(2))) ///
				(scatter dif_`comb' mn_`comb', color(black%95) xaxis(1) msymbol(Oh) yline(`r(mean)', lpattern(solid)) yline(`hi' `lo', lpattern(dot) lcolor(black)) lwidth(thick) xtitle("Mean scores") ytitle("Difference in scores")) ///
				, scheme(s2mono) graphregion(color(white)) legend(off)
		graph export "$directorio\Figuras\bland_altman_`var'_`comb'.pdf", replace

	}

}