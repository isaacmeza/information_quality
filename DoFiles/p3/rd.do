*Cleans data for RD plots in R of the inquiry cards effectiveness

********************************************************************************
************************************2M******************************************
use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3)
qui su date
keep if inrange(date,`r(min)',date(c(current_date) ,"DMY")-70)

*Keep only those who answered 7 days after start of surveying
*keep if survey_date-date<=7+9*7 | missing(survey_date)

*Response variable
gen response=(_merge==3)
replace response=0 if response==1 & status_encuesta!=1

collapse (mean) response , by(date)

gen dte=_n
su dte if date==date("13/06/2018","DMY"), meanonly
replace dte=dte-r(mean)

gen disc=dte>=0
reg response c.dte##i.disc, robust

keep dte response
su dte
local mx=min(abs(r(max)),abs(r(min)))
*keep if inrange(dte, -`mx',`mx')
export delimited using "C:\Users\xps-seira\Downloads\rd2m.csv", replace
********************************************************************************
************************************2W******************************************
use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3)
keep if inrange(date,date("1/01/2017" ,"DMY"),date(c(current_date) ,"DMY")-21)


*Response variable
gen response=(_merge==3)
replace response=0 if response==1 & status_encuesta!=1

collapse (mean) response , by(date)

gen dte=_n
su dte if date==date("13/06/2018","DMY"), meanonly
replace dte=dte-r(mean)

gen disc=dte>=0
reg response c.dte##i.disc, robust


keep dte response
su dte
local mx=min(abs(r(max)),abs(r(min)))
keep if inrange(dte, -`mx',`mx')
export delimited using "C:\Users\xps-seira\Downloads\rd2w.csv", replace
