/*
********************
version 17.0
********************
 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	January 21, 2022
* Last date of modification:   
* Modifications:		
* Files used:     
* Files created:  

* Purpose: 

*******************************************************************************/
*/


filelist, dir("$directorio/Raw/HD/seguimientos/FISCALIZACION") pat("*.xlsx") save("$directorio/_aux/base_seg_hd.dta")  replace 

use "$directorio/_aux/base_seg_hd.dta", clear
local obs = _N 
di `obs'

forvalues i=1/`obs' { 
	di "`i'"
	qui {
		use "$directorio/_aux/base_seg_hd.dta" in `i', clear 
		local f = dirname + "/" + filename 
		noi di "`f'"
		import excel "`f'", sheet("Sheet1") clear
		local rows = _N - 4	
		import excel "`f'", sheet("Sheet1") cellrange(A4:FJ`rows') firstrow clear
		do "$directorio/DoFiles/cleaning/cleaning_vars_seg_aud_hd.do"
		tempfile temp`i' 
		save "`temp`i''" 
	}
}

	 
use "`temp1'", clear 
forvalues i=2/`obs' { 
	append using "`temp`i''" 
} 


duplicates drop 

save "$directorio\DB\seguimiento_aud_hd.dta", replace	