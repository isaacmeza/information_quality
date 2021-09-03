*Seed
set seed X5f477e32ccbd3e6487cdece355f57f2a00041b66

use "$directorio\_aux\assignment_3.dta", clear
sort junta exp anio

gen unif=runiform()
sort unif

*Divide in 28 bins so that a casefile is shared by (at least) 2 lawyers
gen bin=0
forvalues i=1/27 {
	replace bin=`i' if inrange(_n,`i'*17+1,(`i'+1)*17)
	}
replace bin=6 if inrange(_n,477,482) & bin==0
replace bin=11 if inrange(_n,483,488) & bin==0
replace bin=15 if inrange(_n,489,494) & bin==0
replace bin=18 if inrange(_n,495,500) & bin==0

*Lawyers assignation
gen lawyer_1=1 if inlist(bin, 0,1,2,3,4,5,6)
gen lawyer_2=1 if inlist(bin, 0,7,8,9,10,11,12)
gen lawyer_3=1 if inlist(bin, 1,7,13,14,15,16,17)
gen lawyer_4=1 if inlist(bin, 2,8,13,18,19,20,21)
gen lawyer_5=1 if inlist(bin, 3,9,14,18,22,23,24)
gen lawyer_6=1 if inlist(bin, 4,10,15,19,22,25,26)
gen lawyer_7=1 if inlist(bin, 5,11,16,20,23,25,27)
gen lawyer_8=1 if inlist(bin, 6,12,17,21,24,26,27)

forvalues i=1/8 {
	replace lawyer_`i'=0 if missing(lawyer_`i')
	}

*Balance
	*Lawyers
eststo clear
local vlist liq_total_tope gen horas_sem salario_diario abogado_pub c_antiguedad trabajador_base indem sal_caidos prima_antig prima_vac hextra prima_dom desc_sem desc_ob
foreach var of varlist 	`vlist' {
	eststo: reg `var' lawyer_2-lawyer_8 , r
	estadd scalar Erre=e(r2)
	}
**********
esttab using "$directorio/Tables/reg_results/balance_assignment3_lawyers.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
scalars("Erre R-squared") replace 
 	
	
	*Bins
eststo clear
local vlist liq_total_tope gen horas_sem salario_diario abogado_pub c_antiguedad trabajador_base indem sal_caidos prima_antig prima_vac hextra prima_dom desc_sem desc_ob
foreach var of varlist 	`vlist' {
	eststo: reg `var' i.bin if inrange(bin, 0,27), r
	estadd scalar Erre=e(r2)
	}	
**********
esttab using "$directorio/Tables/reg_results/balance_assignment3_bin.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
scalars("Erre R-squared") replace 
 	
	
	
***********************************************	
keep junta exp anio modo_termino liq_total_tope comp_* abogado_pub pos_rec perc_pr lawyer_*
order junta exp anio modo_termino liq_total_tope comp_* abogado_pub pos_rec perc_pr lawyer_*
sort junta exp anio	
export delimited using "$directorio\_aux\asignaciones_3.csv", replace

