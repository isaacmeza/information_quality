*Impact of the update in expectations in the settlement rate


*						2w settlement vs. Inmediate exp - Baseline             *
********************************************************************************

		 
use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2w.dta", keep(3)


*****************************      PROBABILITY      ****************************

*Independent dummy variable
gen bajo_inm=prob_ganar_treat<prob_ganar if  !missing(prob_ganar) & !missing(prob_ganar_treat)
replace bajo_inm=0 if main_treatment==1 & !missing(prob_ganar)


*****************************
*       REGRESSIONS         *
*****************************

gen esample=.
eststo clear

eststo: ivregress 2sls conflicto_arreglado    ///
         mujer antiguedad salario_diario ///
		 (bajo_inm = i.main_treatment), cluster(fecha_alta) first
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"
replace esample=e(sample)
eststo:  reg bajo_inm i.main_treatment mujer antiguedad salario_diario if esample==1, ///
	cluster(fecha_alta)  
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"		 
		 

*Independent continuous variable
cap drop bajo_inm
gen bajo_inm=prob_ganar_treat-prob_ganar if !missing(prob_ganar) & !missing(prob_ganar_treat)
replace bajo_inm=0 if main_treatment==1 & !missing(prob_ganar)


eststo: ivregress 2sls conflicto_arreglado    ///
         mujer antiguedad salario_diario ///
		 (bajo_inm = i.main_treatment), cluster(fecha_alta) first
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"		 
replace esample=e(sample)
eststo:  reg bajo_inm i.main_treatment mujer antiguedad salario_diario if esample==1, ///
	cluster(fecha_alta)  
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"	
	
	
******************************        AMOUNT        ****************************

*Independent dummy variable
cap drop bajo_inm
gen bajo_inm=cantidad_ganar_treat<cantidad_ganar if  !missing(cantidad_ganar) & !missing(cantidad_ganar_treat)
replace bajo_inm=0 if main_treatment==1 & !missing(cantidad_ganar)


*****************************
*       REGRESSIONS         *
*****************************


eststo: ivregress 2sls conflicto_arreglado    ///
         mujer antiguedad salario_diario ///
		 (bajo_inm = i.main_treatment), cluster(fecha_alta) first
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"
replace esample=e(sample)
eststo:  reg bajo_inm i.main_treatment mujer antiguedad salario_diario if esample==1, ///
	cluster(fecha_alta)  
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"		 
		 

*Independent dummy variable
cap drop bajo_inm
gen bajo_inm=cantidad_ganar_treat-cantidad_ganar if !missing(cantidad_ganar) & !missing(cantidad_ganar_treat)
replace bajo_inm=0 if main_treatment==1 & !missing(cantidad_ganar)


eststo: ivregress 2sls conflicto_arreglado    ///
         mujer antiguedad salario_diario ///
		 (bajo_inm = i.main_treatment), cluster(fecha_alta) first
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"		 
replace esample=e(sample)
eststo:  reg bajo_inm i.main_treatment mujer antiguedad salario_diario if esample==1, ///
	cluster(fecha_alta)  
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w"	
			
			
*************************
	esttab using "$directorio/Tables/reg_results/iv_inm_update_2w.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "BVC BVC" "Source Source") replace 
	
			
				
				
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

eststo: ivregress 2sls conflicto_arreglado    ///
         mujer antiguedad salario_diario ///
		 (bajo_inm = i.main_treatment), cluster(fecha_alta) first
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"
replace esample=e(sample)
eststo:  reg bajo_inm i.main_treatment mujer antiguedad salario_diario if esample==1, ///
	cluster(fecha_alta)  
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"		 
		 

*Independent continuous variable
cap drop bajo_inm
gen bajo_inm=prob_ganar_treat-prob_ganar if !missing(prob_ganar) & !missing(prob_ganar_treat)
replace bajo_inm=0 if main_treatment==1 & !missing(prob_ganar)


eststo: ivregress 2sls conflicto_arreglado    ///
         mujer antiguedad salario_diario ///
		 (bajo_inm = i.main_treatment), cluster(fecha_alta) first
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"		 
replace esample=e(sample)
eststo:  reg bajo_inm i.main_treatment mujer antiguedad salario_diario if esample==1, ///
	cluster(fecha_alta)  
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"	
	
	
******************************        AMOUNT        ****************************

*Independent dummy variable
cap drop bajo_inm
gen bajo_inm=cantidad_ganar_treat<cantidad_ganar if  !missing(cantidad_ganar) & !missing(cantidad_ganar_treat)
replace bajo_inm=0 if main_treatment==1 & !missing(cantidad_ganar)


