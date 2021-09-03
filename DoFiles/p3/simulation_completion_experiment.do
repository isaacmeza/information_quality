*Simulate treatment effects at the end of experiment (20/12/2018) with different attrition rates
*at the date current date 
*First run: 18/08/2018

global num_run=10

use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(1 3) keepusing(id_actor conflicto_arreglado entablo_demanda)
*Attrition 
qui su date 
gen attrition_2m=(_merge==1) if inrange(date,`r(min)',date(c(current_date) ,"DMY")-70)


*Covariates for tightening
xtile nq_dw=salario_diario, nq(3)
gen nq_dw1=(nq_dw==1) if !missing(nq_dw)
gen nq_dw2=(nq_dw==2) if !missing(nq_dw)

rename conflicto_arreglado vardep1 
rename entablo_demanda vardep2

*Original dataset
tempfile temp
preserve
keep date vardep1 vardep2 main_treatment telefono_cel nq_dw
tempfile temp_original
save `temp_original'
restore

*Collapse
collapse (count) num=mon_tues (mean) attrition=attrition_2m ///
	(mean) telefono_cel (mean) nq_dw1 (mean) nq_dw2 ///
	(mean) vardep1 ///
	(mean) vardep2 ///
	, by(date main_treatment) 


*Experiment up to end date
qui count
local obs=`r(N)'
qui su date
set obs `=`obs'+date("20/12/2018","DMY")-`r(max)''
replace date=date[_n-1]+1 if missing(date)

*Monday-Friday
gen dow = dow(date)
keep if inlist(dow,1,2,3,4,5)


matrix results = J(29, 4, 0)
local v=1
forvalues attrition_rate=.30(-.01)0.01 {
	qui {
	forvalues run=1/$num_run {
	
		preserve 
		
		*Randomization of treatment assignment by day
		count if !missing(main_treatment)
		local tot=`r(N)'
		forvalues t=1/3 {
			count if main_treatment==`t'
			local tr`t'=`r(N)'/`tot'
			}
		
		cap drop aleatorizacion
		gen aleatorizacion=runiform()
		replace main_treatment=1 if missing(main_treatment) & inrange(aleatorizacion,0,2/3-`tr1')
		replace main_treatment=2 if missing(main_treatment) & inrange(aleatorizacion,2/3-`tr1',4/3-`tr1'-`tr2')
		replace main_treatment=3 if missing(main_treatment) & inrange(aleatorizacion,4/3-`tr1'-`tr2',1)


		*Simulation of treated subjects according to a beta-binomial estimated in MATLAB
		cap drop beta_bin
		gen beta_bin=rbinomial(40, rbeta(3.8291  , 12.8263))
		reg num i.main_treatment, r
		replace num=beta_bin if missing(num) & main_treatment==1
		replace num=beta_bin-round(rnormal(_b[2.main_treatment],_se[2.main_treatment]/1.5)) if missing(num) & main_treatment==2
		replace num=beta_bin-round(rnormal(_b[3.main_treatment],_se[3.main_treatment]/1.5)) if missing(num) & main_treatment==3

		*Proportion of individuals with cellphone
		su telefono
		replace telefono_cel=rnormal(`r(mean)'-.05, `r(sd)') if missing(telefono_cel)
		replace telefono_cel=1 if telefono_cel>1
		replace telefono_cel=0 if telefono_cel<0


		*Proportion of individuals in 1st and 2nd tercile of wage
		forvalues i=1/2 {
			su nq_dw`i'
			local mu`i'=`r(mean)'
			local sd`i'=`r(sd)'
			}
			
			matrix m = (`mu1' , `mu2')
			matrix sd = (`sd1', `sd2')
			corr nq_dw1 nq_dw2
			matrix c = (1, `r(rho)' \ `r(rho)',1)
			
			cap drop wage1 wage2
			drawnorm wage1 wage2 ,  means(m) sds(sd) corr(c)

		forvalues i=1/2 {	
			replace nq_dw`i'=wage`i' if missing(nq_dw`i')
			replace nq_dw`i'=1 if nq_dw`i'>1
			replace nq_dw`i'=0 if nq_dw`i'<0
			}
		cap drop sum_nq_dw 	
		egen sum_nq_dw=rowtotal(nq_dw*)

		forvalues i=1/2 {
			replace nq_dw`i'=nq_dw`i'-(sum_nq_dw-1)/2 if sum_nq_dw>1
			} 



		*Depvar generation

		forvalues j=1/2 {
				*Simulation for the differential effect
			reg vardep`j' i.main_treatment if !missing(attrition), r cluster(date)
			matrix m = (_b[2.main_treatment], _b[3.main_treatment])
			matrix sd = (_se[2.main_treatment]/1.05, _se[3.main_treatment]/1.05)
			cap drop beta2 beta3
			drawnorm beta2 beta3 ,  means(m) sds(sd) 

				*Simulation for rate of vardep per day
			forvalues t=1/3 {	
				su vardep`j' if main_treatment==`t' & !missing(attrition)
				local vardep`j'_sd_`t'=`r(sd)'
				}	

			replace vardep`j'=rnormal(_b[_cons],`vardep`j'_sd_1') if main_treatment==1
			replace vardep`j'=rnormal(_b[_cons]+beta2,`vardep`j'_sd_2') if main_treatment==2
			replace vardep`j'=rnormal(_b[_cons]+beta3,`vardep`j'_sd_3') if main_treatment==3
			replace vardep`j'=0 if vardep`j'<0
			replace vardep`j'=1 if vardep`j'>1

			}

		*Attrition generation

			*Simulation for the differential attrition
		reg attrition i.main_treatment, r cluster(date)
		matrix m = (_b[2.main_treatment], _b[3.main_treatment])
		matrix sd = (_se[2.main_treatment]/1.1, _se[3.main_treatment]/1.1)
		cap drop beta2 beta3
		drawnorm beta2 beta3 ,  means(m) sds(sd) 
		local tasa=`attrition_rate'-(_b[2.main_treatment]+_b[3.main_treatment])/3

			*Simulation for attrition per day
		forvalues t=1/3 {	
			su attrition if main_treatment==`t'
			local attrition_sd_`t'=`r(sd)'
			}

		keep if missing(attrition)

		replace attrition=rnormal(`tasa',`attrition_sd_1') if main_treatment==1 
		replace attrition=rnormal(`tasa'+beta2,`attrition_sd_2') if main_treatment==2 
		replace attrition=rnormal(`tasa'+beta3,`attrition_sd_3') if main_treatment==3
		replace attrition=0 if attrition<0


		*Expand dataset
		expand num

		*Generate variables on the individual level
		replace telefono_cel=(runiform()<=telefono_cel)
		
		cap drop nq_dw
		gen nq_dw=.
		replace nq_dw=1 if inrange(runiform(), 0, nq_dw1)
		replace nq_dw=2 if inrange(runiform(), nq_dw1, nq_dw1+nq_dw2)
		replace nq_dw=1 if inrange(runiform(), nq_dw1+nq_dw2, 1)

		replace vardep1=(runiform()<=vardep1)
		replace vardep2=(runiform()<=vardep2)

		*Attrited individuals
		cap drop uniform
		gen uniform=runiform()
		replace vardep1=. if uniform<=attrition
		replace vardep2=. if uniform<=attrition


		*Append original set
		append using `temp_original'


		*BOUNDS	
		cap drop tratamiento
		gen tratamiento=.
		replace tratamiento=1 if main_treatment==3
		replace tratamiento=0 if main_treatment==1
		
		forvalues i=1/2 {
			*Lee Bounds
			cap leebounds vardep`i' tratamiento , cieffect tight(telefono_cel nq_dw)

			if _rc!=0 {
				cap leebounds vardep`i' tratamiento , cieffect tight(telefono_cel)
				if _rc!=0 {
					leebounds vardep`i' tratamiento , cieffect vce(bootstrap)
					}
				else {	
					mat varlb=e(V)
					if varlb[1,1]==0 {
						leebounds vardep`i' tratamiento , cieffect tight(telefono_cel) vce(bootstrap)
						}
					}	
				}	
			else {	
				mat varlb=e(V)
				if varlb[1,1]==0 {
					leebounds vardep`i' tratamiento , cieffect tight(telefono_cel nq_dw) vce(bootstrap)
					}		
				}

			*Lee Bounds
			mat lb=e(b)
			matrix results[`v',2*`i'-1] =  lb[1,1]+results[`v',2*`i'-1]
			matrix results[`v',2*`i'] =  lb[1,2]+results[`v',2*`i']
			}
		
		restore
	
		}
		}
	local ++v
	di `attrition_rate'
	}

matrix results = results / $num_run
	
clear
matrix colnames results = "lower_vd1" "upper_vd1" "lower_vd2" "upper_vd2"
svmat results, names(col) 

gen rate=69+_n


twoway line lower_vd1 rate || line upper_vd1 rate, name(conflicto, replace) scheme(s2mono) ///
title("Solved conflict") xtitle("Response rate") ytitle("Effect") legend(off) graphregion(color(white))


twoway line lower_vd2 rate || line upper_vd2 rate, name(sue, replace) scheme(s2mono) ///
title("Sue") xtitle("Response rate") ytitle("Effect") legend(off) graphregion(color(white))
graph combine conflicto sue, cols(2) scheme(s2mono) graphregion(color(white))
graph export "$directorio/Figuras/sim_1_3.pdf", replace	

	
