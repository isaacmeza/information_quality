*In case we don't match with defendants
use "$directorio\_aux\merge_mm.dta", clear
	duplicates drop nombre_actor, force
tempfile temp_mm
gen n=_n
save `temp_mm'


*Merge with original datasets
use "$directorio\DB\treatment_data.dta", clear
cap drop plaintiff_name 
cap drop plaintiff_name_hom
forvalues k=1/6 {
	cap drop defendant_name_`k'
	}
merge 1:1 id_actor using "$directorio\_aux\td.dta", nogen
save "$directorio\DB\treatment_data.dta", replace


*Merge with Sues
use "$directorio\DB\survey_data_2m.dta", clear
qui merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3) nogen
keep if entablo_demanda==1
keep id_actor plaintiff_name* defendant_name*

sort id_actor
gen n=_n

merge 1:1 n using `temp_mm', nogen

gen flag_ac=0
gen flag_dem=0
mata: dta_match=J(1,2,"")

*Generate "new name" in alphabetical order
	*Split string
split plaintiff_name, p(" ") gen(aux_names_ac)

/*
forvalues d=1/4 {
	*Generate "new name" in alphabetical order
		*Split string
	split defendant_name_`d', p(" ") gen(aux_names_dem_`d')
	}
*/
	
qui count if !missing(id_actor)
local tot=`r(N)'
forvalues i=1/`tot' {
	
	local id=id_actor[`i']	

	local k=0
	foreach var of varlist aux_names_ac* {
		local k=`k'+1
		}
		
	local num_nm=0	
	forvalues t=1/`k' {
		if !missing(aux_names_ac`t') {
			local num_nm=`num_nm'+1
			}
		}
		
	qui replace flag_ac=0	
	forvalues j=1/`k' {		
		local lc=aux_names_ac`j'[`i']
		forvalues s=1/17 {
			*cap drop strdist
			*qui strdist names_ac`s' "`lc'"
			*qui replace flag_ac=flag_ac+1 if (strdist<=1) & "`lc'"!=""
			qui replace flag_ac=flag_ac+1 if (names_ac`s'=="`lc'") & "`lc'"!=""
			}
		}	
	cap drop tag_good_ac	
	*THRESHOLD OF TOLERANCE IN MATCH
	qui gen tag_good_ac=(flag_ac>=`num_nm')	

/*
	forvalues d=1/4 {

		local k=0
		foreach var of varlist aux_names_dem_`d'* {
			local k=`k'+1
			}
			
		qui replace flag_dem=0	
		forvalues j=1/`k' {		
			local lc=aux_names_dem_`d'`j'[`i']
			forvalues s=1/26 {
				*cap drop strdist
				*qui strdist names_dem`s' "`lc'"
				*replace flag_dem=flag_dem+1 if (strdist<=1) & "`lc'"!=""
				qui replace flag_dem=flag_dem+1 if (names_dem`s'=="`lc'") & "`lc'"!=""
				}
			}	
		cap drop tag_good_dem_`d'	
		qui gen tag_good_dem_`d'=(flag_dem/`k'>=0.5)	
		}
*/		
		
	*Keep id_actor ad FOLIO for 'matches'
	preserve
	qui keep if tag_good_ac==1 
	qui count
	mata: matches=J( `r(N)',2,"")
	forvalues r=1/`r(N)' {
		local folio=FOLIO[`r']
		mata: matches[`r',.]=("`id'","`folio'")
		}
	restore

	mata: dta_match=(dta_match \ matches)
	di "(`i'/`tot')"
	}
	
clear
getmata (id_actor FOLIO) = dta_match
drop if missing(id_actor) & missing(FOLIO)

merge m:1 id_actor using "$directorio\DB\treatment_data.dta", nogen keep(3) ///
	keepusing(plaintiff_name)
merge m:m FOLIO using `temp_mm', nogen keep(3)

sort id_actor FOLIO

