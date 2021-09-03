
import delimited "$directorio\Raw\scaleup_hd.csv", clear 



*************************
*		 ABOGADO		*
*************************

forvalues i=1/3 {
	rename nombre_abogado`i'_ac nombre_abogadoac`i'
	}
	
gen i=_n	
reshape	long nombre_abogadoac, i(i) j(j)
duplicates drop  nombre_abogadoac, force

*Remove blank spaces
gen nombre_abogado=stritrim(trim(itrim(upper(nombre_abogadoac))))
	
*Basic name cleaning 
replace nombre_abogado = subinstr(nombre_abogado, ".", "", .)
replace nombre_abogado = subinstr(nombre_abogado, " & ", " ", .)
replace nombre_abogado = subinstr(nombre_abogado, "&", "", .)
replace nombre_abogado = subinstr(nombre_abogado, ",", "", .)
replace nombre_abogado = subinstr(nombre_abogado, "ñ", "N", .)
replace nombre_abogado = subinstr(nombre_abogado, "Ñ", "N", .)
replace nombre_abogado = subinstr(nombre_abogado, "-", " ", .)
replace nombre_abogado = subinstr(nombre_abogado, "á", "A", .)
replace nombre_abogado = subinstr(nombre_abogado, "é", "E", .)
replace nombre_abogado = subinstr(nombre_abogado, "í", "I", .)
replace nombre_abogado = subinstr(nombre_abogado, "ó", "O", .)
replace nombre_abogado = subinstr(nombre_abogado, "ú", "U", .)
replace nombre_abogado = subinstr(nombre_abogado, "Á", "A", .)
replace nombre_abogado = subinstr(nombre_abogado, "É", "E", .)
replace nombre_abogado = subinstr(nombre_abogado, "Í", "I", .)
replace nombre_abogado = subinstr(nombre_abogado, "Ó", "O", .)
replace nombre_abogado = subinstr(nombre_abogado, "Ú", "U", .)
replace nombre_abogado = subinstr(nombre_abogado, "â", "A", .)
replace nombre_abogado = subinstr(nombre_abogado, "ê", "E", .)
replace nombre_abogado = subinstr(nombre_abogado, "î", "I", .)
replace nombre_abogado = subinstr(nombre_abogado, "ô", "O", .)
replace nombre_abogado = subinstr(nombre_abogado, "ù", "U", .)
replace nombre_abogado = subinstr(nombre_abogado, "Â", "A", .)
replace nombre_abogado = subinstr(nombre_abogado, "Ê", "E", .)
replace nombre_abogado = subinstr(nombre_abogado, "Î", "I", .)
replace nombre_abogado = subinstr(nombre_abogado, "Ô", "O", .)
replace nombre_abogado = subinstr(nombre_abogado, "Û", "U", .)
replace nombre_abogado = subinstr(nombre_abogado, " DE ", " ", .)
replace nombre_abogado = subinstr(nombre_abogado, " DEL ", " ", .)
replace nombre_abogado = subinstr(nombre_abogado, " LA ", " ", .)
replace nombre_abogado = subinstr(nombre_abogado, " LAS ", " ", .)
replace nombre_abogado = subinstr(nombre_abogado, " LO ", " ", .)
replace nombre_abogado = subinstr(nombre_abogado, " LOS ", " ", .)
replace nombre_abogado = subinstr(nombre_abogado, "´", "", .)
replace nombre_abogado = subinstr(nombre_abogado, "'", "", .)

*Remove special characters
gen newname = "" 
gen length = length(nombre_abogado) 
su length, meanonly 

forval i = 1/`r(max)' { 
	 local char substr(nombre_abogado, `i', 1) 
	 local OK inrange(`char', "a", "z") | inrange(`char', "A", "Z")  | `char'==" "
	 replace newname = newname + `char' if `OK' 
	}
replace nombre_abogado=newname
drop newname length
	
replace nombre_abogado=stritrim(trim(itrim(upper(nombre_abogado))))
	
