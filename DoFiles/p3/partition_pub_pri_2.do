/*
Regression to determine difference in NPV compensation between public and private lawyers.
IMPORTANT: For use in implementation of Arm B of PILOT3
*/



******** Global variables 
global int=.797			/* Interest rate */
global perc_pag=.30		/* Percentage of payment to private lawyer */
global pago_pub=0		/* Payment to public lawyer */

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

*Percentage win of private lawyer (relative to public lawyer)
mata: win_pri_above=J(101,101,.)
mata: win_pri_below=J(101,101,.)


local i=1
forvalues pago_pri=0(100)10000 {

	preserve

	*NPV
	qui gen months=(fecha_ter-fechadem)/30
	qui gen npv=.
	qui replace npv=(liq_total_tope/(1+(${int})/100)^months)*(1-${perc_pag})-`pago_pri' if abogado_pub==0
	qui replace npv=(liq_total_tope/(1+(${int})/100)^months)-${pago_pub} if abogado_pub==1


	*Homologation
	qui rename fecha_ter fecha
	qui cap drop anio 
	qui cap drop mes
	qui gen mes=month(fecha)
	qui gen anio=year(fecha)

	qui merge m:1 mes anio using "$sharelatex/Raw/inpc.dta", nogen keep(1 3) 

	*NPV at constant prices (June 2016)
	qui replace npv=(npv/inpc)*118.901

	*Trimming
	qui cap drop perc
	qui xtile perc=npv, nq(100)
	qui replace npv=. if perc>=90

	*Thousand pesos
	qui replace npv=npv/10

	********************************************************************************
	********************************************************************************
	
	*Paritition using a threshold in daily wage
	local j=1
	forvalues dw=100(10)1100 {
	
		qui reg npv i.abogado_pub gen trabajador_base c_antiguedad ///
			salario_diario horas_sem c_total if salario_diario<=`dw', r
		local porc_below=_b[_cons]*100/(_b[_cons]+_b[1.abogado_pub])
		
		qui reg npv i.abogado_pub gen trabajador_base c_antiguedad ///
			salario_diario horas_sem c_total if salario_diario>`dw', r
		local porc_above=_b[_cons]*100/(_b[_cons]+_b[1.abogado_pub])
		
		*Store results in matrix
		mata: win_pri_above[`i',`j']=`porc_above'
		mata: win_pri_below[`i',`j']=`porc_below'
		
		local j=`j'+1
		}
	
	local i=`i'+1
	restore
	}

	
clear
getmata (var*) = win_pri_above
export delimited using "$directorio\Simulations\partition_pub_pri_above.csv", replace novarnames

clear
getmata (var*) = win_pri_below
export delimited using "$directorio\Simulations\partition_pub_pri_below.csv", replace novarnames
		
