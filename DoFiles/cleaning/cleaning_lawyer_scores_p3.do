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
	tempfile temp_id_`i'
	save `temp_id_`i''
	local i = `i' + 1
}

use `temp_id_1', clear
append using `temp_id_2'

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
replace abogado = subinstr(abogado, "ñ","ni",.)
replace abogado = subinstr(abogado, "á", "a", .)
replace abogado = subinstr(abogado, "é", "e", .)
replace abogado = subinstr(abogado, "í", "i", .)
replace abogado = subinstr(abogado, "ó", "o", .)
replace abogado = subinstr(abogado, "ú", "u", .)
replace abogado = subinstr(abogado, "Á", "a", .)
replace abogado = subinstr(abogado, "É", "e", .)
replace abogado = subinstr(abogado, "Í", "i", .)
replace abogado = subinstr(abogado, "Ó", "o", .)
replace abogado = subinstr(abogado, "Ú", "u", .)
replace abogado = subinstr(abogado, "â", "a", .)
replace abogado = subinstr(abogado, "ê", "e", .)
replace abogado = subinstr(abogado, "î", "i", .)
replace abogado = subinstr(abogado, "ô", "o", .)
replace abogado = subinstr(abogado, "ù", "u", .)
replace abogado = subinstr(abogado, "Â", "a", .)
replace abogado = subinstr(abogado, "Ê", "e", .)
replace abogado = subinstr(abogado, "Î", "i", .)
replace abogado = subinstr(abogado, "Ô", "o", .)
replace abogado = subinstr(abogado, "Û", "u", .)	
	
	
*Gen id of lawyer
tostring numero_abogado, replace
tostring expediente, replace
gen folio = numero_abogado + "_" + expediente
drop numero_abogado expediente

duplicates drop folio calif* total prediccion_a prediccion_b monto, force
	
merge 1:1 folio using `temp_id', nogen 
save "$directorio\DB\lawyer_scores_p3.dta" , replace
