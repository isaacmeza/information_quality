local num_run=200
local num_max_obs=700
set matsize 1000

use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2w.dta", keep(1 3) keepusing(id_actor hablo_con_abogado cond_hablo_con_publico)

*Covariates for tightening
xtile nq_dw=salario_diario, nq(3)
tab nq_dw, gen(nq_dw)
forvalues j=1/3 {
su nq_dw`j'
local wage_`j'=`r(mean)'
}


*Proportion of individuals with cellphone
su telefono_cel
local cel=`r(mean)'

			
rename hablo_con_abogado vardep1
rename cond_hablo_con_publico vardep2

forvalues j=1/2 {
				*Simulation for the differential effect
			reg vardep`j' i.group , r cluster(date)
			local cons_`j'=_b[_cons]
			local beta2_`j'=_b[2.group]
			local secons_`j'=_se[_cons]/1.05
			local se2_`j'=_se[2.group]/1.05
			}
			

keep vardep1 vardep2  telefono_cel nq_dw group
matrix results = J(`=(`num_max_obs'-98)/2', 14, 0)

local v=0
forvalues n=100(2)`num_max_obs' {
	local ++v
	di `v'
	forvalues run=1/`num_run' {
		qui {
			preserve
			*Experiment up to end date
			qui count
			local obs=`r(N)'
			set obs `=`obs'+ `n''

			replace group=1 if runiform()<=0.5 & missing(group)
			replace group=2 if missing(group)



			*Generate variables on the individual level
			replace telefono_cel=(runiform()<=`cel') if missing(telefono_cel)
					
					
			replace nq_dw=1 if inrange(runiform(), 0, `wage_1')
			replace nq_dw=2 if inrange(runiform(), `wage_1', `wage_1'+`wage_2')
			replace nq_dw=3 if inrange(runiform(), `wage_1'+`wage_2', 1)

			replace vardep1=(runiform()<=rnormal(`cons_1',`secons_1')) if missing(vardep1) & _n>`obs' ///
				& group==1 
			replace vardep1=(runiform()<=rnormal(`cons_1'+`beta2_1',`se2_1')) if missing(vardep1) & _n>`obs' ///
				& group==2 
				
			replace vardep2=(runiform()<=rnormal(`cons_2',`secons_2')) if missing(vardep2) & _n>`obs' ///
				& group==1 & vardep1==1
			replace vardep2=(runiform()<=rnormal(`cons_2'+`beta2_2',`se2_2')) if missing(vardep2) & _n>`obs' ///
				& group==2 & vardep1==1

				
			*BOUNDS/ATE	
			cap drop tratamiento
			gen tratamiento=.
			replace tratamiento=1 if group==2
			replace tratamiento=0 if group==1
			
			
					*ATE
				reg vardep1 tratamiento, robust	
				local df = e(df_r)
				matrix results[`v',1] = _b[tratamiento]+ results[`v',1]
				matrix results[`v',2] = _b[tratamiento] - invttail(`df',0.05)*_se[tratamiento]+results[`v',2]
				matrix results[`v',3] = _b[tratamiento] + invttail(`df',0.05)*_se[tratamiento]+results[`v',3]
				test _b[tratamiento]=0
				matrix results[`v',4] = (`r(p)'<=0.05) + results[`v',4]
				
					*Lee Bounds
				cap leebounds vardep1 tratamiento , cieffect tight(telefono_cel nq_dw)

				if _rc!=0 {
					cap leebounds vardep1 tratamiento , cieffect tight(telefono_cel)
					if _rc!=0 {
						leebounds vardep1 tratamiento , cieffect 
						}	
					}	
							
					*Lee Bounds
				mat lb=e(b)
				matrix results[`v',5] =  lb[1,1]+results[`v',5]
				matrix results[`v',6] =  lb[1,2]+results[`v',6]
				matrix results[`v',7] =  (lb[1,1]>0 | lb[1,2]<0 )+results[`v',7]
		
		
		
					*ATE
				reg vardep2 tratamiento, robust	
				local df = e(df_r)
				matrix results[`v',8] = _b[tratamiento]+ results[`v',8]
				matrix results[`v',9] = _b[tratamiento] - invttail(`df',0.05)*_se[tratamiento]+results[`v',9]
				matrix results[`v',10] = _b[tratamiento] + invttail(`df',0.05)*_se[tratamiento]+results[`v',10]
				test _b[tratamiento]=0
				matrix results[`v',11] = (`r(p)'<=0.05) + results[`v',11]
				
					*Lee Bounds
				cap leebounds vardep2 tratamiento if vardep1==. | vardep1==1 , cieffect tight(telefono_cel nq_dw)

				if _rc!=0 {
					cap leebounds vardep2 tratamiento  if vardep1==. | vardep1==1  , cieffect tight(telefono_cel)
					if _rc!=0 {
						leebounds vardep2 tratamiento  if vardep1==. | vardep1==1  , cieffect 
						}	
					}	
							
					*Lee Bounds
				mat lb=e(b)
				matrix results[`v',12] =  lb[1,1]+results[`v',12]
				matrix results[`v',13] =  lb[1,2]+results[`v',13]
				matrix results[`v',14] =  (lb[1,1]>0 | lb[1,2]<0 )+results[`v',14]		
		
			discard							
			restore
			}
		}
	}

matrix results = results / `num_run'
	
clear
matrix colnames results = "beta_vd1" "lo_vd1" "hi_vd1" "pwr_vd1" "lower_vd1" "upper_vd1" "pwr_lee_vd1"  ///
			"beta_vd2" "lo_vd2" "hi_vd2"  "pwr_vd2" "lower_vd2" "upper_vd2" "pwr_lee_vd2"  
svmat results, names(col) 

gen extra_obs=_n*2+100


*Bounds plot
twoway 	(rarea lo_vd1 hi_vd1 extra_obs, color(gs13))  || ///
		(line beta_vd1 extra_obs, lwidth(thick) lpattern(dot) lcolor(black)) || ///
		(line lower_vd1 extra_obs, lpattern(solid)) || (line upper_vd1 extra_obs, lpattern(solid))  ///
		, name(talked, replace) scheme(s2mono) ///
title("Talked to lawyer") xtitle("Extra observations") ytitle("Effect") legend(off) graphregion(color(white))


twoway 	(rarea lo_vd2 hi_vd2 extra_obs, color(gs13))  || ///
		(line beta_vd2 extra_obs, lwidth(thick) lpattern(dot) lcolor(black)) || ///
		(line lower_vd2 extra_obs, lpattern(solid)) || (line upper_vd2 extra_obs, lpattern(solid))  ///
		, name(public, replace) scheme(s2mono) ///
title("Talked to pub lawyer") xtitle("Extra observations") ytitle("Effect") legend(off) graphregion(color(white))



graph combine talked public, cols(1) scheme(s2mono) graphregion(color(white))
graph export "$directorio/Figuras/sim_extra_obs_2wB.pdf", replace	


*Power plot
twoway (line pwr_vd1 extra_obs, lwidth(thick) lpattern(dot)) || ///
		(line pwr_vd2 extra_obs, lwidth(thick) lpattern(dash))  ///
		, scheme(s2mono) title("Power simulation") ///
		xtitle("Extra observations") ytitle("Power") ///
		legend(order(1 "Talked to lawyer" 2 "Talked to public" )) graphregion(color(white))
graph export "$directorio/Figuras/pwr_2wB.pdf", replace	



*Lee power plot
twoway (line pwr_lee_vd1 extra_obs, lwidth(thick) lpattern(dot)) || ///
		(line pwr_lee_vd2 extra_obs, lwidth(thick) lpattern(dash)) ///
		, scheme(s2mono) title("Lee bounds power simulation") ///
		xtitle("Extra observations") ytitle("Power") ///
		legend(order(1 "Talked to lawyer" 2 "Talked to public" )) graphregion(color(white))
graph export "$directorio/Figuras/pwr_lee_2wB.pdf", replace	



	