*Group according to Levenshtein distance
strgroup nombre_abogado , gen(id_abogado) threshold(.20) normalize(longer)

sort id_abogado nombre_abogadoac
keep id_abogado nombre_abogadoac
save "$directorio\_aux\abogado_id.dta", replace 

********************************************************************************

*************************
*	DEMANDADO/DESPIDE	*
*************************

import delimited "$directorio\Raw\scaleup_hd.csv", clear 

keep nombre_d*
split nombre_despido, p(";" "," " Y ")
drop nombre_despido

gen i=_n

preserve
reshape	long nombre_despido, i(i) j(j)
duplicates drop  nombre_despido, force
rename nombre_despido nombre_d
keep nombre_d
tempfile temp_desp
save `temp_desp'
restore

reshape	long nombre_d, i(i) j(j)
duplicates drop  nombre_d, force

append  using `temp_desp'

duplicates drop nombre_d, force


*Remove blank spaces
gen nombre_dem=stritrim(trim(itrim(upper(nombre_d))))
	
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
gen wal_mart=strpos(nombre_dem, "WAL M") |  ///
	strpos(nombre_dem, "WAL MART") |  ///
	strpos(nombre_dem, "WALM") |  ///
	strpos(nombre_dem, "WALMART") |  ///
	strpos(nombre_dem, "WAL M") 
gen quien_resulte= strpos(nombre_dem, "QUIEN") |  ///	
	strpos(nombre_dem, "RESULT") |  ///
	strpos(nombre_dem, "RESP") |  ///
	strpos(nombre_dem, "PROPIET") |  ///
	strpos(nombre_dem, "PATRON") 
	
replace nombre_dem="WAL MART" if wal_mart==1
replace nombre_dem="QUIEN RESULTE RESPONSABLE" if quien_resulte==1	


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
	
*Group according to Levenshtein distance
strgroup nombre_dem , gen(id_dem) threshold(.25) normalize(longer) force

sort id_dem nombre_d
keep id_dem nombre_d
save "$directorio\_aux\demandado_id.dta", replace 

********************************************************************************

*************************
*		DESPACHO	    *
*************************

import delimited "$directorio\Raw\scaleup_hd.csv", clear 

duplicates drop despacho_ac, force

*Remove blank spaces
gen despacho_actor=stritrim(trim(itrim(upper(despacho_ac))))

*Generate PROCURADURIA
replace despacho_actor="PROCURADURIA" if abogado_pub==1


