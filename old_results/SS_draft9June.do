*SUMMARY STATISTICS TABLE

local ss_vars_bvc high_school mujer salario_diario antiguedad   /*BVC*/
local ss_vars_exp prob_ganar cantidad_ganar_ponderada /*Baseline survey*/

use "$directorio/DB/treatment_data.dta", clear
merge 1:1 id_actor using "$directorio/DB/survey_data_2w.dta", nogen keep(1 3) keepusing(hablo_con_abogado)
merge 1:1 id_actor using "$directorio/DB/survey_data_2m.dta", nogen keep(1 3) 

*Mover a cleaning
gen no_cantidadexpectations=cantidad_ganar==. 
gen no_probexpectations=prob_ganar==. 
gen cantidad_ganar_ponderada = cantidad_ganar/salario_diario


*calculator predictions
gen quadrant="NE"
replace quadrant="NW" if antiguedad>2.61 & salario_diario<207.66
replace quadrant="SE" if antiguedad<2.61 & salario_diario>207.66
replace quadrant="SW" if antiguedad<2.61 & salario_diario<207.66

gen lowprediction=61.03 if quadrant=="NE"
replace lowprediction=69.87 if quadrant=="NW"
replace lowprediction=42.24 if quadrant=="SE"
replace lowprediction=51.22 if quadrant=="SW"

gen highprediction=90.08 if quadrant=="NE"
replace highprediction=98.69 if quadrant=="NW"
replace highprediction=59.22 if quadrant=="SE"
replace highprediction=67.36 if quadrant=="SW"

gen medianprediction=(highprediction-lowprediction)/2



*SS
orth_out `ss_vars_bvc' , ///
				by(main_treatment) se vce(robust)   bdec(2)  

putexcel set "$directorio/Tables/SS_draft.xlsx", sheet("SS") modify
qui putexcel K6=matrix(r(matrix)) 
		
local i=6	
foreach var of varlist `ss_vars_bvc' {
	qui putexcel J`i'=("`var'") 
	
	qui reg `var' i.main_treatment, robust cluster(date)
	qui test ( 2.main_treatment=0 ) (3.main_treatment=0) 
	qui putexcel N`i'=(`r(p)') 

	local i=`i'+2
	}
*******
orth_out `ss_vars_exp' , ///
				by(main_treatment) se vce(robust)   bdec(2)  
qui putexcel K14=matrix(r(matrix)) 
		
local i=14	
foreach var of varlist `ss_vars_exp' {
	qui putexcel J`i'=("`var'") 
	
		
	qui reg `var' i.main_treatment, robust cluster(date)
	qui test ( 2.main_treatment=0 ) (3.main_treatment=0)
	qui putexcel N`i'=(`r(p)') 
	
	local i=`i'+2
	}

***************************************

*SS
orth_out `ss_vars_bvc' , ///
				by(group) se vce(robust)   bdec(2)  
qui putexcel K39=matrix(r(matrix)) 
		
local i=39	
foreach var of varlist `ss_vars_bvc' {
	qui putexcel J`i'=("`var'") 
	
		
	qui reg `var' i.group, robust cluster(date)
	qui test ( 2.group=0 ) 
	qui putexcel N`i'=(`r(p)') 
	
	local i=`i'+2
	}
*******
orth_out `ss_vars_exp' , ///
				by(group) se vce(robust)   bdec(2)  
qui putexcel K47=matrix(r(matrix)) 
		
local i=47	
foreach var of varlist `ss_vars_exp' {
	qui putexcel J`i'=("`var'") 
		
	qui reg `var' i.group, robust cluster(date)
	qui test ( 2.group=0 ) 
	qui putexcel N`i'=(`r(p)') 
	
	local i=`i'+2
	}
*************************************************************************
								*Tests
								

	
	
***********************************************************************
								*Observations*
	
use "$directorio/DB/treatment_data.dta", clear

putexcel set "$directorio/Tables/SS_draft.xlsx", sheet("SS") modify

*Observations
qui count if main_treatment==1 
qui putexcel K22=(`r(N)') 
qui count if main_treatment==2		
qui putexcel L22=(`r(N)') 
qui count if main_treatment==3	
qui putexcel M22=(`r(N)') 


*Observations A/B
qui count if group==1 
qui putexcel K55=(`r(N)') 
qui count if group==2		
qui putexcel L55=(`r(N)') 

