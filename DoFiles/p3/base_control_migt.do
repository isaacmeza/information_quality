use "$directorio\_aux\match_.dta", clear
merge m:m idadmin using  "$directorio\_aux\expedientes_long.dta", keep(3) keepusing(EXPEDIENTE JUNTA FOLIO)
duplicates drop
keep id id_actor	nombre_actor	plaintiff_name	nombre_demandado1	nombre_demandado2	nombre_demandado3	nombre_demandado4	nombre_demandado5	nombre_demandado6	main_treatment	fecha_alta	fecha_salida	fecha_entrada	giro	similscore	idadmin	plaintiff_name1 JUNTA EXPEDIENTE FOLIO
order id id_actor	nombre_actor	plaintiff_name	nombre_demandado1	nombre_demandado2	nombre_demandado3	nombre_demandado4	nombre_demandado5	nombre_demandado6	main_treatment	fecha_alta	fecha_salida	fecha_entrada	giro	similscore	idadmin	plaintiff_name1 JUNTA EXPEDIENTE FOLIO
gsort -similscore
save "$directorio\_aux\mtch.dta", replace

*Flag to indicate urgency
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keepusing(id_actor)
rename _merge flag
gsort -similscore
export delimited using "$directorio\_aux\match.csv", replace
