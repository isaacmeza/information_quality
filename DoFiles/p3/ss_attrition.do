*ATTRITION SUBPOPULATIONS


********************************************************************************
*									2W - 2M							  		   *
********************************************************************************
use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2w.dta", keep(1 3) keepusing(id_actor status_encuesta)

*Attrition rate
qui su date
gen attrition_2w_full=(_merge==1) if inrange(date,date("1/08/2017" ,"DMY"),date(c(current_date) ,"DMY")-21)
replace attrition_2w_full=1 if attrition_2w_full==0 & status_encuesta!=1

gen attrition_2w_full_cell=(_merge==1) if inrange(date,date("1/08/2017" ,"DMY"),date(c(current_date) ,"DMY")-21) ///
						& telefono_cel==1
replace attrition_2w_full_cell=1 if attrition_2w_full_cell==0 & status_encuesta!=1

gen attrition_2w_full_phone=(_merge==1) if inrange(date,date("1/08/2017" ,"DMY"),date(c(current_date) ,"DMY")-21) ///
						& telefono_cel==1 & telefono_fijo==1
replace attrition_2w_full_phone=1 if attrition_2w_full_phone==0 & status_encuesta!=1
						
						
gen attrition_2w_18=(_merge==1) if inrange(date,date("1/12/2017" ,"DMY"),date(c(current_date) ,"DMY")-21)
replace attrition_2w_18=1 if attrition_2w_18==0 & status_encuesta!=1

gen attrition_2w_18_cell=(_merge==1) if inrange(date,date("1/12/2017" ,"DMY"),date(c(current_date) ,"DMY")-21) ///
						& telefono_cel==1
replace attrition_2w_18_cell=1 if attrition_2w_18_cell==0 & status_encuesta!=1

gen attrition_2w_18_phone=(_merge==1) if inrange(date,date("1/12/2017" ,"DMY"),date(c(current_date) ,"DMY")-21) ///
						& telefono_cel==1 & telefono_fijo==1
replace attrition_2w_18_phone=1 if attrition_2w_18_phone==0 & status_encuesta!=1
						
drop _merge
keep attrition_* id_actor
tempfile temp2w
save `temp2w'


use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(1 3) keepusing(id_actor status_encuesta)
merge 1:1 id_actor using `temp2w', nogen

*Attrition rate
qui su date 
gen attrition_2m_full=(_merge==1) if inrange(date,`r(min)',date(c(current_date) ,"DMY")-70)
replace attrition_2m_full=1 if attrition_2m_full==0 & status_encuesta!=1

gen attrition_2m_full_cell=(_merge==1) if inrange(date,`r(min)',date(c(current_date) ,"DMY")-70) ///
						& telefono_cel==1
replace attrition_2m_full_cell=1 if attrition_2m_full_cell==0 & status_encuesta!=1

gen attrition_2m_full_phone=(_merge==1) if inrange(date,`r(min)',date(c(current_date) ,"DMY")-70) ///
						& telefono_cel==1 & telefono_fijo==1
replace attrition_2m_full_phone=1 if attrition_2m_full_phone==0 & status_encuesta!=1

						
gen attrition_2m_18=(_merge==1) if inrange(date,date("1/11/2017" ,"DMY"),date(c(current_date) ,"DMY")-70)
replace attrition_2m_18=1 if attrition_2m_18==0 & status_encuesta!=1

gen attrition_2m_18_cell=(_merge==1) if inrange(date,date("1/11/2017" ,"DMY"),date(c(current_date) ,"DMY")-70) ///
						& telefono_cel==1
replace attrition_2m_18_cell=1 if attrition_2m_18_cell==0 & status_encuesta!=1

gen attrition_2m_18_phone=(_merge==1) if inrange(date,date("1/11/2017" ,"DMY"),date(c(current_date) ,"DMY")-70) ///
						& telefono_cel==1 & telefono_fijo==1
replace attrition_2m_18_phone=1 if attrition_2m_18_phone==0 & status_encuesta!=1

********************************************************************************

orth_out attrition*, by(main_treatment) count overall bdec(2)
qui putexcel B20=matrix(r(matrix)) using "$directorio\Tables\ss_attrition.xlsx", sheet("ss_attrition") modify

local j=20
foreach var of varlist attrition_2w* {
	qui su `var'
	qui putexcel G`j'=(r(N)) using "$directorio\Tables\ss_attrition.xlsx", sheet("ss_attrition") modify
	local ++j
	}	
	
local j=20
foreach var of varlist attrition_2m* {
	qui su `var'
	qui putexcel H`j'=(r(N)) using "$directorio\Tables\ss_attrition.xlsx", sheet("ss_attrition") modify
	local ++j
	}		

	
	
orth_out attrition_2m_f*, by(group) count overall bdec(2)
qui putexcel B20=matrix(r(matrix)) using "$directorio\Tables\ss_attrition.xlsx", sheet("ss_attrition_ab") modify

local j=20
foreach var of varlist attrition_2w* {
	qui su `var' if !missing(group)
	qui putexcel F`j'=(r(N)) using "$directorio\Tables\ss_attrition.xlsx", sheet("ss_attrition_ab") modify
	local ++j
	}	
	
local j=20
foreach var of varlist attrition_2m* {
	qui su `var' if !missing(group)
	qui putexcel G`j'=(r(N)) using "$directorio\Tables\ss_attrition.xlsx", sheet("ss_attrition_ab") modify
	local ++j
	}		
	
