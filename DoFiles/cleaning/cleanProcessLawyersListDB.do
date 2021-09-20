/*
********************
version 17.0
********************
 
/*******************************************************************************
* Name of file: 		cleanProcessLawyersListDB.do
* Author:          		Enrique Miranda, Sergio Lopez and revisited and edited by
							Emiliano Ramírez	
* Machine:        		Emiliano Ramirez PC                          				   				                         				   											
* Date of creation:     Sept. 10, 2021
* Last date of modification:   
* Modifications:		
* Files used:     
	- "$p3\DB\survey_data_2m.dta"
	- "$p3\DB\treatment_data.dta"
	- "$ql\Raw\Captura Express Completo.csv"
	- "$ql\Raw\base_abogados.csv"
	- "$ql\Raw\relacion_base_calidad.dta"
	- "$ql\Raw\checklist_500.dta"
	- "$qlDB\lawyer_dataset.dta"
	- "$p3\ql\DB\capturas_admin_matched.dta"
	- "$ql\DB\LawyerGrades_`i'.dta" for i=1,2,3
* Files created:  
	- "$qlDB\LawyerIDs`i'_Historical_mergedWP3AndGrades.dta" for i=1,2,3
	- "$qlDB\DespachoIDsHistorical_mergedWP3AndGrades.dta"
	- "$qlDB\ExactMergeLawyers_`i'.dta" for i=1,2,3
	- "$qlDB\LawyersList.dta"
* Purpose:
	- Generate database for table 3 of Relationship of informal lawyers and 
	historical outcomes from Pilot 3 March 2020 draft. 
*******************************************************************************/
*/

global qlDB "D:\Emiliano\CIE\Pilot3\ql\DB"
global ql "D:\Emiliano\CIE\Pilot3\ql"
global p3 "D:\Emiliano\CIE\Pilot3"

**********************************************************************************

*Judges Opinion
insheet using "$ql\Raw\Captura Express Completo.csv", clear
keep junta exp AÑO totaldictaminador
destring totaldictaminador, replace force
rename AÑO anio
tempfile temp_dictamen
save `temp_dictamen'

*this is raw database of lawyers ratings on casefiles 
import delimited "$ql\Raw\base_abogados.csv", varnames(1) clear 


*Cleaning
foreach var of varlist * {
	replace `var' = subinstr(`var', `"""', "",.)
	}

	*Cleaning of time
gen fecha_fin = date(substr(fin,1,11),"YMD")
format fecha_fin %td

*Duration of evaluation
gen start = substr(inicio,1,11)+" " + substr(inicio,13,8)	
gen start_time=clock(start, "YMDhms")
gen end = substr(fin,1,11)+" " + substr(fin,13,8)	
gen end_time=clock(end, "YMDhms")
format start_time end_time %tc
gen duration_eval = minutes(end_time-start_time)

*Scores & Prediction
foreach var of varlist preg1calif preg2calif preg3calif preg4calif preg5calif califglobal ///
				predicciona prediccionb prediccionc predicciond prediccione prediccionmonto1 prediccionmonto2 {
	destring `var', replace force
	}	
encode prediccionseleccion1, gen(prediccion_seleccion1)
encode prediccionseleccion2, gen(prediccion_seleccion2)
drop prediccionseleccion*	

*we replace missings with zeroes
foreach var of varlist predicciona prediccionb prediccionc predicciond prediccione {
	replace  `var'=0 if missing(`var')
	}
	
rename numexpediente nombre_archivo_abogado

*we give some special format to some observations
replace nombre_archivo_abogado = subinstr(nombre_archivo_abogado, " ", "",.)
replace nombre_archivo_abogado = "6_" + ///
	substr(nombre_archivo_abogado,3,length(nombre_archivo_abogado)) ///
		if strpos(nombre_archivo_abogado,"0_")!=0 & ///
		strpos(nombre,"Sergio Cuadra Flores")!=0
replace nombre_archivo_abogado = "8_" + ///
	substr(nombre_archivo_abogado,3,length(nombre_archivo_abogado)) ///
		if strpos(nombre_archivo_abogado,"0_")!=0 & ///
		strpos(nombre,"Miguel Angel")!=0		

*we merge with the following database to recover name of the file from casefile rated
merge 1:1 nombre_archivo_abogado using "$ql\Raw\relacion_base_calidad.dta", keep(3) nogen
*we merge with a database with categoric variables indicating some initial variables from casefiles. 
merge m:1 junta expediente ao using "$ql\Raw\checklist_500.dta", keep(3) nogen

rename expediente exp
rename ao anio

*we keep the five partial rates and the global rates lawyers gave
keep calif* califglobal junta exp anio

collapse (mean)  califglobal , by(junta exp anio)

*we merge db of initials of case files with lawyer office and name data
merge 1:m junta exp anio using "$qlDB\lawyer_dataset.dta"
gen graded=_merge==3
drop _merge

******************************************************************************************
*Create lawyers and lawyer firms datasets
gen ncases=1

/*remember there are four modes of termination 
1 convenio
2 desistimiento
3 laudo
4 caducidad

*/
forvalues i=1/4{
	gen termino`i'=modo_termino==`i'
	}

*there are at most three lawyers for each casefiles since a case file can have different lawyers following up the case
egen lawyerID1=group(nombre_abogado_1)
egen lawyerID2=group(nombre_abogado_2)
egen lawyerID3=group(nombre_abogado_3)

egen despachoID=group(office_emp_law) 

