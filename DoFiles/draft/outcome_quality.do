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
		- lawyer_scores_p3.dta
* Files created:  

* Purpose: 

*******************************************************************************/
*/

use "$directorio\DB\iniciales_dem.dta" , clear
merge m:1 junta exp anio using  "$directorio\DB\seguimiento_dem.dta", nogen
keep junta exp anio id_actor modo_termino_ofirec fecha_termino_ofirec cantidad_otorgada convenio_pagado_completo sueldo_estadistico periodicidad_sueldo_estadistic 
merge m:1 id_actor using "$directorio\DB\survey_data_2w.dta", nogen keepusing(id_actor cantidad_ganar_fixed)
rename cantidad_ganar_fixed cantidad_ganar_fixed_2w
merge m:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3) nogen
merge m:m junta exp anio using "$directorio\DB\lawyer_scores_p3.dta", nogen keep(3)

*-------------------------------------------------------------------------------

*Outliers
xtile perc_q = cantidad_otorgada, nq(100)
replace cantidad_otorgada = . if perc_q>=100

*End mode
gen settlement = (modo_termino==3) if !missing(modo_termino)
gen cr = (modo_termino==6) if !missing(modo_termino)
gen expiry_wd = (inlist(modo_termino,1,4)) if !missing(modo_termino)

*Duration
gen duration = fecha_termino_ofirec - fecha_alta if inlist(modo_termino,1,3,4,6)
replace duration = . if duration<0



eststo clear


eststo : reg settlement total , r 
qui su settlement if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg settlement total prediccion_a, r 
qui su settlement if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg cr total, r
qui su cr if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg cr total prediccion_b, r
qui su cr if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg expiry_wd total, r
qui su expiry_wd if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg duration total, r
qui su duration if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg cantidad_otorgada total, r
qui su cantidad_otorgada if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg cantidad_otorgada total monto, r 
qui su cantidad_otorgada if e(sample)
estadd scalar DepVarMean = `r(mean)'


eststo : reg settlement total if strpos(abogado,"laura")!=0, r 
qui su settlement if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg settlement total prediccion_a if strpos(abogado,"laura")!=0, r 
qui su settlement if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg cr total if strpos(abogado,"laura")!=0, r
qui su cr if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg cr total prediccion_b if strpos(abogado,"laura")!=0, r
qui su cr if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg expiry_wd total if strpos(abogado,"laura")!=0, r
qui su expiry_wd if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg duration total if strpos(abogado,"laura")!=0, r
qui su duration if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg cantidad_otorgada total if strpos(abogado,"laura")!=0, r
qui su cantidad_otorgada if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg cantidad_otorgada total monto if strpos(abogado,"laura")!=0, r 
qui su cantidad_otorgada if e(sample)
estadd scalar DepVarMean = `r(mean)'

esttab using "$directorio/Tables/reg_results/outcome_quality.csv", se r2 ${star} b(a2) label ///
	scalars("DepVarMean DepVarMean") replace 

eststo clear


eststo : reg total i.main_treatment ${controls}, robust cluster(fecha_alta)
qui su total if e(sample)
estadd scalar DepVarMean = `r(mean)'
qui test 2.main_treatment = 3.main_treatment
estadd scalar test_23 = `r(p)'	

eststo : reg total i.main_treatment ${controls} if strpos(abogado,"laura")!=0, robust cluster(fecha_alta)
qui su total if e(sample)
estadd scalar DepVarMean = `r(mean)'
qui test 2.main_treatment = 3.main_treatment
estadd scalar test_23 = `r(p)'	

eststo : reg settlement i.main_treatment ${controls}, robust cluster(fecha_alta)
qui su settlement if e(sample)
estadd scalar DepVarMean = `r(mean)'
qui test 2.main_treatment = 3.main_treatment
estadd scalar test_23 = `r(p)'	

eststo : reg cr i.main_treatment ${controls}, robust cluster(fecha_alta)
qui su settlement if e(sample)
estadd scalar DepVarMean = `r(mean)'
qui test 2.main_treatment = 3.main_treatment
estadd scalar test_23 = `r(p)'	

eststo : reg duration i.main_treatment ${controls}, robust cluster(fecha_alta)
qui su duration if e(sample)
estadd scalar DepVarMean = `r(mean)'
qui test 2.main_treatment = 3.main_treatment
estadd scalar test_23 = `r(p)'	

eststo : reg cantidad_otorgada i.main_treatment ${controls}, robust cluster(fecha_alta)
qui su cantidad_otorgada if e(sample)
estadd scalar DepVarMean = `r(mean)'
qui test 2.main_treatment = 3.main_treatment
estadd scalar test_23 = `r(p)'	


esttab using "$directorio/Tables/reg_results/te_outcome_ofirec.csv", se r2 ${star} b(a2) label ///
	scalars("DepVarMean DepVarMean"  "test_23 T2 = T3") replace 


