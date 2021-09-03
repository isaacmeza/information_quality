*Lee bounds of expectations by type of lawyer

********************************************************************************
*									2M								  		   *
********************************************************************************
use "$directorio\DB\survey_data_2m.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)


local controls mujer antiguedad salario_diario
local more_controls `controls' reclutamiento dummy_confianza horas_sem dummy_desc_sem dummy_prima_dom dummy_desc_ob dummy_sarimssinfo carta_renuncia dummy_reinst c_min_indem c_min_prima_antig c_min_ag c_min_total 
matrix results = J(8, 6, .)


replace cantidad_ganar_survey=cantidad_ganar_survey/1000
replace cantidad_ganar=cantidad_ganar/1000

foreach var of varlist cant_mayor_survey cantidad_coarse prob_ganar_survey ///
		prob_ganar  prob_mayor_survey  prob_coarse {
	replace `var'=`var'*100
	}

	*2M EXPECTATIONS
reg cantidad_ganar_survey   cantidad_ganar ///
		`controls', robust cluster(fecha_alta)
predict amt_1, residuals		
reg cantidad_ganar_survey   cantidad_ganar ///
		`more_controls', robust cluster(fecha_alta)		
predict amt_2, residuals	

reg cant_mayor_survey   cantidad_coarse ///
		`controls', robust cluster(fecha_alta)
predict amtc_1, residuals		
reg cant_mayor_survey   cantidad_coarse ///
		`more_controls', robust cluster(fecha_alta)		
predict amtc_2, residuals	

reg prob_ganar_survey   prob_ganar ///
		`controls', robust cluster(fecha_alta)
predict prob_1, residuals		
reg prob_ganar_survey   prob_ganar ///
		`more_controls', robust cluster(fecha_alta)		
predict prob_2, residuals		


reg prob_mayor_survey   prob_coarse ///
		`controls', robust cluster(fecha_alta)
predict probc_1, residuals				
reg prob_mayor_survey   prob_coarse ///
		`more_controls', robust cluster(fecha_alta)		
