/*
********************
version 17.0
********************
 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	November. 17, 2021
* Last date of modification:   
* Modifications:		
* Files used:     
		- iniciales_dem.dta
		- seguimiento_dem.dta
		- survey_data_2w.dta
		- treatment_data.dta
* Files created:  

* Purpose: 

*******************************************************************************/
*/

use "$directorio\DB\iniciales_dem.dta" , clear
merge m:1 junta exp anio using  "$directorio\DB\seguimiento_dem.dta", nogen
keep id_actor cantidad1 cantidad_ofirec cantidad_inegi cantidad_otorgada cantidad_pagada sueldo_base periodicidad_sueldo_base sueldo_estadistico periodicidad_sueldo_estadistic 
merge m:1 id_actor using "$directorio\DB\survey_data_2w.dta", nogen keepusing(id_actor cantidad_ganar_fixed)
rename cantidad_ganar_fixed cantidad_ganar_fixed_2w
merge m:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3) nogen

*-------------------------------------------------------------------------------

*Daily wage (lawsuit)
gen sueldo_estadistico_diario = sueldo_estadistico if periodicidad_sueldo_estadistic==0
replace sueldo_estadistico_diario = sueldo_estadistico/30 if periodicidad_sueldo_estadistic==1
replace sueldo_estadistico_diario = sueldo_estadistico/15 if periodicidad_sueldo_estadistic==2
replace sueldo_estadistico_diario = sueldo_estadistico/7 if periodicidad_sueldo_estadistic==3

*Inflation of wage (lawsuit - survey)
gen inflate = sueldo_estadistico_diario - salario_diario
gen inflate_prop = inflate/salario_diario * 100
cap drop out
bacon inflate_prop, gen(out) percentile(10)
replace inflate_prop = . if out==1

su inflate_prop, d
hist inflate_prop , percent color(navy%80) xtitle("% inflation") xlabel(-100(100)600) xline(`r(mean)', lcolor(green) lwidth(thick)) xline(`r(p50)', lcolor(red) lwidth(thick))  scheme(s2mono) graphregion(color(white)) 
graph export "C:\Users\isaac\Dropbox\Apps\ShareLaTeX\Response to Editor ReStud\Figures\inflation_wage.pdf", replace
*-------------------------------------------------------------------------------

*Entitlement vs expectation
gen ent_exp = cantidad_ganar_fixed_2w - c_min_total 
gen ent_exp_p = ent_exp/c_min_total*100 if c_min_total!=0
cap drop out
bacon ent_exp_p, gen(out) percentile(5)

twoway (hist ent_exp_p if out!=1, percent color(navy%70)), scheme(s2mono) graphregion(color(white)) xtitle("% of entitlement") 
graph export "C:\Users\isaac\Dropbox\Apps\ShareLaTeX\Response to Editor ReStud\Figures\ent_exp.pdf", replace


*Min entitlement (90 days daily wage) 
su inflate_prop
gen ent_exp_min = cantidad_ganar_fixed_2w - c_min_indem
gen ent_exp_min_p = ent_exp_min/c_min_indem*100 if c_min_indem!=0
cap drop out
bacon ent_exp_min_p, gen(out) percentile(5)

twoway (hist ent_exp_min_p if out!=1, percent color(navy%70)), scheme(s2mono) graphregion(color(white)) xtitle("% of entitlement") 
graph export "C:\Users\isaac\Dropbox\Apps\ShareLaTeX\Response to Editor ReStud\Figures\min_ent_exp.pdf", replace
*-------------------------------------------------------------------------------

*Ruling vs expectation
gen ruling_exp = cantidad_ganar_fixed_2w - cantidad_otorgada
gen ruling_exp_p = ruling_exp/cantidad_otorgada*100 if cantidad_otorgada!=0
cap drop out
bacon ent_exp_p, gen(out) percentile(5)

twoway (hist ruling_exp_p if out!=1, percent width(50) color(navy%70)), scheme(s2mono) graphregion(color(white)) xtitle("% of Court Ruling") 
graph export "C:\Users\isaac\Dropbox\Apps\ShareLaTeX\Response to Editor ReStud\Figures\ruling_exp.pdf", replace
*-------------------------------------------------------------------------------


