*PREDICTING ATTRITION REGRESSIONS

*Load boosted reg program
program drop _all
do "$directorio\DoFiles\boosted_reg.do"
* a plugin has to be explicitly loaded (unlike an ado file)
* "capture" means that if it's loaded already this line won't give an error

*Directory for .\boost64.dll 
cd $directorio

capture program drop boost_plugin
program boost_plugin, plugin using(".\boost64.dll")
	
	
eststo clear

********************************************************************************
*									2W - 2M							  		   *
********************************************************************************
use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2w.dta", keep(1 3) keepusing(id_actor status_encuesta)

*Attrition rate
qui su date
gen attrition_2w=(_merge==1) if inrange(date,date("1/08/2017" ,"DMY"),date(c(current_date) ,"DMY")-21)
replace attrition_2w=1 if attrition_2w==0 & status_encuesta!=1

drop _merge
keep attrition_2w id_actor
tempfile temp2w
save `temp2w'

use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(1 3) keepusing(id_actor status_encuesta)
merge 1:1 id_actor using `temp2w', nogen

*Attrition rate
qui su date 
gen attrition_2m=(_merge==1) if inrange(date,`r(min)',date(c(current_date) ,"DMY")-70)
replace attrition_2m=1 if attrition_2m==0 & status_encuesta!=1


********************************************************************************

*Interactions
gen telefono_int=telefono_cel*telefono_fijo


*Regression 2w
eststo: regress attrition_2w  telefono* email  mujer na_prob na_cant *_coarse salario_diario antiguedad m_cp, r cluster(fecha_alta)
eststo: stepwise, pr(.2)  : regress attrition_2w  (telefono*) email  mujer na_prob na_cant *_coarse salario_diario antiguedad m_cp, r cluster(fecha_alta)
eststo: stepwise, pr(.2) hierarchical  : regress attrition_2w  (telefono*) email  mujer na_prob na_cant *_coarse salario_diario antiguedad m_cp, r cluster(fecha_alta)
boosted_reg attrition_2w  "telefono_cel telefono_fijo telefono_int email  mujer na_prob na_cant *_coarse salario_diario antiguedad m_cp" 0.7 
graph export "$directorio\Figuras\boost_attrition_2w.pdf", replace 
boosted_reg attrition_2w  "telefono_cel telefono_fijo telefono_int email  mujer na_prob na_cant *_coarse antiguedad  m_cp" 0.7 
graph export "$directorio\Figuras\boost_attrition_2wb.pdf", replace 
 


*Regression 2m
eststo: regress attrition_2m  telefono* email  mujer na_prob na_cant *_coarse salario_diario antiguedad m_cp, r cluster(fecha_alta)
eststo: stepwise, pr(.2)  : regress attrition_2m  (telefono*) email  mujer na_prob na_cant *_coarse salario_diario antiguedad m_cp, r cluster(fecha_alta)
eststo: stepwise, pr(.2) hierarchical  : regress attrition_2m  (telefono*) email  mujer na_prob na_cant *_coarse salario_diario antiguedad m_cp, r cluster(fecha_alta)
boosted_reg attrition_2m  "telefono_cel telefono_fijo telefono_int email  mujer na_prob na_cant *_coarse salario_diario antiguedad m_cp" 0.7 
graph export "$directorio\Figuras\boost_attrition_2m.pdf", replace 
boosted_reg attrition_2m  "telefono_cel telefono_fijo telefono_int email  mujer na_prob na_cant *_coarse antiguedad  m_cp" 0.7 
graph export "$directorio\Figuras\boost_attrition_2mb.pdf", replace 
 	
	


********************************************************************************
*									2W & 2M							  		   *
********************************************************************************
use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2w.dta", keep(3) keepusing(id_actor)
qui su date
keep if inrange(date,date("1/08/2017" ,"DMY"),date(c(current_date) ,"DMY")-21)

drop _merge
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(1 3) keepusing(id_actor status_encuesta)

*Attrition rate
qui su date 
gen attrition_2w2m=(_merge==1) if inrange(date,`r(min)',date(c(current_date) ,"DMY")-70)
replace attrition_2w2m=1 if attrition_2w2m==0 & status_encuesta!=1


********************************************************************************

*Interactions
gen telefono_int=telefono_cel*telefono_fijo


*Regression 2w2m
eststo: regress attrition_2w2m  telefono* email  mujer na_prob na_cant *_coarse salario_diario antiguedad m_cp, r cluster(fecha_alta)
eststo: stepwise, pr(.2)  : regress attrition_2w2m  (telefono*) email  mujer na_prob na_cant *_coarse salario_diario antiguedad m_cp, r cluster(fecha_alta)
eststo: stepwise, pr(.2) hierarchical  : regress attrition_2w2m  (telefono*) email  mujer na_prob na_cant *_coarse salario_diario antiguedad m_cp, r cluster(fecha_alta)
boosted_reg attrition_2w2m  "telefono_cel telefono_fijo telefono_int email  mujer na_prob na_cant *_coarse salario_diario antiguedad m_cp" 0.7 
graph export "$directorio\Figuras\boost_attrition_2w2m.pdf", replace 
boosted_reg attrition_2w2m  "telefono_cel telefono_fijo telefono_int email  mujer na_prob na_cant *_coarse antiguedad  m_cp" 0.7 
graph export "$directorio\Figuras\boost_attrition_2w2mb.pdf", replace 
	
	
	
	
	*************************
	esttab using "$directorio/Tables/reg_results/predict_attrition.csv", se  r2 star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	 replace 
		

		
********************************************************************************		
*DIFFERENTIAL ATTRIRION 
use "$directorio\DB\treatment_data.dta", clear
eststo clear
*Interactions
gen telefono_int=telefono_cel*telefono_fijo

foreach var of varlist telefono* salario_diario antiguedad {
	eststo: reg `var' i.main_treatment, r	
	}
	
	*************************
	esttab using "$directorio/Tables/reg_results/diff_attrition.csv", se  r2 star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	 replace 
			

eststo clear

foreach var of varlist telefono* salario_diario antiguedad {
	eststo: reg `var' i.group, r	
	}
	
	*************************
	esttab using "$directorio/Tables/reg_results/diff_attrition_ab.csv", se  r2 star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	 replace 
						
