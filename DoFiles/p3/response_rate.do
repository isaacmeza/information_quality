*Response rate results

********************************************************************************
use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2w.dta", keep(1 3) keepusing(id_actor status_encuesta)

*Response rate 2w
qui su date
gen response_2w=(_merge==3) if inrange(date,date("1/08/2017" ,"DMY"),date(c(current_date) ,"DMY")-21)  
replace response_2w=0 if response_2w==1 & status_encuesta!=1

drop _merge
keep response_2w id_actor
tempfile temp2w
save `temp2w'

use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(1 3) keepusing(id_actor status_encuesta)

*Response rate 2m
qui su date 
gen response_2m=(_merge==3) if inrange(date,date("1/01/2018" ,"DMY"),date(c(current_date) ,"DMY")-70) 
replace response_2m=0 if response_2m==1 & status_encuesta!=1

merge 1:1 id_actor using `temp2w', nogen

su response_2m, meanonly
qui putexcel I2=(r(mean)) using "$directorio\Tables\response_rate.xlsx", sheet("tab_response") modify
su response_2w, meanonly
qui putexcel I3=(r(mean)) using "$directorio\Tables\response_rate.xlsx", sheet("tab_response") modify

tab response*, m  matcell(tab_response)
qui putexcel I6=matrix(tab_response) using "$directorio\Tables\response_rate.xlsx", sheet("tab_response") modify

*Does answering 2W predict answering 2M?
eststo clear
eststo: reg response_2m response_2w, r cluster(date)
estadd scalar Erre=e(r2)
estadd local BVC="NO"
eststo: reg response_2m response_2w mujer salario_diario antiguedad, r cluster(date)
estadd scalar Erre=e(r2)
estadd local BVC="YES"
eststo: reg response_2m response_2w i.main_treatment mujer salario_diario antiguedad, r cluster(date)
estadd scalar Erre=e(r2)
estadd local BVC="YES"

	*************************
	esttab using "$directorio/Tables/reg_results/response_rate.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "BVC BVC" ) replace 
	

