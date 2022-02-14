
import delimited "$directorio/_aux/case_value.csv",  clear
duplicates drop
drop if missing(id_actor)

tempfile temp
save `temp'



use "$directorio\DB\iniciales_dem.dta" , clear
merge m:1 junta exp anio using  "$directorio\DB\seguimiento_dem.dta", nogen
keep junta exp anio id_actor modo_termino_ofirec fecha_termino_ofirec cantidad_ofirec  cantidad_inegi cantidad_otorgada convenio_pagado_completo cantidad_pagada sueldo_estadistico periodicidad_sueldo_estadistic 
merge m:m id_actor using `temp', nogen
merge m:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3) nogen
merge m:m junta exp anio using "$directorio\DB\lawyer_scores_p3.dta", nogen 



gen case_value = prez_hgb if dem==1
replace case_value = prez_hgb if dem==0

duplicates drop total case_v, force

reg  total case_value, r