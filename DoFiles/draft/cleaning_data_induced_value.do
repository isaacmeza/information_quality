/*
********************
version 17.0
********************
 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	December. 5, 2021
* Last date of modification:   
* Modifications:		
* Files used:     
* Files created:  

* Purpose: Preparation of HD for prediction of case value.

*******************************************************************************/
*/

******************************************************
********************* casefile ***********************
******************************************************

use "$directorio\DB\iniciales_dem.dta" , clear
merge m:1 junta exp anio using  "$directorio\DB\seguimiento_dem.dta", nogen

* Feature cleaning
rename gen gen
gen num_actores = numero_actores_totales
replace num_actores = 3 if num_actores>=3 & !missing(num_actores) 
gen salario_diario = sueldo_estadistico if periodicidad_sueldo_estadistic==0
replace salario_diario = sueldo_estadistico/30 if periodicidad_sueldo_estadistic==1
replace salario_diario = sueldo_estadistico/15 if periodicidad_sueldo_estadistic==2
replace salario_diario = sueldo_estadistico/7 if periodicidad_sueldo_estadistic==3
gen horas_sem = numero_horas_laboradas  if periodicidad_horas_laboradas==3
replace horas_sem = numero_horas_laboradas/4 if periodicidad_sueldo_estadistic==1
replace horas_sem = numero_horas_laboradas/2 if periodicidad_sueldo_estadistic==2
#delimit ; 
rename (reinstalacion 
indemnizacion_constitucional 
salarios_caidos 
prima_antiguedad
prima_vacacional
horas_extra 
indemnizacion_20_dias_anio_ser
prima_dominical
descanso_semanal 
cuotas_sar_imss_info) 
	(reinst
indem
sal_caidos
prima_antig
prima_vac 
horas_extra
rec20 
prima_dom 
desc_sem
sarimssinf) ;

keep junta exp anio id_actor
num_actores 
gen
reclutamiento 
salario_diario 
horas_sem 
reinst
indem  
sal_caidos 
prima_antig
prima_vac 
horas_extra
rec20 
prima_dom 
desc_sem
sarimssinf 
utilidades
nulidad ;

#delimit cr
gen dem = 1
tempfile temp_dem
save `temp_dem'

******************************************************
************************* P3 *************************
******************************************************

use "$directorio\DB\treatment_data.dta", clear

* Feature cleaning
#delimit ; 
rename ( mujer 
dummy_reinst
dummy_prima_dom
dummy_desc_sem 
dummy_sarimssinfo
cant_rec_sueldo 
dummy_desc_ob
c_min_prima_antig
c_min_ag 
c_min_vac 
c_min_total)
	(gen
reinst 
prima_dom 
desc_sem
sarimssinf 
c_recsueldo
desc_ob 
min_prima_antig
min_ag 
min_vac 
min_ley) ;

keep  id_actor treatment
gen 
reclutamiento 
salario_diario 
horas_sem 
reinst
prima_dom 
desc_sem
sarimssinf 
antiguedad 
c_recsueldo
desc_ob 
min_prima_antig
min_ag 
min_vac 
min_ley ;

#delimit cr

gen dem = 0
merge 1:m id_actor using `temp_dem', update replace nogen

* Further pre-processing
replace nulidad = 1 if nulidad>1 & !missing(nulidad)

export delimited using "$directorio\_aux\p3_case_value.csv", replace quote 



******************************************************
************************* HD *************************
******************************************************

import delimited "C:\Users\isaac\Dropbox\Apps\ShareLaTeX\information_lawyer_quality\Raw\HD\scaleup_hd.csv", clear 

* Feature cleaning
gen horas_extra = (c_hextra>0) if !missing(c_hextra) 
rename antig antiguedad
destring salario_diario, replace force
replace num_actores = 3 if num_actores>=3  & !missing(num_actores)

* Outcome discounted
replace duracion = 0 if duracion<0
gen liq_total_disc = liq_total/(1+0.25)^(duracion)

#delimit ; 

keep 
num_actores 	 
gen 	
reclutamiento 	
salario_diario	 	
horas_sem 	
reinst	
indem 	  
sal_caidos 	
prima_antig	
prima_vac 	
horas_extra
rec20 
prima_dom 	
desc_sem	 
sarimssinf 	
utilidades	
nulidad 	 	
antiguedad
c_recsueldo	
desc_ob 	
min_prima_antig	
min_ag 	
min_vac 		
min_ley 	
duracion
liq_total 
liq_total_disc	 ;
	
#delimit cr

gen hd = 1
tempfile temp_hd
save `temp_hd'

******************************************************
*********************** P1/P2 ************************
****************************************************** 

import delimited "C:\Users\isaac\Dropbox\Apps\ShareLaTeX\information_lawyer_quality\Raw\p1p2\calc_p1p2.csv", clear 

* Feature cleaning
rename hextra horas_extra
rename c_antiguedad antiguedad
gen liq_total = cantidadotorgada
replace liq_total = cantidadpagada if missing(liq_total) & !missing(cantidadpagada)
replace liq_total = cant_convenio if missing(liq_total) & !missing(cant_convenio)
replace liq_total = cant_convenio_exp if missing(liq_total) & !missing(cant_convenio_exp)
replace liq_total = cant_convenio_ofirec if missing(liq_total) & !missing(cant_convenio_ofirec)
foreach var of varlist fecha* {
	gen `var'_ = date(`var', "DMY")
	format `var'_ %td
	drop `var'
	rename `var'_ `var'
}
gen fecha_termino = fechaofirec
replace fecha_termino = fecha_termino_exp if missing(fecha_termino) & !missing(fecha_termino_exp)
replace fecha_termino = fechaexp if missing(fecha_termino) & !missing(fechaexp)
gen duracion = fecha_termino - fecha
replace duracion = . if duracion<0

* Keep only controls
keep if treatment == "Control"

* Outcome discounted
gen liq_total_disc = liq_total/(1+0.25)^(duracion)

#delimit ; 

keep 
num_actores 	 
gen 	
reclutamiento 	
salario_diario	 	
horas_sem 	
reinst	
indem 	  
sal_caidos 	
prima_antig	
prima_vac 	
horas_extra
rec20 
prima_dom 	
desc_sem	 
sarimssinf 	
utilidades	
nulidad 	 	
antiguedad
c_recsueldo	
desc_ob 	
min_prima_antig	
min_ag 	
min_vac 		
min_ley 	
duracion
liq_total 
liq_total_disc	 ;
	
#delimit cr

gen hd = 0
append using `temp_hd'

* Further pre-processing
drop if horas_extra>1 & !missing(horas_extra)
drop if missing(liq_total)
drop if missing(liq_total_disc)


export delimited using "$directorio\_aux\hd_case_value.csv", replace quote
