*Another thing to look at is the relation between those who talk to lawyer at 2W
* and those who sue with either public or private lawyer

use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", nogen keep(3) keepusing(demando_con_abogado_publico)
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)


tab demando_con_abogado_publico cond_hablo_con_publico, m matcell(tab_talked_sue)
qui putexcel I8=matrix(tab_talked_sue) using "$directorio\Tables\talked_sue.xlsx", sheet("tab_talked_sue") modify


*************************************
*			Regressions				*
*************************************

eststo clear
gen esample=.


eststo: reg demando_con_abogado_publico cond_hablo_con_publico ///
	mujer salario_diario antiguedad , cluster(fecha_alta)
estadd scalar Erre=e(r2)
estadd local BVC="YES"

*------------------------------------------------------------------------------

eststo: ivregress 2sls demando_con_abogado_publico    ///
         mujer antiguedad salario_diario ///
		 (cond_hablo_con_publico = i.group), cluster(fecha_alta) 
estadd scalar Erre=e(r2)
estadd local BVC="YES"

replace esample=e(sample)

eststo:  reg cond_hablo_con_publico i.group mujer antiguedad salario_diario if esample==1, ///
	cluster(fecha_alta)  
estadd scalar Erre=e(r2)
estadd local BVC="YES"

	
eststo: reg demando_con_abogado_publico cond_hablo_con_publico ///
	mujer salario_diario antiguedad if esample==1, cluster(fecha_alta)
estadd scalar Erre=e(r2)
estadd local BVC="YES"


*------------------------------------------------------


eststo: ivregress 2sls demando_con_abogado_publico    ///
         mujer antiguedad salario_diario ///
		 (cond_hablo_con_publico = i.main_treatment), cluster(fecha_alta) 
estadd scalar Erre=e(r2)
estadd local BVC="YES"

replace esample=e(sample)

eststo:  reg cond_hablo_con_publico i.main_treatment mujer antiguedad salario_diario if esample==1, ///
	cluster(fecha_alta)  
estadd scalar Erre=e(r2)
estadd local BVC="YES"

	
eststo: reg demando_con_abogado_publico cond_hablo_con_publico ///
	mujer salario_diario antiguedad if esample==1, cluster(fecha_alta)
estadd scalar Erre=e(r2)
estadd local BVC="YES"

*************************
	esttab using "$directorio/Tables/reg_results/talked_sue.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "BVC BVC") replace 
		
		
