*PLOT OF BOUNDS

*-------------------------------------------------------------------------------
args vardep t0 t1 survey condvar condcond method dummy 


*Load boosted reg program
program drop _all
do "$directorio\DoFiles\boost_reg.do"
* a plugin has to be explicitly loaded (unlike an ado file)
* "capture" means that if it's loaded already this line won't give an error

*Directory for .\boost64.dll 
cd $directorio

capture program drop boost_plugin
program boost_plugin, plugin using(".\boost64.dll")
	

*IMPUTATION OF CONDITIONING VARIABLE
if "`condvar'"=="no_condition" {
	cap drop no_condition
	gen no_condition=1
	}
else {
	if "`condcond'"=="" {
		*Method of imputation
		if `method'==1 {
			*Random imputation
			replace `condvar'=(runiform()<=0.5) if missing(`condvar')
			local nota "Imputation on conditioning variable: Random"
			}
		else {
			*PLM imputation
			reg `condvar'  telefono* email  mujer na_prob na_cant *_coarse salario_diario antiguedad m_cp ///
					if tratamiento==1, r cluster(fecha_alta)
			cap drop predicted
			predict predicted 
			replace `condvar'=(predicted>=0.6) if missing(`condvar') ///
						& tratamiento==1 
						
			reg `condvar'  telefono* email  mujer na_prob na_cant *_coarse salario_diario antiguedad m_cp ///
					if tratamiento==0, r cluster(fecha_alta)
			cap drop predicted
			predict predicted 		
			replace `condvar'=(predicted>=0.4) if missing(`condvar') ///
						& tratamiento==0 	
			local nota "Imputation on conditioning variable: PLM"
			}
		}
	else {
		*Method of imputation
		if `method'==1 {
			*Random imputation
			replace `condcond'=(runiform()<=0.5) if missing(`condcond')
			replace `condvar'=(runiform()<=0.5) if missing(`condvar') & `condcond'==1
			local nota "Imputation on conditioning variable: Random"
			}
		else {
			*PLM imputation
			reg `condcond'  telefono* email  mujer na_prob na_cant *_coarse salario_diario antiguedad m_cp ///
					if tratamiento==1, r cluster(fecha_alta)
			cap drop predicted
			predict predicted 
			replace `condcond'=(predicted>=0.6) if missing(`condcond') ///
						& tratamiento==1 
						
			reg `condcond'  telefono* email  mujer na_prob na_cant *_coarse salario_diario antiguedad m_cp ///
					if tratamiento==0, r cluster(fecha_alta)
			cap drop predicted
			predict predicted 		
			replace `condcond'=(predicted>=0.4) if missing(`condcond') ///
						& tratamiento==0 	
						
						
			reg `condvar'  telefono* email  mujer na_prob na_cant *_coarse salario_diario antiguedad m_cp ///
					if tratamiento==1, r cluster(fecha_alta)
			cap drop predicted
			predict predicted 
			replace `condvar'=(predicted>=0.6) if missing(`condvar') ///
						& tratamiento==1 & `condcond'==1
						
			reg `condvar'  telefono* email  mujer na_prob na_cant *_coarse salario_diario antiguedad m_cp ///
					if tratamiento==0, r cluster(fecha_alta)
			cap drop predicted
			predict predicted 		
			replace `condvar'=(predicted>=0.4) if missing(`condvar') ///
						& tratamiento==0 & `condcond'==1	
			local nota "Imputation on conditioning variable: PLM"
			}
		}	
	}
	


*Generation of variables
cap drop `vardep'_1
gen `vardep'_1=`vardep' 
forvalues i=2/5 {
	cap drop `vardep'_`i'ub
	gen `vardep'_`i'ub=`vardep'
	cap drop `vardep'_`i'lb
	gen `vardep'_`i'lb=`vardep'
	}

	
*IMPUTATION	
	
*Random imputation
replace `vardep'_1=(runiform()<=0.5) if missing(`vardep'_1) & `condvar'==1
	

