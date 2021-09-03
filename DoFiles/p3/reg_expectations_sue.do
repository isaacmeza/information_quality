********************************************************************************
*									2M								  		   *
********************************************************************************
use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)


local controls mujer antiguedad salario_diario
local more_controls `controls' reclutamiento dummy_confianza horas_sem dummy_desc_sem dummy_prima_dom dummy_desc_ob dummy_sarimssinfo carta_renuncia dummy_reinst c_min_indem c_min_prima_antig c_min_ag c_min_total 
  
*******************************
* 			REGRESSIONS		  *
*******************************

********************************************************************************
	*2M EXPECTATIONS
eststo clear

eststo: reg cantidad_ganar_survey  i.demando_con_abogado_publico cantidad_ganar ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su cantidad_ganar_survey if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2m"	
eststo: reg cantidad_ganar_survey  i.demando_con_abogado_publico cantidad_ganar ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su cantidad_ganar_survey if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2m"	


eststo: reg cant_mayor_survey  i.demando_con_abogado_publico cantidad_coarse ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su cant_mayor_survey if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2m"	
eststo: reg cant_mayor_survey  i.demando_con_abogado_publico cantidad_coarse ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su cant_mayor_survey if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2m"	


eststo: reg prob_ganar_survey  i.demando_con_abogado_publico prob_ganar ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su prob_ganar_survey if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2m"	
eststo: reg prob_ganar_survey  i.demando_con_abogado_publico prob_ganar ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su prob_ganar_survey if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2m"	


eststo: reg prob_mayor_survey  i.demando_con_abogado_publico prob_coarse ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su prob_mayor_survey if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2m"	
eststo: reg prob_mayor_survey  i.demando_con_abogado_publico prob_coarse ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su prob_mayor_survey if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2m"


	*************************
	esttab using "$directorio/Tables/reg_results/reg_expectation_2m.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "DepVarMean DepVarMean" "BVC BVC" "MC MC" "Source Source" ) replace 
	
	
	
********************************************************************************
	*SUE
eststo clear

eststo: reg entablo_demanda cantidad_ganar ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su entablo_demanda if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2m"	
eststo: reg entablo_demanda cantidad_ganar ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su entablo_demanda if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2m"


eststo: reg entablo_demanda cantidad_coarse ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su entablo_demanda if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2m"	
eststo: reg entablo_demanda cantidad_coarse ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su entablo_demanda if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2m"	


eststo: reg entablo_demanda prob_ganar ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su entablo_demanda if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2m"	
eststo: reg entablo_demanda prob_ganar ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su entablo_demanda if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2m"


eststo: reg entablo_demanda prob_coarse ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su entablo_demanda if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2m"	
eststo: reg entablo_demanda prob_coarse ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su entablo_demanda if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2m"


eststo: reg entablo_demanda cantidad_ganar prob_ganar ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su entablo_demanda if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2m"	
eststo: reg entablo_demanda cantidad_ganar prob_ganar ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su entablo_demanda if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2m"


eststo: reg entablo_demanda cantidad_coarse prob_coarse ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su entablo_demanda if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2m"	
eststo: reg entablo_demanda cantidad_coarse prob_coarse ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su entablo_demanda if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2m"


	*************************
	esttab using "$directorio/Tables/reg_results/reg_sue_2m.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "DepVarMean DepVarMean" "BVC BVC" "MC MC" "Source Source" ) replace 
	
	
********************************************************************************
	*PUBLIC LAWYER
eststo clear

eststo: reg demando_con_abogado_publico cantidad_ganar ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su demando_con_abogado_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2m"	
eststo: reg demando_con_abogado_publico cantidad_ganar ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su demando_con_abogado_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2m"


eststo: reg demando_con_abogado_publico cantidad_coarse ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su demando_con_abogado_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2m"	
eststo: reg demando_con_abogado_publico cantidad_coarse ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su demando_con_abogado_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2m"	


eststo: reg demando_con_abogado_publico prob_ganar ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su demando_con_abogado_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2m"	
eststo: reg demando_con_abogado_publico prob_ganar ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su demando_con_abogado_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2m"


eststo: reg demando_con_abogado_publico prob_coarse ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su demando_con_abogado_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2m"	
eststo: reg demando_con_abogado_publico prob_coarse ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su demando_con_abogado_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2m"


eststo: reg demando_con_abogado_publico cantidad_ganar prob_ganar ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su demando_con_abogado_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2m"	
eststo: reg demando_con_abogado_publico cantidad_ganar prob_ganar ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su demando_con_abogado_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2m"


eststo: reg demando_con_abogado_publico cantidad_coarse prob_coarse ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su demando_con_abogado_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2m"	
eststo: reg demando_con_abogado_publico cantidad_coarse prob_coarse ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su demando_con_abogado_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2m"


	*************************
	esttab using "$directorio/Tables/reg_results/reg_sue_public_2m.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "DepVarMean DepVarMean" "BVC BVC" "MC MC" "Source Source" ) replace 
	
