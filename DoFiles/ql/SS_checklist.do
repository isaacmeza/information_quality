*SUMMMARY STATISTICS TABLE FOR CHECKLIST

use "$directorio\DB\checklist_db.dta", clear
gen dummy=1

*SS
orth_out $varlist_checklist c_obj c_sub , ///
				by(dummy) overall se vce(robust)   bdec(2)  
putexcel K5=matrix(r(matrix)) using "$directorio\Tables\SS_checklist.xlsx", sheet("SS_checklist") modify
