
use "$directorio\DB\treatment_data.dta", clear

*2M
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(1 3) 

*Variables of interest
rename entablo_demanda demando_2m
rename conflicto_arreglado arreglo_2m
rename _merge _merge_2m

keep id_actor genero demando_2m arreglo_2m _merge_2m treatment date

*2W
merge 1:1 id_actor using "$directorio\DB\survey_data_2w.dta", keep(1 3)

*Variables of interest
rename entablo_demanda demando_2w
rename conflicto_arreglado arreglo_2w

*Fix inconsistency
replace demando_2w=0 if demando_2m==0 & demando_2w==1

tab demando_*, m
tab arreglo_*, m
*Imputation for final variables
gen demando=demando_2m
replace demando=demando_2w if missing(demando_2m) & demando_2w==1
gen arreglo=arreglo_2m
replace arreglo=arreglo_2w if missing(arreglo_2m) & arreglo_2w==1
drop if missing(genero)
gen gen=(genero=="Mujer")
drop genero
rename gen genero


forvalues yr = 2018/2019 {

if `yr' == 2018 {
	local num_mes = 12
	}
else {
	local num_mes = 7
	}
	
forvalues t=1/`num_mes' {

	di `yr'
	di `t'

	preserve

	
	*Date range
	keep if month(date)==`t' & year(date)==`yr'
	
	if `yr'==2018 {
	if `t'==1 {
	local mes="enero18"
	}
	if `t'==2 {
	local mes="febrero18"
	}
	if `t'==3 {
	local mes="marzo18"
	}
	if `t'==4 {
	local mes="abril18"
	}
	if `t'==5 {
	local mes="mayo18"
	}
	if `t'==6 {
	local mes="junio18"
	}
	if `t'==7 {
	local mes="julio18"
	}
	if `t'==8 {
	local mes="agosto18"
	}
	if `t'==9 {
	local mes="septiembre18"
	}
	if `t'==10 {
	local mes="octubre18"
	}
	if `t'==11 {
	local mes="noviembre18"
	}
	if `t'==12 {
	local mes="diciembre18"
	}
	}
	
	if `yr'==2019 {
	if `t'==1 {
	local mes="enero19"
	}
	if `t'==2 {
	local mes="febrero19"
	}
	if `t'==3 {
	local mes="marzo19"
	}
	if `t'==4 {
	local mes="abril19"
	}
	if `t'==5 {
	local mes="mayo19"
	}
	if `t'==6 {
	local mes="junio19"
	}
	if `t'==7 {
	local mes="julio19"
	}
	if `t'==8 {
	local mes="agosto19"
	}
	if `t'==9 {
	local mes="septiembre19"
	}
	if `t'==10 {
	local mes="octubre19"
	}
	if `t'==11 {
	local mes="noviembre19"
	}
	if `t'==12 {
	local mes="diciembre19"
	}	
	}

	*Stats numbers
	count if genero==1
	qui putexcel G4=(`r(N)') using "$directorio\Tables\count_stats.xlsx", sheet("`mes'") modify
	count if genero==0
	qui putexcel H4=(`r(N)') using "$directorio\Tables\count_stats.xlsx", sheet("`mes'") modify

	su arreglo if genero==1 
	qui putexcel G6=(`r(mean)') using "$directorio\Tables\count_stats.xlsx", sheet("`mes'") modify
	su arreglo if genero==0 
	qui putexcel H6=(`r(mean)') using "$directorio\Tables\count_stats.xlsx", sheet("`mes'") modify

	su demando if genero==1 & arreglo==0
	qui putexcel G8=(`r(mean)') using "$directorio\Tables\count_stats.xlsx", sheet("`mes'") modify
	su demando if genero==0 & arreglo==0
	qui putexcel H8=(`r(mean)') using "$directorio\Tables\count_stats.xlsx", sheet("`mes'") modify
		
	restore
	}
	}

*Date range
keep if inrange(date,date("1/1/2018" ,"DMY"),date("01/01/2020" ,"DMY"))

*Stats numbers
count if genero==1
qui putexcel G4=(`r(N)') using "$directorio\Tables\count_stats.xlsx", sheet("total") modify
count if genero==0
qui putexcel H4=(`r(N)') using "$directorio\Tables\count_stats.xlsx", sheet("total") modify

su arreglo if genero==1 
qui putexcel G6=(`r(mean)') using "$directorio\Tables\count_stats.xlsx", sheet("total") modify
su arreglo if genero==0 
qui putexcel H6=(`r(mean)') using "$directorio\Tables\count_stats.xlsx", sheet("total") modify

su demando if genero==1 & arreglo==0
qui putexcel G8=(`r(mean)') using "$directorio\Tables\count_stats.xlsx", sheet("total") modify
su demando if genero==0 & arreglo==0
qui putexcel H8=(`r(mean)') using "$directorio\Tables\count_stats.xlsx", sheet("total") modify
	
