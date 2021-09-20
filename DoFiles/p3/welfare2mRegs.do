/*
********************
version 17.0
********************
 
/*******************************************************************************
* Name of file: 		welfare2mRegs.do
* Author:          		Enrique Miranda, Sergio Lopez and revisited and edited by
							Emiliano Ramírez	
* Machine:        		Emiliano Ramirez PC                          				   				                         				   											
* Date of creation:     Sept. 17, 2021
* Last date of modification:   
* Modifications:		
* Files used:     
	-
* Files created:  
	- 
* Purpose:
	- Generate table 11 of Welfare effects at 2 months 
	from Pilot 3 March 2020 draft. 
*******************************************************************************/
*/

*directory 

cd $directorio 
clear all

*first open our treatment database
use "DB\treatment_data.dta", clear
*and do merge with follow up survey at 2 months (keep only those who match)
merge 1:1 id_actor using "DB\survey_data_2m.dta", keep(3)

*define locals of covariates and basic variable controls 
local welfare_vars nivel_de_felicidad ultimos_3_meses_ha_dejado_de_pag ultimos_3_meses_le_ha_faltado_di trabaja_actualmente tiempo_arreglar_asunto_imputed
local controls mujer antiguedad salario_diario



*******************************
* 			REGRESSIONS		  *
*******************************
eststo clear

*regression by arm of treatment 
foreach var of varlist `welfare_vars' {
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
	esttab using "tables/reg_results/welfare_reg_2m.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "DepVarMean DepVarMean" "BVC BVC" "Source Source" "test_23 T2=T3") replace 
	
	
	eststo clear

*regression by group of treatment (NOTE: This piece of code requieres variable group to be coded, nevertheless this table is not in the paper but I leave it if needed later)

/*
foreach var of varlist `welfare_vars' {
	eststo: reg `var' i.group `controls', r cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	qui test 2.group
	estadd scalar test_23=`r(p)'
	qui su `var' if e(sample)
	estadd scalar DepVarMean=r(mean)
	estadd local BVC="YES"
	estadd local Source="2m"	
	}
	
	*************************
	esttab using "tables/reg_results/welfare_reg_2m_AB.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "DepVarMean DepVarMean" "BVC BVC" "Source Source" "test_23 T2=T3") replace 
*/	