*Basic name cleaning 
replace despacho_actor = subinstr(despacho_actor, ".", "", .)
replace despacho_actor = subinstr(despacho_actor, " & ", " ", .)
replace despacho_actor = subinstr(despacho_actor, "&", "", .)
replace despacho_actor = subinstr(despacho_actor, " Y ", " ", .)
replace despacho_actor = subinstr(despacho_actor, ",", "", .)
replace despacho_actor = subinstr(despacho_actor, "Ñ", "N", .)
replace despacho_actor = subinstr(despacho_actor, "-", " ", .)
replace despacho_actor = subinstr(despacho_actor, "á", "A", .)
replace despacho_actor = subinstr(despacho_actor, "é", "E", .)
replace despacho_actor = subinstr(despacho_actor, "í", "I", .)
replace despacho_actor = subinstr(despacho_actor, "ó", "O", .)
replace despacho_actor = subinstr(despacho_actor, "ú", "U", .)
replace despacho_actor = subinstr(despacho_actor, "Á", "A", .)
replace despacho_actor = subinstr(despacho_actor, "É", "E", .)
replace despacho_actor = subinstr(despacho_actor, "Í", "I", .)
replace despacho_actor = subinstr(despacho_actor, "Ó", "O", .)
replace despacho_actor = subinstr(despacho_actor, "Ú", "U", .)
replace despacho_actor = subinstr(despacho_actor, "â", "A", .)
replace despacho_actor = subinstr(despacho_actor, "ê", "E", .)
replace despacho_actor = subinstr(despacho_actor, "î", "I", .)
replace despacho_actor = subinstr(despacho_actor, "ô", "O", .)
replace despacho_actor = subinstr(despacho_actor, "ù", "U", .)
replace despacho_actor = subinstr(despacho_actor, "Â", "A", .)
replace despacho_actor = subinstr(despacho_actor, "Ê", "E", .)
replace despacho_actor = subinstr(despacho_actor, "Î", "I", .)
replace despacho_actor = subinstr(despacho_actor, "Ô", "O", .)
replace despacho_actor = subinstr(despacho_actor, "Û", "U", .)
replace despacho_actor = subinstr(despacho_actor, " S C", " SC", .)
replace despacho_actor = subinstr(despacho_actor, " SC", " ", .)
replace despacho_actor = subinstr(despacho_actor, " SA DE CV", " ", .)
replace despacho_actor = subinstr(despacho_actor, "ABOGADOS", "", .)
replace despacho_actor = subinstr(despacho_actor, "ABOGADO", " ", .)
replace despacho_actor = subinstr(despacho_actor, "ASOCIADOS", " ", .)
replace despacho_actor = subinstr(despacho_actor, "ASOCIADO", " ", .)
replace despacho_actor = subinstr(despacho_actor, "ASOSCIADO", " ", .)
replace despacho_actor = subinstr(despacho_actor, "LIC ", " ", .)
replace despacho_actor = subinstr(despacho_actor, "LICENCIADA ", " ", .)
replace despacho_actor = subinstr(despacho_actor, "LICENCIADO ", " ", .)
replace despacho_actor = subinstr(despacho_actor, "-", " ", .)

*Remove special characters
gen newname = "" 
gen length = length(despacho_actor) 
su length, meanonly 

forval i = 1/`r(max)' { 
     local char substr(despacho_actor, `i', 1) 
     local OK inrange(`char', "a", "z") | inrange(`char', "A", "Z")  | `char'==" "
     replace newname = newname + `char' if `OK' 
}
replace despacho_actor=newname
drop newname length

replace despacho_actor=stritrim(trim(itrim(upper(despacho_actor))))
replace despacho_actor="ABOGADOS ASOCIADOS" if missing(despacho_actor) & !missing(despacho_ac)

*Group according to Levenshtein distance
strgroup despacho_actor , gen(id_despacho) threshold(.2) normalize(longer)

sort id_despacho despacho_ac
keep id_despacho despacho_ac
save "$directorio\_aux\despacho_id.dta", replace 

********************************************************************************

*************************
*		  ACTOR  	    *
*************************

import delimited "$directorio\Raw\scaleup_hd.csv", clear 


duplicates drop nombre_ac , force

*Remove blank spaces
gen nombre_actor=stritrim(trim(itrim(upper(nombre_ac))))

*Basic name cleaning 
replace nombre_actor = subinstr(nombre_actor, ".", "", .)
replace nombre_actor = subinstr(nombre_actor, " & ", " ", .)
replace nombre_actor = subinstr(nombre_actor, "&", "", .)
replace nombre_actor = subinstr(nombre_actor, " Y ", " ", .)
replace nombre_actor = subinstr(nombre_actor, ",", "", .)
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

*Remove special characters
gen newname = "" 
gen length = length(nombre_actor) 
su length, meanonly 

forval i = 1/`r(max)' { 
     local char substr(nombre_actor, `i', 1) 
     local OK inrange(`char', "a", "z") | inrange(`char', "A", "Z")  | `char'==" "
     replace newname = newname + `char' if `OK' 
}
replace nombre_actor=newname
drop newname length

replace nombre_actor=stritrim(trim(itrim(upper(nombre_actor))))

*Group according to Levenshtein distance
strgroup nombre_actor , gen(id_emp) threshold(.2) normalize(longer)

sort id_emp nombre_ac
keep id_emp nombre_ac
save "$directorio\_aux\actor_id.dta", replace 
