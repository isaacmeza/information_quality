*TREATMENT EFFECTS REGRESSIONS


clear
matrix p_val = J(100,16,.)
********************************************************************************
*									2W								  		   *
********************************************************************************
use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)

********************************************************************************

local depvar conflicto_arreglado hablo_con_abogado cond_hablo_con_publico coyote
local controls mujer antiguedad salario_diario

*Pool
gen original = 1
gen unif = .
gen freq = 1


forvalues iter = 1/100 {
*Draw sample
replace unif = runiform() if original==1
sort unif
replace freq = freq +1 if _n<=10 


	
local j = 1
foreach var in `depvar'	{
	
	reg `var' i.group [fw=freq], robust
	*p-value
	matrix p_val[`iter',`j'] = 2*ttail(e(df_r), abs(_b[2.group]/_se[2.group]))
	
	reg `var' i.group `controls' [fw=freq], robust
	*p-value
	matrix p_val[`iter',`j'+1] = 2*ttail(e(df_r), abs(_b[2.group]/_se[2.group]))
	
	local j = `j'+2
	}
	
}	
	

	
	

********************************************************************************
*									2M								  		   *
********************************************************************************
use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)

********************************************************************************


local depvar conflicto_arreglado entablo_demanda demando_con_abogado_publico coyote
local controls mujer antiguedad salario_diario


*Pool
gen original = 1
gen unif = .
gen freq = 1


forvalues iter = 1/100 {
*Draw sample
replace unif = runiform() if original==1
sort unif
replace freq = freq +1 if _n<=10 


	
local j = 9
foreach var in `depvar'	{
	
	reg `var' i.group [fw=freq], robust
	*p-value
	matrix p_val[`iter',`j'] = 2*ttail(e(df_r), abs(_b[2.group]/_se[2.group]))
	
	reg `var' i.group `controls' [fw=freq], robust
	*p-value
	matrix p_val[`iter',`j'+1] = 2*ttail(e(df_r), abs(_b[2.group]/_se[2.group]))
	
	local j = `j'+2
	}
	
}	
	
********************************************************************************
	
	
matrix colnames p_val = "conflicto_arreglado" "conflicto_arreglado_c" "hablo_con_abogado" "hablo_con_abogado_c" "cond_hablo_con_publico" "cond_hablo_con_publico_c" "coyote" "coyote_c"  "conflicto_arreglado_2m"  "conflicto_arreglado_2m_c"  "entablo_demanda_2m" "entablo_demanda_2m_c" "demando_con_abogado_publico_2m" "demando_con_abogado_publico_2m_c" "coyote_2m" "coyote_2m_c"
matlist p_val

clear
svmat p_val, names(col) 	


********************************************************************************
********************************************************************************

gen iter = _n*10

tsset iter

tsline conflicto_arreglado conflicto_arreglado_c conflicto_arreglado_2m conflicto_arreglado_2m_c
tsline coyote*
tsline entablo*
