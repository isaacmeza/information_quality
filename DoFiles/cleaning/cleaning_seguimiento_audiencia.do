/*
********************
version 17.0
********************
 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M 
* Machine:	Isaac M 											
* Date of creation:	January. 19 2022  
* Last date of modification: 
* Modifications: 	
* Files used:     
		- 
* Files created:  

* Purpose: Cleaning 'seguimientos de audiencia' following the lawsuits of the casefiles graded by Laura.

*******************************************************************************/
*/


import excel "$directorio\Raw\seguimientos\BASE_HISTORICA_REDUCIDA_2021_APPEND.xlsx", ///
	sheet("REDUCIDA") firstrow clear
	
drop if missing(capturista)

*Keep relevant variables
keep  junta exp anio actor_contestacion demandado_contestacion tipo_persona_demandado dummy_contestacion dummy_correccion_domicilio dummy_asociacion dummy_ampliacion_modif fecha_primer_cambio_abogado fecha_ultimo_cambio_abogado fecha_auto_rad fecha_emplazamiento_intento fecha_emplazamiento_exitoso dummy_exhorto fecha_primera_audiencia_cde contador_notificacion_actor comparecencia_cde_actor contador_notificacion_demandado comparecencia_cde_demandado contador_cde fecha_primera_audiencia_oap comparecencia_oap_actor comparecencia_oap_demanda contador_oap fecha_primera_audiencia_dp comparecencia_dp_actor comparecencia_dp_demanda contador_dp alegatos_actor alegatos_demandado fecha_cierre_instr_1 fecha_cierre_instr_last confes_ofr_actor testi_ofr_actor docum_ofr_actor inspec_ofr_actor peric_ofr_actor confes_adm_actor testi_adm_actor docum_adm_actor inspec_adm_actor peric_adm_actor confes_desahg_actor testi_desahog_actor docum_desahog_actor inspec_desahog_actor peric_desahog_actor confes_desahog_pres_actor confes_desahog_ficto_actor confes_desahog_desist_actor testi_desahog_sust_actor testi_desahog_desist_actor docum_objecion_actor inspec_parte_actor dummy_inspec_compar_actor dummy_inspec_mostro_actor confes_ofr_dem testi_ofr_de docum_ofr_dem inspec_ofr_dem peric_ofr_dem confes_adm_de testi_adm_dem docum_adm_de inspec_adm_de peric_adm_de confes_desahg_dem testi_desahog_dem docum_desahog_dem inspec_desahog_dem peric_desahog_dem confes_desahog_pres_dem confes_desahog_ficto_de confes_desahog_desist_dem testi_desahog_sust_dem testi_desahog_desist_dem docum_objecion_dem dummy_carta_renuncia_dem inspec_parte_dem dummy_inspec_compar_dem dummy_inspec_mostro_dem fecha_dictame reinst indem indem_c sal_caidos sal_caidos_c prima_antig prima_antig_c vac vac_c prima_vac prima_vac_c aguinaldo aguinaldo_c hr_extra hr_extra_cant hr_extra_c rec_20 rec_20_c prima_dom prima_dom_c desc_sem desc_sem_c desc_oblig desc_oblig_c sarimssinfo utilidades utilidades_c rec_sueldo_c liq_total_otorgada salario_cuantif Dictaminador existio_relacion comprobo_despido no_renuncio_volunt ofrecimiento_trabajo mala_fe aceptacion_ofrecimiento reinst_efectiva causa_no_reinst last_etapa fecha_termino modo_termino convenio_c


replace actor_contestacion = ustrlower(ustrregexra(ustrnormalize(stritrim(trim(itrim(actor_contestacion))), "nfd"), "\p{Mark}", "")) 

replace demandado_contestacion = ustrlower(ustrregexra(ustrnormalize(stritrim(trim(itrim(demandado_contestacion))), "nfd"), "\p{Mark}", "")) 


label define moral 0 "Moral" 1 "Fisica"
label values tipo_persona_demandado moral

