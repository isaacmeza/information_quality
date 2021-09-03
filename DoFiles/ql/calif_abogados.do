*Judges Opinion
insheet using "$directorio\Raw\Captura Express Completo.csv", clear
keep junta exp AÃ‘O totaldictaminador
destring totaldictaminador, replace force
rename AÃ‘O anio
tempfile temp_dictamen
save `temp_dictamen'

*
import delimited "$directorio\Raw\base_abogados2.csv", varnames(1) clear 


*Cleaning
foreach var of varlist * {
	replace `var' = subinstr(`var', `"""', "",.)
	}

	*Cleaning of time
gen fecha_fin = date(substr(fin,1,11),"YMD")
format fecha_fin %td

	*Duration of evaluation
gen start = substr(inicio,1,11)+" " + substr(inicio,13,8)	
gen start_time=clock(start, "YMDhms")
gen end = substr(fin,1,11)+" " + substr(fin,13,8)	
gen end_time=clock(end, "YMDhms")
format start_time end_time %tc
gen duration_eval = minutes(end_time-start_time)

	*Scores & Prediction
foreach var of varlist preg1calif preg2calif preg3calif preg4calif preg5calif califglobal ///
				predicciona prediccionb prediccionc predicciond prediccione prediccionmonto1 prediccionmonto2 {
	destring `var', replace force
	}
	
encode prediccionseleccion1, gen(prediccion_seleccion1)
encode prediccionseleccion2, gen(prediccion_seleccion2)
drop prediccionseleccion*	

foreach var of varlist predicciona prediccionb prediccionc predicciond prediccione {
	replace  `var'=0 if missing(`var')
	}
	
rename numexpediente nombre_archivo_abogado
*rename Ã¯nombre nombre
replace nombre_archivo_abogado = subinstr(nombre_archivo_abogado, " ", "",.)
replace nombre_archivo_abogado = "6_" + ///
	substr(nombre_archivo_abogado,3,length(nombre_archivo_abogado)) ///
		if strpos(nombre_archivo_abogado,"0_")!=0 & ///
		strpos(nombre,"Sergio Cuadra Flores")!=0
replace nombre_archivo_abogado = "8_" + ///
	substr(nombre_archivo_abogado,3,length(nombre_archivo_abogado)) ///
		if strpos(nombre_archivo_abogado,"0_")!=0 & ///
		strpos(nombre,"Miguel Angel")!=0		
		

merge 1:1 nombre_archivo_abogado using "$directorio\Raw\relacion_base_calidad.dta", keep(3) nogen
rename expediente exp
rename ao anio

merge m:1 junta exp anio using "$directorio\DB\lawyer_dataset_predicc.dta", keep(3) nogen
merge m:m junta exp anio using `temp_dictamen', keep(1 3) nogen
duplicates drop nombre_archivo_abogado, force

*Generation of variables of interest
do "$directorio\DoFiles\gen_measures.do"

********************************************************************************

*Histogram of scores
foreach var of varlist preg1calif preg2calif preg3calif preg4calif preg5calif califglobal {
	hist `var', discrete percent scheme(s2mono) graphregion(color(white)) ///
		xtitle("Score") ytitle("Percent")
		graph export "$directorio\Figuras\\`var'.pdf", replace
	}
	
*Comparison of scores across lawyers - reg
tab abogado, gen(abogado_d)
eststo clear
eststo: reg califglobal abogado_d*, nocons r
**********
esttab using "$directorio/Tables/reg_results/califglobal_law.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) r2 ///
	replace 

	
*Panel set 
egen expediente=group(nombre_archivo_original)
xtset  abogado expediente

			
	
