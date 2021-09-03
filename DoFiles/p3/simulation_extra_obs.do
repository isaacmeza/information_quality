args tr num_run num_max_obs

use "$directorio\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$directorio\DB\survey_data_2m.dta", keep(1 3) keepusing(id_actor conflicto_arreglado entablo_demanda)

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


forvalues j=1/2 {
				*Simulation for the differential effect
			reg vardep`j' i.main_treatment if date>=date("12/09/2017", "DMY"), r cluster(date)
			local cons_`j'=_b[_cons]
			local beta2_`j'=_b[2.main_treatment]
			local beta3_`j'=_b[3.main_treatment]
			local secons_`j'=_se[_cons]/1.05
			local se2_`j'=_se[2.main_treatment]/1.05
			local se3_`j'=_se[3.main_treatment]/1.05
			}
			

keep vardep1 vardep2 telefono_cel nq_dw main_treat
matrix results = J(`=(`num_max_obs'-98)/2', 10, 0)

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

			replace main_treatment=1 if runiform()<=0.5 & missing(main_treatment)
			replace main_treatment=`tr' if missing(main_treatment)



			*Generate variables on the individual level
			replace telefono_cel=(runiform()<=`cel') if missing(telefono_cel)
					
					
			replace nq_dw=1 if inrange(runiform(), 0, `wage_1')
			replace nq_dw=2 if inrange(runiform(), `wage_1', `wage_1'+`wage_2')
			replace nq_dw=3 if inrange(runiform(), `wage_1'+`wage_2', 1)

			forvalues j=1/2 {
				replace vardep`j'=(runiform()<=rnormal(`cons_`j'',`secons_`j'')) if missing(vardep`j') & _n>`obs' ///
					& main_treatment==1
				replace vardep`j'=(runiform()<=rnormal(`cons_`j''+`beta2_`j'',`se2_`j'')) if missing(vardep`j') & _n>`obs' ///
					& main_treatment==2
				replace vardep`j'=(runiform()<=rnormal(`cons_`j''+`beta3_`j'',`se3_`j'')) if missing(vardep`j') & _n>`obs' ///
					& main_treatment==3		
				}

	

			*BOUNDS/ATE	
			cap drop tratamiento
			gen tratamiento=.
			replace tratamiento=1 if main_treatment==`tr'
			replace tratamiento=0 if main_treatment==1
			
			forvalues i=1/2 {
			
					*ATE
				reg vardep`i' tratamiento, robust	
				local df = e(df_r)
				matrix results[`v',5*`i'-4] = _b[tratamiento]+ results[`v',5*`i'-4]
				matrix results[`v',5*`i'-3] = _b[tratamiento] - invttail(`df',0.05)*_se[tratamiento]+results[`v',5*`i'-3]
				matrix results[`v',5*`i'-2] = _b[tratamiento] + invttail(`df',0.05)*_se[tratamiento]+results[`v',5*`i'-2]
	
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
				matrix results[`v',5*`i'-1] =  lb[1,1]+results[`v',5*`i'-1]
				matrix results[`v',5*`i'] =  lb[1,2]+results[`v',5*`i']
				}
			discard							
			restore
			}
		}
	}

matrix results = results / `num_run'
	
clear
matrix colnames results = "beta_vd1" "lo_vd1" "hi_vd1" "lower_vd1" "upper_vd1" ///
			"beta_vd2" "lo_vd2" "hi_vd2"  "lower_vd2" "upper_vd2"
svmat results, names(col) 

gen extra_obs=_n*2


twoway 	(rarea lo_vd1 hi_vd1 extra_obs, color(gs13))  || ///
		(line beta_vd1 extra_obs, lwidth(thick) lpattern(dot) lcolor(black)) || ///
		(line lower_vd1 extra_obs, lpattern(solid)) || (line upper_vd1 extra_obs, lpattern(solid))  ///
		, name(conflicto, replace) scheme(s2mono) ///
title("Solved conflict") xtitle("Extra observations") ytitle("Effect") legend(off) graphregion(color(white))


twoway 	(rarea lo_vd2 hi_vd2 extra_obs, color(gs13))  || ///
		(line beta_vd2 extra_obs, lwidth(thick) lpattern(dot) lcolor(black)) || ///
		(line lower_vd2 extra_obs, lpattern(solid)) || (line upper_vd2 extra_obs, lpattern(solid))  ///
		, name(sue, replace) scheme(s2mono) ///
title("Sue") xtitle("Extra observations") ytitle("Effect") legend(off) graphregion(color(white))


graph combine conflicto sue, cols(2) scheme(s2mono) graphregion(color(white))
graph export "$directorio/Figuras/sim_extra_obs_`tr'.pdf", replace	

	
