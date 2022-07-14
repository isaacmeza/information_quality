
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

* Purpose: Duration SS

*******************************************************************************/
*/

use "$directorio\DB\iniciales_dem.dta" , clear
merge m:1 junta exp anio using  "$directorio\DB\seguimiento_dem.dta", nogen keep(3)

keep junta exp anio id_actor modo_termino_exp fecha_termino_exp fecha_demanda
*Keep unique id_actor
duplicates drop
drop if missing(id_actor)
*CAUTION (review)
duplicates drop junta exp anio id_actor, force
duplicates tag id_actor, gen(tg)
drop if tg>0

merge m:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3) nogen


replace fecha_termino_exp = date("05/05/2022", "DMY") if modo_termino_exp == 2
gen duracion = (fecha_termino_exp - fecha_demanda)/30 
replace duracion = . if duracion<0

keep if inlist(modo_termino,2,6)
su duracion,d
hist duracion
cumul duracion , gen(cdf)
cumul duracion if main_treatment==1, gen(cdf_1)
cumul duracion if treatment==1, gen(cdf_1a)
sort duracion

twoway (line cdf duracion ) (line cdf_1 duracion ) (line cdf_1a duracion ), graphregion(color(white)) legend(order(1 "all" 2 "control" 3 "control a"))


xtile perc = duracion, nq(100)