replace Dictaminador = "" if Dictaminador=="X"
encode Dictaminador, gen(Dictaminador_)
drop Dictaminador
rename Dictaminador_ Dictaminador

replace last_etapa = ustrlower(ustrregexra(ustrnormalize(stritrim(trim(itrim(last_etapa))), "nfd"), "\p{Mark}", "")) 
encode last_etapa, gen(last_etapa_)
drop last_etapa
rename last_etapa_ last_etapa

destring modo_termino, replace force
label define modo_termino 1 "Settlement" 2 "Drop" 3 "Court ruling" 4 "Drop"
label values modo_termino modo_termino

* Renaming to aviod name conflicts
foreach var of varlist reinst indem indem_c sal_caidos sal_caidos_c prima_antig prima_antig_c vac vac_c prima_vac prima_vac_c aguinaldo aguinaldo_c hr_extra hr_extra_cant hr_extra_c rec_20 rec_20_c prima_dom prima_dom_c desc_sem desc_sem_c desc_oblig desc_oblig_c sarimssinfo utilidades utilidades_c rec_sueldo_c liq_total_otorgada salario_cuantif {
	rename `var' `var'_dict
}

* Cleaning when 'X' is treated as NA
foreach var of varlist dummy_contestacion existio_relacion comprobo_despido no_renuncio_volunt ofrecimiento_trabajo mala_fe aceptacion_ofrecimiento reinst_efectiva causa_no_reinst convenio_c  {	
	destring `var', replace force
}

* Cleaning when 'X' is treated as new category
foreach var of varlist  tipo_persona_demandado dummy_correccion_domicilio dummy_asociacion dummy_ampliacion_modif dummy_exhorto contador_notificacion_actor comparecencia_cde_actor contador_notificacion_demandado comparecencia_cde_demandado contador_cde comparecencia_oap_actor comparecencia_oap_demanda contador_oap comparecencia_dp_actor comparecencia_dp_demanda contador_dp alegatos_actor alegatos_demandado {	
	destring `var', replace force
	replace `var' = -1 if missing(`var') 
}


* Cleaning when 'X' is treated as 0
foreach var of varlist confes_ofr_actor testi_ofr_actor docum_ofr_actor inspec_ofr_actor peric_ofr_actor confes_adm_actor testi_adm_actor docum_adm_actor inspec_adm_actor peric_adm_actor confes_desahg_actor testi_desahog_actor docum_desahog_actor inspec_desahog_actor peric_desahog_actor confes_desahog_pres_actor confes_desahog_ficto_actor confes_desahog_desist_actor testi_desahog_sust_actor testi_desahog_desist_actor docum_objecion_actor dummy_inspec_compar_actor dummy_inspec_mostro_actor confes_ofr_dem testi_ofr_de docum_ofr_dem inspec_ofr_dem peric_ofr_dem confes_adm_de testi_adm_dem docum_adm_de inspec_adm_de peric_adm_de confes_desahg_dem testi_desahog_dem docum_desahog_dem inspec_desahog_dem peric_desahog_dem confes_desahog_pres_dem confes_desahog_ficto_de confes_desahog_desist_dem testi_desahog_sust_dem testi_desahog_desist_dem docum_objecion_dem dummy_carta_renuncia_dem  dummy_inspec_compar_dem dummy_inspec_mostro_dem reinst_dict indem_dict indem_c_dict sal_caidos_dict sal_caidos_c_dict prima_antig_dict prima_antig_c_dict vac_dict vac_c_dict prima_vac_dict prima_vac_c_dict aguinaldo_dict aguinaldo_c_dict hr_extra_dict hr_extra_cant_dict hr_extra_c_dict rec_20_dict rec_20_c_dict prima_dom_dict prima_dom_c_dict desc_sem_dict desc_sem_c_dict desc_oblig_dict desc_oblig_c_dict sarimssinfo_dict utilidades_dict utilidades_c_dict rec_sueldo_c_dict liq_total_otorgada_dict salario_cuantif_dict {
	destring  `var', replace force
	replace `var' = 0 if missing(`var')
}

