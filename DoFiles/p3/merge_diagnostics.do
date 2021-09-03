********************************************************************************
********************************************************************************
*									EXACT									   *
********************************************************************************
********************************************************************************


********************************************************************************

use "$directorio\DB\survey_data_2m.dta", clear
qui merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3) nogen
duplicates drop plaintiff_name, force
merge 1:m plaintiff_name using "$directorio\_aux\expedientes_long.dta", keep (1 3)
*Match up to admin data date
qui su survey_date
drop if inrange(survey_date,`r(min)',date("31/03/2019","DMY"))!=1 & _merge==1
duplicates drop id_actor, force
*Sue exact
rename demanda demanda_exact


keep id_actor FOLIO EXPEDIENTE JUNTA plaintiff_name* nombre_actor nombre_demandado* ///
	main_treatment entablo_demanda conflicto_arreglado ///
	demanda_exact 
	

order id_actor FOLIO EXPEDIENTE JUNTA plaintiff_name* nombre_actor nombre_demandado* ///
	main_treatment entablo_demanda conflicto_arreglado ///
	demanda_exact 
	
sort id_actor
gen n=_n


save "$directorio\_aux\merge_diagnostics_exact.dta", replace


 
********************************************************************************
********************************************************************************
********************************************************************************


	
	
