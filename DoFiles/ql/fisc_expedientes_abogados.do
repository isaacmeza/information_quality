*Select casefiles to check according to dissimilarity in scores and similiaity in 
*justification
import delimited "$directorio\Raw\base_abogados.csv", varnames(1) clear 


*Cleaning
foreach var of varlist * {
	replace `var' = subinstr(`var', `"""', "",.)
	}

	*Cleaning of time
gen fecha_fin = date(substr(fin,1,11),"YMD")
format fecha_fin %td


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
		
duplicates drop nombre_archivo_abogado, force


********************************************************************************

	
	
*Group according to levenshtein distance
foreach var of varlist *justificacion {
	*Remove blank spaces
	gen `var'_=stritrim(trim(itrim(upper(`var'))))

	*Basic name cleaning 
	replace `var'_ = subinstr(`var'_, ".", "", .)
	replace `var'_ = subinstr(`var'_, " & ", " ", .)
	replace `var'_ = subinstr(`var'_, "&", "", .)
	replace `var'_ = subinstr(`var'_, ",", "", .)
	replace `var'_ = subinstr(`var'_, "Ñ", "N", .)
	replace `var'_ = subinstr(`var'_, "-", " ", .)
	replace `var'_ = subinstr(`var'_, "á", "A", .)
	replace `var'_ = subinstr(`var'_, "é", "E", .)
	replace `var'_ = subinstr(`var'_, "í", "I", .)
	replace `var'_ = subinstr(`var'_, "ó", "O", .)
	replace `var'_ = subinstr(`var'_, "ú", "U", .)
	replace `var'_ = subinstr(`var'_, "Á", "A", .)
	replace `var'_ = subinstr(`var'_, "É", "E", .)
	replace `var'_ = subinstr(`var'_, "Í", "I", .)
	replace `var'_ = subinstr(`var'_, "Ó", "O", .)
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

*id	
egen id=group(junta exp anio)	
	
*Average answer length
egen avg_length=rowmean(length_*)	
*Variance in answer by lawyer
bysort abogado: egen sd_ans1=sd(preg1justificacion_gp)
bysort abogado: egen sd_ans2=sd(preg2justificacion_gp)
bysort abogado: egen sd_ans3=sd(preg3justificacion_gp)
bysort abogado: egen sd_ans4=sd(preg4justificacion_gp)
bysort abogado: egen sd_ans5=sd(preg5justificacion_gp)

egen mean_sd_ans_law=rowmean(sd_ans*)

preserve	
*Disimilarity/Similarity in scores
keep califglobal *calif  *justificacion_gp  id abogado
reshape wide califglobal preg* , i(id) j(abogado)

*Dissimilarity/Similarity
foreach var in preg1calif preg2calif preg3calif preg4calif preg5calif califglobal ///
		preg1justificacion_gp preg2justificacion_gp preg3justificacion_gp ///
		preg4justificacion_gp preg5justificacion_gp  {
	egen sd_`var'= rowsd(`var'*)
	}
	
egen mean_sd_score=rowmean(sd_preg1calif sd_preg2calif sd_preg3calif sd_preg4calif sd_preg5calif sd_califglobal)	
egen mean_sd_ans=rowmean(sd_preg1justificacion_gp sd_preg2justificacion_gp sd_preg3justificacion_gp sd_preg4justificacion_gp sd_preg5justificacion_gp)
keep id mean_sd_score mean_sd_ans
tempfile temp_dev
save `temp_dev'
restore

keep id junta exp anio abogado avg_length mean_sd_ans_law 
merge m:1 id using `temp_dev', nogen

*Order criteria
replace avg_length=avg_length+0.1  
replace mean_sd_ans=0.1 if missing(mean_sd_ans)
gen indice=(mean_sd_score/(mean_sd_ans*avg_length*mean_sd_ans_law))
gsort -indice -mean_sd_score mean_sd_ans_law avg_length mean_sd_ans 

gen prioridad=_n
keep prioridad junta exp anio abogado indice
export delimited using "$directorio\_aux\fiscalizacion.csv", replace
