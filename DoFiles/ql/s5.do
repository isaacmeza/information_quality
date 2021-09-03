*Impact of the update in expectations in the settlement rate

				
*						2m settlement vs. Inmediate exp - Baseline             *
********************************************************************************

		 
use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(3)


*****************************      PROBABILITY      ****************************

*Independent dummy variable
gen bajo_inm=prob_ganar_treat<prob_ganar if  !missing(prob_ganar) & !missing(prob_ganar_treat)
replace bajo_inm=0 if main_treatment==1 & !missing(prob_ganar)


*****************************
*       REGRESSIONS         *
*****************************

gen esample=.

eststo clear


*First stage
eststo: reg bajo_inm i.main_treatment mujer antiguedad salario_diario, ///
	cluster(fecha_alta)  
estadd scalar Erre=e(r2)
test (2.main_treatment=0) (3.main_treatment=0)
estadd scalar Efe=r(F)
estadd local BVC="YES"
estadd local Source="2m"	

*Second stage
eststo: ivregress 2sls conflicto_arreglado    ///
         mujer antiguedad salario_diario ///
		 (bajo_inm = i.main_treatment), cluster(fecha_alta) first
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"
replace esample=e(sample)	 
		 

******************************        AMOUNT        ****************************

*Independent dummy variable
cap drop bajo_inm
gen bajo_inm=cantidad_ganar_treat<cantidad_ganar if  !missing(cantidad_ganar) & !missing(cantidad_ganar_treat)
replace bajo_inm=0 if main_treatment==1 & !missing(cantidad_ganar)


*****************************
*       REGRESSIONS         *
*****************************
*First stage
eststo:  reg bajo_inm i.main_treatment mujer antiguedad salario_diario , ///
	cluster(fecha_alta)  
estadd scalar Erre=e(r2)
test (2.main_treatment=0) (3.main_treatment=0)
estadd scalar Efe=r(F)
estadd local BVC="YES"
estadd local Source="2m"		 
	

*Second Stage
eststo: ivregress 2sls conflicto_arreglado    ///
         mujer antiguedad salario_diario ///
		 (bajo_inm = i.main_treatment), cluster(fecha_alta) first
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"
replace esample=e(sample)	 

			
*************************
	esttab using "$directorio/Tables_Draft/reg_results/iv_inm_update_2m.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	order(bajo_inm *main_treatment mujer antiguedad salario_diario) ///
	scalars("Erre R-squared" "Efe F-statistic" "BVC BVC" "Source Source") replace 
	
	

*						2m settlement vs. Survey 2w - Baseline                 *
********************************************************************************

		 
use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3) 
keep group id_actor prob_ganar_survey prob_ganar cantidad_ganar_survey cantidad_ganar main_treatment mujer antiguedad salario_diario fecha_alta
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keepusing(conflicto_arreglado)


*****************************      PROBABILITY      ****************************

*Independent dummy variable
gen bajo_inm=prob_ganar_survey<prob_ganar if  !missing(prob_ganar) & !missing(prob_ganar_survey)


*****************************
*       REGRESSIONS         *
*****************************

gen esample=.
eststo clear


*First stage
eststo:  reg bajo_inm i.group mujer antiguedad salario_diario , ///
	cluster(fecha_alta)  
test 2.group
estadd scalar Efe=r(F)	
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w-2m"		 

*Second stage
eststo: ivregress 2sls conflicto_arreglado    ///
         mujer antiguedad salario_diario ///
		 (bajo_inm = i.group), cluster(fecha_alta) first
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w-2m"
replace esample=e(sample)
		 

******************************        AMOUNT        ****************************

*Independent dummy variable
cap drop bajo_inm
gen bajo_inm=cantidad_ganar_survey<cantidad_ganar if  !missing(cantidad_ganar) & !missing(cantidad_ganar_survey)


*****************************
*       REGRESSIONS         *
*****************************


*First stage
eststo:  reg bajo_inm i.group mujer antiguedad salario_diario , ///
	cluster(fecha_alta)  
test 2.group
estadd scalar Efe=r(F)	
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w-2m"		 

*Second stage
eststo: ivregress 2sls conflicto_arreglado    ///
         mujer antiguedad salario_diario ///
		 (bajo_inm = i.group), cluster(fecha_alta) first
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w-2m"
replace esample=e(sample)

			
*************************
	esttab using "$directorio/Tables_Draft/reg_results/iv_2w_update_2m_AB.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	order(bajo_inm *group mujer antiguedad salario_diario) ///
	scalars("Erre R-squared" "Efe F-statistic" "BVC BVC" "Source Source") replace 
				
			
				
		
