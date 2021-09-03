use "$directorio\DB\lawyer_dataset.dta", clear

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

bysort gp_office : gen num_casefiles=_N
drop if num_casefiles<=4
sort gp_office
egen id=group(gp_office)
*FE Office	
xi i.id, noomit


foreach var of varlist settlement pos_rec winpos_asked win_minley duration {
preserve
reg  `var'  $input_varlist $sd_input_varlist $bvc _Iid_1-_Iid_`=${lista1}-1' _Iid_`=${lista1}+1'-_Iid_138, r
	local df = e(df_r)
	

matrix results = J(138, 4, .) // empty matrix for results
//  4 cols are: (1) office, (2) beta, (3) std error, (4) pvalue
forval row = 1/138 {
	matrix results[`row',1] = `row'
	*Omited office
	if `row'!=$lista1 { 
	// Beta 
	matrix results[`row',2] = _b[_Iid_`row']
	// Standard error
	matrix results[`row',3] = _se[_Iid_`row']
	// P-value
	matrix results[`row',4] = 2*ttail(`df', abs(_b[_Iid_`row']/_se[_Iid_`row']))
		}
	}
	
	matrix colnames results = "k" "beta" "se" "p"
	matlist results
	
clear
	svmat results, names(col) 
	// Confidence intervals (95%)
	local alpha = .05 // for 95% confidence intervals
	gen rcap_lo = beta - invttail(`df',`=`alpha'/2')*se
	gen rcap_hi = beta + invttail(`df',`=`alpha'/2')*se

	replace beta=0 if missing(beta)
	gsort -beta 
	gen orden=_n

foreach vr of varlist beta-orden {
	rename `vr' `vr'_`var'	
	}

save "$directorio\_aux\rank_`var'.dta", replace
restore
}

preserve
use "$directorio\_aux\rank_settlement.dta", clear
foreach var in  pos_rec winpos_asked win_minley duration {
 merge 1:1 k using "$directorio\_aux\rank_`var'.dta", nogen
 }
 
 
 
   

factor beta*, pcf		

predict f1

gsort -f1

gen orden_f1=_n

graph matrix orden*, scheme(s2mono) graphregion(color(white))
graph export "$directorio\Figuras\betas_factor.pdf", replace 

 *****************
 
gsort -f1 -orden_pos_rec
rename k id
save "$directorio\_aux\rank.dta", replace
restore

merge m:1 id using  "$directorio\_aux\rank.dta", nogen

reg pos_rec  $input_varlist $sd_input_varlist $bvc _Iid_1-_Iid_`=${lista1}-1' _Iid_`=${lista1}+1'-_Iid_138, r	
predict pr

*Select suits
		*Good					*Bad						*Dummy
keep if inrange(orden_f1,1,5) | inrange(orden_f1,134,138) | inlist(orden_f1,60,70)
keep if !missing(pr)
gsort -f1 -pr

bysort id: gen suit_num=_n
drop if suit_num>10

keep office_emp_law id junta exp anio orden_f1 
sort junta exp anio
duplicates drop junta exp anio, force
save "$directorio\_aux\assignment_2.dta", replace
