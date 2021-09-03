use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(3)

local controls mujer antiguedad salario_diario

*How do you find your lawyer (private)
gen encontro_abogado=como_lo_consiguio
	*public
replace encontro_abogado=donde_lo_contacto+8 if missing(encontro_abogado)


label define encontro_abogado ///
	1 "Me lo recomendaron en la entrada de la Junta" ///
2 "Lo encontre en la entrada de la Junta" ///
3 "Me haba representado en un asunto anterior" /// 
4 "Fue recomendado por un familiar, amigo o conocido" ///
5 "Es un familiar, amigo o conocido" ///
6 "Lo encontre por internet" ///
7 "Lo encontre por algun otro medio de comunicacion" ///
8 "Otro" ///
9 "Publico - en la junta" ///
10 "Publico - Procuraduria"


label values encontro_abogado encontro_abogado


levelsof encontro_abogado, local(levels) 	
foreach outcome of local levels {
	gen find_lawyer_`outcome'=(encontro_abogado==`outcome') if !missing(encontro_abogado)
	}

	
eststo clear

foreach outcome of local levels {
	eststo: reg find_lawyer_`outcome' i.main_treatment `controls', r cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	qui test 2.main_treatment=3.main_treatment
	estadd local test_23=round(`r(p)',0.01)
	qui su find_lawyer_`outcome' if e(sample)
	estadd scalar DepVarMean=r(mean)
	estadd local BVC="YES"
	estadd local Source="2m"
	}

	*************************
	esttab using "$directorio/Tables/reg_results/find_lawyer.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "DepVarMean DepVarMean" "BVC BVC" "Source Source" "test_23 T2=T3" ) replace 
		
