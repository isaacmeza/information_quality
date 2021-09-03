*In the experiment T1 began to appear as T2. This do file tries to identify the
*date where T1 and T2 became "undistinguishable"

		
********************************************************************************
*									2M								  		   *
********************************************************************************
use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)

********************************************************************************

qui gen esample=1	
qui gen nvals=.

local depvar conflicto_arreglado entablo_demanda 
local controls mujer antiguedad salario_diario
local dte = date("12/09/2017", "DMY")


*******************************
* 			RDD				  *
*******************************

matrix rdd_1=J(300,4,.)
matrix rdd_2=J(300,4,.)

eststo clear
foreach var in `depvar'	{
	cap drop rd_dummy
	gen rd_dummy=(date>=`dte')
	eststo: reg `var' i.rd_dummy##i.main_treatment `controls' , robust cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	estadd local BVC="YES"
	estadd local Source="2m"
	}
	
	
forvalues d=1/300 {	
	qui {
	local k=1
	foreach var in `depvar'	{
		cap drop rd_dummy
		gen rd_dummy=(date>=date("01/06/2017" ,"DMY")+`d')
		reg `var' i.rd_dummy##i.main_treatment `controls' , robust cluster(fecha_alta)
		matrix rdd_`k'[`d',1]=_b[1.rd_dummy#2.main_treatment]
		matrix rdd_`k'[`d',2]=_se[1.rd_dummy#2.main_treatment]
		matrix rdd_`k'[`d',3]=_b[1.rd_dummy#3.main_treatment]
		matrix rdd_`k'[`d',4]=_se[1.rd_dummy#3.main_treatment]
		local df = e(df_r)
		local ++k
		}
		}	
	}
	

forvalues k=1/2 {
	clear
	matrix colnames rdd_`k' = "beta_rdd_2" "se_rdd_2"  "beta_rdd_3" "se_rdd_3"
	svmat rdd_`k', names(col) 

	*CI
	gen lo_rdd_2=beta_rdd_2-invttail(`df',.025)*se_rdd_2
	gen lo_rdd_3=beta_rdd_3-invttail(`df',.025)*se_rdd_3
	gen hi_rdd_2=beta_rdd_2+invttail(`df',.025)*se_rdd_2
	gen hi_rdd_3=beta_rdd_3+invttail(`df',.025)*se_rdd_3

	*Date of Discontinuity
	gen disc_date=_n+date("01/06/2017" ,"DMY")
	format disc_date %td
	tsset disc_date

	gen zero=0

	forvalues j=2/3 {
		twoway rarea lo_rdd_`j' hi_rdd_`j' disc_date, color(gs10)  || ///
				line beta_rdd_`j' disc_date, lwidth(thick) lpattern(solid) lcolor(black) ///
				|| line zero disc_date , xline(`dte', lcolor(red)) lpattern(solid) lcolor(navy) ///
				, scheme(s2mono) graphregion(color(white))  ///
			xtitle("Date of discontinuity") ytitle("RDD Beta") /// 
			title("Treatment: `j'") legend(off) name(plot_`j', replace)
		}	
	graph combine plot_2 plot_3 , cols(2) scheme(s2mono) graphregion(color(white)) ///
		title("Variable: `k'")
	graph export "$directorio/Figuras/diff_beta_var`k'.pdf", replace	 	
	}	
	
esttab using "$directorio/Tables/reg_results/diff_beta_disc_t1.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "BVC BVC" "Source Source") replace 
		
