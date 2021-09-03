

*Merge with Sues
use "$directorio\DB\survey_data_2m.dta", clear
qui merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3) nogen
duplicates drop plaintiff_name, force
merge 1:m plaintiff_name using "$directorio\_aux\expedientes_long.dta", keep (1 3)  keepusing(demanda EXPEDIENTE JUNTA FOLIO)
rename demanda demanda_exact
merge m:m id_actor using "$directorio\_aux\fuzzy_sue_match.dta", keep (1 3) nogen 


keep FOLIO EXPEDIENTE JUNTA plaintiff_name* nombre_actor id_actor similscore entablo_demanda
order FOLIO EXPEDIENTE JUNTA plaintiff_name* nombre_actor id_actor similscore entablo_demanda
sort similscore

export delimited using "$directorio\_aux\lista_expedientes_demanda_match.csv", replace
