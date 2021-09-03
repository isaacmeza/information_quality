*Seed
set seed X5f477e32ccbd3e6487cdece355f57f2a00041b66

*Scanned casefiles 
***********************************
import excel "$directorio\Raw\JLCA_MC_EscaneosCompleto_censo.xlsx", sheet("Hoja1") cellrange(A1:B6961) firstrow clear

split nombre, gen(name) parse("_")
destring name1, gen(junta) ignore("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMOPQRSTUVWXYZ")
destring name2, gen(exp) force	
destring name3, replace force
replace exp=name3 if missing(exp) & name3!=2011
gen anio=2011
duplicates drop junta exp anio, force
tempfile temp_escaneo
save `temp_escaneo'
***********************************

*Previous selected casefiles
use "$directorio\_aux\assignment_1.dta", clear
append using "$directorio\_aux\assignment_2.dta"
duplicates drop junta exp anio, force
merge 1:m junta exp anio using "$directorio\DB\lawyer_dataset.dta", nogen keep(3)
duplicates drop junta exp anio, force
tempfile temp_previous
save `temp_previous'

***********************************
use "$directorio\DB\lawyer_dataset.dta", clear
merge m:1 junta exp anio using `temp_escaneo', keep(3) keepusing(junta exp anio) nogen

*Basic cleaning
foreach var of varlist junta exp anio modo_termino liq_total_tope comp_* {
	drop if missing(`var')
	}
	
*Generation of variables of interest
do "$directorio\DoFiles\gen_measures.do"

*Seed
set seed X5f477e32ccbd3e6487cdece355f57f2a00041b66

*Variable name cleaning
foreach var of varlist perc* {
	local nvar=substr("`var'",6,.)
	cap rename `var' `nvar'
	}

foreach var of varlist ratio* {
	local nvar=substr("`var'",7,.)
	cap rename `var' `nvar'
	}

bysort gp_office : gen num_casefiles=_N
drop if num_casefiles<=4
sort gp_office
egen id=group(gp_office)
*FE Office	
xi i.id, noomit
preserve
keep if abogado_pub==1
qui su id
local pub=`r(mean)'
restore
qui su id
local mx=`r(max)'

qui reg pos_rec  $input_varlist $sd_input_varlist $bvc _Iid_1-_Iid_`=`pub'-1' _Iid_`=`pub'-1'-_Iid_`mx', r	
predict pr
xtile perc_pr=pr, nq(100)
*Exclude previuos selected casefiles
merge m:1 junta exp anio using "$directorio\_aux\assignment_1.dta", nogen keep(1)
merge m:1 junta exp anio using "$directorio\_aux\assignment_2.dta", nogen keep(1)

*-------------------------------------------------------------------------------
duplicates drop junta exp anio, force

*Original composition
tab modo_termino
tab pos_rec
tab abogado_pub

*Pseudo-balance
sample 60 if modo_termino==1
sample 40 if modo_termino==2
tab modo_termino 

*Stratified sample
sample 110 if abogado_pub==1 & pos_rec==1, count
sample 125 if abogado_pub==0 & perc_pr>=70 & pos_rec==1, count
sample 95 if abogado_pub==0 & perc_pr<=40 & pos_rec==1, count

sample 110 if abogado_pub==1 & pos_rec==0, count
sample 125 if abogado_pub==0 & perc_pr>=70 & pos_rec==0, count
sample 95 if abogado_pub==0 & perc_pr<=40 & pos_rec==0, count

drop if inrange(perc_pr,41,69)
sample 406, count

*Include previuos selected casefiles
append using `temp_previous'
duplicates drop junta exp anio, force
merge 1:1 junta exp anio using `temp_escaneo', keep(3) keepusing(junta exp anio) nogen
*Cleaning
replace pos_rec=(liq_total_tope>0) if missing(pos_rec)

*Stratification
tab modo_termino
tab pos_rec
tab abogado_pub
tab perc_pr

 
save "$directorio\_aux\assignment_3.dta", replace
keep junta exp anio modo_termino liq_total_tope comp_* abogado_pub pos_rec perc_pr
order junta exp anio modo_termino liq_total_tope comp_* abogado_pub pos_rec perc_pr
sort junta exp anio
export delimited using "$directorio\_aux\asignaciones_3.csv", replace

