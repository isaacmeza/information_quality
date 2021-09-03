/*
Regression to determine difference in NPV compensation between public and private lawyers.
IMPORTANT: For use in implementation of Arm B of PILOT3
*/



******** Global variables 
global int=.797				/* Interest rate */
global perc_pag=.30			/* Percentage of payment to private lawyer */
global pago_pub=0			/* Payment to public lawyer */
global pago_pri=2000		/* Payment to private lawyer */
global threshold_dw=317		/* Cutoff of parition in daily wage*/

global sharelatex C:\Users\xps-seira\Dropbox\Apps\ShareLaTeX\information_settlement\Paper

*********************************HD DATA****************************************
use  "$sharelatex\DB\scaleup_hd.dta", clear


*Outliers
cap drop perc
xtile perc=liq_total_tope, nq(100)
replace liq_total_tope=. if perc>=95


*Date 
gen fecha_ter=date(fecha_termino, "YMD")
gen fechadem=date(fecha_demanda, "YMD")


*NPV
gen months=(fecha_ter-fechadem)/30
gen npv=.
replace npv=(liq_total_tope/(1+(${int})/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npv=(liq_total_tope/(1+(${int})/100)^months)-${pago_pub} if abogado_pub==1


*Homologation
rename fecha_ter fecha
cap drop anio 
cap drop mes
gen mes=month(fecha)
gen anio=year(fecha)

merge m:1 mes anio using "$sharelatex/Raw/inpc.dta", nogen keep(1 3) 

*NPV at constant prices (June 2016)
replace npv=(npv/inpc)*118.901

*Trimming
cap drop perc
xtile perc=npv, nq(100)
replace npv=. if perc>=90

*Thousand pesos
replace npv=npv/1000

********************************************************************************
********************************************************************************

*REGRESSION

qui reg npv i.abogado_pub gen trabajador_base c_antiguedad ///
			salario_diario horas_sem c_total if salario_diario<=${threshold_dw}, r
*Lower bound % compensation for private
di round(_b[_cons]*100/(_b[_cons]+_b[1.abogado_pub]))
		
qui reg npv i.abogado_pub gen trabajador_base c_antiguedad ///
			salario_diario horas_sem c_total if salario_diario>${threshold_dw}, r
*Upper bound % compensation for private
di round(_b[_cons]*100/(_b[_cons]+_b[1.abogado_pub]))
		
		

