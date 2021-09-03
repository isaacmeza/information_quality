local num_run=90
local num_max_obs=700
set matsize 1000

use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(1 3) keepusing(id_actor conflicto_arreglado entablo_demanda demando_con_abogado_publico)
 
qui su date 
keep if inrange(date,`r(min)',date(c(current_date) ,"DMY")-70)


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

			
rename conflicto_arreglado vardep1 
rename entablo_demanda vardep2
rename demando_con_abogado_publico vardep3

forvalues j=1/3 {
				*Simulation for the differential effect
			reg vardep`j' i.group , r cluster(date)
			local cons_`j'=_b[_cons]
			local beta2_`j'=_b[2.group]
			local secons_`j'=_se[_cons]/1.05
			local se2_`j'=_se[2.group]/1.05
			}
			

keep vardep1 vardep2 vardep3 telefono_cel nq_dw group
matrix results = J(`=(`num_max_obs'-98)/2', 21, 0)

local v=0
forvalues n=100(2)`num_max_obs' {
	local ++v
	di `v'
	forvalues run=1/`num_run' {
		*qui {
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

			forvalues j=1/2 {
				replace vardep`j'=(runiform()<=rnormal(`cons_`j'',`secons_`j'')) if missing(vardep`j') & _n>`obs' ///
					& group==1
				replace vardep`j'=(runiform()<=rnormal(`cons_`j''+`beta2_`j'',`se2_`j'')) if missing(vardep`j') & _n>`obs' ///
					& group==2	
				}

			replace vardep3=(runiform()<=rnormal(`cons_3',`secons_3')) if missing(vardep3) & _n>`obs' ///
				& group==1 & vardep2==1
			replace vardep3=(runiform()<=rnormal(`cons_3'+`beta2_3',`se2_3')) if missing(vardep3) & _n>`obs' ///
				& group==2 & vardep2==1

			*BOUNDS/ATE	
			cap drop tratamiento
			gen tratamiento=.
			replace tratamiento=1 if group==2
			replace tratamiento=0 if group==1
			
			forvalues i=1/2 {
			
					*ATE
				reg vardep`i' tratamiento, robust	
				local df = e(df_r)
				matrix results[`v',7*`i'-6] = _b[tratamiento]+ results[`v',7*`i'-6]
				matrix results[`v',7*`i'-5] = _b[tratamiento] - invttail(`df',0.05)*_se[tratamiento]+results[`v',7*`i'-5]
				matrix results[`v',7*`i'-4] = _b[tratamiento] + invttail(`df',0.05)*_se[tratamiento]+results[`v',7*`i'-4]
				test _b[tratamiento]=0
				matrix results[`v',7*`i'-3] = (`r(p)'<=0.05) + results[`v',7*`i'-3]
				
					*Lee Bounds
				cap leebounds vardep`i' tratamiento , cieffect tight(telefono_cel nq_dw)

				if _rc!=0 {
					cap leebounds vardep`i' tratamiento , cieffect tight(telefono_cel)
					if _rc!=0 {
						leebounds vardep`i' tratamiento , cieffect 
						}	
					}	
							
					*Lee Bounds
				mat lb=e(b)
				matrix results[`v',7*`i'-2] =  lb[1,1]+results[`v',7*`i'-2]
				matrix results[`v',7*`i'-1] =  lb[1,2]+results[`v',7*`i'-1]
				matrix results[`v',7*`i'] =  (lb[1,1]>0 | lb[1,2]<0 )+results[`v',7*`i']
				

				}
				
				
				*ATE
				reg vardep3 tratamiento, robust	
				local df = e(df_r)
				matrix results[`v',15] = _b[tratamiento]+ results[`v',15]
				matrix results[`v',16] = _b[tratamiento] - invttail(`df',0.05)*_se[tratamiento]+results[`v',16]
				matrix results[`v',17] = _b[tratamiento] + invttail(`df',0.05)*_se[tratamiento]+results[`v',17]
				test _b[tratamiento]=0
				matrix results[`v',18] = (`r(p)'<=0.05) + results[`v',18]
				
					*Lee Bounds
				cap leebounds vardep3 tratamiento if vardep2==. | vardep2==1  , cieffect tight(telefono_cel nq_dw)

				if _rc!=0 {
					cap leebounds vardep3 tratamiento if vardep2==. | vardep2==1  , cieffect tight(telefono_cel)
					if _rc!=0 {
						leebounds vardep3 tratamiento if vardep2==. | vardep2==1  , cieffect 
						}	
					}	
							
					*Lee Bounds
				mat lb=e(b)
				matrix results[`v',19] =  lb[1,1]+results[`v',19]
				matrix results[`v',20] =  lb[1,2]+results[`v',20]
				matrix results[`v',21] =  (lb[1,1]>0 | lb[1,2]<0 )+results[`v',21]
				
				
			discard							
			restore
			}
		*}
	}

matrix results = results / `num_run'
	
clear
matrix colnames results = "beta_vd1" "lo_vd1" "hi_vd1" "pwr_vd1" "lower_vd1" "upper_vd1" "pwr_lee_vd1" ///
			"beta_vd2" "lo_vd2" "hi_vd2"  "pwr_vd2" "lower_vd2" "upper_vd2" "pwr_lee_vd2"  ///
			"beta_vd3" "lo_vd3" "hi_vd3"  "pwr_vd3" "lower_vd3" "upper_vd3" "pwr_lee_vd3" 
svmat results, names(col) 

gen extra_obs=_n*2+100


*Bounds plot
twoway 	(rarea lo_vd1 hi_vd1 extra_obs, color(gs13))  || ///
		(line beta_vd1 extra_obs, lwidth(thick) lpattern(dot) lcolor(black)) || ///
		(line lower_vd1 extra_obs, lpattern(solid)) || (line upper_vd1 extra_obs, lpattern(solid))  ///
		, name(conflicto, replace) scheme(s2mono) ///
title("Solved conflict") xtitle("Extra observations") ytitle("Effect") legend(off) graphregion(color(white))
graph export "$directorio/Figuras/sim_extra_obs__solved_conflict_2mB.png", replace	


twoway 	(rarea lo_vd2 hi_vd2 extra_obs, color(gs13))  || ///
		(line beta_vd2 extra_obs, lwidth(thick) lpattern(dot) lcolor(black)) || ///
		(line lower_vd2 extra_obs, lpattern(solid)) || (line upper_vd2 extra_obs, lpattern(solid))  ///
		, name(sue, replace) scheme(s2mono) ///
title("Sue") xtitle("Extra observations") ytitle("Effect") legend(off) graphregion(color(white))
graph export "$directorio/Figuras/sim_extra_obs__sue_2mB.png", replace	


twoway 	(rarea lo_vd3 hi_vd3 extra_obs, color(gs13))  || ///
		(line beta_vd3 extra_obs, lwidth(thick) lpattern(dot) lcolor(black)) || ///
		(line lower_vd3 extra_obs, lpattern(solid)) || (line upper_vd3 extra_obs, lpattern(solid))  ///
		, name(public, replace) scheme(s2mono) ///
title("Sue w/public") xtitle("Extra observations") ytitle("Effect") legend(off) graphregion(color(white))
graph export "$directorio/Figuras/sim_extra_obs__suepublic_2mB.png", replace	


graph combine conflicto sue public, cols(1) scheme(s2mono) graphregion(color(white))
graph export "$directorio/Figuras/sim_extra_obs_2mB.pdf", replace	


*Power plot
twoway (line pwr_vd1 extra_obs, lwidth(thick) lpattern(dot)) || ///
		(line pwr_vd2 extra_obs, lwidth(thick) lpattern(dash)) ||  ///
		(line pwr_vd3 extra_obs, lwidth(thick) lpattern(solid)) ///
		, scheme(s2mono) title("Power simulation") ///
		xtitle("Extra observations") ytitle("Power") ///
		legend(order(1 "Solved" 2 "Sue" 3 "Sue w/public")) graphregion(color(white))
graph export "$directorio/Figuras/pwr_2mB.pdf", replace	



*Lee power plot
twoway (line pwr_lee_vd1 extra_obs, lwidth(thick) lpattern(dot)) || ///
		(line pwr_lee_vd2 extra_obs, lwidth(thick) lpattern(dash))   ||  ///
		(line pwr_lee_vd3 extra_obs, lwidth(thick) lpattern(solid)) ///
		, scheme(s2mono) title("Lee bounds power simulation") ///
		xtitle("Extra observations") ytitle("Power") ///
		legend(order(1 "Solved" 2 "Sue" 3 "Sue w/public")) graphregion(color(white))
graph export "$directorio/Figuras/pwr_lee_2mB.pdf", replace	



