*Number of lawyers per office

use "$directorio\DB\lawyer_dataset.dta", clear


keep despacho_office nombre_abogado_*
drop if missing(despacho_office)
duplicates drop
egen gp_despacho_office=group(despacho_office)
gen id=_n

*Long dataset 
reshape long nombre_abogado_, i(id) j(num_law)

*Count number of distinct lawyers by office
duplicates drop nombre_abogado gp, force
drop if missing(nombre_abogado)

collapse (count) num_law, by(gp)

*Histogram
xtile perc_num_law=num_law, nq(100)
hist num_law if inrange(perc,0,99), percent discrete scheme(s2mono) graphregion(color(white)) ///
	xtitle("Number of lawyers") title("# lawyers / office")
graph export "$directorio\Figuras\hist_num_law_offices.pdf", replace
	
