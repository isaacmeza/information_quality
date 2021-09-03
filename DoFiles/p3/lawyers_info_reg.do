use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(3)


local lawyers_info esquema_de_cobro_pago_para_inici esquema_de_cobro_porcentaje sabe_dias_salario nivel_de_satisfaccion_abogado quiere_cambiar_abogado 
local controls mujer antiguedad salario_diario

*******************************
* 			REGRESSIONS		  *
*******************************
eststo clear

foreach var of varlist `lawyers_info' {
	eststo: reg `var' i.main_treatment `controls', r cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	qui test 2.main_treatment=3.main_treatment
	estadd scalar test_23=`r(p)'	
	qui su `var' if e(sample)
	estadd scalar DepVarMean=r(mean)
	estadd local BVC="YES"
	estadd local Source="2m"	
	}
	
	*************************
	esttab using "$directorio/Tables/reg_results/lawyers_info_reg.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "DepVarMean DepVarMean" "BVC BVC" "Source Source" "test_23 T2=T3") replace 
	

	
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************



use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(3)

local controls mujer antiguedad salario_diario

	*Type of lawyer: 0-Public 1-Private 2-Coyote
gen type_lawyer=demando_con_abogado_privado
replace type_lawyer=2 if coyote==1

*******************************
* 			REGRESSIONS		  *
*******************************
eststo clear

	eststo: reg quiere_cambiar_abogado i.main_treatment `controls', r cluster(fecha_alta)
	estadd scalar Erre=e(r2)	
	qui su quiere_cambiar_abogado if e(sample)
	estadd scalar DepVarMean=r(mean)
	estadd local BVC="YES"
	estadd local Source="2m"
	
	eststo: reg quiere_cambiar_abogado i.type_lawyer `controls', r cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	qui su quiere_cambiar_abogado if e(sample)
	estadd scalar DepVarMean=r(mean)
	estadd local BVC="YES"
	estadd local Source="2m"	

	
	*************************
	esttab using "$directorio/Tables/reg_results/lawyerstype_info_reg.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "DepVarMean DepVarMean" "BVC BVC" "Source Source") replace 
	

