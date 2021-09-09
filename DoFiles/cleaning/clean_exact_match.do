*EXACT MATCHING - Cleaning

use "$directorio\DB\treatment_data.dta", clear
keep nombre_actor nombre_demandado* id_actor


********************************************************************************
*									ACTOR   								   *
********************************************************************************
*Remove blank spaces
replace nombre_actor = stritrim(trim(itrim(upper(nombre_actor))))

*Basic name cleaning 
replace nombre_actor = subinstr(nombre_actor, ".", "", .)
replace nombre_actor = subinstr(nombre_actor, " & ", " ", .)
replace nombre_actor = subinstr(nombre_actor, "&", "", .)
replace nombre_actor = subinstr(nombre_actor, ",", "", .)
replace nombre_actor = subinstr(nombre_actor, "ñ", "N", .)
replace nombre_actor = subinstr(nombre_actor, "Ñ", "N", .)
replace nombre_actor = subinstr(nombre_actor, "-", " ", .)
replace nombre_actor = subinstr(nombre_actor, "á", "A", .)
replace nombre_actor = subinstr(nombre_actor, "é", "E", .)
replace nombre_actor = subinstr(nombre_actor, "í", "I", .)
replace nombre_actor = subinstr(nombre_actor, "ó", "O", .)
replace nombre_actor = subinstr(nombre_actor, "ú", "U", .)
replace nombre_actor = subinstr(nombre_actor, "Á", "A", .)
replace nombre_actor = subinstr(nombre_actor, "É", "E", .)
replace nombre_actor = subinstr(nombre_actor, "Í", "I", .)
replace nombre_actor = subinstr(nombre_actor, "Ó", "O", .)
replace nombre_actor = subinstr(nombre_actor, "Ú", "U", .)
replace nombre_actor = subinstr(nombre_actor, "â", "A", .)
replace nombre_actor = subinstr(nombre_actor, "ê", "E", .)
replace nombre_actor = subinstr(nombre_actor, "î", "I", .)
replace nombre_actor = subinstr(nombre_actor, "ô", "O", .)
replace nombre_actor = subinstr(nombre_actor, "ù", "U", .)
replace nombre_actor = subinstr(nombre_actor, "Â", "A", .)
replace nombre_actor = subinstr(nombre_actor, "Ê", "E", .)
replace nombre_actor = subinstr(nombre_actor, "Î", "I", .)
replace nombre_actor = subinstr(nombre_actor, "Ô", "O", .)
replace nombre_actor = subinstr(nombre_actor, "Û", "U", .)
replace nombre_actor = subinstr(nombre_actor, " DE ", " ", .)
replace nombre_actor = subinstr(nombre_actor, " DEL ", " ", .)
replace nombre_actor = subinstr(nombre_actor, " LA ", " ", .)
replace nombre_actor = subinstr(nombre_actor, " LAS ", " ", .)
replace nombre_actor = subinstr(nombre_actor, " LO ", " ", .)
replace nombre_actor = subinstr(nombre_actor, " LOS ", " ", .)

replace nombre_actor = stritrim(trim(itrim(upper(nombre_actor))))


*Remove special characters
gen newname = "" 
gen length = length(nombre_actor) 
su length, meanonly 

forval i = 1/`r(max)' { 
     local char substr(nombre_actor, `i', 1) 
     local OK inrange(`char', "a", "z") | inrange(`char', "A", "Z")  | `char'==" "
     qui replace newname = newname + `char' if `OK' 
}
replace nombre_actor = newname
drop newname length

*Generate "new name" in alphabetical order
	*Split string
split nombre_actor, p(" ") gen(aux_names)

local k = 0
foreach var of varlist aux_names* {
	local k = `k'+1
	}
	*Sort in rows
rowsort aux_names1-aux_names`k', generate(order_names1-order_names`k')

	*Gen "new name"
gen plaintiff_name = ""
forvalues i = 1/`k' {
	replace plaintiff_name = plaintiff_name + " " + order_names`i'
	}
replace plaintiff_name = stritrim(trim(itrim(upper(plaintiff_name))))

********************************************************************************
*									DEMANDADOS								   *
********************************************************************************

