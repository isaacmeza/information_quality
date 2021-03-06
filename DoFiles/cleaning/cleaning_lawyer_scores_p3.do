/*
Cleaning Lawyers scores of P3 lawsuits
Author : Isaac Meza
*/

********************************************************************************
***************************** Id - iniciales ***********************************
********************************************************************************

local files : dir "$directorio\Raw\calif\id_iniciales\" files "*.csv" 

local i = 1
foreach file in `files' {	
	import delimited "$directorio\Raw\calif\id_iniciales\\`file'" ,  clear
	capture confirm variable expediente
	if !_rc {
		*Recover junta/exp/anio
		split expediente, parse("_")
		destring expediente*, replace
		rename (expediente1 expediente2 expediente3) (junta exp anio)
	}
	tempfile temp_id_`i'
	save `temp_id_`i''
	local i = `i' + 1
}

use `temp_id_1', clear
forvalues j = 2/`=`i'-1' {
	append using `temp_id_`j''
}

keep junta exp anio folio

tempfile temp_id
save `temp_id'

********************************************************************************
******************************* Scores *****************************************
********************************************************************************
local var_calif abogado numero_abogado expediente calif_rubro_proemio just_rubro_proemio calif_prestaciones just_prestaciones calif_hechos just_hechos calif_derechos just_derechos calif_puntos_petitorios just_puntos_petitorios total prediccion_a prediccion_b monto

local files : dir "$directorio\Raw\calif\captura_calidad\" files "*.csv" 

local i = 1
foreach file in `files' {	
	import delimited "$directorio\Raw\calif\captura_calidad\\`file'", clear colrange(:17) bindquote(strict)

	*Rename 
	local oldnames = ""
	foreach var of varlist _all  {
	local oldnames `oldnames' `var'
	}
	di "`oldnames'"
	rename (`oldnames') (`var_calif') 

	tempfile temp_`i'
	save `temp_`i''
	local i = `i' + 1
}

use `temp_1', clear
forvalues j = 2/`=`i'-1' {
	append using `temp_`j''
}

duplicates drop

*Lawyer name
bysort numero_abogado : replace abogado = abogado[_n-1] if _n>1
replace abogado = stritrim(trim(itrim(lower(abogado))))
replace abogado = subinstr(abogado, "??","ni",.)
replace abogado = subinstr(abogado, "??", "a", .)
replace abogado = subinstr(abogado, "??", "e", .)
replace abogado = subinstr(abogado, "??", "i", .)
replace abogado = subinstr(abogado, "??", "o", .)
replace abogado = subinstr(abogado, "??", "u", .)
replace abogado = subinstr(abogado, "??", "a", .)
replace abogado = subinstr(abogado, "??", "e", .)
replace abogado = subinstr(abogado, "??", "i", .)
replace abogado = subinstr(abogado, "??", "o", .)
replace abogado = subinstr(abogado, "??", "u", .)
replace abogado = subinstr(abogado, "??", "a", .)
replace abogado = subinstr(abogado, "??", "e", .)
replace abogado = subinstr(abogado, "??", "i", .)
replace abogado = subinstr(abogado, "??", "o", .)
replace abogado = subinstr(abogado, "??", "u", .)
replace abogado = subinstr(abogado, "??", "a", .)
replace abogado = subinstr(abogado, "??", "e", .)
replace abogado = subinstr(abogado, "??", "i", .)
replace abogado = subinstr(abogado, "??", "o", .)
replace abogado = subinstr(abogado, "??", "u", .)	
	
replace abogado = "zlaura alicia aquino arriaga" if strpos(abogado, "laura")!=0	

*Gen id of lawyer
tostring numero_abogado, replace
tostring expediente, replace
gen folio = numero_abogado + "_" + expediente
drop numero_abogado expediente

duplicates drop folio calif* total prediccion_a prediccion_b monto, force
	
merge 1:1 folio using `temp_id', nogen keep(3)
save "$directorio\DB\lawyer_scores_p3.dta" , replace