predict probc_2, residuals				

		
*COMPUTATION OF BOUNDS
local v=0
foreach var of varlist amt_1 amt_2 amtc_1 amtc_2 prob_1 prob_2 probc_1 probc_2 {
	local ++v
	leebounds `var' demando_con_abogado_publico, cieffect
	mat lb=e(b)
	mat varlb=e(V)
	local alpha=0.1
	matrix results[`v',1] = lb[1,1]
	matrix results[`v',2] = lb[1,1] - invttail(e(Nsel)-1,`=`alpha'/2')*sqrt(varlb[1,1])
	matrix results[`v',3] = lb[1,1] + invttail(e(Nsel)-1,`=`alpha'/2')*sqrt(varlb[1,1])

	matrix results[`v',4] = lb[1,2]
	matrix results[`v',5] = lb[1,2] - invttail(e(Nsel)-1,`=`alpha'/2')*sqrt(varlb[2,2])
	matrix results[`v',6] = lb[1,2] + invttail(e(Nsel)-1,`=`alpha'/2')*sqrt(varlb[2,2])
	}
	
clear
matrix colnames results = "lb" "lb_lo" "lb_hi"  ///
						"ub" "ub_lo" "ub_hi" 
						
svmat results, names(col) 

cap drop k
gen k=_n
forvalues i=3(2)8 {
	replace k=k+4 if _n>=`i'
	}	
		


twoway  (rcap ub lb k if inlist(k ,1,2), yaxis(1)  ///
				msize(huge) lwidth(thick) color(black) lpattern(solid)) ///	
		(rcap ub lb k if inlist(k ,1,2)!=1, yaxis(2)  ///
				msize(huge) lwidth(thick) color(black) lpattern(solid)) ///			
		(scatter ub k if inlist(k ,1,2), yaxis(1) msize(medlarge) color(black) mfcolor(white) msymbol(circle)) ///	
		(scatter lb k if inlist(k ,1,2), yaxis(1) msize(medlarge) color(black) mfcolor(white) msymbol(circle)) ///	
		(rcap ub_hi ub_lo k if inlist(k ,1,2), yaxis(1) msize(small) color(gs9)) ///
		(rcap lb_hi lb_lo k if inlist(k ,1,2), yaxis(1) msize(small) color(gs9)) ///
		(scatter ub k if inlist(k ,1,2)!=1, yaxis(2) msize(medlarge) color(black) mfcolor(white) msymbol(circle)) ///	
		(scatter lb k if inlist(k ,1,2)!=1, yaxis(2) msize(medlarge) color(black) mfcolor(white) msymbol(circle)) ///	
		(rcap ub_hi ub_lo k if inlist(k ,1,2)!=1, yaxis(2) msize(small) color(gs9)) ///
		(rcap lb_hi lb_lo k if inlist(k ,1,2)!=1, yaxis(2) msize(small) color(gs9)) ///
		, scheme(s2mono) graphregion(color(white)) ///	
		legend(off) ///
		 title("Lee Bounds") subtitle("2M") ytitle("ATE", axis(1)) ytitle("ATE", axis(2)) xtitle("") ///
		 xlabel(1.5 "Amt exp" 7.5 "Amt coarse" 13.5 "Prob exp" 19.5 "Prob coarse")
graph export "$directorio/Figuras/lb_exp_law_2m.pdf", replace 		 
		 
	
	
********************************************************************************
*									2W								  		   *
********************************************************************************
use "$directorio\DB\survey_data_2w.dta", clear
merge 1:1 id_actor using "$directorio\DB\treatment_data.dta", keep(3)


local controls mujer antiguedad salario_diario
local more_controls `controls' reclutamiento dummy_confianza horas_sem dummy_desc_sem dummy_prima_dom dummy_desc_ob dummy_sarimssinfo carta_renuncia dummy_reinst c_min_indem c_min_prima_antig c_min_ag c_min_total 
matrix results = J(8, 6, .)

replace cantidad_ganar_survey=cantidad_ganar_survey/1000
replace cantidad_ganar=cantidad_ganar/1000

foreach var of varlist cant_mayor_survey cantidad_coarse prob_ganar_survey ///
		prob_ganar  prob_mayor_survey  prob_coarse {
	replace `var'=`var'*100
	}
	
	*2W EXPECTATIONS
reg cantidad_ganar_survey   cantidad_ganar ///
		`controls', robust cluster(fecha_alta)
predict amt_1, residuals		
reg cantidad_ganar_survey   cantidad_ganar ///
		`more_controls', robust cluster(fecha_alta)		
predict amt_2, residuals	

reg cant_mayor_survey   cantidad_coarse ///
		`controls', robust cluster(fecha_alta)
predict amtc_1, residuals		
reg cant_mayor_survey   cantidad_coarse ///
		`more_controls', robust cluster(fecha_alta)		
predict amtc_2, residuals	

reg prob_ganar_survey   prob_ganar ///
		`controls', robust cluster(fecha_alta)
predict prob_1, residuals		
reg prob_ganar_survey   prob_ganar ///
		`more_controls', robust cluster(fecha_alta)		
predict prob_2, residuals		


reg prob_mayor_survey   prob_coarse ///
		`controls', robust cluster(fecha_alta)
predict probc_1, residuals				
reg prob_mayor_survey   prob_coarse ///
		`more_controls', robust cluster(fecha_alta)		
predict probc_2, residuals				

		
*COMPUTATION OF BOUNDS
local v=0
foreach var of varlist amt_1 amt_2 amtc_1 amtc_2 prob_1 prob_2 probc_1 probc_2 {
	local ++v
	leebounds `var' cond_hablo_con_publico, cieffect
	mat lb=e(b)
	mat varlb=e(V)
	local alpha=0.1
	matrix results[`v',1] = lb[1,1]
	matrix results[`v',2] = lb[1,1] - invttail(e(Nsel)-1,`=`alpha'/2')*sqrt(varlb[1,1])
	matrix results[`v',3] = lb[1,1] + invttail(e(Nsel)-1,`=`alpha'/2')*sqrt(varlb[1,1])

	matrix results[`v',4] = lb[1,2]
	matrix results[`v',5] = lb[1,2] - invttail(e(Nsel)-1,`=`alpha'/2')*sqrt(varlb[2,2])
	matrix results[`v',6] = lb[1,2] + invttail(e(Nsel)-1,`=`alpha'/2')*sqrt(varlb[2,2])
	}
	
clear
matrix colnames results = "lb" "lb_lo" "lb_hi"  ///
						"ub" "ub_lo" "ub_hi" 
						
svmat results, names(col) 

cap drop k
gen k=_n
forvalues i=3(2)8 {
	replace k=k+4 if _n>=`i'
	}	
		


twoway  (rcap ub lb k if inlist(k ,1,2), yaxis(1)  ///
				msize(huge) lwidth(thick) color(black) lpattern(solid)) ///	
		(rcap ub lb k if inlist(k ,1,2)!=1, yaxis(2)  ///
				msize(huge) lwidth(thick) color(black) lpattern(solid)) ///			
		(scatter ub k if inlist(k ,1,2), yaxis(1) msize(medlarge) color(black) mfcolor(white) msymbol(circle)) ///	
		(scatter lb k if inlist(k ,1,2), yaxis(1) msize(medlarge) color(black) mfcolor(white) msymbol(circle)) ///	
		(rcap ub_hi ub_lo k if inlist(k ,1,2), yaxis(1) msize(small) color(gs9)) ///
		(rcap lb_hi lb_lo k if inlist(k ,1,2), yaxis(1) msize(small) color(gs9)) ///
		(scatter ub k if inlist(k ,1,2)!=1, yaxis(2) msize(medlarge) color(black) mfcolor(white) msymbol(circle)) ///	
		(scatter lb k if inlist(k ,1,2)!=1, yaxis(2) msize(medlarge) color(black) mfcolor(white) msymbol(circle)) ///	
		(rcap ub_hi ub_lo k if inlist(k ,1,2)!=1, yaxis(2) msize(small) color(gs9)) ///
		(rcap lb_hi lb_lo k if inlist(k ,1,2)!=1, yaxis(2) msize(small) color(gs9)) ///
		, scheme(s2mono) graphregion(color(white)) ///	
		legend(off) ///
		 title("Lee Bounds") subtitle("2W") ytitle("ATE", axis(1)) ytitle("ATE", axis(2)) xtitle("") ///
		 xlabel(1.5 "Amt exp" 7.5 "Amt coarse" 13.5 "Prob exp" 19.5 "Prob coarse")
graph export "$directorio/Figuras/lb_exp_law_2w.pdf", replace 		 
		 
		 		
	
