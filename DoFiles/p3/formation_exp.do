use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(3)

local controls mujer antiguedad salario_diario

levelsof que_elemento_es_el_mas_important, local(levels) 	
foreach outcome of local levels {
	gen formation_exp_`outcome'=(que_elemento_es_el_mas_important==`outcome') if !missing(que_elemento_es_el_mas_important)
	}

eststo clear	
*********************************	   
*Multiple Logistic Regression 
*********************************
*https://stats.idre.ucla.edu/stata/dae/logistic-regression/

foreach outcome of local levels {
	eststo: reg formation_exp_`outcome' i.main_treatment `controls', r cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	qui test 2.main_treatment=3.main_treatment
	estadd scalar test_23=`r(p)'	
	qui su formation_exp_`outcome' if e(sample)
	estadd scalar DepVarMean=r(mean)
	estadd local BVC="YES"
	estadd local Source="2m"
	eststo: logit formation_exp_`outcome' i.main_treatment `controls', r cluster(fecha_alta)
	estadd scalar Erre=e(r2_p)
	qui test 2.main_treatment=3.main_treatment
	estadd scalar test_23=`r(p)'	
	qui su formation_exp_`outcome' if e(sample)
	estadd scalar DepVarMean=r(mean)
	estadd local BVC="YES"
	estadd local Source="2m"
	}

	*************************
	esttab using "$directorio/Tables/reg_results/logit_formation_exp.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "DepVarMean DepVarMean" "BVC BVC" "Source Source" "test_23 T2=T3") replace 
	
	
eststo clear	
*********************************	   
*Multinomial Logistic Regression
*********************************
*https://stats.idre.ucla.edu/stata/dae/multinomiallogistic-regression/

eststo: mlogit que_elemento_es_el_mas_important i.main_treatment `controls', r cluster(fecha_alta)
estadd scalar Erre=e(r2_p)
estadd local BVC="YES"
estadd local Source="2m"

	*************************
	esttab using "$directorio/Tables/reg_results/mlogit_formation_exp.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "BVC BVC" "Source Source" ) replace 
	
