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
		- survey_data_2m.dta
		- treatment_data.dta
		- lawyer_scores_p3.dta
* Files created:  

* Purpose: 

*******************************************************************************/
*/

use "$directorio\DB\iniciales_dem.dta" , clear
merge m:1 junta exp anio using  "$directorio\DB\seguimiento_dem.dta", nogen
keep junta exp anio id_actor modo_termino_ofirec fecha_termino_ofirec cantidad_ofirec  cantidad_inegi cantidad_otorgada convenio_pagado_completo cantidad_pagada sueldo_estadistico periodicidad_sueldo_estadistic 
merge m:1 id_actor using "$directorio\DB\survey_data_2m.dta", nogen keepusing(id_actor demando_con_abogado_privado demando_con_abogado_publico coyote type_lawyer)
merge m:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3) nogen
merge m:m junta exp anio using "$directorio\DB\lawyer_scores_p3.dta", nogen 

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


eststo : reg settlement total ${controls}, r 
qui su settlement if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg settlement total prediccion_a ${controls}, r 
qui su settlement if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg cr total ${controls}, r
qui su cr if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg cr total prediccion_b ${controls}, r
qui su cr if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg expiry_wd total ${controls}, r
qui su expiry_wd if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg duration total ${controls}, r
qui su duration if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg cantidad_ofirec total ${controls}, r
qui su cantidad_otorgada if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg cantidad_ofirec total monto ${controls}, r 
qui su cantidad_otorgada if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg convenio_pagado_completo total ${controls}, r
qui su convenio_pagado_completo if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg convenio_pagado_completo total monto ${controls}, r 
qui su convenio_pagado_completo if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg settlement total ${controls} if strpos(abogado,"laura")!=0, r 
qui su settlement if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg settlement total prediccion_a ${controls} if strpos(abogado,"laura")!=0, r 
qui su settlement if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg cr total ${controls} if strpos(abogado,"laura")!=0, r
qui su cr if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg cr total prediccion_b ${controls} if strpos(abogado,"laura")!=0, r
qui su cr if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg expiry_wd total ${controls} if strpos(abogado,"laura")!=0, r
qui su expiry_wd if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg duration total ${controls} if strpos(abogado,"laura")!=0, r
qui su duration if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg cantidad_ofirec total ${controls} if strpos(abogado,"laura")!=0, r
qui su cantidad_otorgada if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg cantidad_ofirec total monto ${controls} if strpos(abogado,"laura")!=0, r 
qui su cantidad_otorgada if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg convenio_pagado_completo total ${controls} if strpos(abogado,"laura")!=0, r
qui su convenio_pagado_completo if e(sample)
estadd scalar DepVarMean = `r(mean)'

eststo : reg convenio_pagado_completo total monto ${controls} if strpos(abogado,"laura")!=0, r 
qui su convenio_pagado_completo if e(sample)
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

	
	
replace coyote = 0 if !missing(demando_con_abogado_privado ) & missing(coyote)
gen privado = demando_con_abogado_privado  == 1 & coyote==0 if !missing(demando_con_abogado_privado )

eststo clear
eststo : reg total privado coyote  ${controls}, robust
reg total privado coyote  ${controls} if strpos(abogado,"laura")!=0, robust

eststo : reg settlement privado coyote  ${controls}, robust
eststo : reg cr privado coyote  ${controls}, robust
eststo : reg duration privado coyote  ${controls}, robust
eststo : reg cantidad_otorgada privado coyote  ${controls}, robust
eststo : reg cantidad_ofirec privado coyote  ${controls}, robust
eststo : reg convenio_pagado_completo privado coyote  ${controls}, robust

esttab using "$directorio/Tables/reg_results/te_outcome_abogado.csv", se r2 ${star} b(a2) label ///
	scalars("DepVarMean DepVarMean"  "test_23 T2 = T3") replace 

	
eststo clear
eststo : reg total i.type_lawyer  ${controls}, robust
reg total i.type_lawyer  ${controls} if strpos(abogado,"laura")!=0, robust

gen log_monto = log(monto)
eststo : reg log_monto i.type_lawyer  ${controls}, robust
eststo : reg log_monto i.type_lawyer  ${controls} if strpos(abogado,"laura")!=0, robust


eststo : reg settlement i.type_lawyer  ${controls}, robust
eststo : reg cr i.type_lawyer  ${controls}, robust
eststo : reg duration i.type_lawyer ${controls}, robust
eststo : reg cantidad_otorgada i.type_lawyer  ${controls}, robust
gen log_cantidad = log(cantidad_ofirec)
eststo : reg log_cantidad i.type_lawyer  ${controls}, robust
eststo : reg convenio_pagado_completo i.type_lawyer  ${controls}, robust


	
foreach var of varlist {
	
}	

cap drop treatment_data
gen treat = main_treatment==2 if inlist(main_treatment,1,2)

	 teffects nnmatch (cantidad_otorgada  ///
	/*Calculator prediction*/  	  ///
	/*Entitlement by law*/        ///
	/*Basic variable contrlols*/  ${controls} ///
					) (treat) 
					
					, ///
	ematch(abogado_pub) biasadj( min_ley c_antiguedad salario_diario horas_sem)
	
	
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
	
	