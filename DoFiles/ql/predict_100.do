*Dataset ~100 initial casefiles
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
	
foreach varj of varlist $output_varlist calificacion_sub calificacion_obj {

	eststo : reg `varj' *_clv $bvc, r
	estadd scalar Erre=e(r2)
	qui su `varj' if e(sample)
	estadd scalar DepVarMean=r(mean)
	estadd scalar F_stat=e(F)

	}
	
**********
esttab using "$directorio/Tables/reg_results/predict_100.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
scalars("Erre R-squared"  "DepVarMean DepVarMean"  "F_stat F_stat") replace 
 
 	
hist calificacion_obj, xtitle("Score") scheme(s2mono) graphregion(color(white)) 
graph export "$directorio\Figuras\dist_score.pdf", replace
