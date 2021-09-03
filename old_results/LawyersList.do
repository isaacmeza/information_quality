
local dropduplicates=1
**********************************************************************************

*Judges Opinion
insheet using "$directorio/Raw/Captura Express Completo.csv", clear
keep junta exp AÑO totaldictaminador
destring totaldictaminador, replace force
rename AÑO anio
tempfile temp_dictamen
save `temp_dictamen'


import delimited "$directorio/Raw/base_abogados.csv", varnames(1) clear 


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

foreach var of varlist predicciona prediccionb prediccionc predicciond prediccione {
	replace  `var'=0 if missing(`var')
	}
	
rename numexpediente nombre_archivo_abogado
rename ïnombre nombre
replace nombre_archivo_abogado = subinstr(nombre_archivo_abogado, " ", "",.)
replace nombre_archivo_abogado = "6_" + ///
	substr(nombre_archivo_abogado,3,length(nombre_archivo_abogado)) ///
		if strpos(nombre_archivo_abogado,"0_")!=0 & ///
		strpos(nombre,"Sergio Cuadra Flores")!=0
replace nombre_archivo_abogado = "8_" + ///
	substr(nombre_archivo_abogado,3,length(nombre_archivo_abogado)) ///
		if strpos(nombre_archivo_abogado,"0_")!=0 & ///
		strpos(nombre,"Miguel Angel")!=0		
		
merge 1:1 nombre_archivo_abogado using "$directorio/Raw/relacion_base_calidad.dta", keep(3) nogen
merge m:1 junta expediente ao using "$directorio/Raw/checklist_500.dta", keep(3) nogen

rename expediente exp
rename ao anio

keep calif* califglobal junta exp anio

collapse (mean)  califglobal , by(junta exp anio)
merge 1:m junta exp anio using "$directorio/DB/lawyer_dataset.dta"
gen graded=_merge==3
drop _merge

******************************************************************************************
*Create lawyers and lawyer firms datasets
gen ncases=1

forvalues i=1/4{
	gen termino`i'=modo_termino==`i'
	}

egen lawyerID1=group(nombre_abogado_1)
egen lawyerID2=group(nombre_abogado_2)
egen lawyerID3=group(nombre_abogado_3)

egen despachoID=group(office_emp_law) 

forvalues i=1/3{
	preserve
	collapse (sum) graded_`i'=graded ncases_`i'=ncases (mean) termino1_`i'=termino1 termino2_`i'=termino2 termino3_`i'=termino3 termino4_`i'=termino4 avgGlobalGrade_`i'=califglobal (min) minGlobalGrade_`i'=califglobal (max) maxGlobalGrade_`i'=califglobal, by(lawyerID`i'  nombre_abogado_`i' )
	save "$directorio/LawyerIDs`i'_Historical_mergedWP3AndGrades.dta",replace
	restore
	}

preserve
collapse (sum) graded ncases (mean) termino* avgGlobalGrade=califglobal (min) minGlobalGrade=califglobal (max) maxGlobalGrade=califglobal, by(despachoID office_emp_law)
save "$directorio/DespachoIDsHistorical_mergedWP3AndGrades.dta",replace
restore
******************************************************************************************

*Pilot 3 matched data
use "$directorio/DB/survey_data_2m.dta", clear
qui merge 1:1 id_actor using "$directorio/DB/treatment_data.dta", keep(2 3) nogen


tostring colonia, replace
tostring especifique, replace
*joinby plaintiff_name using "$p3/DB/MatchedCasefiles.dta"
joinby plaintiff_name using "$directorio/DB/capturas_admin_matched.dta"

forvalues i=1/3{
	rename Nombreabogado`i' nombreabogado`i'
	}
bysort nombreabogado1: gen cases=_N	
bysort nombreabogado1: gen aux=_n
 gen liedtoclient=[entablo_demanda==. | entablo_demanda==0]
bysort nombreabogado1: egen lawyer_liedtoclient=max(liedtoclient)


replace coyote=0 if entablo_demanda==1 & coyote==.


forvalues i=1/3{
	bysort nombreabogado`i': egen coyote_propensity_`i'=mean(coyote)
	bysort nombreabogado`i': egen lieToClient_propensity_`i'=mean(liedtoclient)
	}
	
	
*joinby id_actor  using "$directorio/800ish"
*joinby id_actor  using "$directorio/predicted_scores_800ish"

if `dropduplicates'==1{
	bysort id_actor: gen repetitions=_N
	drop if repetitions>1

	}


forvalues i=1/3{
	preserve
	rename nombreabogado`i' nombre_abogado_`i'
	bysort nombre_abogado_`i': egen buysFromCoyote_`i'=mean(coyote)
	
	*bysort nombre_abogado_`i': egen avgBoostPred_`i'=mean(boost_pred)
	*bysort nombre_abogado_`i': egen maxBoostPred_`i'=max(boost_pred)
	*bysort nombre_abogado_`i': egen minBoostPred_`i'=min(boost_pred)

	keep nombre_abogado_`i' buysFromCoyote_`i'
	merge m:1 nombre_abogado_`i' using "$directorio/DB/LawyerIDs`i'_Historical_mergedWP3AndGrades.dta" 
	drop if _merge==1
	bysort nombre_abogado_`i': gen p3cases_`i'=_N
	replace p3cases=0 if _merge!=3	
	drop _merge
	bysort nombre_abogado_`i': keep if _n==1
	rename nombre_abogado_`i' nombre_abogado
	drop if nombre_abogado==""
	save "$directorio/DB/ExactMergeLawyers_`i'.dta", replace
	restore
	}

