
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

* Purpose: Determinants of choosing type of lawyer (conditional on suing)
*******************************************************************************/
*/

use "$directorio\DB\iniciales_dem.dta" , clear
merge m:1 junta exp anio using  "$directorio\DB\seguimiento_dem.dta", nogen
keep junta exp anio id_actor modo_termino modo_termino_ofirec modo_termino_exp fecha_termino_ofirec cantidad_ofirec cantidad_inegi cantidad_otorgada convenio_pagado_completo cantidad_pagada sueldo_estadistico periodicidad_sueldo_estadistic 
*Keep unique id_actor
duplicates drop
drop if missing(id_actor)
*CAUTION (review)
duplicates drop junta exp anio id_actor, force
duplicates tag id_actor, gen(tg)
drop if tg>0


********************************************************************************
*									2W & 2M							  		   *
********************************************************************************
merge 1:1 id_actor using "$directorio\DB\survey_data_2w.dta", keep(2 3) nogen 
*2w variables
rename conflicto_arreglado conflicto_arreglado_2w
rename entablo_demanda entablo_demanda_2w

merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(3) nogen force
*2m variables
rename conflicto_arreglado conflicto_arreglado_2m
rename entablo_demanda entablo_demanda_2m

merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3) nogen

********************************************************************************

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

tab type_lawyer, gen(type_law_d)

local controls mujer antiguedad salario_diario
local more_controls  reclutamiento dummy_confianza horas_sem dummy_desc_sem dummy_prima_dom dummy_desc_ob dummy_sarimssinfo carta_renuncia dummy_reinst c_min_indem c_min_prima_antig c_min_ag c_min_total 
lasso linear type_law_d1 `controls' cantidad_ganar if main_treatment==1
 lassocoef , display(coef)

 local controls mujer antiguedad salario_diario
reg type_law_d1 `controls'  if ab_treatment==1
reg type_law_d1 `controls'  if ab_treatment==2
 qui lasso logit type_law_d1 `controls' `more_controls' if ab_treatment==1
 lassocoef , display(coef)

 
 reg type_law_d1 mujer if ab_treatment==1
 reg type_law_d1 mujer if ab_treatment==2
 
 reg type_law_d1 i.ab_treatment##mujer i.ab_treatment##c.antiguedad i.ab_treatment##c.salario_diario , r
 
 
  reg ha_hablado_con_abogado_publico mujer antiguedad salario_diario if ab_treatment==1
 reg ha_hablado_con_abogado_publico mujer antiguedad salario_diario if ab_treatment==2
 
  
  
 reg ha_hablado_con_abogado_publico i.ab_treatment##mujer i.ab_treatment##c.antiguedad i.ab_treatment##c.salario_diario   , vce(cluster fecha_alta)
 
 
 
   
 reg type_law_d1 i.ab_treatment##mujer i.ab_treatment##c.antiguedad i.ab_treatment##c.salario_diario , vce(cluster fecha_alta)
 
 
 
  reg type_law_d1 i.ab_treatment##mujer i.ab_treatment##c.antiguedad i.ab_treatment##c.salario_diario i.ab_treatment##c.horas_sem, vce(cluster fecha_alta)
 
 
 
 