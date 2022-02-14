/*
********************
version 17.0
********************
 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	January 21, 2022
* Last date of modification:   
* Modifications:		
* Files used:     
* Files created:  

* Purpose: 

*******************************************************************************/
*/

********************************************************************************
use  "$directorio\DB\quality_lawyer_dataset.dta", clear
keep junta exp anio 
merge m:m junta exp anio using "$directorio\DB\seguimiento_aud_hd.dta", keepusing(junta exp anio) nogen

duplicates drop 
egen id_exp = group(junta exp anio)
tempfile tempid
save `tempid'

use  "$directorio\DB\quality_lawyer_dataset.dta", clear
merge m:1  junta exp anio using `tempid', nogen keep(1 3)
save  "$directorio\_aux\quality_lawyer_dataset.dta", replace

use  "$directorio\DB\seguimiento_aud_hd.dta", clear
merge m:1  junta exp anio using `tempid', nogen keep(1 3)
save  "$directorio\_aux\seguimiento_aud_hd.dta", replace
********************************************************************************

use  "$directorio\_aux\quality_lawyer_dataset.dta", clear
matchit  id_exp  nombre_ac  using "$directorio\_aux\seguimiento_aud_hd.dta" , idu(id_exp) txtu(nombre_ac)
save  "$directorio\_aux\matchit_hd.dta", replace

********************************************************************************

use "$directorio\_aux\matchit_hd.dta",clear
keep if id_exp==id_exp1
duplicates drop 

*Manual join
keep if similscore>0.73
drop if id_exp==2376 & nombre_ac=="alma delia martinez patricio"  & similscore!=1
drop if id_exp==2376 & nombre_ac=="juliana patricio martinez"  & similscore!=1
drop if id_exp==2665 & nombre_ac=="salvador guerrero vazquez"  & similscore!=1
drop if id_exp==2665 & nombre_ac=="salvador guerrero garcia"  & similscore!=1
drop if id_exp==2309 & nombre_ac=="iliana barragan carrillo"  & similscore!=1
drop if id_exp==2309 & nombre_ac=="elizabeth barragan carrillo"  & similscore!=1
drop if id_exp==846 & nombre_ac=="lorenzo carrera martinez"  & similscore!=1
drop if id_exp==846 & nombre_ac=="erasto carrera martinez"  & similscore!=1
drop if id_exp==2168 & nombre_ac=="imelda blancas rivera"  & similscore!=1
drop if id_exp==2168 & nombre_ac=="celia blancas rivera"  & similscore!=1


joinby id_exp nombre_ac using "$directorio\_aux\quality_lawyer_dataset.dta", unmatched(using)
duplicates drop
replace nombre_ac1 = nombre_ac if missing(nombre_ac1)
drop nombre_ac _merge
rename nombre_ac1 nombre_ac

save "$directorio\DB\quality_lawyer_dataset.dta", replace

/* To merge with seguimiento de audiencias : */
/*

merge m:m id_exp nombre_ac using "$directorio\_aux\seguimiento_aud_hd.dta", nogen
duplicates drop

*/


