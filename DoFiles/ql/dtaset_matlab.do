*Dataset for MATLAB

use "$directorio\DB\lawyer_dataset_collapsed.dta", clear


*Variable name cleaning
foreach var of varlist mean_perc* {
	local nvar=substr("`var'",11,.)
	rename `var' `nvar'
	}

foreach var of varlist sd_perc* {
	local nvar=substr("`var'",9,.)
	rename `var' sd_`nvar'
	}

foreach var of varlist mean_ratio* {
	local nvar=substr("`var'",12,.)
	rename `var' `nvar'
	}
	
foreach var of varlist sd_ratio* {
	local nvar=substr("`var'",10,.)
	rename `var' sd_`nvar'
	}

foreach var of varlist mean_* {
	local nvar=substr("`var'",6,.)
	rename `var' `nvar'
	}
	
foreach var of varlist sd_* {
	local nvar=substr("`var'",4,.)
	rename `var' sd_`nvar'
	}	
	

drop hi_* low_*

export delimited using "$directorio\DB\lawyer_dataset_collapsed.csv", replace
	