foreach var of varlist inspec_parte_actor inspec_parte_dem {
	replace `var' = ustrlower(ustrregexra(ustrnormalize(stritrim(trim(itrim(`var'))), "nfd"), "\p{Mark}", ""))
	gen `var'_ = strpos(`var', "actor")
	drop `var'
	rename `var'_ `var'
}


* Cleaning date
foreach var of varlist fecha_primer_cambio_abogado fecha_ultimo_cambio_abogado fecha_auto_rad fecha_emplazamiento_intento fecha_emplazamiento_exitoso fecha_primera_audiencia_cde fecha_primera_audiencia_oap fecha_primera_audiencia_dp fecha_cierre_instr_1 fecha_cierre_instr_last fecha_dictame fecha_termino {
	gen d_`var' = date(`var', "DMY")
	drop `var'
	rename d_`var' `var'
	format `var' %td
}

order  junta exp anio actor_contestacion demandado_contestacion tipo_persona_demandado dummy_contestacion dummy_correccion_domicilio dummy_asociacion dummy_ampliacion_modif fecha_primer_cambio_abogado fecha_ultimo_cambio_abogado fecha_auto_rad fecha_emplazamiento_intento fecha_emplazamiento_exitoso dummy_exhorto fecha_primera_audiencia_cde contador_notificacion_actor comparecencia_cde_actor contador_notificacion_demandado comparecencia_cde_demandado contador_cde fecha_primera_audiencia_oap comparecencia_oap_actor comparecencia_oap_demanda contador_oap fecha_primera_audiencia_dp comparecencia_dp_actor comparecencia_dp_demanda contador_dp alegatos_actor alegatos_demandado fecha_cierre_instr_1 fecha_cierre_instr_last confes_ofr_actor testi_ofr_actor docum_ofr_actor inspec_ofr_actor peric_ofr_actor confes_adm_actor testi_adm_actor docum_adm_actor inspec_adm_actor peric_adm_actor confes_desahg_actor testi_desahog_actor docum_desahog_actor inspec_desahog_actor peric_desahog_actor confes_desahog_pres_actor confes_desahog_ficto_actor confes_desahog_desist_actor testi_desahog_sust_actor testi_desahog_desist_actor docum_objecion_actor inspec_parte_actor dummy_inspec_compar_actor dummy_inspec_mostro_actor confes_ofr_dem testi_ofr_de docum_ofr_dem inspec_ofr_dem peric_ofr_dem confes_adm_de testi_adm_dem docum_adm_de inspec_adm_de peric_adm_de confes_desahg_dem testi_desahog_dem docum_desahog_dem inspec_desahog_dem peric_desahog_dem confes_desahog_pres_dem confes_desahog_ficto_de confes_desahog_desist_dem testi_desahog_sust_dem testi_desahog_desist_dem docum_objecion_dem dummy_carta_renuncia_dem inspec_parte_dem dummy_inspec_compar_dem dummy_inspec_mostro_dem fecha_dictame reinst_dict indem_dict indem_c_dict sal_caidos_dict sal_caidos_c_dict prima_antig_dict prima_antig_c_dict vac_dict vac_c_dict prima_vac_dict prima_vac_c_dict aguinaldo_dict aguinaldo_c_dict hr_extra_dict hr_extra_cant_dict hr_extra_c_dict rec_20_dict rec_20_c_dict prima_dom_dict prima_dom_c_dict desc_sem_dict desc_sem_c_dict desc_oblig_dict desc_oblig_c_dict sarimssinfo_dict utilidades_dict utilidades_c_dict rec_sueldo_c_dict liq_total_otorgada_dict salario_cuantif_dict Dictaminador existio_relacion comprobo_despido no_renuncio_volunt ofrecimiento_trabajo mala_fe aceptacion_ofrecimiento reinst_efectiva causa_no_reinst last_etapa fecha_termino modo_termino convenio_c

rename (actor_contestacion demandado_contestacion) (nombre_ac nombre_d)

duplicates drop 

save "$directorio\DB\seguimiento_aud_p3.dta", replace	