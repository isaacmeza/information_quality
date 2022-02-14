/*
********************
version 17.0
********************
 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	November. 29, 2021
* Last date of modification:   
* Modifications:		
* Files used:     
* Files created:  

* Purpose: Look at the calculator predictions of the cases that have completed/are still ongoing by treatment. It may be that treatment induces low-value cases to settle? That is, the treatment induces low-value cases to settle even conditional on filing, so that we see a "negative treatment effect" because the low-value cases are still pending in the control group.

*******************************************************************************/
*/


import delimited "$directorio/_aux/case_value.csv",  clear
duplicates drop
drop if missing(id_actor)
merge m:1 id_actor using "$directorio\DB\treatment_data.dta",  nogen


foreach var of varlist prex_gb prex_hgb prex_rf {
	su `var' if dem==0 & main_treatment==2
	local mn2 = `r(mean)'
	local num2 = `r(N)'
	su `var' if dem==0 & main_treatment==3
	local mn3 = `r(mean)'
	local num3 = `r(N)'
	replace `var' = (`num2'*`mn2' + `num3'`mn3') /(`num2'+`num3') if dem==0 & main_treatment==1
	*replace `var' = . if dem==1
}

foreach var of varlist prez_gb prez_hgb prez_rf {
	*replace `var' = . if dem==0
}


merge m:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(1 3) nogen

gen case_value = prez_hgb if dem==1
replace case_value = prez_hgb if dem==0


reg prez_hgb i.dem##i.main_treatment, r
reg prez_hgb i.main_treatment if dem==1, r

eststo clear
eststo : reg case_value i.dem##i.main_treatment, r
eststo : reg case_value i.main_treatment if dem==1, r
esttab using "$directorio/Tables/reg_results/te_a_b.csv", se r2 ${star} b(a2) label replace