*rename despachoactor office_emp_law
*merge m:1 office_emp_law using "$directorio/DespachoIDsHistorical_mergedWP3AndGrades.dta"
*drop if _merge==1
*bysort office_emp_law: gen p3cases_`i'=_N
*replace p3cases=p3cases*[_merge==3]	
*drop _merge
*bysort office_emp_law: keep if _n==1
*save "$directorio/ExactMergeLawyerFirms.dta", replace


******************************************************************************************
*Final dataset

use "$directorio/DB/ExactMergeLawyers_1.dta", clear
merge 1:1 nombre_abogado using "$directorio/DB/ExactMergeLawyers_2.dta"
rename _merge _merge2
merge 1:1 nombre_abogado using "$directorio/DB/ExactMergeLawyers_3.dta"
rename _merge _merge3

forvalues i=1/3{
	merge 1:1 nombre_abogado using  "$directorio/DB/LawyerGrades_`i'.dta"
	drop if _merge==2
	drop _merge
	replace p3cases_`i'=0 if p3cases_`i'==.
	}


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
save "$directorio/DB/LawyersList.dta", replace


***************************************************************************************

use "$directorio/DB/lawyer_dataset.dta", clear	

foreach var in "ncases" "termino1" "termino2" "termino3" "termino4" "buysFromCoyote" "avg_boost_pred" "max_boost_pred" "min_boost_pred" {
	gen imputed_`var'=.
	}	
gen lawyer=""

forvalues i=1/3{
	merge m:1 nombre_abogado_`i' using "$directorio/DB/LawyersList.dta"
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
*win
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

*replace imputed_buysFromCoyote=imputed_buysFromCoyote>.5

sum perc_non_pos_npv
local mean=`r(mean)'
local se=`r(sd)'

forvalues i=1/3{
	reg perc_non_pos_npv new_coyote abogado_pub `bvc' if cases>`i', robust cluster(lawyer)
	outreg2 using "$directorio/Tables/V2InformalLawyersOutcomes_`i'Cases.xls", replace addstat(Dep. var mean, `mean', "s", `se')

	foreach var in "ratio_win_minley" "win" "lost" "settement" "drop" "loose_or_drop" "settle_or_win"{

	sum `var'
	local mean=`r(mean)'
	local se=`r(sd)'
	reg `var' new_coyote abogado_pub `bvc' if cases>`i', robust cluster(lawyer)
	outreg2 using "$directorio/Tables/V2InformalLawyersOutcomes_`i'Cases.xls", append addstat(Dep. var mean, `mean', "s", `se')

	}
}
*******************************************************************************

egen lawyer_group=group(nombre_abogado_1 nombre_abogado_2 nombre_abogado_3)
bysort lawyer_group: keep if _n==1

local i=1
hist avgcoyote_propensity if cases >`i', sch(s1mono) xtitle("Informality propensity")
hist avgcoyote_propensity if new_coyote>0 & cases >`i', sch(s1mono) xtitle("Informality propensity")

*Data Chris asked force
*Number of lawyers
bysort lawyer: gen unique = _n
count if unique ==1
*Number of casefiles

bysort junta exp anio: gen unique_casefile = _n
count if unique_casefile ==1
