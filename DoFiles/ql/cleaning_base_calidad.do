*CLEANING OF RATINGS OF LAWYERS DATASET

********************************************************************************
*Judges Opinion
insheet using "$directorio\Raw\Captura Express Completo.csv", clear
keep junta exp ao totaldictaminador
destring totaldictaminador, replace force
rename ao anio
tempfile temp_dictamen
save `temp_dictamen'
********************************************************************************
*Laura's Grades
import excel "$directorio\Raw\Calificaciones prioritarias y de abogados.xlsx", ///
	sheet("Calificaciones prioritarias y d") firstrow clear
tempfile temp_laura
save `temp_laura'


********************************************************************************

*Payment to lawyers according to TOR

import delimited "$directorio\Raw\base_abogados.csv", varnames(1) clear 


*Cleaning
foreach var of varlist * {
	replace `var' = subinstr(`var', `"""', "",.)
	}

	*Cleaning of time
gen fecha_fin = date(substr(fin,1,11),"YMD")
format fecha_fin %td


	*Scores & Prediction
foreach var of varlist preg1calif preg2calif preg3calif preg4calif preg5calif califglobal ///
				predicciona prediccionb prediccionc predicciond prediccione prediccionmonto1 prediccionmonto2 {
	destring `var', replace force
	}	
encode prediccionseleccion1, gen(prediccion_seleccion1)
encode prediccionseleccion2, gen(prediccion_seleccion2)
drop prediccionseleccion*	

foreach var of varlist predicciona prediccionb prediccionc predicciond prediccione {
	replace  `var'=0 if missing(`var')
	}
	
rename numexpediente nombre_archivo_abogado
replace nombre_archivo_abogado = subinstr(nombre_archivo_abogado, " ", "",.)
replace nombre_archivo_abogado = "6_" + ///
	substr(nombre_archivo_abogado,3,length(nombre_archivo_abogado)) ///
		if strpos(nombre_archivo_abogado,"0_")!=0 & ///
		strpos(nombre,"Sergio Cuadra Flores")!=0
replace nombre_archivo_abogado = "8_" + ///
	substr(nombre_archivo_abogado,3,length(nombre_archivo_abogado)) ///
		if strpos(nombre_archivo_abogado,"0_")!=0 & ///
		strpos(nombre,"Miguel Angel")!=0		
		

merge 1:1 nombre_archivo_abogado using "$directorio\Raw\relacion_base_calidad.dta", keep(3) nogen
rename expediente exp
rename ao anio

append using `temp_laura', force

merge m:1 junta exp anio using "$directorio\DB\lawyer_dataset_predicc.dta", keep(3) nogen
merge m:m junta exp anio using `temp_dictamen', keep(1 3) nogen

gen lc=_n
tostring lc, replace
replace nombre_archivo_abogado = "0_0_" if strpos(nombre,"Laura Aquino")!=0
replace nombre_archivo_abogado = nombre_archivo_abogado + lc if strpos(nombre,"Laura Aquino")!=0
drop lc

duplicates drop nombre_archivo_abogado, force


save "$directorio\DB\base_calidad_abogados.dta", replace
