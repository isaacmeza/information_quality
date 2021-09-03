use "$directorio\DB\treatment_data.dta", clear

********************************************************************************
*Cumulative p-value distribution over time
	

*Varlist 
local balance_all_vlist mujer prob_ganar na_prob prob_mayor na_prob_mayor ///
	cantidad_ganar na_cant cant_mayor na_cant_mayor sueldo  salario_diario ///
	antiguedad mon_tue 
	
local balance_23_vlist	horas_sem dias_sal_dev ///
	high_school angry diurno top_sue big_size ///
	reclutamiento dummy_confianza dummy_desc_sem ///
	dummy_prima_dom dummy_desc_ob dummy_sarimssinfo  carta_renuncia dummy_reinst 


*Variable creation
mata
date=.
pval_23_mean=.
pval_23_hi=.
pval_23_low=.
pval_23_p25=.
pval_23_p50=.
pval_mv_mean=.
pval_mv_hi=.
pval_mv_low=.
pval_mv_p25=.
pval_mv_p50=.
pval_ab_mean=.
pval_ab_hi=.
pval_ab_low=.
pval_ab_p25=.
pval_ab_p50=.
end

qui su date

local start=`r(min)' + 7
di `start'
local end=`r(max)' 

local j=1
*Iterate through each day	
forvalues t=`start'(7)`end' {
    di `j'
	preserve

	gen pval_23_=.
	gen pval_mv_=.
	gen pval_ab_=.
	gen date_=`t'+7

	*Data until date `t'
	keep if inrange(date,`start',`t'+7) 
	set obs 4000
	
	*SS of the p-values
	local i=1	
	foreach var of varlist  `balance_all_vlist' {
		di "`var'"
		*MV test
		capture mvtest means `var' , by(main_treatment) 
		capture replace pval_mv=`r(p_F)' in `i'
		
		*2-3 ttest
		capture mvtest means `var' if inlist(main_treatment, 2,3), by(main_treatment)
		capture replace pval_23=`r(p_F)' in `i'
		
		*A-B ttest
		capture mvtest means `var' , by(group) 
		capture replace pval_ab=`r(p_F)' in `i'
		local i=`i'+1
		}
		
	foreach var of varlist  `balance_23_vlist' {
		di "`var'"
		*2-3 ttest
		capture mvtest means `var' if inlist(main_treatment, 2,3), by(main_treatment)
		capture replace pval_23=`r(p_F)' in `i'
		
		*A-B ttest
		capture mvtest means `var' , by(group) 
		capture replace pval_ab=`r(p_F)' in `i'
		local i=`i'+1
		}

	qui su pval_23, d
	gen pval_23_mean_=`r(mean)'
	gen pval_23_hi_=max(min (`r(mean)' + invttail(`r(N)'-1,0.05)*(`r(sd)' / sqrt(`r(N)')),1),0) if `r(N)'!=0
	gen pval_23_low_=max(min (`r(mean)' - invttail(`r(N)'-1,0.05)*(`r(sd)' / sqrt(`r(N)')),1),0) if `r(N)'!=0
	gen pval_23_p25_=`r(p25)'
	gen pval_23_p50_=`r(p50)'
		
	qui su pval_mv, d
	gen pval_mv_mean_=`r(mean)'
	gen pval_mv_hi_=max(min (`r(mean)' + invttail(`r(N)'-1,0.05)*(`r(sd)' / sqrt(`r(N)')),1),0) if `r(N)'!=0
	gen pval_mv_low_=max(min (`r(mean)' - invttail(`r(N)'-1,0.05)*(`r(sd)' / sqrt(`r(N)')),1),0) if `r(N)'!=0
	gen pval_mv_p25_=`r(p25)'
	gen pval_mv_p50_=`r(p50)'
	
	qui su pval_ab, d
	if `r(N)'!=0 {
		gen pval_ab_mean_=`r(mean)'
		gen pval_ab_hi_=max(min (`r(mean)' + invttail(`r(N)'-1,0.05)*(`r(sd)' / sqrt(`r(N)')),1),0) if `r(N)'!=0
		gen pval_ab_low_=max(min (`r(mean)' - invttail(`r(N)'-1,0.05)*(`r(sd)' / sqrt(`r(N)')),1),0) if `r(N)'!=0
		gen pval_ab_p25_=`r(p25)'
		gen pval_ab_p50_=`r(p50)'
		}
	else {
		gen pval_ab_mean_=.
		gen pval_ab_hi_=.
		gen pval_ab_low_=.
		gen pval_ab_p25_=.
		gen pval_ab_p50_=.
		}
	
	sort date_
	keep if _n==1 

	putmata date_ pval_23* pval_mv* pval_ab*, replace
	
	mata: date=(date,date_)
	mata: pval_23_mean=(pval_23_mean,pval_23_mean_)
	mata: pval_23_hi=(pval_23_hi,pval_23_hi_)
	mata: pval_23_low=(pval_23_low,pval_23_low_)
	mata: pval_23_p25=(pval_23_p25, pval_23_p25_)
	mata: pval_23_p50=(pval_23_p50, pval_23_p50_)
	mata: pval_mv_mean=(pval_mv_mean,pval_mv_mean_)
	mata: pval_mv_hi=(pval_mv_hi,pval_mv_hi_)
	mata: pval_mv_low=(pval_mv_low,pval_mv_low_)
	mata: pval_mv_p25=(pval_mv_p25, pval_mv_p25_)
	mata: pval_mv_p50=(pval_mv_p50, pval_mv_p50_)
	mata: pval_ab_mean=(pval_ab_mean,pval_ab_mean_)
	mata: pval_ab_hi=(pval_ab_hi,pval_ab_hi_)
	mata: pval_ab_low=(pval_ab_low,pval_ab_low_)
	mata: pval_ab_p25=(pval_ab_p25, pval_ab_p25_)
	mata: pval_ab_p50=(pval_ab_p50, pval_ab_p50_)
	
	restore
	local ++j
	}

mata
date=date'
pval_23_mean=pval_23_mean'
pval_23_hi=pval_23_hi'
pval_23_low=pval_23_low'
pval_23_p25=pval_23_p25'
pval_23_p50=pval_23_p50'
pval_mv_mean=pval_mv_mean'
pval_mv_hi=pval_mv_hi'
pval_mv_low=pval_mv_low'
pval_mv_p25=pval_mv_p25'
pval_mv_p50=pval_mv_p50'
pval_ab_mean=pval_ab_mean'
pval_ab_hi=pval_ab_hi'
pval_ab_low=pval_ab_low'
pval_ab_p25=pval_ab_p25'
pval_ab_p50=pval_ab_p50'
end

clear 

getmata date pval_23_mean pval_23_hi pval_23_low pval_23_p25 pval_23_p50 ///
	pval_mv_mean pval_mv_hi pval_mv_low pval_mv_p25 pval_mv_p50 ///
	pval_ab_mean pval_ab_hi pval_ab_low pval_ab_p25 pval_ab_p50, force
keep date pval_*

format date %td
tsset date

twoway (tsline pval_23_mean, lwidth(thick) lcolor(black)) ///
	(tsline pval_23_low, lpattern(dash) lcolor(gs3)) ///
	(tsline pval_23_hi, lpattern(dash) lcolor(gs3)) ///
	(tsline pval_23_p25, lcolor(blue) lpattern(solid) ) ///
	(lfit pval_23_mean date, lcolor(navy) lpattern(dot)) , legend(off) ///
		 tlabel(, format(%dm-CY)) ytitle("Mean") xtitle("Date")  ///
		subtitle("2-3 t-test") scheme(s2mono) graphregion(color(white)) name(p_23, replace)
		
twoway (tsline pval_mv_mean, lwidth(thick) lcolor(black)) ///
	(tsline pval_mv_low, lpattern(dash) lcolor(gs3)) ///
	(tsline pval_mv_hi, lpattern(dash) lcolor(gs3)) ///
	(tsline pval_mv_p25, lcolor(blue) lpattern(solid) ) ///
	(lfit pval_mv_mean date, lcolor(navy) lpattern(dot)) , legend(off) ///
		 tlabel(, format(%dm-CY)) ytitle("Mean") xtitle("Date")  ///
		subtitle("MV-test") scheme(s2mono) graphregion(color(white)) name(p_mv, replace)

twoway (tsline pval_ab_mean, lwidth(thick) lcolor(black)) ///
	(tsline pval_ab_low, lpattern(dash) lcolor(gs3)) ///
	(tsline pval_ab_hi, lpattern(dash) lcolor(gs3)) ///
	(tsline pval_ab_p25, lcolor(blue) lpattern(solid) ) ///
	(lfit pval_ab_mean date, lcolor(navy) lpattern(dot)) , legend(off) ///
		 tlabel(, format(%dm-CY)) ytitle("Mean") xtitle("Date")  ///
		subtitle("AB t-test") scheme(s2mono) graphregion(color(white)) name(p_ab, replace) 
				
graph combine p_23 p_mv p_ab, xcommon cols(1) scheme(s2mono) graphregion(color(none)) ///
	title("Cumulative p-value distribution over time") 
graph export "$directorio/Figuras/pvalue_time_reg.pdf", replace 
	

