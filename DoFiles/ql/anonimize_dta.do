
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
replace nombre_abogado = subinstr(nombre_abogado, "�", "N", .)
replace nombre_abogado = subinstr(nombre_abogado, "�", "N", .)
replace nombre_abogado = subinstr(nombre_abogado, "-", " ", .)
replace nombre_abogado = subinstr(nombre_abogado, "�", "A", .)
replace nombre_abogado = subinstr(nombre_abogado, "�", "E", .)
replace nombre_abogado = subinstr(nombre_abogado, "�", "I", .)
replace nombre_abogado = subinstr(nombre_abogado, "�", "O", .)
replace nombre_abogado = subinstr(nombre_abogado, "�", "U", .)
replace nombre_abogado = subinstr(nombre_abogado, "�", "A", .)
replace nombre_abogado = subinstr(nombre_abogado, "�", "E", .)
replace nombre_abogado = subinstr(nombre_abogado, "�", "I", .)
replace nombre_abogado = subinstr(nombre_abogado, "�", "O", .)
replace nombre_abogado = subinstr(nombre_abogado, "�", "U", .)
replace nombre_abogado = subinstr(nombre_abogado, "�", "A", .)
replace nombre_abogado = subinstr(nombre_abogado, "�", "E", .)
replace nombre_abogado = subinstr(nombre_abogado, "�", "I", .)
replace nombre_abogado = subinstr(nombre_abogado, "�", "O", .)
replace nombre_abogado = subinstr(nombre_abogado, "�", "U", .)
replace nombre_abogado = subinstr(nombre_abogado, "�", "A", .)
replace nombre_abogado = subinstr(nombre_abogado, "�", "E", .)
replace nombre_abogado = subinstr(nombre_abogado, "�", "I", .)
replace nombre_abogado = subinstr(nombre_abogado, "�", "O", .)
replace nombre_abogado = subinstr(nombre_abogado, "�", "U", .)
replace nombre_abogado = subinstr(nombre_abogado, " DE ", " ", .)
replace nombre_abogado = subinstr(nombre_abogado, " DEL ", " ", .)
replace nombre_abogado = subinstr(nombre_abogado, " LA ", " ", .)
replace nombre_abogado = subinstr(nombre_abogado, " LAS ", " ", .)
replace nombre_abogado = subinstr(nombre_abogado, " LO ", " ", .)
replace nombre_abogado = subinstr(nombre_abogado, " LOS ", " ", .)
replace nombre_abogado = subinstr(nombre_abogado, "�", "", .)
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
replace despacho_actor = subinstr(despacho_actor, "�", "N", .)
replace despacho_actor = subinstr(despacho_actor, "-", " ", .)
replace despacho_actor = subinstr(despacho_actor, "�", "A", .)
replace despacho_actor = subinstr(despacho_actor, "�", "E", .)
replace despacho_actor = subinstr(despacho_actor, "�", "I", .)
replace despacho_actor = subinstr(despacho_actor, "�", "O", .)
replace despacho_actor = subinstr(despacho_actor, "�", "U", .)
replace despacho_actor = subinstr(despacho_actor, "�", "A", .)
replace despacho_actor = subinstr(despacho_actor, "�", "E", .)
replace despacho_actor = subinstr(despacho_actor, "�", "I", .)
replace despacho_actor = subinstr(despacho_actor, "�", "O", .)
replace despacho_actor = subinstr(despacho_actor, "�", "U", .)
replace despacho_actor = subinstr(despacho_actor, "�", "A", .)
replace despacho_actor = subinstr(despacho_actor, "�", "E", .)
replace despacho_actor = subinstr(despacho_actor, "�", "I", .)
replace despacho_actor = subinstr(despacho_actor, "�", "O", .)
replace despacho_actor = subinstr(despacho_actor, "�", "U", .)
replace despacho_actor = subinstr(despacho_actor, "�", "A", .)
replace despacho_actor = subinstr(despacho_actor, "�", "E", .)
replace despacho_actor = subinstr(despacho_actor, "�", "I", .)
replace despacho_actor = subinstr(despacho_actor, "�", "O", .)
replace despacho_actor = subinstr(despacho_actor, "�", "U", .)
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
