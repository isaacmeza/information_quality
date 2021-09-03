*********************************************************************
* This do file is analogous to InforomalLawyersGrades_regression.do *
* The only difference is how you define a public lawyer. 			*
* The previous version infers this information from the 2m survey 	*
* This version does it taking into account the despacho specified 	*
* in the inicial de demanda 										*
* If despacho = procuraduria, then we say it was a public lawyer 	*
*********************************************************************

local dropduplicates=1
**Pilot 3 matched data
*use "$p3\DB\survey_data_2m.dta", clear
*qui merge 1:1 id_actor using "$p3\DB\treatment_data.dta", keep(2 3) nogen
*tempfile baseline
*save `baseline', replace
*
**
**
**tostring colonia, replace
**tostring especifique, replace
**joinby plaintiff_name using "$p3\DB\MatchedCasefiles.dta"
***joinby plaintiff_name using "$p3\ql\DB\capturas_admin_matched.dta"
*
*replace coyote=0 if entablo_demanda==1 & coyote==.
use $qualityDir\DB\preds_c_todo_lasso.dta, clear
*
joinby id_actor using "$directorio\DB\MatchedCasefiles3.dta"

*joinby  id_actor using `baseline'

forvalues i=1/3{
	rename Nombreabogado`i' nombreabogado`i' 
	bysort nombreabogado`i': egen coyote_propensity_`i'=mean(coyote)
	}

bysort nombreabogado1: gen cases=_N	
bysort nombreabogado1: gen aux=_n
bysort nombreabogado1: gen liedtoclient=[entablo_demanda==. | entablo_demanda==0]

*joinby plaintiff_name id_actor using "$qlDB\preds_c_todo"

*keep if !missing(main_treatment)

if `dropduplicates'==1{
	bysort plaintiff_name id_actor: gen repetitions=_N
	drop if repetitions>1
	bysort plaintiff_name id_actor: drop if _n>1
	}

	
********************************************************************************************
*Gen lie measures

gen salary_difference=salario_mensual_demanda-salario_mensual_baseline
gen salary_exageration=salary_difference/salario_mensual_baseline
	
_pctile salary_exageration ,p(95)
gen winsor_salary_exageration=salary_exageration
replace winsor_salary_exageration=r(r1) if  salary_exageration>=r(r1) 

*hist winsor_salary_exageration
************************************************************************************	
	
gen positive_coyote_propensity=coyote_propensity_1>0
gen high_coyote_propensity=coyote_propensity_1>.5


tab positive_coyote_propensity demando_con_abogado_publico

tab positive_coyote_propensity entablo_demanda


forvalues i=1/3{
	replace coyote_propensity_`i'=0 if missing(coyote_propensity_`i')
	}

gen new_coyote=coyote_propensity_1+coyote_propensity_2+coyote_propensity_3
replace new_coyote=new_coyote/3
qui sum coyote_propensity_1,d
replace new_coyote=coyote_propensity_1>r(p75)

gen public_lawyer= strpos(Despachoactor, "PROCURAD")>0 & positive_coyote_propensity == 0
gen private_lawyer=[public_lawyer==0 & positive_coyote_propensity==0]
*replace positive_coyote_propensity=0 if public_lawyer==1
gen clasified=public_lawyer +private_lawyer +positive_coyote_propensity

egen lawyer_type=group(public_lawyer private_lawyer positive_coyote_propensity)
*
*replace new_coyote=new_coyote>.14
******************************************************************************

sum reg_pred
local mean=r(mean)
local se=r(sd)

