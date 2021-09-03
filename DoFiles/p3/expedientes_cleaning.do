
********************************************************************************
forvalues j=1/3 {
import excel "$directorio\Raw\expedientes_`j'.xlsx", sheet("Detalle actores") firstrow clear
drop FECHA_INGRESO JUNTA

duplicates drop

rename ACTOR nombre_actor

save "$directorio\_aux\detalle_actores_long_`j'.dta", replace
}

********************************************************************************
forvalues j=1/3 {
import excel "$directorio\Raw\expedientes_`j'.xlsx", sheet("Detalle demandados") firstrow clear
drop FECHA_INGRESO JUNTA

duplicates drop

rename DEMANDADO nombre_demandado

save "$directorio\_aux\detalle_demandados_long_`j'.dta", replace
}

********************************************************************************
forvalues j=1/3 {
import excel "$directorio\Raw\expedientes_`j'.xlsx", sheet("Demandas gral") firstrow clear
drop FECHA_INGRESO

duplicates drop

rename DEMANDADO nombre_demandado
rename ACTOR nombre_actor

save "$directorio\_aux\demandas_gral_`j'.dta", replace
}

********************************************************************************
forvalues j=1/3 {
import excel "$directorio\Raw\expedientes_`j'.xlsx", sheet("Convenios") firstrow clear
drop FECHA_INGRESO

duplicates drop

rename DEMANDADO nombre_demandado
rename ACTOR nombre_actor

save "$directorio\_aux\convenios_`j'.dta", replace
}

********************************************************************************
use "$directorio\_aux\detalle_actores_long_1.dta", clear
append using "$directorio\_aux\detalle_actores_long_2.dta"
append using "$directorio\_aux\detalle_actores_long_3.dta"
duplicates drop
save "$directorio\_aux\detalle_actores_long.dta", replace

use "$directorio\_aux\detalle_demandados_long_1.dta", clear
append using "$directorio\_aux\detalle_demandados_long_2.dta"
append using "$directorio\_aux\detalle_demandados_long_3.dta"
duplicates drop
save "$directorio\_aux\detalle_demandados_long.dta", replace

use "$directorio\_aux\demandas_gral_1.dta", clear
append using "$directorio\_aux\demandas_gral_2.dta"
append using "$directorio\_aux\demandas_gral_3.dta"
duplicates drop
save "$directorio\_aux\demandas_gral.dta", replace

use "$directorio\_aux\convenios_1.dta", clear
append using "$directorio\_aux\convenios_2.dta", force
append using "$directorio\_aux\convenios_3.dta", force
duplicates drop
save "$directorio\_aux\convenios.dta", replace

********************************************************************************

use "$directorio\_aux\demandas_gral.dta", clear
destring JUNTA, replace
append using "$directorio\_aux\detalle_actores_long.dta"
duplicates drop FOLIO nombre_actor, force

*Identify sues
gen demanda=1

gsort FOLIO -EXPEDIENTE -JUNTA
bysort FOLIO: replace EXPEDIENTE = EXPEDIENTE[_n-1] if missing(EXPEDIENTE) 
bysort FOLIO: replace JUNTA = JUNTA[_n-1] if missing(JUNTA)


append using "$directorio\_aux\convenios.dta"

*Identify settlements
replace demanda=0 if missing(demanda)

save "$directorio\_aux\expedientes_long.dta", replace

********************************************************************************

