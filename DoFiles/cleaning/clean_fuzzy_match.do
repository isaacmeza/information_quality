/*
Fuzzy match to compare 'sue' according to administrative & survey data
Author : Isaac Meza
*/

use "$directorio\_aux\expedientes_long.dta", clear
keep if demanda==1
egen idadmin = group(FOLIO)
duplicates drop plaintiff_name FOLIO, force
tempfile temp_exp
save `temp_exp'

use "$directorio\DB\treatment_data.dta", clear
duplicates drop plaintiff_name, force
sort plaintiff_name
egen id = group(id_actor)

*FUZZY MATCH
matchit id plaintiff_name using `temp_exp' ///
 , idu(idadmin) txtu(plaintiff_name) override
save "$directorio\_aux\match.dta", replace
 
	
****************


use "$directorio\DB\treatment_data.dta", clear
duplicates drop plaintiff_name, force
sort plaintiff_name
egen id = group(id_actor)
merge 1:m id using  "$directorio\_aux\match.dta", nogen

*Keep exact and fuzzy matches above certain thresholds
keep if similscore>${threshold_similscore} & !missing(similscore)

rename plaintiff_name1 plaintiff_name_admin
keep id_actor similscore plaintiff_name_admin
gen demanda_fuzzy=1

save "$directorio\_aux\fuzzy_sue_match.dta", replace
 
