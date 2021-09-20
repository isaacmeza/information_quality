/*
********************
version 17.0
********************
 
/*******************************************************************************
* Name of file: 		kdensPredictedValueCasefile.do
* Author:          		Enrique Miranda, Sergio Lopez and revisited and edited by
							Emiliano Ramírez	
* Machine:        		Emiliano Ramirez PC                          				   				                         				   											
* Date of creation:     Sept. 17, 2021
* Last date of modification:   
* Modifications:		
* Files used:     
	-
* Files created:  
	- 
* Purpose:
	- Generate figure 4 of predicted casefile values kdensity 
	from Pilot 3 March 2020 draft. 
*******************************************************************************/
*/

*directory 

cd $directorio 
clear all

*NOTE: Before running do file make sure winsor package is installed if not run: 
*ssc install winsor

use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta"

*where all these bounds came from????

*bounds for kdensity winsorize
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

*winsorize prediction variables with 'winsor' command
foreach var in low high median {
	replace `var'prediction=`var'prediction*salario_diario	
	winsor `var'prediction, gen(winsor_`var'prediction) p(.03) highonly 
}

	
********************************************************************************
* Kdensities by treatment arms (treatment arm 1, 2 and 3)
********************************************************************************
	
foreach var in low high median {
	
	
	*densities of expected casefile value by treatment arm without high winsorized on predicted casefile value
	twoway (kdensity `var'prediction if entablo_demanda==1 & main_treatment==1 /*
		*/ ,   lc(black)  legend(label(1 "Treatment 1")) ) /*
		*/ (kdensity `var'prediction if entablo_demanda==1 & main_treatment==2 /*
		*/ ,   lc(black) legend(label(2 "Treatment 2")) ) /*
		*/ (kdensity `var'prediction if entablo_demanda==1 & main_treatment==3 /*
		*/ ,  lc(black) legend(label(3 "Treatment 3")) ),sch(s2mono) graphregion(fcolor(white)) /*
		*/ ytitle("k density") xtitle("Casefile value") xlabel(,nogrid) ylabel(, nogrid angle(0))
	
	graph export "Figures\CalculatorCasefileValuesHistogram_ConditionalOnSued_T123_`var'.pdf", replace 		 
	
	*densities of expected casefile value by treatment arm WITH high winsorized	on predicted casefile value
	twoway (kdensity winsor_`var'prediction if entablo_demanda==1 & main_treatment==1 /*
		*/ ,   lc(black)  legend(label(1 "Treatment 1")) ) /*
		*/ (kdensity winsor_`var'prediction if entablo_demanda==1 & main_treatment==2 /*
		*/ ,   lc(black) legend(label(2 "Treatment 2")) ) /*
		*/ (kdensity winsor_`var'prediction if entablo_demanda==1 & main_treatment==3 /*
		*/ ,  lc(black) legend(label(3 "Treatment 3")) ),sch(s2mono) graphregion(fcolor(white)) /*
		*/ ytitle("k density") xtitle("Casefile value") xlabel(,nogrid) ylabel(, nogrid angle(0))

	graph export "Figures\CalculatorCasefileValuesHistogram_ConditionalOnSued_T123_winsor`var'.pdf", replace 		 
	
	********************************************************************************
	* Unconditional on suing kdensities
	********************************************************************************

	twoway (kdensity `var'prediction if  main_treatment==1 /*
		*/ ,   lc(black)  legend(label(1 "Treatment 1")) ) /*
		*/ (kdensity `var'prediction if  main_treatment==2 /*
		*/ ,   lc(black) legend(label(2 "Treatment 2")) ) /*
		*/ (kdensity `var'prediction if  main_treatment==3 /*
		*/ ,  lc(black) legend(label(3 "Treatment 3")) ),sch(s2mono) graphregion(fcolor(white)) /*
		*/ ytitle("k density") xtitle("Casefile value") xlabel(,nogrid) ylabel(, nogrid angle(0))

	graph export "Figures\CalculatorCasefileValuesHistogram_Unconditional_T123_`var'.pdf", replace 		 

	twoway (kdensity winsor_`var'prediction if main_treatment==1 /*
		*/ ,   lc(black)  legend(label(1 "Treatment 1")) ) /*
		*/ (kdensity winsor_`var'prediction if  main_treatment==2 /*
		*/ ,   lc(black) legend(label(2 "Treatment 2")) ) /*
		*/ (kdensity winsor_`var'prediction if  main_treatment==3 /*
		*/ ,  lc(black) legend(label(3 "Treatment 3")) ),sch(s2mono) graphregion(fcolor(white)) /*
		*/ ytitle("k density") xtitle("Casefile value") xlabel(,nogrid) ylabel(, nogrid angle(0))
	
	graph export "Figures\CalculatorCasefileValuesHistogram_Unconditional_T123_winsor`var'.pdf", replace 		 

}

********************************************************************************
* Kdensities by treatment groups (groups A & B)
********************************************************************************

*NOTE: THESE KDENSITIES DO NOT APPEAR ON PAPER BUT I LEAVE THEM IF NEEDED LATER.

/*	
foreach var in low high median {	
	********************************************************************************
	* Conditional on suing 
	********************************************************************************
	
	twoway (kdensity `var'prediction if entablo_demanda==1 & group==1 /*
		*/ ,   lc(black)  legend(label(1 "Treatment A")) ) /*
		*/ (kdensity `var'prediction if entablo_demanda==1 & group==2 /*
		*/ ,   lc(black) legend(label(2 "Treatment B")) ) /*
		*/ ,sch(s2mono) graphregion(fcolor(white)) /*
		*/ ytitle("k density") xtitle("Casefile value") xlabel(,nogrid) ylabel(,nogrid)
	
	graph export "Figures\CalculatorCasefileValuesHistogram_ConditionalOnSued_TAB_`var'.pdf", replace 		 

	twoway (kdensity winsor_`var'prediction if entablo_demanda==1 & main_treatment==1 /*
		*/ ,   lc(black)  legend(label(1 "Treatment A")) ) /*
		*/ (kdensity winsor_`var'prediction if entablo_demanda==1 & main_treatment==2 /*
		*/ ,   lc(black) legend(label(2 "Treatment B")) ) /*
		*/ ,sch(s2mono) graphregion(fcolor(white)) /*
		*/ ytitle("k density") xtitle("Casefile value") xlabel(,nogrid) ylabel(,nogrid)

		graph export "Figures\CalculatorCasefileValuesHistogram_ConditionalOnSued_TAB_winsor`var'.pdf", replace 		 

	********************************************************************************
	* Unconditional on suing 
	********************************************************************************

	twoway (kdensity `var'prediction if  main_treatment==1 /*
		*/ ,   lc(black)  legend(label(1 "Treatment A")) ) /*
		*/ (kdensity `var'prediction if  main_treatment==2 /*
		*/ ,   lc(black) legend(label(2 "Treatment B")) ) /*
		*/ ,sch(s2mono) graphregion(fcolor(white)) /*
		*/ ytitle("k density") xtitle("Casefile value") xlabel(,nogrid) ylabel(,nogrid)

		graph export "Figures\CalculatorCasefileValuesHistogram_Unconditional_TAB_`var'.pdf", replace 		 

	twoway (kdensity winsor_`var'prediction if main_treatment==1 /*
		*/ ,   lc(black)  legend(label(1 "Treatment A")) ) /*
		*/ (kdensity winsor_`var'prediction if  main_treatment==2 /*
		*/ ,   lc(black) legend(label(2 "Treatment B")) ) /*
		*/ ,sch(s2mono) graphregion(fcolor(white)) /*
		*/ ytitle("k density") xtitle("Casefile value") xlabel(,nogrid) ylabel(,nogrid)

		graph export "Figures\CalculatorCasefileValuesHistogram_Unconditional_TAB_winsor`var'.pdf", replace 		 

}
*/