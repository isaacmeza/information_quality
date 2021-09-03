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
	

********************************************************************************


*****************************************
* 				CORRELATIONS            *
*****************************************

local j=2
foreach varj of varlist $output_varlist $sd_varlist_output {
	local Col=substr(c(ALPHA),2*`j'-1,1)
	*Output variable
	qui putexcel `Col'1=("`varj'")  using "$directorio/Tables/Corr.xlsx", ///
		sheet("corr") modify
	local ++j	
	}
	
	
local i=5			
foreach vari of varlist $input_varlist $sd_varlist_input {	
	local j=2

	foreach varj of varlist $output_varlist $sd_varlist_output {
	
		local Col=substr(c(ALPHA),2*`j'-1,1)
		
		qui corr `vari' `varj'
		
		*Correlation
		local rho=round(r(rho),0.01)
		qui putexcel `Col'`i'=("`rho'")  using "$directorio/Tables/Corr.xlsx", ///
			sheet("corr") modify
		local ++j
		}
	local ++j
	local Col=substr(c(ALPHA),2*`j'-1,1)
	*Input variable
	qui putexcel `Col'`i'=("`vari'")  using "$directorio/Tables/Corr.xlsx", ///
		sheet("corr") modify
		
	local ++i
	}