*****************************
*       REGRESSIONS         *
*****************************


eststo: ivregress 2sls conflicto_arreglado    ///
         mujer antiguedad salario_diario ///
		 (bajo_inm = i.main_treatment), cluster(fecha_alta) first
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"
replace esample=e(sample)
eststo:  reg bajo_inm i.main_treatment mujer antiguedad salario_diario if esample==1, ///
	cluster(fecha_alta)  
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"		 
		 

*Independent dummy variable
cap drop bajo_inm
gen bajo_inm=cantidad_ganar_treat-cantidad_ganar if !missing(cantidad_ganar) & !missing(cantidad_ganar_treat)
replace bajo_inm=0 if main_treatment==1 & !missing(cantidad_ganar)


eststo: ivregress 2sls conflicto_arreglado    ///
         mujer antiguedad salario_diario ///
		 (bajo_inm = i.main_treatment), cluster(fecha_alta) first
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"		 
replace esample=e(sample)
eststo:  reg bajo_inm i.main_treatment mujer antiguedad salario_diario if esample==1, ///
	cluster(fecha_alta)  
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2m"	
			
			
*************************
	esttab using "$directorio/Tables/reg_results/iv_inm_update_2m.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "BVC BVC" "Source Source") replace 
	
	

*						2m settlement vs. Survey 2w - Baseline                 *
********************************************************************************

		 
use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3) 
keep id_actor prob_ganar_survey prob_ganar cantidad_ganar_survey cantidad_ganar main_treatment mujer antiguedad salario_diario fecha_alta
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keepusing(conflicto_arreglado)


*****************************      PROBABILITY      ****************************

*Independent dummy variable
gen bajo_inm=prob_ganar_survey<prob_ganar if  !missing(prob_ganar) & !missing(prob_ganar_survey)


*****************************
*       REGRESSIONS         *
*****************************

gen esample=.
eststo clear

eststo: ivregress 2sls conflicto_arreglado    ///
         mujer antiguedad salario_diario ///
		 (bajo_inm = i.main_treatment), cluster(fecha_alta) first
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w-2m"
replace esample=e(sample)
eststo:  reg bajo_inm i.main_treatment mujer antiguedad salario_diario if esample==1, ///
	cluster(fecha_alta)  
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w-2m"		 
		 

*Independent continuous variable
cap drop bajo_inm
gen bajo_inm=prob_ganar_survey-prob_ganar if !missing(prob_ganar) & !missing(prob_ganar_survey)


eststo: ivregress 2sls conflicto_arreglado    ///
         mujer antiguedad salario_diario ///
		 (bajo_inm = i.main_treatment), cluster(fecha_alta) first
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w-2m"		 
replace esample=e(sample)
eststo:  reg bajo_inm i.main_treatment mujer antiguedad salario_diario if esample==1, ///
	cluster(fecha_alta)  
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w-2m"	
	
	
******************************        AMOUNT        ****************************

*Independent dummy variable
cap drop bajo_inm
gen bajo_inm=cantidad_ganar_survey<cantidad_ganar if  !missing(cantidad_ganar) & !missing(cantidad_ganar_survey)


*****************************
*       REGRESSIONS         *
*****************************


eststo: ivregress 2sls conflicto_arreglado    ///
         mujer antiguedad salario_diario ///
		 (bajo_inm = i.main_treatment), cluster(fecha_alta) first
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w-2m"
replace esample=e(sample)
eststo:  reg bajo_inm i.main_treatment mujer antiguedad salario_diario if esample==1, ///
	cluster(fecha_alta)  
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w-2m"		 
		 

*Independent dummy variable
cap drop bajo_inm
gen bajo_inm=cantidad_ganar_survey-cantidad_ganar if !missing(cantidad_ganar) & !missing(cantidad_ganar_survey)


eststo: ivregress 2sls conflicto_arreglado    ///
         mujer antiguedad salario_diario ///
		 (bajo_inm = i.main_treatment), cluster(fecha_alta) first
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w-2m"		 
replace esample=e(sample)
eststo:  reg bajo_inm i.main_treatment mujer antiguedad salario_diario if esample==1, ///
	cluster(fecha_alta)  
estadd scalar Erre=e(r2)
estadd local BVC="YES"
estadd local Source="2w-2m"	
			
			
*************************
	esttab using "$directorio/Tables/reg_results/iv_2w_update_2m.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "BVC BVC" "Source Source") replace 
				
			
				
		