*we generate DB of historical (5000 ish) casefile data from lawyers 
forvalues i=1/3{
	preserve
	collapse (sum) graded_`i'=graded ncases_`i'=ncases (mean) termino1_`i'=termino1 termino2_`i'=termino2 termino3_`i'=termino3 termino4_`i'=termino4 avgGlobalGrade_`i'=califglobal (min) minGlobalGrade_`i'=califglobal (max) maxGlobalGrade_`i'=califglobal, by(lawyerID`i'  nombre_abogado_`i' )
	save "$qlDB\LawyerIDs`i'_Historical_mergedWP3AndGrades.dta",replace
	restore
	}

*we generate DB of historical (5000 ish) casefile data but now from lawyer firms 
preserve
collapse (sum) graded ncases (mean) termino* avgGlobalGrade=califglobal (min) minGlobalGrade=califglobal (max) maxGlobalGrade=califglobal, by(despachoID office_emp_law)
save "$qlDB\DespachoIDsHistorical_mergedWP3AndGrades.dta",replace
restore
******************************************************************************************

*Pilot 3 matched data
*Invoke follow up survey from 2 months and merge with treatment data of casefiles

*we recover "plaintiff_name" variable from old databases
use "$p3\DB\survey_data_2m(old).dta", clear
qui merge 1:1 id_actor using "$p3\DB\treatment_data(old).dta", keep(2 3) nogen
keep id_actor plaintiff_name
tempfile surv2m_w_treat_plaintiff
save `surv2m_w_treat_plaintiff', replace

*we use the most recent Isaac db 
use "$p3\DB\survey_data_2m.dta", clear
qui merge 1:1 id_actor using "$p3\DB\treatment_data.dta", keep(2 3) nogen
merge 1:1 id_actor using `surv2m_w_treat_plaintiff', nogen 

tostring colonia, replace
tostring especifique, replace
*joinby plaintiff_name using "$p3\DB\MatchedCasefiles.dta"
*we use admin data to recover plaintiff name and some other variables to trace plaintiff with treatment data and survey data of case files
joinby plaintiff_name using "$p3\ql\DB\capturas_admin_matched.dta"


forvalues i=1/3{
	rename Nombreabogado`i' nombreabogado`i'
	}


bysort nombreabogado1: gen cases=_N	
bysort nombreabogado1: gen aux=_n

* Does lawyer lied to client? dummy
gen liedtoclient=[entablo_demanda==. | entablo_demanda==0]
bysort nombreabogado1: egen lawyer_liedtoclient=max(liedtoclient)


replace coyote=0 if entablo_demanda==1 & coyote==.

* generating coyote propensity and lying propensity to lawyers from surey data
forvalues i=1/3{
	bysort nombreabogado`i': egen coyote_propensity_`i'=mean(coyote)
	bysort nombreabogado`i': egen lieToClient_propensity_`i'=mean(liedtoclient)
	}
	
*we get rid of duplicates
bysort id_actor: gen repetitions=_N
drop if repetitions>1

* what we are going to do below is linki up the coyote and lying propensity and treatment data of case files and lawyers 
* to the historical lawyers data from 5000 ish casefiles database. The following codelines will give three databases corresponding each 
* one to the the group of lawyers captured. Remember each casefile in database has at most three responsable lawyers. 

forvalues i=1/3{
	preserve
	rename nombreabogado`i' nombre_abogado_`i'
	bysort nombre_abogado_`i': egen buysFromCoyote_`i'=mean(coyote)
	
	*bysort nombre_abogado_`i': egen avgBoostPred_`i'=mean(boost_pred)
	*bysort nombre_abogado_`i': egen maxBoostPred_`i'=max(boost_pred)
	*bysort nombre_abogado_`i': egen minBoostPred_`i'=min(boost_pred)

	keep nombre_abogado_`i' buysFromCoyote_`i'
	merge m:1 nombre_abogado_`i' using "$qlDB\LawyerIDs`i'_Historical_mergedWP3AndGrades.dta" 
	drop if _merge==1
	*we count how many P3 casefiles have been related by lawyer 
	bysort nombre_abogado_`i': gen p3cases_`i'=_N
	replace p3cases=0 if _merge!=3	
	drop _merge
	bysort nombre_abogado_`i': keep if _n==1
	rename nombre_abogado_`i' nombre_abogado
	drop if nombre_abogado==""
	save "$qlDB\ExactMergeLawyers_`i'.dta", replace
	restore
	}

******************************************************************************************
*Final dataset

*we merge the last three db we generated before to have for each lawyer her variables sectioned by group 
use "$qlDB\ExactMergeLawyers_1.dta", clear
merge 1:1 nombre_abogado using "$qlDB\ExactMergeLawyers_2.dta"
rename _merge _merge2
merge 1:1 nombre_abogado using "$qlDB\ExactMergeLawyers_3.dta"
rename _merge _merge3

*merge rates we predicted for casefiles with three machine learning models. Preicted for each group of lawyers.
forvalues i=1/3{
	merge 1:1 nombre_abogado using  "$ql\DB\LawyerGrades_`i'.dta"
	drop if _merge==2
	drop _merge
	replace p3cases_`i'=0 if p3cases_`i'==.
	}

*we only keep lawyers that have rated pilot 3 casefiles  
keep if p3cases_1>0 | p3cases_2>0 | p3cases_3>0

foreach var in "ncases" "termino1" "termino2" "termino3" "termino4" "buysFromCoyote" "avg_boost_pred" "max_boost_pred" "min_boost_pred" {
	gen `var'=`var'_1
	replace `var'=`var'_2 if `var'==.
	replace `var'=`var'_3 if `var'==.
	}
gen nombre_abogado_1=nombre_abogado
gen nombre_abogado_2=nombre_abogado
gen nombre_abogado_3=nombre_abogado


keep ncases termino1 termino2 termino3 termino4 avg_boost_pred min_boost_pred max_boost_pred buysFromCoyote nombre_abogado*
save "$qlDB\LawyersList.dta", replace


