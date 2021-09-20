/*
********************
version 17.0
********************
 
/*******************************************************************************
* Name of file: 		relationInformalLawyers.do
* Author:          		Enrique Miranda, Sergio Lopez and revisited and edited by
							Emiliano Ramírez	
* Machine:        		Emiliano Ramirez PC                          				   				                         				   											
* Date of creation:     Sept. 10, 2021
* Last date of modification:   
* Modifications:		
* Files used:     
	-
* Files created:  
	- 
* Purpose:
	- Generate table 3 of Relationship of informal lawyers and 
	historical outcomes from Pilot 3 March 2020 draft. 
*******************************************************************************/
*/

global qlDB "D:\Emiliano\CIE\Pilot3\ql\DB"
global ql "D:\Emiliano\CIE\Pilot3\ql"
global p3 "D:\Emiliano\CIE\Pilot3"

*First we will process some variables before making the table 

*use db of initials of case files with lawyer's office and name data
use "$qlDB\lawyer_dataset.dta", clear	

foreach var in "ncases" "termino1" "termino2" "termino3" "termino4" "buysFromCoyote" "avg_boost_pred" "max_boost_pred" "min_boost_pred" {
	gen imputed_`var'=.
	}	
gen lawyer=""


forvalues i=1/3{
	merge m:1 nombre_abogado_`i' using "$qlDB\LawyersList.dta"
	replace lawyer=nombre_abogado_`i' if _merge==3
	foreach var in "ncases" "termino1" "termino2" "termino3" "termino4" "buysFromCoyote" "avg_boost_pred" "max_boost_pred" "min_boost_pred" {
		replace imputed_`var'=`var' if _merge==3 & imputed_`var'==.
		drop if _merge==2
		if "`var'"=="buysFromCoyote"{
			gen buysFromCoyote_`i'=buysFromCoyote
			replace  buysFromCoyote_`i'=0 if buysFromCoyote==1
		}
		
		drop `var'
		}
		drop _merge
	}
	
keep if lawyer!=""

*******************************************************************************************++
*we make some format and generation of new variables 

gen positive_coyote_propensity=imputed_buysFromCoyote>0

*positive recovery
gen perc_pos_rec=liq_total_pos	
*positive recovery dummy
gen pos_rec_dummy=liq_total_pos>0
*ratio win to asked
gen ratio_win_asked=npv/(c_total)
*positive recovery in court ruling
gen perc_pos_rec_cr=liq_total_pos if modo_termino==3	
*settlement
gen settement=modo_termino==1
*laudo
gen win=modo_termino==3
*lost
gen lost=modo_termino==4
*drop
gen drop=modo_termino==2

*Ratio win/entitlementlaw
gen ratio_win_minley=npv/min_ley

*Net recovery non-positive	
gen perc_non_pos_npv = (npv<=0)
gen perc_pos_npv = (npv>0)

forvalues i=1/3{
	replace buysFromCoyote_`i'=0 if buysFromCoyote_`i'==.
	}

gen new_coyote=(buysFromCoyote_1+buysFromCoyote_2+buysFromCoyote_3)/3

gen avgcoyote_propensity=new_coyote
qui sum new_coyote,d
replace new_coyote=new_coyote>r(p75)

*************************
gen settle_or_win=[win==1 | settement==1]

gen loose_or_drop=[drop==1 | lost==1]

***************************************************************************************
local bvc salario_diario c_antiguedad gen

bysort lawyer: gen cases=_N

sum perc_non_pos_npv
local mean=`r(mean)'
local se=`r(sd)'

*we generate the table 

forvalues i=1/3{
	reg perc_non_pos_npv new_coyote abogado_pub `bvc' if cases>`i', robust cluster(lawyer)
	outreg2 using "$ql\Tables\V2InformalLawyersOutcomes_`i'Cases.xls", replace addstat(Dep. var mean, `mean', "s", `se')

	foreach var in "ratio_win_minley" "win" "lost" "settement" "drop"{

	sum `var'
	local mean=`r(mean)'
	local se=`r(sd)'
	reg `var' new_coyote abogado_pub `bvc' if cases>`i', robust cluster(lawyer)
	outreg2 using "$ql\Tables\V2InformalLawyersOutcomes_`i'Cases.xls", append addstat(Dep. var mean, `mean', "s", `se')

	}
}