*Merge with Sues
use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\_aux\match_.dta"

*Match up to admin data date
qui su survey_date
drop if inrange(survey_date,`r(min)',date("31/08/2018","DMY"))!=1  & (entablo_demanda==1 & similscore!=1)
duplicates drop id_actor, force

 
*Sue based on admin data
gen sue_admin=(similscore==1) 
gen sue_fuzzy=(similscore>=0.9)


tab entablo_demanda sue_admin
tab entablo_demanda sue_fuzzy

qui count if entablo_demanda==0
local den_0=`r(N)'
qui count if entablo_demanda==1
local den_1=`r(N)'
qui gen score=.
qui gen match_0=.
qui gen match_1=.

local j=1
forvalues i=0.6(0.01)1 {
	qui replace score=`i' in `j'
	cap drop sue_fuzzy
	qui gen sue_fuzzy=(similscore>=`i')
	qui count if entablo_demanda==0 & sue_fuzzy==0
	qui replace match_0=`r(N)'/`den_0' in `j'
	qui count if entablo_demanda==1 & sue_fuzzy==1
	qui replace match_1=`r(N)'/`den_1' in `j'
	local ++j
	}
	

twoway (line match_0 score) (line match_1 score)

eststo: reg entablo_demanda i.main_treatment, robust cluster(fecha_alta)
eststo: reg sue_admin i.main_treatment, robust cluster(fecha_alta)
eststo: reg entablo_demanda i.main_treatment, robust cluster(fecha_alta)
