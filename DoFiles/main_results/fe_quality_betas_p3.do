/*
Office FE heterogeneity on observed quality measures.
Author :  Isaac Meza
*/

********************************************************************************
global input_varlist_p3 indem sal_caidos prima_antig ///
	prima_vac hextra prima_dom desc_sem desc_ob sarimssinf utilidades nulidad ///
	codem reinst


global bvc_p3 gen horas_sem  salario_diario abogado_pub  c_antiguedad 	


// GRAPH FORMATTING
// For graphs:
local labsize medlarge
local bigger_labsize large
local ylabel_options nogrid notick labsize(`labsize') angle(horizontal)
local xlabel_options nogrid notick labsize(`labsize')
local xtitle_options size(`labsize') margin(top)
local title_options size(`bigger_labsize') margin(bottom) color(black)
local manual_axis lwidth(thin) lcolor(black) lpattern(solid)
local plotregion plotregion(margin(sides) fcolor(white) lstyle(none) lcolor(white)) 
local graphregion graphregion(fcolor(white) lstyle(none) lcolor(white)) 
local T_line_options lwidth(thin) lcolor(gray) lpattern(dash)
// To show significance: hollow gray (gs7) will be insignificant from 0,
//  filled-in gray significant at 10%
//  filled-in black significant at 5%
local estimate_options_0  mcolor(gs7)   msymbol(Oh) msize(medlarge)
local estimate_options_90 mcolor(gs7)   msymbol(O)  msize(medlarge)
local estimate_options_95 mcolor(black) msymbol(O)  msize(medlarge)
local rcap_options_0  lcolor(gs7)   lwidth(thin)
local rcap_options_90 lcolor(gs7)   lwidth(thin)
local rcap_options_95 lcolor(black) lwidth(thin)

********************************************************************************


use "$directorio\DB\iniciales_dem_p3.dta" , clear
merge m:m junta exp anio using "$directorio\DB\lawyer_scores_p3.dta", nogen 


bysort gp_office : gen num_casefiles = _N
drop if num_casefiles<=4
sort gp_office
egen id = group(gp_office)
qui tab id
local num_off = `r(r)'
di `num_off'
*Identify "Procuraduria"
su id if abogado_pub==1 
if `r(sd)' == 0 {
	local procu = int(`r(mean)')
}
	
	
foreach varj of varlist  total calif_rubro_proemio calif_prestaciones calif_hechos calif_derechos calif_puntos_petitorios prediccion_a prediccion_b monto {

	*Standardization
	su `varj'
	gen std_`varj' = (`varj'-`r(mean)')/`r(sd)'
	
	*wrt procu
	reg std_`varj' $input_varlist_p3 $bvc_p3 ib`procu'.id, r cluster(id)
	
	local df = e(df_r)
	levelsof id if e(sample), local(levels) 
	
	matrix results = J(`num_off', 4, .) // empty matrix for results
	//  4 cols are: (1) office, (2) beta, (3) std error, (4) pvalue
	
	foreach row of local levels {
		matrix results[`row',1] = `row'
		*Omited office
		if `row'!=`procu' { 
		// Beta 
		matrix results[`row',2] = (_b[`row'.id] )
		// Standard error
		matrix results[`row',3] = _se[`row'.id]
		// P-value
		matrix results[`row',4] = 2*ttail(`df', abs(_b[`row'.id]/_se[`row'.id]))
			}
	}
	
	matrix colnames results = "k" "beta" "se" "p"
	matlist results
	
	preserve
	clear
	svmat results, names(col) 
	drop if missing(k)

	// Confidence intervals (95%) (wrt the proportion of the mean)
	local alpha = .05 // for 95% confidence intervals
	gen rcap_lo = beta - (invttail(`df',`=`alpha'/2')*se )
	gen rcap_hi = beta + (invttail(`df',`=`alpha'/2')*se )

	*Procuraduria
	replace beta = 0 if missing(beta)
	replace se = 0 if missing(se)
	sort beta 
	gen orden = _n
	qui su orden if k==`procu'
	local procu_orden = `r(mean)'

		// GRAPH
	#delimit ;
	graph twoway 
		(scatter beta orden if p<0.05,           `estimate_options_95') 
		(scatter beta orden if p>=0.05 & p<0.10, `estimate_options_90') 
		(scatter beta orden if p>=0.10,          `estimate_options_0' ) 
		(rcap rcap_hi rcap_lo orden if p<0.05,           `rcap_options_95')
		(rcap rcap_hi rcap_lo orden if p>=0.05 & p<0.10, `rcap_options_90')
		(rcap rcap_hi rcap_lo orden if p>=0.10,          `rcap_options_0' )		
		, 
		title(" ", `title_options')
		ylabel(, `ylabel_options') 
		yline(0, `manual_axis')
		xtitle("Lawyer", `xtitle_options')
		xscale(range(`min_xaxis' `max_xaxis'))
		xline(`procu_orden', `T_line_options')
		xscale(noline) /* because manual axis at 0 with yline above) */
		`plotregion' `graphregion'
		legend(off)  
	;
	
	#delimit cr
	graph export "$directorio\Figuras\betasp3_ql_`varj'.pdf", replace
	
	
	*Save estimation
	rename k id
	foreach vare of varlist beta se {
		rename `vare'  `vare'_`varj'
	}
	keep id beta se
	tempfile temp_e
	save `temp_e'
	
	restore
	
	*Paste estimation
	merge m:1 id using `temp_e', nogen
	}
	
pwcorr beta*, star(.05) sig
putexcel set "$directorio\Tables\betas_cor.xlsx", sheet("betasp3_cor") modify
putexcel C4 =  matrix(r(C)), names
putexcel N4 =  matrix(r(sig)), names

spearman beta*, star(.05)
putexcel set "$directorio\Tables\betas_cor.xlsx", sheet("betasp3_spearman") modify
putexcel C4 =  matrix(r(Rho)), names	
putexcel N4 =  matrix(r(P)), names	
********************************************************************************
********************************************************************************
********************************************************************************


merge m:m id_exp nombre_ac using "$directorio\_aux\seguimiento_aud_p3.dta", nogen
merge m:1 junta exp anio using "$directorio\DB\seguimiento_dem_p3.dta", nogen
duplicates drop


* Pre-Processing
*Wizorise all at 95th percentile
for var contador_notificacion_actor comparecencia_cde_actor contador_cde comparecencia_oap_actor contador_oap comparecencia_dp_actor contador_dp: capture egen X95 = pctile(X) , p(95)
for var contador_notificacion_actor comparecencia_cde_actor contador_cde comparecencia_oap_actor contador_oap comparecencia_dp_actor contador_dp: ///
	capture replace X=X95 if X>X95 & X~=.
drop *95


foreach var of varlist  contador_notificacion_actor comparecencia_cde_actor contador_cde comparecencia_oap_actor contador_oap comparecencia_dp_actor contador_dp {
	tab `var'
}

replace docum_objecion_actor = 1 if docum_objecion_actor>1 & !missing(docum_objecion_actor)


keep ///
/*Casefile id*/ ///
junta exp anio id ///
/*Iniciales*/ ///
gen horas_sem salario_diario abogado_pub c_antiguedad trabajador_base indem sal_caidos prima_antig prima_vac hextra prima_dom desc_sem desc_ob sarimssinf utilidades nulidad codem reinst ///
giro_empresa ///
/*Quality vars*/ ///
accion_principal derecho_propio_c_clv giro_defendant_c_clv num_demandados_totales num_demandados_completos num_abogados_proemio num_abogados_proemio_completos incrementos_sal_c_clv contrato_c_clv lugar_trabajo_c_clv horario_inicio_jornada_c_clv horario_fin_jornada_c_clv especifican_dias_c_clv salario_int_clv periodo_sal_int_clv fecha_despido_c_clv lugar_despido_c_clv motivo_despido_c_clv cargo_despide_clv presentado_tiempo_forma_c_clv personalidad_c_clv firma_trabajador_c_clv ///
/*Seguimiento Aud*/ ///
tipo_persona_demandado dummy_correccion_domicilio dummy_ampliacion_modif dummy_exhorto contador_notificacion_actor comparecencia_cde_actor contador_cde comparecencia_oap_actor contador_oap comparecencia_dp_actor contador_dp alegatos_actor  ///
/*Pruebas*/ ///
confes_ofr_actor testi_ofr_actor docum_ofr_actor inspec_ofr_actor peric_ofr_actor confes_adm_actor testi_adm_actor docum_adm_actor inspec_adm_actor peric_adm_actor confes_desahg_actor testi_desahog_actor docum_desahog_actor inspec_desahog_actor peric_desahog_actor confes_desahog_desist_actor testi_desahog_desist_actor docum_objecion_actor dummy_inspec_compar_actor dummy_inspec_mostro_actor  ///
/*Outcome*/ 	///
total calif* monto ///
/*Office score*/  ///
beta_* se_*

order  ///
/*Casefile id*/ ///
junta exp anio id ///
/*Iniciales*/ ///
gen horas_sem salario_diario abogado_pub c_antiguedad trabajador_base indem sal_caidos prima_antig prima_vac hextra prima_dom desc_sem desc_ob sarimssinf utilidades nulidad codem reinst ///
giro_empresa ///
/*Quality vars*/ ///
accion_principal derecho_propio_c_clv giro_defendant_c_clv num_demandados_totales num_demandados_completos num_abogados_proemio num_abogados_proemio_completos incrementos_sal_c_clv contrato_c_clv lugar_trabajo_c_clv horario_inicio_jornada_c_clv horario_fin_jornada_c_clv especifican_dias_c_clv salario_int_clv periodo_sal_int_clv fecha_despido_c_clv lugar_despido_c_clv motivo_despido_c_clv cargo_despide_clv presentado_tiempo_forma_c_clv personalidad_c_clv firma_trabajador_c_clv ///
/*Seguimiento Aud*/ ///
tipo_persona_demandado dummy_correccion_domicilio dummy_ampliacion_modif dummy_exhorto contador_notificacion_actor comparecencia_cde_actor contador_cde comparecencia_oap_actor contador_oap comparecencia_dp_actor contador_dp alegatos_actor  ///
/*Pruebas*/ ///
confes_ofr_actor testi_ofr_actor docum_ofr_actor inspec_ofr_actor peric_ofr_actor confes_adm_actor testi_adm_actor docum_adm_actor inspec_adm_actor peric_adm_actor confes_desahg_actor testi_desahog_actor docum_desahog_actor inspec_desahog_actor peric_desahog_actor confes_desahog_desist_actor testi_desahog_desist_actor docum_objecion_actor dummy_inspec_compar_actor dummy_inspec_mostro_actor  ///
/*Outcome*/ 	///
total calif* monto ///
/*Office score*/  ///
beta_* se_*


export delimited using "$directorio\_aux\betas_score_p3.csv", replace quote nolabel 
