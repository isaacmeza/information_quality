* Do File to obatin dataset to import to excel and feed MATLAB code for 
* 'Calculator B'

******** Global variables 
global int=.797			/* Interest rate */
global perc_pag=.30		/* Percentage of payment to private lawyer */
global pago_pub=0		/* Payment to public lawyer */
global pago_pri=0		/* Payment to private lawyer (to add later in MATLAB)*/

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
gen npv_pri=(liq_total_tope/(1+(${int})/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
gen npv_pub=(liq_total_tope/(1+(${int})/100)^months)-${pago_pub} if abogado_pub==1


*Homologation
rename fecha_ter fecha
cap drop anio 
cap drop mes
gen mes=month(fecha)
gen anio=year(fecha)

merge m:1 mes anio using "$sharelatex/Raw/inpc.dta", nogen keep(1 3) 


*Subsample according to Tenure and Daily wage
keep if c_antiguedad<=25 & !missing(c_antiguedad)
	*We allow private lawyers to inflate daily wage
gen flag=0
replace flag=1 if salario_diario<=650 & !missing(salario_diario) & abogado_pub==1
replace flag=1 if salario_diario<=(650+0) & !missing(salario_diario) & abogado_pub==0
keep if flag==1

keep inpc npv_pri npv_pub 


*Private
preserve
sort npv_pri
drop npv_pub
drop if missing(npv_pri)
export excel using "$directorio\calculadora_B\npv.xlsx", sheet("pri") sheetmodify
restore

*Public
preserve
sort npv_pub
drop npv_pri
drop if missing(npv_pub)
export excel using "$directorio\calculadora_B\npv.xlsx", sheet("pub") sheetmodify
restore

clear
