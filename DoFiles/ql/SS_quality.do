*Summary statistics table

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


*************************
********** MEAN *********
*************************

local n=5

*Input measures
foreach var of varlist $input_varlist  {
qui su `var'
*Variable
qui putexcel E`n'=("`var'")  using "$directorio/Tables/SS_quality.xlsx", ///
		sheet("SS_quality") modify
*Mean		
local mu=round(r(mean),0.01)
qui putexcel B`n'=("`mu'")  using "$directorio/Tables/SS_quality.xlsx", ///
		sheet("SS_quality") modify
local ++n
*SD
local std=round(r(sd),0.01)
local sd="(`std')"
qui putexcel B`n'=("`sd'")  using "$directorio/Tables/SS_quality.xlsx", ///
		sheet("SS_quality") modify	
local ++n		
}


*Output measures
qui putexcel A`n'=("Output measures")  using "$directorio/Tables/SS_quality.xlsx", ///
		sheet("SS_quality") modify	
local ++n

foreach var of varlist $output_varlist {
qui su `var'
*Variable
qui putexcel E`n'=("`var'")  using "$directorio/Tables/SS_quality.xlsx", ///
		sheet("SS_quality") modify
*Mean		
local mu=round(r(mean),0.01)
qui putexcel B`n'=("`mu'")  using "$directorio/Tables/SS_quality.xlsx", ///
		sheet("SS_quality") modify
local ++n
*SD
local std=round(r(sd),0.01)
local sd="(`std')"
qui putexcel B`n'=("`sd'")  using "$directorio/Tables/SS_quality.xlsx", ///
		sheet("SS_quality") modify	
local ++n		
}

qui putexcel A`n'=("# Offices")  using "$directorio/Tables/SS_quality.xlsx", ///
		sheet("SS_quality") modify	
qui count
qui putexcel B`n'=(`r(N)')  using "$directorio/Tables/SS_quality.xlsx", ///
		sheet("SS_quality") modify	


*************************
*********** SD **********
*************************

local n=5

*Input measures
foreach var of varlist $input_varlist {
qui su sd_`var'
*Mean		
local mu=round(r(mean),0.01)
qui putexcel C`n'=("`mu'")  using "$directorio/Tables/SS_quality.xlsx", ///
		sheet("SS_quality") modify
local ++n
*SD
local std=round(r(sd),0.01)
local sd="(`std')"
qui putexcel C`n'=("`sd'")  using "$directorio/Tables/SS_quality.xlsx", ///
		sheet("SS_quality") modify	
local ++n		
}


*Output measures
local ++n

foreach var of varlist $output_varlist {
qui su sd_`var'
*Mean		
local mu=round(r(mean),0.01)
qui putexcel C`n'=("`mu'")  using "$directorio/Tables/SS_quality.xlsx", ///
		sheet("SS_quality") modify
local ++n
*SD
local std=round(r(sd),0.01)
local sd="(`std')"
qui putexcel C`n'=("`sd'")  using "$directorio/Tables/SS_quality.xlsx", ///
		sheet("SS_quality") modify	
local ++n		
}

