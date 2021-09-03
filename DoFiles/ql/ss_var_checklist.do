*Dataset ~100 initial casefiles
do "$directorio\DoFiles\initials_dataset.do"


*Generation of variables of interest
do "$directorio\DoFiles\gen_measures.do"


*Variable name cleaning
foreach var of varlist perc* {
	local nvar=substr("`var'",6,.)
	cap rename `var' `nvar'
	}

foreach var of varlist ratio* {
	local nvar=substr("`var'",7,.)
	cap rename `var' `nvar'
	}

	
foreach varj of varlist pos_rec settlement win_asked {
		foreach var of varlist *_clv {
		reg `varj' `var' , r
		qui putexcel e(r2)
		
		qui su `var' if e(sample)
		
		}
	}
	
**********
