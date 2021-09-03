********************************************************************************
*									2W								  		   *
********************************************************************************
use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)


local controls mujer antiguedad salario_diario
local more_controls `controls' reclutamiento dummy_confianza horas_sem dummy_desc_sem dummy_prima_dom dummy_desc_ob dummy_sarimssinfo carta_renuncia dummy_reinst c_min_indem c_min_prima_antig c_min_ag c_min_total 
  
*******************************
* 			REGRESSIONS		  *
*******************************

********************************************************************************
	*2W EXPECTATIONS
eststo clear

eststo: reg cantidad_ganar_survey  i.cond_hablo_con_publico cantidad_ganar ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su cantidad_ganar_survey if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2w"	
eststo: reg cantidad_ganar_survey  i.cond_hablo_con_publico cantidad_ganar ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su cantidad_ganar_survey if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2w"	


eststo: reg cant_mayor_survey  i.cond_hablo_con_publico cantidad_coarse ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su cant_mayor_survey if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2w"	
eststo: reg cant_mayor_survey  i.cond_hablo_con_publico cantidad_coarse ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su cant_mayor_survey if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2w"	


eststo: reg prob_ganar_survey  i.cond_hablo_con_publico prob_ganar ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su prob_ganar_survey if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2w"	
eststo: reg prob_ganar_survey  i.cond_hablo_con_publico prob_ganar ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su prob_ganar_survey if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2w"	


eststo: reg prob_mayor_survey  i.cond_hablo_con_publico prob_coarse ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su prob_mayor_survey if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2w"	
eststo: reg prob_mayor_survey  i.cond_hablo_con_publico prob_coarse ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su prob_mayor_survey if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2w"


	*************************
	esttab using "$directorio/Tables/reg_results/reg_expectation_2w.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "DepVarMean DepVarMean" "BVC BVC" "MC MC" "Source Source" ) replace 
	
	
	
********************************************************************************
	*TALKED LAWYER
eststo clear

eststo: reg hablo_con_abogado cantidad_ganar ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su hablo_con_abogado if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2w"	
eststo: reg hablo_con_abogado cantidad_ganar ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su hablo_con_abogado if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2w"


eststo: reg hablo_con_abogado cantidad_coarse ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su hablo_con_abogado if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2w"	
eststo: reg hablo_con_abogado cantidad_coarse ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su hablo_con_abogado if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2w"	


eststo: reg hablo_con_abogado prob_ganar ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su hablo_con_abogado if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2w"	
eststo: reg hablo_con_abogado prob_ganar ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su hablo_con_abogado if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2w"


eststo: reg hablo_con_abogado prob_coarse ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su hablo_con_abogado if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2w"	
eststo: reg hablo_con_abogado prob_coarse ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su hablo_con_abogado if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2w"


eststo: reg hablo_con_abogado cantidad_ganar prob_ganar ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su hablo_con_abogado if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2w"	
eststo: reg hablo_con_abogado cantidad_ganar prob_ganar ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su hablo_con_abogado if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2w"


eststo: reg hablo_con_abogado cantidad_coarse prob_coarse ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su hablo_con_abogado if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2w"	
eststo: reg hablo_con_abogado cantidad_coarse prob_coarse ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su hablo_con_abogado if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2w"


	*************************
	esttab using "$directorio/Tables/reg_results/reg_talked_2w.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "DepVarMean DepVarMean" "BVC BVC" "MC MC" "Source Source" ) replace 
	
	
********************************************************************************
	*PUBLIC LAWYER
eststo clear

eststo: reg cond_hablo_con_publico cantidad_ganar ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su cond_hablo_con_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2w"	
eststo: reg cond_hablo_con_publico cantidad_ganar ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su cond_hablo_con_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2w"


eststo: reg cond_hablo_con_publico cantidad_coarse ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su cond_hablo_con_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2w"	
eststo: reg cond_hablo_con_publico cantidad_coarse ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su cond_hablo_con_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2w"	


eststo: reg cond_hablo_con_publico prob_ganar ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su cond_hablo_con_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2w"	
eststo: reg cond_hablo_con_publico prob_ganar ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su cond_hablo_con_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2w"


eststo: reg cond_hablo_con_publico prob_coarse ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su cond_hablo_con_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2w"	
eststo: reg cond_hablo_con_publico prob_coarse ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su cond_hablo_con_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2w"


eststo: reg cond_hablo_con_publico cantidad_ganar prob_ganar ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su cond_hablo_con_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2w"	
eststo: reg cond_hablo_con_publico cantidad_ganar prob_ganar ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su cond_hablo_con_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2w"


eststo: reg cond_hablo_con_publico cantidad_coarse prob_coarse ///
		`controls', robust cluster(fecha_alta)
estadd scalar Erre=e(r2)
qui su cond_hablo_con_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="NO"
estadd local Source="2w"	
eststo: reg cond_hablo_con_publico cantidad_coarse prob_coarse ///
		`more_controls', robust cluster(fecha_alta)		
estadd scalar Erre=e(r2)
qui su cond_hablo_con_publico if e(sample)
estadd scalar DepVarMean=r(mean)
estadd local BVC="YES"
estadd local MC="YES"
estadd local Source="2w"


	*************************
	esttab using "$directorio/Tables/reg_results/reg_talked_public_2w.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "DepVarMean DepVarMean" "BVC BVC" "MC MC" "Source Source" ) replace 
	