*Uniformly impute 0/1
replace `vardep'_2ub=1 if missing(`vardep'_2ub) & `condvar'==1
replace `vardep'_2lb=0 if missing(`vardep'_2lb) & `condvar'==1


*Best/Worst case imputation (This results in the largest bounds)
replace `vardep'_3ub=1 if missing(`vardep'_3ub) ///
			& tratamiento==1 & `condvar'==1
replace `vardep'_3ub=0 if missing(`vardep'_3ub) ///
			& tratamiento==0 & `condvar'==1
			
replace `vardep'_3lb=0 if missing(`vardep'_3lb) ///
			& tratamiento==1 & `condvar'==1
replace `vardep'_3lb=1 if missing(`vardep'_3lb) ///
			& tratamiento==0 & `condvar'==1

			

*PLM imputation
reg `vardep'  telefono* email  mujer na_prob na_cant *_coarse salario_diario antiguedad m_cp ///
		if tratamiento==1, r cluster(fecha_alta)
cap drop predicted
predict predicted 
replace `vardep'_4ub=(predicted>=0.4) if missing(`vardep'_4ub) ///
			& tratamiento==1 & `condvar'==1
replace `vardep'_4lb=(predicted>=0.6) if missing(`vardep'_4lb) ///
			& tratamiento==1 & `condvar'==1
			
reg `vardep'  telefono* email  mujer na_prob na_cant *_coarse salario_diario antiguedad m_cp ///
		if tratamiento==0, r cluster(fecha_alta)