reg reg_pred new_coyote i.public_lawyer mujer antiguedad salario_diario if cases>2, robust cluster(nombreabogado1)
sum reg_pred if e(sample)==1
local mean=r(mean)
local se=r(sd)
test new_coyote=1.public_lawyer
outreg2 using "$ql\Tables\V2GlobalGradesRegressions_1.xls", replace addstat("Dep. var. mean", `mean' ,"s" , `se', "Public=Inforomal", `r(F)', "p-value", `r(p)' )

forvalues i=3/5{
	reg reg_pred new_coyote i.public_lawyer mujer antiguedad salario_diario  if cases>`i', robust cluster(nombreabogado1)
	sum reg_pred if e(sample)==1
local mean=r(mean)
local se=r(sd)
	test new_coyote=1.public_lawyer
outreg2 using "$ql\Tables\V2GlobalGradesRegressions_1.xls", append addstat("Dep. var. mean", `mean' ,"s" , `se', "Public=Inforomal", `r(F)', "p-value", `r(p)' )
}


forvalues i=2/5{
	reg reg_pred new_coyote i.public_lawyer mujer antiguedad salario_diario  prob_coarse cantidad_coarse if cases>`i', robust cluster(nombreabogado1)
sum reg_pred if e(sample)==1
local mean=r(mean)
local se=r(sd)
test new_coyote=1.public_lawyer
outreg2 using "$ql\Tables\V2GlobalGradesRegressions_1.xls", append addstat("Dep. var. mean", `mean' ,"s" , `se', "Public=Inforomal", `r(F)', "p-value", `r(p)' )
}

******************************************************************************

sum reg_pred
local mean=r(mean)
local se=r(sd)

reg reg_pred i.main_treatment mujer antiguedad salario_diario if cases>1, robust cluster(nombreabogado1)
sum reg_pred if e(sample)==1
local mean=r(mean)
local se=r(sd)
test 2.main_treatment=3.main_treatment
outreg2 using "$ql\Tables\V2GlobalGradesRegressionsTE_1.xls", replace addstat("Dep. var. mean", `mean' ,"s" , `se', "Public=Inforomal", `r(F)', "p-value", `r(p)' )

forvalues i=2/4{
	reg reg_pred i.main_treatment mujer antiguedad salario_diario  if cases>`i', robust cluster(nombreabogado1)
	sum reg_pred if e(sample)==1
local mean=r(mean)
local se=r(sd)
test 2.main_treatment=3.main_treatment
outreg2 using "$ql\Tables\V2GlobalGradesRegressionsTE_1.xls", append addstat("Dep. var. mean", `mean' ,"s" , `se', "Public=Inforomal", `r(F)', "p-value", `r(p)' )
}


forvalues i=1/5{
	reg reg_pred i.main_treatment mujer antiguedad salario_diario  prob_coarse cantidad_coarse if cases>`i', robust cluster(nombreabogado1)
sum reg_pred if e(sample)==1
local mean=r(mean)
local se=r(sd)
test 2.main_treatment=3.main_treatment
outreg2 using "$ql\Tables\V2GlobalGradesRegressionsTE_1.xls", append addstat("Dep. var. mean", `mean' ,"s" , `se', "Public=Inforomal", `r(F)', "p-value", `r(p)' )
}

******************************************************************************

sum reg_pred
local mean=r(mean)
local se=r(sd)

reg reg_pred new_coyote i.public_lawyer mujer antiguedad salario_diario if cases>1 & main_treatment!=., robust cluster(nombreabogado1)
sum reg_pred if e(sample)==1
local mean=r(mean)
local se=r(sd)
test new_coyote=1.public_lawyer
outreg2 using "$ql\Tables\V2GlobalGradesRegressionsOnlyTE_1.xls", replace addstat("Dep. var. mean", `mean' ,"s" , `se', "Public=Inforomal", `r(F)', "p-value", `r(p)' )

forvalues i=2/4{
	reg reg_pred new_coyote i.public_lawyer mujer antiguedad salario_diario  if cases>`i' & main_treatment!=., robust cluster(nombreabogado1)
	sum reg_pred if e(sample)==1
local mean=r(mean)
local se=r(sd)
	test new_coyote=1.public_lawyer
outreg2 using "$ql\Tables\V2GlobalGradesRegressionsOnlyTE_1.xls", append addstat("Dep. var. mean", `mean' ,"s" , `se', "Public=Inforomal", `r(F)', "p-value", `r(p)' )
}


forvalues i=1/4{
	reg reg_pred new_coyote i.public_lawyer mujer antiguedad salario_diario  prob_coarse cantidad_coarse if cases>`i' & main_treatment!=., robust cluster(nombreabogado1)
sum reg_pred if e(sample)==1
local mean=r(mean)
local se=r(sd)
test new_coyote=1.public_lawyer
outreg2 using "$ql\Tables\V2GlobalGradesRegressionsOnlyTE_1.xls", append addstat("Dep. var. mean", `mean' ,"s" , `se', "Public=Inforomal", `r(F)', "p-value", `r(p)' )
}
