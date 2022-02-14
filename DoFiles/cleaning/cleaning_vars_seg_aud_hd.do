/*
********************
version 17.0
********************
 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	January 21, 2022
* Last date of modification:   
* Modifications:		
* Files used:     
* Files created:  

* Purpose: 

*******************************************************************************/
*/

*Rename 
local oldnames = ""
foreach var of varlist _all  {
local oldnames `oldnames' `var'
}
di "`oldnames'"

#delimit ;
 
rename (`oldnames') (capturista
				fecha_captura
				observaciones
				junta
				exp
				anio
				id
				borrar
				actor_contestacion
				demandado_contestacion
				tipo_persona_demandado
				abogado_patron_1
				abogado_patron_2
				abogado_patron_3
				categoria
				fecha_entrada
				fecha_salida
				hora_salida
				persona_despide
				excpecion_principal
				salario_base
				per_salario_base
				salario_int
				per_salario_int
				tipo_jornada
				horas
				per_horas
				dummy_ofr_reinst
				acepta_ofr_actor
				dummy_reinst_ef
				dummy_correccion_domicilio
				dummy_asociacion
				dummy_ampliacion_modif
				fecha_primer_cambio_abogado
				fecha_ultimo_cambio_abogado
				fecha_auto_rad
				fecha_emplazamiento_intento
				fecha_emplazamiento_exitoso
				dummy_exhorto
				entidad_exhorto
				fecha_primera_audiencia_cde
				contador_notificacion_actor
				comparecencia_cde_actor
				contador_notificacion_demandado
				comparecencia_cde_demandado
				contador_cde
				fecha_primera_audiencia_oap
				comparecencia_oap_actor
				comparecencia_oap_demanda
				contador_oap
				fecha_primera_audiencia_dp
				comparecencia_dp_actor
				comparecencia_dp_demanda
				contador_dp
				fecha_incidente_1
				tipo_incidente_1
				fecha_incidente_2
				tipo_incidente_2
				alegatos_actor
				alegatos_demandado
				fecha_cierre_instr_1
				fecha_cierre_instr_last
				confes_ofr_actor
				testi_ofr_actor
				docum_ofr_actor
				inspec_ofr_actor
				peric_ofr_actor
				confes_adm_actor
				testi_adm_actor
				docum_adm_actor
				inspec_adm_actor
				peric_adm_actor
				confes_desahg_actor
				testi_desahog_actor
				docum_desahog_actor
				inspec_desahog_actor
				peric_desahog_actor
				confes_desahog_pres_actor
				confes_desahog_ficto_actor
				confes_desahog_desist_actor
				testi_desahog_sust_actor
				testi_desahog_desist_actor
				docum_objecion_actor
				inspec_parte_actor
				dummy_inspec_compar_actor
				dummy_inspec_mostro_actor
				periciales_act
				confes_ofr_dem
				testi_ofr_de
				docum_ofr_dem
				inspec_ofr_dem
				peric_ofr_dem
				confes_adm_de
				testi_adm_dem
				docum_adm_de
				inspec_adm_de
				peric_adm_de
				confes_desahg_dem
				testi_desahog_dem
				docum_desahog_dem
				inspec_desahog_dem
				peric_desahog_dem
				confes_desahog_pres_dem
				confes_desahog_ficto_de
				confes_desahog_desist_dem
				testi_desahog_sust_dem
				testi_desahog_desist_dem
				docum_objecion_dem
				dummy_carta_renuncia_dem
				inspec_parte_dem
				dummy_inspec_compar_dem
				dummy_inspec_mostro_dem
				periciales_dem
				fecha_dictame
				reinst_dict
				indem_dict
				indem_c_dict
				sal_caidos_dict
				sal_caidos_c_dict
				prima_antig_dict
				prima_antig_c_dict
				vac_dict
				vac_c_dict
				prima_vac_dict
				prima_vac_c_dict
				aguinaldo_dict
				aguinaldo_c_dict
				hr_extra_dict
				hr_extra_cant_dict
				hr_extra_c_dict
				rec_20_dict
				rec_20_c_dict
				prima_dom_dict
				prima_dom_c_dict
				desc_sem_dict
				desc_sem_c_dict
				desc_oblig_dict
				desc_oblig_c_dict
				sarimssinfo_dict
				utilidades_dict
				utilidades_c_dict
				rec_sueldo_c_dict
				liq_total_otorgada_dict
				salario_cuantif_dict
				Dictaminador
				existio_relacion
				comprobo_despido
				no_renuncio_volunt
				ofrecimiento_trabajo
				mala_fe
				aceptacion_ofrecimiento
				reinst_efectiva
				causa_no_reinst
				veredicto_1
				veredicto_2
				num_aut_ejec
				fecha_ejec_1
				fecha_ejec_2
				fecha_ejec_3
				num_amparos_act
				amp_act_cambio_ver
				num_amparos_dem
				amp_dem_cambio_ver
				fecha_termino
				modo_termino_aud
				convenio_c
				) ;

#delimit cr

	
drop if missing(capturista)
destring salario_base, gen(salario_base_) force
gen dummy_contestacion = !missing(salario_base_) 

*Keep relevant variables
keep  junta exp anio actor_contestacion demandado_contestacion tipo_persona_demandado dummy_contestacion dummy_correccion_domicilio dummy_asociacion dummy_ampliacion_modif fecha_primer_cambio_abogado fecha_ultimo_cambio_abogado fecha_auto_rad fecha_emplazamiento_intento fecha_emplazamiento_exitoso dummy_exhorto fecha_primera_audiencia_cde contador_notificacion_actor comparecencia_cde_actor contador_notificacion_demandado comparecencia_cde_demandado contador_cde fecha_primera_audiencia_oap comparecencia_oap_actor comparecencia_oap_demanda contador_oap fecha_primera_audiencia_dp comparecencia_dp_actor comparecencia_dp_demanda contador_dp alegatos_actor alegatos_demandado fecha_cierre_instr_1 fecha_cierre_instr_last confes_ofr_actor testi_ofr_actor docum_ofr_actor inspec_ofr_actor peric_ofr_actor confes_adm_actor testi_adm_actor docum_adm_actor inspec_adm_actor peric_adm_actor confes_desahg_actor testi_desahog_actor docum_desahog_actor inspec_desahog_actor peric_desahog_actor confes_desahog_pres_actor confes_desahog_ficto_actor confes_desahog_desist_actor testi_desahog_sust_actor testi_desahog_desist_actor docum_objecion_actor inspec_parte_actor dummy_inspec_compar_actor dummy_inspec_mostro_actor confes_ofr_dem testi_ofr_de docum_ofr_dem inspec_ofr_dem peric_ofr_dem confes_adm_de testi_adm_dem docum_adm_de inspec_adm_de peric_adm_de confes_desahg_dem testi_desahog_dem docum_desahog_dem inspec_desahog_dem peric_desahog_dem confes_desahog_pres_dem confes_desahog_ficto_de confes_desahog_desist_dem testi_desahog_sust_dem testi_desahog_desist_dem docum_objecion_dem dummy_carta_renuncia_dem inspec_parte_dem dummy_inspec_compar_dem dummy_inspec_mostro_dem fecha_dictame reinst_dict indem_dict indem_c_dict sal_caidos_dict sal_caidos_c_dict prima_antig_dict prima_antig_c_dict vac_dict vac_c_dict prima_vac_dict prima_vac_c_dict aguinaldo_dict aguinaldo_c_dict hr_extra_dict hr_extra_cant_dict hr_extra_c_dict rec_20_dict rec_20_c_dict prima_dom_dict prima_dom_c_dict desc_sem_dict desc_sem_c_dict desc_oblig_dict desc_oblig_c_dict sarimssinfo_dict utilidades_dict utilidades_c_dict rec_sueldo_c_dict liq_total_otorgada_dict salario_cuantif_dict Dictaminador existio_relacion comprobo_despido no_renuncio_volunt ofrecimiento_trabajo mala_fe aceptacion_ofrecimiento reinst_efectiva causa_no_reinst num_aut_ejec	fecha_ejec_1 fecha_ejec_2 fecha_ejec_3 num_amparos_act amp_act_cambio_ver num_amparos_dem	amp_act_cambio_ver fecha_termino modo_termino convenio_c


replace actor_contestacion = ustrlower(ustrregexra(ustrnormalize(stritrim(trim(itrim(actor_contestacion))), "nfd"), "\p{Mark}", "")) 

replace demandado_contestacion = ustrlower(ustrregexra(ustrnormalize(stritrim(trim(itrim(demandado_contestacion))), "nfd"), "\p{Mark}", "")) 

cap destring tipo_persona_demandado, replace force
replace tipo_persona_demandado = . if !inlist(tipo_persona_demandado, 0, 1)
label define moral 0 "Moral" 1 "Fisica"
label values tipo_persona_demandado moral

replace Dictaminador = "" if Dictaminador=="X"
encode Dictaminador, gen(Dictaminador_)
drop Dictaminador
rename Dictaminador_ Dictaminador


destring modo_termino, replace force
label define modo_termino 1 "Settlement" 2 "Drop" 3 "Court ruling" 4 "Drop"
label values modo_termino modo_termino


* Cleaning when 'X' is treated as NA
foreach var of varlist dummy_contestacion existio_relacion comprobo_despido no_renuncio_volunt ofrecimiento_trabajo mala_fe aceptacion_ofrecimiento reinst_efectiva causa_no_reinst convenio_c num_aut_ejec num_amparos_act amp_act_cambio_ver num_amparos_dem	amp_act_cambio_ver {	
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
foreach var of varlist fecha_primer_cambio_abogado fecha_ultimo_cambio_abogado fecha_auto_rad fecha_emplazamiento_intento fecha_emplazamiento_exitoso fecha_primera_audiencia_cde fecha_primera_audiencia_oap fecha_primera_audiencia_dp fecha_cierre_instr_1 fecha_cierre_instr_last fecha_dictame fecha_termino fecha_ejec_1 fecha_ejec_2 fecha_ejec_3 {

	su `var'
	if `r(N)'==0 {
		replace `var' = "" if strpos(`var', "X")!=0
		gen d_`var' = date(`var', "DMY")
		drop `var'
		rename d_`var' `var'
		format `var' %td
		}
}

order  junta exp anio actor_contestacion demandado_contestacion tipo_persona_demandado dummy_contestacion dummy_correccion_domicilio dummy_asociacion dummy_ampliacion_modif fecha_primer_cambio_abogado fecha_ultimo_cambio_abogado fecha_auto_rad fecha_emplazamiento_intento fecha_emplazamiento_exitoso dummy_exhorto fecha_primera_audiencia_cde contador_notificacion_actor comparecencia_cde_actor contador_notificacion_demandado comparecencia_cde_demandado contador_cde fecha_primera_audiencia_oap comparecencia_oap_actor comparecencia_oap_demanda contador_oap fecha_primera_audiencia_dp comparecencia_dp_actor comparecencia_dp_demanda contador_dp alegatos_actor alegatos_demandado fecha_cierre_instr_1 fecha_cierre_instr_last confes_ofr_actor testi_ofr_actor docum_ofr_actor inspec_ofr_actor peric_ofr_actor confes_adm_actor testi_adm_actor docum_adm_actor inspec_adm_actor peric_adm_actor confes_desahg_actor testi_desahog_actor docum_desahog_actor inspec_desahog_actor peric_desahog_actor confes_desahog_pres_actor confes_desahog_ficto_actor confes_desahog_desist_actor testi_desahog_sust_actor testi_desahog_desist_actor docum_objecion_actor inspec_parte_actor dummy_inspec_compar_actor dummy_inspec_mostro_actor confes_ofr_dem testi_ofr_de docum_ofr_dem inspec_ofr_dem peric_ofr_dem confes_adm_de testi_adm_dem docum_adm_de inspec_adm_de peric_adm_de confes_desahg_dem testi_desahog_dem docum_desahog_dem inspec_desahog_dem peric_desahog_dem confes_desahog_pres_dem confes_desahog_ficto_de confes_desahog_desist_dem testi_desahog_sust_dem testi_desahog_desist_dem docum_objecion_dem dummy_carta_renuncia_dem inspec_parte_dem dummy_inspec_compar_dem dummy_inspec_mostro_dem fecha_dictame reinst_dict indem_dict indem_c_dict sal_caidos_dict sal_caidos_c_dict prima_antig_dict prima_antig_c_dict vac_dict vac_c_dict prima_vac_dict prima_vac_c_dict aguinaldo_dict aguinaldo_c_dict hr_extra_dict hr_extra_cant_dict hr_extra_c_dict rec_20_dict rec_20_c_dict prima_dom_dict prima_dom_c_dict desc_sem_dict desc_sem_c_dict desc_oblig_dict desc_oblig_c_dict sarimssinfo_dict utilidades_dict utilidades_c_dict rec_sueldo_c_dict liq_total_otorgada_dict salario_cuantif_dict Dictaminador existio_relacion comprobo_despido no_renuncio_volunt ofrecimiento_trabajo mala_fe aceptacion_ofrecimiento reinst_efectiva causa_no_reinst num_aut_ejec	fecha_ejec_1 fecha_ejec_2 fecha_ejec_3 num_amparos_act amp_act_cambio_ver num_amparos_dem	amp_act_cambio_ver fecha_termino modo_termino convenio_c

rename (actor_contestacion demandado_contestacion) (nombre_ac nombre_d)