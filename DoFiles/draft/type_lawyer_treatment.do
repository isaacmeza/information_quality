
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	May. 02, 2022
* Last date of modification:   
* Modifications:		
* Files used:     
* Files created:  

* Purpose: Table of share of type of lawyer by treatment arm, along with characteristics.

*******************************************************************************/
*/

use "$directorio\DB\iniciales_dem.dta" , clear
merge m:1 junta exp anio using  "$directorio\DB\seguimiento_dem.dta", nogen
keep junta exp anio id_actor modo_termino modo_termino_ofirec modo_termino_exp fecha_termino_ofirec cantidad_ofirec cantidad_inegi cantidad_otorgada convenio_pagado_completo cantidad_pagada sueldo_estadistico periodicidad_sueldo_estadistic periodicidad_sueldo_estadistic numero_horas_laboradas
*Keep unique id_actor
duplicates drop
drop if missing(id_actor)
*CAUTION (review)
duplicates drop junta exp anio id_actor, force
duplicates tag id_actor, gen(tg)
drop if tg>0

merge m:1 id_actor using "$directorio\DB\survey_data_2w.dta", keep(2 3) nogen 
merge m:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(2 3) nogen force 
merge m:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3) nogen
*******************************************************************************


gen sueldo_estadistico_diario = sueldo_estadistico if periodicidad_sueldo_estadistic==0
replace sueldo_estadistico_diario = sueldo_estadistico/30 if periodicidad_sueldo_estadistic==1
replace sueldo_estadistico_diario = sueldo_estadistico/15 if periodicidad_sueldo_estadistic==2
replace sueldo_estadistico_diario = sueldo_estadistico/7 if periodicidad_sueldo_estadistic==3

count if sueldo_estadistico>500000 & !missing(sueldo_estadistico)
su sueldo_estadistico_diario, d
su salario_diario, d


replace sueldo_estadistico_diario = 2300 if sueldo_estadistico_diario>2300  & !missing(sueldo_estadistico_diario)

replace salario_diario = 1600 if salario_diario>1600  & !missing(salario_diario)

gen exageracion = sueldo_estadistico_diario/salario_diario


su exageracion, d

gsort -exageracion
*br exageracion sueldo_estadistico_diario salario_diario
*Shares of type of lawyer by treatment
tab type_law, gen(type_law_d)
orth_out type_law_d1 type_law_d2 type_law_d3 , by(main_treatment)  se vce(cluster fecha_alta)

gen log_daily_wage = log(salario_diario)
gen log_sueldo = log(sueldo_estadistico_diario)
egen type_treat = group(type_lawyer main_treatment)
orth_out ${controls} log_daily_wage sueldo_estadistico_diario log_sueldo numero_horas_laboradas exageracion, by(type_treat)  se vce(cluster fecha_alta)

orth_out ${controls} log_daily_wage sueldo_estadistico_diario log_sueldo numero_horas_laboradas exageracion, by(type_lawyer)  se vce(cluster fecha_alta)


orth_out ${controls} log_daily_wage sueldo_estadistico_diario log_sueldo numero_horas_laboradas exageracion if main_treatment==1, by(type_lawyer)  se vce(cluster fecha_alta)

*Table which lawyers people use
 gen mas_prepa = inlist(nivel_educativo,3, 4) if nivel_educativo!=.
 
 gen conoce = cuantos_dias_de_salario_correspo==90
 
 gen nobs = 1 
 
 
table como_lo_consiguio if demando_con_abogado_privado==1, statistic(mean salario_diario mas_prepa conoce pidio_ser_reinstalado)  statistic(count nobs) 

table coyote if demando_con_abogado_privado==1, statistic(mean salario_diario mas_prepa conoce pidio_ser_reinstalado)  statistic(count nobs) 



*Balance table
table main_treatment , statistic(mean salario_diario mas_prepa conoce pidio_ser_reinstalado)  statistic(count nobs) 

*See selection + TE see how the treatment uoshes different people into different types of lawyers



table coyote if demando_con_abogado_privado==1 & main_treatment==1, statistic(mean salario_diario mas_prepa conoce pidio_ser_reinstalado)  statistic(count nobs) 

table coyote if demando_con_abogado_privado==1 & main_treatment==2, statistic(mean salario_diario mas_prepa conoce pidio_ser_reinstalado)  statistic(count nobs) 
 
table coyote if demando_con_abogado_privado==1 & main_treatment==3, statistic(mean salario_diario mas_prepa conoce pidio_ser_reinstalado)  statistic(count nobs) 