forvalues k = 1/6 {
	cap drop nombre_dem
	*Remove blank spaces
	gen nombre_dem = stritrim(trim(itrim(upper(nombre_demandado`k'))))
		
	*Basic name cleaning 
	replace nombre_dem = subinstr(nombre_dem, ".", "", .)
	replace nombre_dem = subinstr(nombre_dem, "-", "", .)
	replace nombre_dem = subinstr(nombre_dem, " & ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, "&", "", .)
	replace nombre_dem = subinstr(nombre_dem, ",", "", .)
	replace nombre_dem = subinstr(nombre_dem, "ñ", "N", .)
	replace nombre_dem = subinstr(nombre_dem, "Ñ", "N", .)
	replace nombre_dem = subinstr(nombre_dem, "-", " ", .)
	replace nombre_dem = subinstr(nombre_dem, "á", "A", .)
	replace nombre_dem = subinstr(nombre_dem, "é", "E", .)
	replace nombre_dem = subinstr(nombre_dem, "í", "I", .)
	replace nombre_dem = subinstr(nombre_dem, "ó", "O", .)
	replace nombre_dem = subinstr(nombre_dem, "ú", "U", .)
	replace nombre_dem = subinstr(nombre_dem, "Á", "A", .)
	replace nombre_dem = subinstr(nombre_dem, "É", "E", .)
	replace nombre_dem = subinstr(nombre_dem, "Í", "I", .)
	replace nombre_dem = subinstr(nombre_dem, "Ó", "O", .)
	replace nombre_dem = subinstr(nombre_dem, "Ú", "U", .)
	replace nombre_dem = subinstr(nombre_dem, "â", "A", .)
	replace nombre_dem = subinstr(nombre_dem, "ê", "E", .)
	replace nombre_dem = subinstr(nombre_dem, "î", "I", .)
	replace nombre_dem = subinstr(nombre_dem, "ô", "O", .)
	replace nombre_dem = subinstr(nombre_dem, "ù", "U", .)
	replace nombre_dem = subinstr(nombre_dem, "Â", "A", .)
	replace nombre_dem = subinstr(nombre_dem, "Ê", "E", .)
	replace nombre_dem = subinstr(nombre_dem, "Î", "I", .)
	replace nombre_dem = subinstr(nombre_dem, "Ô", "O", .)
	replace nombre_dem = subinstr(nombre_dem, "Û", "U", .)
	replace nombre_dem = subinstr(nombre_dem, " SA ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " CV ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " SAB ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " SAP ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " RL ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " SC ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " SRL ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " S ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " AC ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " C ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " SADECV ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " SA DECV ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " SADE CV ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " SA", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " CV", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " SAB", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " SAP", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " RL", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " SC", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " SRL", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " S", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " AC", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " C", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " SADECV", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " SA DECV", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " SADE CV", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " OPERADOR ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " OPERADORA ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " OPERADORAS ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " OPERADORES ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " OPERACION ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " OPERADPRA ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " OPERACIONES ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " DE ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " DEL ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " LA ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " LAS ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " LO ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, " LOS ", " ", .)
	replace nombre_dem = subinstr(nombre_dem, "´", "", .)
	replace nombre_dem = subinstr(nombre_dem, "'", "", .)

	*Identify main occurrences
	cap drop wal_mart 
	gen wal_mart=strpos(nombre_dem, "WAL M") |  ///
		strpos(nombre_dem, "WAL MART") |  ///
		strpos(nombre_dem, "WALM") |  ///
		strpos(nombre_dem, "WALMART") |  ///
		strpos(nombre_dem, "WAL M") 
		
	replace nombre_dem="WAL MART" if wal_mart==1


	*Remove special characters
	gen newname = "" 
	gen length = length(nombre_dem) 
	su length, meanonly 

	forval i = 1/`r(max)' { 
		 local char substr(nombre_dem, `i', 1) 
		 local OK inrange(`char', "a", "z") | inrange(`char', "A", "Z")  | `char'==" "
		 replace newname = newname + `char' if `OK' 
		}
	replace nombre_dem=newname
	drop newname length
		
	gen defendant_name_`k' = stritrim(trim(itrim(upper(nombre_dem))))

	}

keep plaintiff_name defendant_name* id_actor
save "$directorio\_aux\td.dta", replace


*Merge with original datasets
use "$directorio\DB\treatment_data.dta", clear
cap drop plaintiff_name 
cap drop plaintiff_name_hom
forvalues k = 1/6 {
	cap drop defendant_name_`k'
	}
merge 1:1 id_actor using "$directorio\_aux\td.dta", nogen
save "$directorio\DB\treatment_data.dta", replace


********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************



use "$directorio\_aux\expedientes_long.dta", clear
keep nombre_actor FOLIO EXPEDIENTE JUNTA demanda
gen name = nombre_actor

*Remove blank spaces
replace nombre_actor = stritrim(trim(itrim(upper(nombre_actor))))

*Basic name cleaning 
replace nombre_actor = subinstr(nombre_actor, ".", "", .)
replace nombre_actor = subinstr(nombre_actor, " & ", " ", .)
replace nombre_actor = subinstr(nombre_actor, "&", "", .)
replace nombre_actor = subinstr(nombre_actor, ",", "", .)
replace nombre_actor = subinstr(nombre_actor, "ñ", "N", .)
replace nombre_actor = subinstr(nombre_actor, "Ñ", "N", .)
replace nombre_actor = subinstr(nombre_actor, "-", " ", .)
replace nombre_actor = subinstr(nombre_actor, "á", "A", .)
replace nombre_actor = subinstr(nombre_actor, "é", "E", .)
replace nombre_actor = subinstr(nombre_actor, "í", "I", .)
replace nombre_actor = subinstr(nombre_actor, "ó", "O", .)
replace nombre_actor = subinstr(nombre_actor, "ú", "U", .)
replace nombre_actor = subinstr(nombre_actor, "Á", "A", .)
replace nombre_actor = subinstr(nombre_actor, "É", "E", .)
replace nombre_actor = subinstr(nombre_actor, "Í", "I", .)
replace nombre_actor = subinstr(nombre_actor, "Ó", "O", .)
replace nombre_actor = subinstr(nombre_actor, "Ú", "U", .)
replace nombre_actor = subinstr(nombre_actor, "â", "A", .)
replace nombre_actor = subinstr(nombre_actor, "ê", "E", .)
replace nombre_actor = subinstr(nombre_actor, "î", "I", .)
replace nombre_actor = subinstr(nombre_actor, "ô", "O", .)
replace nombre_actor = subinstr(nombre_actor, "ù", "U", .)
replace nombre_actor = subinstr(nombre_actor, "Â", "A", .)
replace nombre_actor = subinstr(nombre_actor, "Ê", "E", .)
replace nombre_actor = subinstr(nombre_actor, "Î", "I", .)
replace nombre_actor = subinstr(nombre_actor, "Ô", "O", .)
replace nombre_actor = subinstr(nombre_actor, "Û", "U", .)
replace nombre_actor = subinstr(nombre_actor, " DE ", " ", .)
replace nombre_actor = subinstr(nombre_actor, " DEL ", " ", .)
replace nombre_actor = subinstr(nombre_actor, " LA ", " ", .)
replace nombre_actor = subinstr(nombre_actor, " LAS ", " ", .)
replace nombre_actor = subinstr(nombre_actor, " LO ", " ", .)
replace nombre_actor = subinstr(nombre_actor, " LOS ", " ", .)

replace nombre_actor = stritrim(trim(itrim(upper(nombre_actor))))


*Remove special characters
gen newname = "" 
gen length = length(nombre_actor) 
su length, meanonly 

forval i = 1/`r(max)' { 
     local char substr(nombre_actor, `i', 1) 
     local OK inrange(`char', "a", "z") | inrange(`char', "A", "Z")  | `char'==" "
     qui replace newname = newname + `char' if `OK' 
}
replace nombre_actor=newname
drop newname length

*Generate "new name" in alphabetical order
	*Split string
split nombre_actor, p(" ") gen(aux_names)

local k = 0
foreach var of varlist aux_names* {
	local k = `k'+1
	}
	*Sort in rows
rowsort aux_names1-aux_names`k', generate(order_names1-order_names`k')

	*Gen "new name"
gen plaintiff_name = ""
forvalues i = 1/`k' {
	replace plaintiff_name = plaintiff_name + " " + order_names`i'
	}
replace plaintiff_name = stritrim(trim(itrim(upper(plaintiff_name))))

save "$directorio\_aux\expedientes_long.dta", replace
