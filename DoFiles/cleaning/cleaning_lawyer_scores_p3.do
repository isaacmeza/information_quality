/*
Cleaning Lawyers scores of P3 lawsuits
Author : Isaac Meza
*/

********************************************************************************
*******************************               **********************************
********************************************************************************

import excel $directorio\Raw\calif\expedientesLaura2021.xlsx , firstrow  clear
keep junta exp anio Folio
rename Folio folio
tempfile temp_id
save `temp_id'


********************************************************************************
*******************************               **********************************
********************************************************************************

import delimited $directorio\Raw\calif\Captura_CalidadDemandas_BD_Laura.csv ,   clear

drop v* nombreactor

foreach var of varlist * {
	local varlabel : var label `var'
	local clean_name = stritrim(trim(itrim(lower("`varlabel'"))))
	local clean_name = subinstr("`clean_name'", " ","_",.)
	local clean_name = subinstr("`clean_name'", "/","_",.)
	local clean_name = subinstr("`clean_name'", "#","",.)
	local clean_name = subinstr("`clean_name'", "ñ","ni",.)
	local clean_name = subinstr("`clean_name'", "_de_","_",.)
	local clean_name = subinstr("`clean_name'", "_del_","_",.)
	local clean_name = subinstr("`clean_name'", "_la_","_",.)
	local clean_name = subinstr("`clean_name'", "_las_","_",.)	
	local clean_name = subinstr("`clean_name'", "_por_","_",.)	
	local clean_name = subinstr("`clean_name'", "_el_","_",.)	
	local clean_name = subinstr("`clean_name'", "_en_","_",.)	
	local clean_name = subinstr("`clean_name'", "_que_","_",.)		
	local clean_name = subinstr("`clean_name'", "_y_","_",.)
	local clean_name = subinstr("`clean_name'", "á", "a", .)
	local clean_name = subinstr("`clean_name'", "é", "e", .)
	local clean_name = subinstr("`clean_name'", "í", "i", .)
	local clean_name = subinstr("`clean_name'", "ó", "o", .)
	local clean_name = subinstr("`clean_name'", "ú", "u", .)
	local clean_name = subinstr("`clean_name'", "Á", "a", .)
	local clean_name = subinstr("`clean_name'", "É", "e", .)
	local clean_name = subinstr("`clean_name'", "Í", "i", .)
	local clean_name = subinstr("`clean_name'", "Ó", "o", .)
	local clean_name = subinstr("`clean_name'", "Ú", "u", .)
	local clean_name = subinstr("`clean_name'", "â", "a", .)
	local clean_name = subinstr("`clean_name'", "ê", "e", .)
	local clean_name = subinstr("`clean_name'", "î", "i", .)
	local clean_name = subinstr("`clean_name'", "ô", "o", .)
	local clean_name = subinstr("`clean_name'", "ù", "u", .)
	local clean_name = subinstr("`clean_name'", "Â", "a", .)
	local clean_name = subinstr("`clean_name'", "Ê", "e", .)
	local clean_name = subinstr("`clean_name'", "Î", "i", .)
	local clean_name = subinstr("`clean_name'", "Ô", "o", .)
	local clean_name = subinstr("`clean_name'", "Û", "u", .)	
	local clean_name = substr("`clean_name'",1,30)
	cap rename `var' `clean_name'
}

*Gen id iof lawyer
tostring numero_abogado, replace
tostring expediente, replace
gen folio = numero_abogado + "_" + expediente
drop numero_abogado expediente

merge 1:1 folio using `temp_id', nogen keep(3)
save "$directorio\DB\lawyer_scores_p3.dta" , replace