*Group according to levenshtein distance
foreach var of varlist *justificacion {
	*Remove blank spaces
	gen `var'_=stritrim(trim(itrim(upper(`var'))))

	*Basic name cleaning 
	replace `var'_ = subinstr(`var'_, ".", "", .)
	replace `var'_ = subinstr(`var'_, " & ", " ", .)
	replace `var'_ = subinstr(`var'_, "&", "", .)
	replace `var'_ = subinstr(`var'_, ",", "", .)
	replace `var'_ = subinstr(`var'_, "ÃƒÂ±", "N", .)
	replace `var'_ = subinstr(`var'_, "Ãƒâ€˜", "N", .)
	replace `var'_ = subinstr(`var'_, "-", " ", .)
	replace `var'_ = subinstr(`var'_, "ÃƒÂ¡", "A", .)
	replace `var'_ = subinstr(`var'_, "ÃƒÂ©", "E", .)
	replace `var'_ = subinstr(`var'_, "ÃƒÂ­", "I", .)
	replace `var'_ = subinstr(`var'_, "ÃƒÂ³", "O", .)
	replace `var'_ = subinstr(`var'_, "ÃƒÂº", "U", .)
	replace `var'_ = subinstr(`var'_, "Ãƒâ€°", "A", .)
	replace `var'_ = subinstr(`var'_, "É", "E", .)
	replace `var'_ = subinstr(`var'_, "Ãƒ\u008d", "I", .)
	replace `var'_ = subinstr(`var'_, "Ãƒâ€œ", "O", .)
	replace `var'_ = subinstr(`var'_, "Ú", "U", .)
	replace `var'_ = subinstr(`var'_, "â", "A", .)
	replace `var'_ = subinstr(`var'_, "ê", "E", .)
	replace `var'_ = subinstr(`var'_, "î", "I", .)
	replace `var'_ = subinstr(`var'_, "ô", "O", .)
	replace `var'_ = subinstr(`var'_, "ù", "U", .)
	replace `var'_ = subinstr(`var'_, "Â", "A", .)
	replace `var'_ = subinstr(`var'_, "Ê", "E", .)
	replace `var'_ = subinstr(`var'_, "Î", "I", .)
	replace `var'_ = subinstr(`var'_, "Ô", "O", .)
	replace `var'_ = subinstr(`var'_, "Û", "U", .)
	replace `var'_ = subinstr(`var'_, "-", " ", .)

	*Remove special characters
	gen newname = "" 
	gen length_`var' = length(`var'_) 
	su length_`var', meanonly 

	forval i = 1/`r(max)' { 
		 local char substr(`var'_, `i', 1) 
		 local OK inrange(`char', "a", "z") | inrange(`char', "A", "Z")  | `char'==" "
		 replace newname = newname + `char' if `OK' 
	}
	replace `var'_=newname
	drop newname 

	replace `var'_=stritrim(trim(itrim(upper(`var'_))))

	*Group according to Levenshtein distance
	strgroup `var'_ , gen(`var'_gp) threshold(.45) normalize(longer)
	}


*Variance 
xtsum preg1calif preg2calif preg3calif preg4calif preg5calif califglobal ///
				predicciona prediccionb prediccionc predicciond prediccione prediccionmonto1 prediccionmonto2 ///
				preg1justificacion_gp ///
				preg2justificacion_gp ///
				preg3justificacion_gp ///
				preg4justificacion_gp ///
				preg5justificacion_gp  length*
		

*Correlation between different scores of same lawsuit
corr *calif califglobal
putexcel J4=matrix(r(C)) using "$directorio/Tables/cor_scores.xlsx", ///
			sheet("cor_scores") modify
		

****************************************
	
*Correlation between scores and outcomes
eststo clear
foreach var of varlist perc_pos_rec perc_pos_rec_cr perc_settlement perc_cr ///
	ratio_win_asked ratio_winpos_asked ratio_win_minley ratio_win_minley_cr ///
	duration {
	eststo: areg `var' califglobal *calif , r absorb(abogado)
	}
**********
esttab using "$directorio/Tables/reg_results/outcomes_scores.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) r2 ///
	replace 
 
foreach varscore of varlist *calif califglobal {
	eststo clear
	foreach var of varlist perc_pos_rec  perc_settlement perc_cr ///
		ratio_win_asked ratio_winpos_asked ratio_win_minley  ///
		duration {
		eststo: areg `var' `varscore' , r absorb(abogado)
		}
	**********
	esttab using "$directorio/Tables/reg_results/outcomes_score_`varscore'.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) r2 ///
		replace  
	}	
	 

****************************************

preserve
egen id=group(junta exp anio)
foreach var of varlist califglobal preg1calif preg2calif preg3calif preg4calif preg5calif {
	bysort id : gen dif_`var' = abs(`var'[2]-`var'[1])
	}
*Keep casefiles that differ at most 2 in scores	
*keep if dif<=2	

