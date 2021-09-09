/*
Generation of lawyer quality dataset
Author :  Isaac Meza
*/

******** Global variables 
global int = 3.43			/* Interest rate */
global perc_pag = .30		/* Percentage of payment to private lawyer */
global pago_pub = 0		/* Payment to public lawyer */
global pago_pri = 2000	/* Payment to private lawyer */


*****************************HD DATA CLEANING***********************************

*Average daily wage according to SCIAN catalogue
***********************************

use "$directorio\Raw\ENOE\Viviendas.dta", clear
keep folioviv foliohog factor

merge 1:m  folioviv foliohog using "$directorio\Raw\ENOE\Trabajos.dta", nogen

*Keep principal job
keep if numtrab=="1"

merge 1:m folioviv foliohog numren using "$directorio\Raw\ENOE\Ingresos.dta", nogen

*Keep only CDMX
keep if substr(folioviv,1,2)=="09"

*Keep only wage
keep if clave=="P001"

*Keep first 2 digits of SCIAN to match with 'giro_empresa' of 'lawyers_dataset'
gen giro_empresa = substr(scian,1,2)
destring giro_empresa, replace

collapse (mean) ing_tri [fw = factor], by(giro_empresa)

*Daily wage
gen dw_scian = ing_tri/(3*30)

keep dw_scian giro_empresa


tempfile temp_dwscian
save `temp_dwscian'

import delimited "$directorio\Raw\HD\scaleup_hd.csv", clear 
duplicates drop junta exp anio id_actor, force
merge m:1 giro_empresa using `temp_dwscian', nogen keep(1 3)
merge 1:1 junta exp anio id_actor using "$directorio\Raw\HD\calculator.dta", nogen keep(3)

***********************************

*Destring
destring salario_base_diario, replace force
destring salario_diario, force replace

*No negative values
for var c_antiguedad c_indem-c_desc_ob c_recsueldo liq_total: ///
	capture replace X = 0 if X<0 & X~=.
	
*Wizorise all at 99th percentile
for var c_* liq_total liq_total_tope : capture egen X99 = pctile(X) , p(99)
for var c_* liq_total liq_total_tope : ///
	capture replace X = X99 if X>X99 & X~=.
drop *99

*Dates
gen fechadem = date(fecha_demanda,"DMY")
gen fechater = date(fecha_termino,"DMY")
format %td fechadem fechater

*NPV
gen months = (fechater - fechadem)/30
gen npv = .
replace npv = (liq_total/(1+(${int})/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npv = (liq_total/(1+(${int})/100)^months)-${pago_pub} if abogado_pub==1
replace npv = (liq_total/(1+(${int})/100)^months) if missing(npv) & !missing(liq_total)
drop if npv==.

gen mes = month(fechadem)


merge m:1 mes anio using "$directorio/Raw/ENOE/inpc.dta", nogen keep(1 3) 

*Constant prices (June 2016)
foreach var of varlist npv c_indem c_prima_antig c_rec20 c_ag c_vac ///
	c_hextra c_prima_vac c_prima_dom c_desc_sem c_desc_ob c_utilidades ///
	c_recsueldo c_total c_sal_caidos ///
	min_ley salario_diario salario_base_diario dw_scian {
	
	replace `var' = (`var'/inpc)*118.901
	
	}



********************************************************************************
*Lawyers name cleaning
do "$directorio\DoFiles\cleaning\name_cleaning_hd.do"


********************************DATASET LAWYER**********************************

*Drop 'bad' id's
drop if salario_base_diario>salario_diario + 1 & !missing(salario_base_diario) & !missing(salario_diario)
drop if salario_base_diario + 1 <salario_minimo & !missing(salario_base_diario) & !missing(salario_minimo)


keep /*Lawyers information*/ ///
	office_emp_law despacho_office gp_office_emp_law nombre_abogado_* abogados_orden gp_orden repeats ///
	/*Operation data*/ ///
	modo_termino npv liq_total*   ///
	/*BVC*/ ///
	gen horas_sem  salario_diario abogado_pub  c_antiguedad trabajador_base ///
	/*Casefile characteristics*/ ///
	indem sal_caidos prima_antig prima_vac hextra ///
	prima_dom desc_sem desc_ob sarimssinf utilidades nulidad  ///
	codem reinst ///
	/*Quantification*/ ///
	comp_* salario_base_diario c_antiguedad c_indem c_prima_antig c_rec20 c_ag c_vac c_hextra c_prima_vac c_prima_dom c_desc_sem c_desc_ob c_utilidades c_recsueldo c_total c_sal_caidos ///
	min_ley dw_scian ///
	/*Dates*/ ///
	fechadem fechater ///
	/*Other*/ ///
	giro_empresa ///
	/*Id*/ ///
	junta exp anio
	

order  /*Lawyers information*/ ///
	office_emp_law despacho_office gp_office_emp_law nombre_abogado_* abogados_orden gp_orden repeats ///
	/*Operation data*/ ///
	modo_termino npv liq_total*   ///
	/*BVC*/ ///
	gen horas_sem  salario_diario abogado_pub  c_antiguedad trabajador_base ///
	/*Casefile characteristics*/ ///
	indem sal_caidos prima_antig prima_vac hextra ///
	prima_dom desc_sem desc_ob sarimssinf utilidades nulidad  ///
	codem reinst ///
	/*Quantification*/ ///
	comp_* salario_base_diario c_antiguedad c_indem c_prima_antig c_rec20 c_ag c_vac c_hextra c_prima_vac c_prima_dom c_desc_sem c_desc_ob c_utilidades c_recsueldo c_total c_sal_caidos ///
	min_ley dw_scian ///
	/*Dates*/ ///
	fechadem fechater ///
	/*Other*/ ///
	giro_empresa ///
	/*Id*/ ///
	junta exp anio

duplicates drop	
save "$directorio\DB\quality_lawyer_dataset.dta", replace
