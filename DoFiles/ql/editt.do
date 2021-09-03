
do "$directorio\DoFiles\initials_dataset.do"


*Generation of variables of interest
do "$directorio\DoFiles\gen_measures.do"


*Variable name cleaning
foreach var of varlist perc* {
	local nvar=substr("`var'",6,.)
	cap rename `var' `nvar'
	}

foreach var of varlist ratio* {
	local nvar=substr("`var'",7,.)
	cap rename `var' `nvar'
	}

	

	
eststo clear		
	
foreach varj of varlist $output_varlist {


	eststo :   reg `varj' giro_defendant_c_clv  ///
indem_const_c_clv  ///
reinstalacion_c_clv  ///
dias20_c_clv  ///
antiguedad_c_clv  ///
vacaciones_c_clv  ///
prima_vac_c_clv  ///
giro_c_clv  ///
categoria_c_clv  ///
horario_inicio_jornada_c_clv  ///
especifican_dias_c_clv  ///
periodo_salario_c_clv  ///
nombre_despide_c_clv  ///
derecho_propio_c_clv  ///
nombre_law_c_clv  ///
mun_plaintiff_c_clv  ///
 ad_cautelam_clv ///
 declaracion_junta_clv ///
 $bvc, r
	estadd scalar Erre=e(r2)
	qui su `varj' if e(sample)
	estadd scalar DepVarMean=r(mean)
	estadd scalar F_stat=e(F)

	}
	
**********
esttab using "$directorio/Tables/reg_results/predict_100_sw.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
scalars("Erre R-squared"  "DepVarMean DepVarMean"  "F_stat F_stat") replace 
 	
