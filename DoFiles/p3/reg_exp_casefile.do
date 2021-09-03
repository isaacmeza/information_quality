********************************************************************************
*									2M								  		   *
********************************************************************************
use "$directorio\DB\treatment_data.dta", clear


local controls mujer antiguedad salario_diario
local more_controls `controls' reclutamiento dummy_confianza horas_sem dummy_desc_sem dummy_prima_dom dummy_desc_ob dummy_sarimssinfo carta_renuncia dummy_reinst c_min_indem c_min_prima_antig c_min_ag c_min_total
 
  
*******************************
* 			REGRESSIONS		  *
*******************************

********************************************************************************
	*Baseline exp
eststo clear

eststo: reg  cantidad_ganar ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su cantidad_ganar if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="Baseline"	
eststo: reg  cantidad_ganar ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su cantidad_ganar if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="Baseline"	


eststo: reg prob_ganar ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su prob_ganar if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="Baseline"	
eststo: reg prob_ganar ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su prob_ganar if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="Baseline"	


	*************************
	esttab using "$directorio/Tables/reg_results/reg_exp_casefile.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "DepVarMean DepVarMean" "BVC BVC" "MC MC" "Source Source" ) replace 
	
