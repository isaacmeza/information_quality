*Update in expectations against gender interacted with the treatment arms

eststo clear

*							Inmediate exp - Baseline    	   			       *
********************************************************************************

		 
use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2w.dta", keep(3)


*****************************      PROBABILITY      ****************************

*Independent dummy variable
cap drop bajo_inm
gen bajo_inm=prob_ganar_treat<prob_ganar if  !missing(prob_ganar) & !missing(prob_ganar_treat)
replace bajo_inm=0 if main_treatment==1 & !missing(prob_ganar)

eststo: reg bajo_inm i.main_treatment##i.mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)
qui su mujer if e(sample)
estadd scalar woman=r(mean)	

*Independent continuous variable
cap drop bajo_inm
gen bajo_inm=prob_ganar_treat-prob_ganar if !missing(prob_ganar) & !missing(prob_ganar_treat)
replace bajo_inm=0 if main_treatment==1 & !missing(prob_ganar)

eststo: reg bajo_inm i.main_treatment##i.mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)
qui su mujer if e(sample)
estadd scalar woman=r(mean)		
	
******************************        AMOUNT        ****************************

*Independent dummy variable
cap drop bajo_inm
gen bajo_inm=cantidad_ganar_treat<cantidad_ganar if  !missing(cantidad_ganar) & !missing(cantidad_ganar_treat)
replace bajo_inm=0 if main_treatment==1 & !missing(cantidad_ganar)

eststo: reg bajo_inm i.main_treatment##i.mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)
qui su mujer if e(sample)
estadd scalar woman=r(mean)	

*Independent dummy variable
cap drop bajo_inm
gen bajo_inm=cantidad_ganar_treat-cantidad_ganar if !missing(cantidad_ganar) & !missing(cantidad_ganar_treat)
replace bajo_inm=0 if main_treatment==1 & !missing(cantidad_ganar)

eststo: reg bajo_inm i.main_treatment##i.mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)	
qui su mujer if e(sample)
estadd scalar woman=r(mean)					
				
*								2W - Baseline  		 	  	   			       *
********************************************************************************

*****************************      PROBABILITY      ****************************

*Independent dummy variable
cap drop bajo_inm
gen bajo_inm=prob_ganar_survey<prob_ganar if  !missing(prob_ganar) & !missing(prob_ganar_survey)

eststo: reg bajo_inm i.main_treatment##i.mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)
qui su mujer if e(sample)
estadd scalar woman=r(mean)	

*Independent continuous variable
cap drop bajo_inm
gen bajo_inm=prob_ganar_survey-prob_ganar if !missing(prob_ganar) & !missing(prob_ganar_survey)

eststo: reg bajo_inm i.main_treatment##i.mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)
qui su mujer if e(sample)
estadd scalar woman=r(mean)	
	
	
******************************        AMOUNT        ****************************

*Independent dummy variable
cap drop bajo_inm
gen bajo_inm=cantidad_ganar_survey<cantidad_ganar if  !missing(cantidad_ganar) & !missing(cantidad_ganar_survey)

eststo: reg bajo_inm i.main_treatment##i.mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)
qui su mujer if e(sample)
estadd scalar woman=r(mean)	

*Independent dummy variable
cap drop bajo_inm
gen bajo_inm=cantidad_ganar_survey-cantidad_ganar if !missing(cantidad_ganar) & !missing(cantidad_ganar_survey)

eststo: reg bajo_inm i.main_treatment##i.mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)	
qui su mujer if e(sample)
estadd scalar woman=r(mean)	
	
	
	
use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(3)


*								2M - Baseline  		 	  	   			       *
********************************************************************************

*****************************      PROBABILITY      ****************************

*Independent dummy variable
cap drop bajo_inm
gen bajo_inm=prob_ganar_survey<prob_ganar if  !missing(prob_ganar) & !missing(prob_ganar_survey)

eststo: reg bajo_inm i.main_treatment##i.mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)
qui su mujer if e(sample)
estadd scalar woman=r(mean)	

*Independent continuous variable
cap drop bajo_inm
gen bajo_inm=prob_ganar_survey-prob_ganar if !missing(prob_ganar) & !missing(prob_ganar_survey)

eststo: reg bajo_inm i.main_treatment##i.mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)
qui su mujer if e(sample)
estadd scalar woman=r(mean)	
	
	
******************************        AMOUNT        ****************************

*Independent dummy variable
cap drop bajo_inm
gen bajo_inm=cantidad_ganar_survey<cantidad_ganar if  !missing(cantidad_ganar) & !missing(cantidad_ganar_survey)

eststo: reg bajo_inm i.main_treatment##i.mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)
qui su mujer if e(sample)
estadd scalar woman=r(mean)	

*Independent dummy variable
cap drop bajo_inm
gen bajo_inm=cantidad_ganar_survey-cantidad_ganar if !missing(cantidad_ganar) & !missing(cantidad_ganar_survey)

eststo: reg bajo_inm i.main_treatment##i.mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)
qui su mujer if e(sample)
estadd scalar woman=r(mean)	





*									2M - 2W            				           *
********************************************************************************

		 
use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3) 
keep id_actor prob_ganar_survey  cantidad_ganar_survey  main_treatment mujer antiguedad salario_diario fecha_alta
rename prob_ganar_survey prob_ganar_survey_2w
rename cantidad_ganar_survey cantidad_ganar_survey_2w
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keepusing(cantidad_ganar_survey prob_ganar_survey)


*****************************      PROBABILITY      ****************************

*Independent dummy variable
cap drop bajo_inm
gen bajo_inm=prob_ganar_survey<prob_ganar_survey_2w if  !missing(prob_ganar_survey_2w) & !missing(prob_ganar_survey)

eststo: reg bajo_inm i.main_treatment##i.mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)
qui su mujer if e(sample)
estadd scalar woman=r(mean)	

*Independent continuous variable
cap drop bajo_inm
gen bajo_inm=prob_ganar_survey-prob_ganar_survey_2w if !missing(prob_ganar_survey_2w) & !missing(prob_ganar_survey)

eststo: reg bajo_inm i.main_treatment##i.mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)
qui su mujer if e(sample)
estadd scalar woman=r(mean)	
	
	
******************************        AMOUNT        ****************************

*Independent dummy variable
cap drop bajo_inm
gen bajo_inm=cantidad_ganar_survey<cantidad_ganar_survey_2w if  !missing(cantidad_ganar_survey_2w) & !missing(cantidad_ganar_survey)

eststo: reg bajo_inm i.main_treatment##i.mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)
qui su mujer if e(sample)
estadd scalar woman=r(mean)	

*Independent dummy variable
cap drop bajo_inm
gen bajo_inm=cantidad_ganar_survey-cantidad_ganar_survey_2w if !missing(cantidad_ganar_survey_2w) & !missing(cantidad_ganar_survey)

eststo: reg bajo_inm i.main_treatment##i.mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)
qui su mujer if e(sample)
estadd scalar woman=r(mean)	

	
*************************
	esttab using "$directorio/Tables/reg_results/update_treatment_gen.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) r2 ///
	scalars("woman % Woman") replace 
				
			
			
