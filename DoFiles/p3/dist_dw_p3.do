*Disribution of daily wage

use "$directorio\DB\treatment_data.dta", clear

qui su salario_diario, d
hist salario_diario if salario_diario<=`r(p90)', percent scheme(s2mono) graphregion(color(white)) lcolor(black) ///
	fcolor(none) xline(`r(mean)', lwidth(thick)) xline(`r(p50)', lwidth(thick)) ///
	xtitle("Pesos") ytitle("Percent")
graph export "$directorio\Figuras\dist_dw_p3.pdf", replace 
 
