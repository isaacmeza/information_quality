*SETTLEMENT AGAINST GENDER & INTERACTION WITH TREATMENT ARMS REGRESSIONS



********************************************************************************
*									2W								  		   *
********************************************************************************
use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)

********************************************************************************

eststo clear	
eststo: reg conflicto_arreglado i.mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)
qui su mujer if e(sample)
estadd scalar woman=r(mean)	
eststo: reg conflicto_arreglado i.main_treatment##i.mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)
qui su mujer if e(sample)
estadd scalar woman=r(mean)	

	
	

********************************************************************************
*									2M								  		   *
********************************************************************************
use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)

********************************************************************************

eststo: reg conflicto_arreglado i.mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)
qui su mujer if e(sample)
estadd scalar woman=r(mean)		
eststo: reg conflicto_arreglado i.main_treatment##i.mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)
qui su mujer if e(sample)
estadd scalar woman=r(mean)		

	
	*************************
	esttab using "$directorio/Tables/reg_results/reg_sett_gen.csv", se r2 star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("woman % Woman") replace 
	