cap drop predicted
predict predicted 		
replace `vardep'_4ub=(predicted>=0.6) if missing(`vardep'_4ub) ///
			& tratamiento==0 & `condvar'==1
replace `vardep'_4lb=(predicted>=0.4) if missing(`vardep'_4lb) ///
			& tratamiento==0 & `condvar'==1			
			
			
			
			
*Boosted imputation
boost_reg `vardep'  "telefono* email  mujer na_prob na_cant *_coarse salario_diario antiguedad m_cp" "predicted" "normal" 1
replace `vardep'_5ub=(predicted>=0.4) if missing(`vardep'_5ub) ///
			& tratamiento==1 & `condvar'==1
replace `vardep'_5lb=(predicted>=0.6) if missing(`vardep'_5lb) ///
			& tratamiento==1 & `condvar'==1

boost_reg `vardep'  "telefono* email  mujer na_prob na_cant *_coarse salario_diario antiguedad m_cp" "predicted" "normal" 0
replace `vardep'_5ub=(predicted>=0.6) if missing(`vardep'_5ub) ///
			& tratamiento==0 & `condvar'==1
replace `vardep'_5lb=(predicted>=0.4) if missing(`vardep'_5lb) ///
			& tratamiento==0 & `condvar'==1


****

*BOUNDS		
		
local controls mujer antiguedad salario_diario

matrix results = J(7, 9, .)
// Confidence intervals (90%)
local alpha = .1 // for 90% confidence intervals


*Point estimate
reg `vardep' tratamiento `controls', robust cluster(fecha_alta)
local df = e(df_r)
forvalues i=1/7 {
	matrix results[`i',1] = _b[tratamiento]
	matrix results[`i',2] = _b[tratamiento] - invttail(`df',`=`alpha'/2')*_se[tratamiento]
	matrix results[`i',3] = _b[tratamiento] + invttail(`df',`=`alpha'/2')*_se[tratamiento]
	}
	
		
*Random imputation
reg `vardep'_1 tratamiento `controls', robust cluster(fecha_alta)
local df = e(df_r)
matrix results[1,4] = _b[tratamiento] - invttail(`df',`=`alpha'/4')*_se[tratamiento]
matrix results[1,7] = _b[tratamiento] + invttail(`df',`=`alpha'/4')*_se[tratamiento]



forvalues i=2/5 {
	*Imputation Bounds
	reg `vardep'_`i'lb tratamiento `controls', robust cluster(fecha_alta)
	local df = e(df_r)
	matrix results[`i',4] = _b[tratamiento]
	matrix results[`i',5] = _b[tratamiento] - invttail(`df',`=`alpha'/2')*_se[tratamiento]
	matrix results[`i',6] = _b[tratamiento] + invttail(`df',`=`alpha'/2')*_se[tratamiento]
	
	reg `vardep'_`i'ub tratamiento `controls', robust cluster(fecha_alta)
	local df = e(df_r)
	matrix results[`i',7] = _b[tratamiento]
	matrix results[`i',8] = _b[tratamiento] - invttail(`df',`=`alpha'/2')*_se[tratamiento]
	matrix results[`i',9] = _b[tratamiento] + invttail(`df',`=`alpha'/2')*_se[tratamiento]
	}


cap drop nq_dw
xtile nq_dw=salario_diario, nq(3)
*Lee Bounds
cap leebounds `vardep' tratamiento if `condvar'==1, cieffect tight(telefono_cel nq_dw)

if _rc!=0 {
	cap leebounds `vardep' tratamiento if `condvar'==1, cieffect tight(telefono_cel)
	if _rc!=0 {
		leebounds `vardep' tratamiento if `condvar'==1, cieffect vce(bootstrap)
		}
	else {	
		mat varlb=e(V)
		if varlb[1,1]==0 {
			leebounds `vardep' tratamiento if `condvar'==1, cieffect tight(telefono_cel) vce(bootstrap)
			}
		}	
	}	
else {	
	mat varlb=e(V)
	if varlb[1,1]==0 {
		leebounds `vardep' tratamiento if `condvar'==1, cieffect tight(telefono_cel nq_dw) vce(bootstrap)
		}		
	}
	
	
mat lb=e(b)
mat varlb=e(V)
matrix results[6,4] = lb[1,1]
matrix results[6,5] = lb[1,1] - invttail(e(Nsel)-1,`=`alpha'/2')*sqrt(varlb[1,1])
matrix results[6,6] = lb[1,1] + invttail(e(Nsel)-1,`=`alpha'/2')*sqrt(varlb[1,1])

matrix results[6,7] = lb[1,2]
matrix results[6,8] = lb[1,2] - invttail(e(Nsel)-1,`=`alpha'/2')*sqrt(varlb[2,2])
matrix results[6,9] = lb[1,2] + invttail(e(Nsel)-1,`=`alpha'/2')*sqrt(varlb[2,2])


*Manski-Imbens Bounds
matrix results[7,4] =  e(cilower)
matrix results[7,7] =  e(ciupper)

***
cap drop t t_lo t_hi lb lb_lo lb_hi ub ub_lo ub_hi k
matrix colnames results = "t" "t_lo" "t_hi" ///
						"lb" "lb_lo" "lb_hi"  ///
						"ub" "ub_lo" "ub_hi"  
						
svmat results, names(col) 
gen k=_n if _n<=7


*Plot results
twoway (line t k , lwidth(medium) color(black) lpattern(solid)) ///
		(line t_lo k, color(gs10) fintensity(inten50) lpattern(dot) ) ///
		(line t_hi k, color(gs10) fintensity(inten50) lpattern(dot)) ///
		(rcap ub lb k, xtitle("Method") ytitle("ATE") ///
				msize(huge) lwidth(thick) color(black) ///
				xlabel(1(1)7))  ///
		(scatter ub k, msize(medlarge) color(black) msymbol(circle)) ///	
		(scatter lb k, msize(medlarge) color(black) msymbol(circle)) ///	
		(rcap ub_hi ub_lo k, msize(small) color(gs9)) ///
		(rcap lb_hi lb_lo k, msize(small) color(gs9)) ///
		, legend(order(1 "Point estimate" 2 "Classic CI"  4 "Bounds" ///
			7 "Bounds CI")) scheme(s2mono) graphregion(color(white)) ///	
		 title("T`t0'-T`t1'") ///
		subtitle("(`survey')")	note(`nota', size(small))
if "`dummy'"=="" {
	graph export "$directorio/Figuras/t`t0't`t1'_`vardep'_`survey'.pdf", replace 
	 }
else {
	graph export "$directorio/Figuras/t`t0't`t1'_`vardep'_`survey'_`dummy'.pdf", replace 
	}


