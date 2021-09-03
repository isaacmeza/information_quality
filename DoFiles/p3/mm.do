********************************************************************************
*									DEMANDADOS								   *
********************************************************************************
use "$directorio\_aux\demandas_gral.dta", clear
append using "$directorio\_aux\detalle_demandados_long.dta"
drop nombre_actor
duplicates drop 


*Remove blank spaces
gen nombre_dem=stritrim(trim(itrim(upper(nombre_d))))
	
*Basic name cleaning 
replace nombre_dem = subinstr(nombre_dem, ".", "", .)
replace nombre_dem = subinstr(nombre_dem, "-", "", .)
replace nombre_dem = subinstr(nombre_dem, " & ", " ", .)
replace nombre_dem = subinstr(nombre_dem, "&", "", .)
replace nombre_dem = subinstr(nombre_dem, ",", "", .)
replace nombre_dem = subinstr(nombre_dem, "�", "N", .)
replace nombre_dem = subinstr(nombre_dem, "�", "N", .)
replace nombre_dem = subinstr(nombre_dem, "-", " ", .)
replace nombre_dem = subinstr(nombre_dem, "�", "A", .)
replace nombre_dem = subinstr(nombre_dem, "�", "E", .)
replace nombre_dem = subinstr(nombre_dem, "�", "I", .)
replace nombre_dem = subinstr(nombre_dem, "�", "O", .)
replace nombre_dem = subinstr(nombre_dem, "�", "U", .)
replace nombre_dem = subinstr(nombre_dem, "�", "A", .)
replace nombre_dem = subinstr(nombre_dem, "�", "E", .)
replace nombre_dem = subinstr(nombre_dem, "�", "I", .)
replace nombre_dem = subinstr(nombre_dem, "�", "O", .)
replace nombre_dem = subinstr(nombre_dem, "�", "U", .)
replace nombre_dem = subinstr(nombre_dem, "�", "A", .)
replace nombre_dem = subinstr(nombre_dem, "�", "E", .)
replace nombre_dem = subinstr(nombre_dem, "�", "I", .)
replace nombre_dem = subinstr(nombre_dem, "�", "O", .)
replace nombre_dem = subinstr(nombre_dem, "�", "U", .)
replace nombre_dem = subinstr(nombre_dem, "�", "A", .)
replace nombre_dem = subinstr(nombre_dem, "�", "E", .)
replace nombre_dem = subinstr(nombre_dem, "�", "I", .)
replace nombre_dem = subinstr(nombre_dem, "�", "O", .)
replace nombre_dem = subinstr(nombre_dem, "�", "U", .)
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
replace nombre_dem = subinstr(nombre_dem, "�", "", .)
replace nombre_dem = subinstr(nombre_dem, "'", "", .)

*Identify main occurrences
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
	
replace nombre_dem=stritrim(trim(itrim(upper(nombre_dem))))
keep EXPEDIENTE JUNTA FOLIO nombre_dem
duplicates drop 
tempfile temp_dem
save `temp_dem'	

********************************************************************************
*									ACTORES 								   *
********************************************************************************
use "$directorio\_aux\demandas_gral.dta", clear
append using "$directorio\_aux\detalle_actores_long.dta"
drop nombre_dem
duplicates drop 

*Remove blank spaces
replace nombre_actor=stritrim(trim(itrim(upper(nombre_actor))))

*Basic name cleaning 
replace nombre_actor = subinstr(nombre_actor, ".", "", .)
replace nombre_actor = subinstr(nombre_actor, " & ", " ", .)
replace nombre_actor = subinstr(nombre_actor, "&", "", .)
replace nombre_actor = subinstr(nombre_actor, ",", "", .)
replace nombre_actor = subinstr(nombre_actor, "�", "N", .)
replace nombre_actor = subinstr(nombre_actor, "�", "N", .)
replace nombre_actor = subinstr(nombre_actor, "-", " ", .)
replace nombre_actor = subinstr(nombre_actor, "�", "A", .)
replace nombre_actor = subinstr(nombre_actor, "�", "E", .)
replace nombre_actor = subinstr(nombre_actor, "�", "I", .)
replace nombre_actor = subinstr(nombre_actor, "�", "O", .)
replace nombre_actor = subinstr(nombre_actor, "�", "U", .)
replace nombre_actor = subinstr(nombre_actor, "�", "A", .)
replace nombre_actor = subinstr(nombre_actor, "�", "E", .)
replace nombre_actor = subinstr(nombre_actor, "�", "I", .)
replace nombre_actor = subinstr(nombre_actor, "�", "O", .)
replace nombre_actor = subinstr(nombre_actor, "�", "U", .)
replace nombre_actor = subinstr(nombre_actor, "�", "A", .)
replace nombre_actor = subinstr(nombre_actor, "�", "E", .)
replace nombre_actor = subinstr(nombre_actor, "�", "I", .)
replace nombre_actor = subinstr(nombre_actor, "�", "O", .)
replace nombre_actor = subinstr(nombre_actor, "�", "U", .)
replace nombre_actor = subinstr(nombre_actor, "�", "A", .)
replace nombre_actor = subinstr(nombre_actor, "�", "E", .)
replace nombre_actor = subinstr(nombre_actor, "�", "I", .)
replace nombre_actor = subinstr(nombre_actor, "�", "O", .)
replace nombre_actor = subinstr(nombre_actor, "�", "U", .)
replace nombre_actor = subinstr(nombre_actor, " DE ", " ", .)
replace nombre_actor = subinstr(nombre_actor, " DEL ", " ", .)
replace nombre_actor = subinstr(nombre_actor, " LA ", " ", .)
replace nombre_actor = subinstr(nombre_actor, " LAS ", " ", .)
replace nombre_actor = subinstr(nombre_actor, " LO ", " ", .)
replace nombre_actor = subinstr(nombre_actor, " LOS ", " ", .)

replace nombre_actor=stritrim(trim(itrim(upper(nombre_actor))))


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
replace nombre_actor=stritrim(trim(itrim(upper(nombre_actor))))

duplicates drop 

********************************************************************************

merge m:m FOLIO using `temp_dem', nogen
gsort FOLIO -EXPEDIENTE -JUNTA
bysort FOLIO: replace EXPEDIENTE = EXPEDIENTE[_n-1] if missing(EXPEDIENTE) 
bysort FOLIO: replace JUNTA = JUNTA[_n-1] if missing(JUNTA)

*Generate "new name" in alphabetical order
	*Split string
split nombre_actor, p(" ") gen(names_ac)
split nombre_dem, p(" ") gen(names_dem)


save "$directorio\_aux\merge_mm.dta", replace