*Keep casefiles that are above median in duration of evaluation
qui su duration_eval, d
keep if duration_eval>=`r(p50)'

*Correlation between scores and outcomes (collapsed)
collapse perc_pos_rec perc_pos_rec_cr perc_settlement perc_cr ///
	ratio_win_asked ratio_winpos_asked ratio_win_minley ratio_win_minley_cr ///
	duration ///
	(mean) avg_califglobal = califglobal (sd) sd_califglobal = califglobal ///
	(mean) avg_preg1calif = preg1calif (sd) sd_preg1calif = preg1calif ///
	(mean) avg_preg2calif = preg2calif (sd) sd_preg2calif = preg2calif ///
	(mean) avg_preg3calif = preg3calif (sd) sd_preg3calif = preg3calif ///
	(mean) avg_preg4calif = preg4calif (sd) sd_preg4calif = preg4calif ///
	(mean) avg_preg5calif = preg5calif (sd) sd_preg5calif = preg5calif ///
	, by(id)
	
foreach varscore in califglobal preg1calif preg2calif preg3calif preg4calif preg5calif {
	eststo clear
	foreach var of varlist perc_pos_rec  perc_settlement perc_cr ///
		ratio_win_asked ratio_winpos_asked ratio_win_minley  ///
		duration {
		eststo: reg `var' avg_`varscore' , r 
		eststo: reg `var' avg_`varscore' sd_`varscore' , r 
		}
	**********
	esttab using "$directorio/Tables/reg_results/outcomes_score_coll_`varscore'.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) r2 ///
		replace  
	}		 
restore
	
**************************************** 
 
*Correlation of scores
preserve
egen id=group(junta exp anio)
keep califglobal *calif prediccion* id abogado
reshape wide califglobal preg* prediccion* , i(id) j(abogado)			

*Shared casefile
forvalues i=1/8 {
	forvalues j=`=`i'+1'/8 {
		egen nm_`i'_`j'=rownonmiss(califglobal`i' califglobal`j')
		replace nm_`i'_`j'=(nm_`i'_`j'==2)
		}
	}
	
br id califglobal* nm*
su nm*


forvalues i=1/8 {
	forvalues j=`=`i'+1'/8 {
		local COL = substr(c(ALPHA),2*(10+`i')-1,1)
		local row=`j'+3
		local cell = "`COL'" + "`row'"
		qui corr califglobal`i' califglobal`j'
		mat c=r(C)
		local rho=round(c[1,2],0.01)
		qui putexcel `cell'=("`rho'") using "$directorio/Tables/cor_scores.xlsx", ///
			sheet("cor_global") modify
		}
	}	

foreach var in preg1calif preg2calif preg3calif preg4calif preg5calif {	
	forvalues i=1/8 {
		forvalues j=`=`i'+1'/8 {
			local COL = substr(c(ALPHA),2*(10+`i')-1,1)
			local row=`j'+3
			local cell = "`COL'" + "`row'"
			qui corr `var'`i' `var'`j'
			mat c=r(C)
			local rho=round(c[1,2],0.01)
			qui putexcel `cell'=("`rho'") using "$directorio/Tables/cor_scores.xlsx", ///
				sheet("cor_`var'") modify
			}
		}	
	}
	
	
restore
	
**************************************
*De-mean each lawyers grade, Then get a single correlation of the de-meaned score 1 vs score 2 	
**************************************		

preserve
egen id=group(junta exp anio)
keep califglobal *calif prediccion* id abogado
foreach var of varlist califglobal preg* {
	bysort abogado: egen avg_`var'=mean(`var')
	replace `var'=`var'-avg_`var'
	drop avg_`var'
	}
	
	
*Correlation of scores
reshape wide califglobal preg* prediccion* , i(id) j(abogado)			


forvalues i=1/8 {
	forvalues j=`=`i'+1'/8 {
		local COL = substr(c(ALPHA),2*(10+`i')-1,1)
		local row=`j'+3
		local cell = "`COL'" + "`row'"
		qui corr califglobal`i' califglobal`j'
		mat c=r(C)
		local rho=round(c[1,2],0.01)
		qui putexcel `cell'=("`rho'") using "$directorio/Tables/cor_scores.xlsx", ///
			sheet("cor_global_demean") modify
		}
	}	
			
foreach var in preg1calif preg2calif preg3calif preg4calif preg5calif {	
	forvalues i=1/8 {
		forvalues j=`=`i'+1'/8 {
			local COL = substr(c(ALPHA),2*(10+`i')-1,1)
			local row=`j'+3
			local cell = "`COL'" + "`row'"
			qui corr `var'`i' `var'`j'
			mat c=r(C)
			local rho=round(c[1,2],0.01)
			qui putexcel `cell'=("`rho'") using "$directorio/Tables/cor_scores.xlsx", ///
				sheet("cor_`var'_demean") modify
			}
		}	
	}			
restore			
