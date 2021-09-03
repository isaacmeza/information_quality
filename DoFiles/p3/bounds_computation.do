
*Computation of bounds
/*
do "$directorio\DoFiles\plot_bounds.do" ///	
	vardep t0 t1 survey condvar condcond method dummy 
*/

********************************************************************************
*FULL SAMPLE
********************************************************************************

*Survey
foreach s in m w {

	use "$directorio\DB\survey_data_2`s'.dta", clear
	merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3)
	qui su date
	if "`s'"=="w" {
		keep if inrange(date,date("1/08/2017" ,"DMY"),date(c(current_date) ,"DMY")-21)
		}
	else {	
		keep if inrange(date, `r(min)' ,date(c(current_date) ,"DMY")-70)
		}
		
	qui gen telefono_int=telefono_cel*telefono_fijo

	*Treatment arm comparison
	foreach t in 2 3 {

		preserve

		keep if inlist(main_treatment,1,`t')
		gen tratamiento=(main_treatment==`t')

		*Main outcomes
		if "`s'"=="m" {
			foreach var of varlist conflicto_arreglado entablo_demanda {
				do "$directorio\DoFiles\plot_bounds.do" ///
						`var' "1" "`t'" "2`s'" "no_condition" "" "" ""
				}
			do "$directorio\DoFiles\plot_bounds.do" ///
					demando_con_abogado_publico "1" "`t'" "2`s'" entablo_demanda "" 2 "" ""	
					
			do "$directorio\DoFiles\plot_bounds.do" ///
					coyote "1" "`t'" "2`s'" demando_con_abogado_privado entablo_demanda  2 "" ""			
			}

		else {
			foreach var of varlist conflicto_arreglado hablo_con_abogado {
				do "$directorio\DoFiles\plot_bounds.do" ///
						`var' "1" "`t'" "2`s'" "no_condition" "" "" ""
				}
			do "$directorio\DoFiles\plot_bounds.do" ///
					cond_hablo_con_publico "1" "`t'" "2`s'" hablo_con_abogado "" 2 "" ""	
					
			do "$directorio\DoFiles\plot_bounds.do" ///
					coyote "1" "`t'" "2`s'" cond_hablo_con_privado hablo_con_abogado  2 "" ""				
			}
			
		restore		
			
		}	

	}	
	
	
	
********************************************************************************	
*2018 SAMPLE	
********************************************************************************

*Survey
foreach s in m w {

	use "$directorio\DB\survey_data_2`s'.dta", clear
	merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3)
	qui su date
	if "`s'"=="w" {
		keep if inrange(date,date("1/11/2017" ,"DMY"),date(c(current_date) ,"DMY")-21)
		}
	else {	
		keep if inrange(date,date("1/12/2017" ,"DMY"),date(c(current_date) ,"DMY")-70)
		}
		
	qui gen telefono_int=telefono_cel*telefono_fijo

	*Treatment arm comparison
	foreach t in 2 3 {

		preserve

		keep if inlist(main_treatment,1,`t')
		gen tratamiento=(main_treatment==`t')

		*Main outcomes
		if "`s'"=="m" {
			foreach var of varlist conflicto_arreglado entablo_demanda {
				do "$directorio\DoFiles\plot_bounds.do" ///
						`var' "1" "`t'" "2`s'" "no_condition" "" "" "2018"
				}
			do "$directorio\DoFiles\plot_bounds.do" ///
					demando_con_abogado_publico "1" "`t'" "2`s'" entablo_demanda "" 2 "" "2018"	
					
			do "$directorio\DoFiles\plot_bounds.do" ///
					coyote "1" "`t'" "2`s'" demando_con_abogado_privado entablo_demanda  2 "" "2018"			
			}

		else {
			foreach var of varlist conflicto_arreglado hablo_con_abogado {
				do "$directorio\DoFiles\plot_bounds.do" ///
						`var' "1" "`t'" "2`s'" "no_condition" "" "" "2018"
				}
			do "$directorio\DoFiles\plot_bounds.do" ///
					cond_hablo_con_publico "1" "`t'" "2`s'" hablo_con_abogado "" 2 "" "2018"	
					
			do "$directorio\DoFiles\plot_bounds.do" ///
					coyote "1" "`t'" "2`s'" cond_hablo_con_privado hablo_con_abogado  2 "" "2018"				
			}
			
		restore		
			
		}	

	}	
	
	
	
