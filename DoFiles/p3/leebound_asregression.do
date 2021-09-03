********************************************************************************
************************************2M******************************************
use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3)
qui su date
keep if inrange(date,`r(min)',date(c(current_date) ,"DMY")-70)
			
keep if inlist(main_treatment,1,3)
gen tratamiento=(main_treatment==3)	

keep conflicto_arreglado tratamiento
rename conflicto_arreglado y
rename tratamiento t
		
leebounds y t

qui gen s=!missing(y)
 su s if t==1
local p_s_t1=r(mean)
 su s if t==0
local p_s_t0=r(mean)

 su y if t==1 & s==1
local p_y_t1_s1=r(mean)

 su y if t==0 & s==1
local p_y_t0_s1=r(mean)



gen lower=max(0,(`p_s_t1'/`p_s_t0')*(`p_y_t1_s1'-(`p_s_t1'-`p_s_t0')/`p_s_t1'))-`p_y_t0_s1'
gen upper=min(1, (`p_y_t1_s1'*`p_s_t1')/`p_s_t0')-`p_y_t0_s1'
su lower upper

reg s t
reg y t
predict p

gen hola=y 
replace hola=p if missing(hola)



reg hola t


gen hola1=y 
replace hola1=1 if missing(hola1) & t==1
replace hola1=0 if missing(hola1) & t==0

reg hola1 t

gen hola2=y 
replace hola2=0 if missing(hola2) & t==1
replace hola2=1 if missing(hola2) & t==0

reg hola2 t 






sort s t 
gen uno=_n if s==0 & t==0
gsort s -t
gen dos=_n if s==0 & t==1

 su uno
local n_uno=r(N)
 su dos
local n_dos=r(N)

matrix efect=J(`n_uno'+1, `n_dos'+1, .)
forvalues i=0/`n_uno' {
forvalues j=0/`n_dos' {
qui {
cap drop hola3
gen hola3=y
replace hola3=1 if missing(hola3) & t==0 & uno<=`i'
replace hola3=0 if missing(hola3) & t==1 & dos<=`j'
reg hola3 t
matrix efect[`=`i'+1', `=`j'+1']=_b[t]
}
}
di `i'
}

putexcel A2=matrix(efect) using "$directorio\_aux\efect.xlsx", ///
	sheet("efect") modify





