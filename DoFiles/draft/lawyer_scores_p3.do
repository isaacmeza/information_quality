/*
********************
version 17.0
********************
 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	Sept. 27, 2021
* Last date of modification:   
* Modifications:		
* Files used:     
		- iniciales_dem.dta
		- lawyer_scores_p3.dta
* Files created:  

* Purpose: Analysis of lawyer scores. Predicting power of scores to objective output measures and correlation of input measures with grades. Which is best to predict output : scores or input variables?

*******************************************************************************/
*/


use "$directorio\DB\iniciales_dem_p3.dta" , clear
merge m:m junta exp anio using "$directorio\DB\lawyer_scores_p3.dta", nogen keep(3)

keep id_actor junta exp anio nombre_actor tipo_abogado reclutamiento giro_empresa trabajador_confianza sueldo_estadistico  periodicidad_sueldo_estadistic tipo_jornada numero_horas_laboradas periodicidad_horas_laboradas reinstalacion indemnizacion_constitucional salarios_caidos prima_antiguedad vacaciones prima_vacacional aguinaldo horas_extra indemnizacion_20_dias_anio_ser prima_dominical descanso_semanal descanso_obligatorio cuotas_sar_imss_info utilidades salarios_devengados_numero_dia nulidad accion_principal tipo_prevencion derecho_propio_c_clv giro_defendant_c_clv num_demandados_totales num_demandados_totales num_demandados_completos num_abogados_proemio num_abogados_proemio_completos incrementos_sal_c_clv contrato_c_clv lugar_trabajo_c_clv horario_inicio_jornada_c_clv horario_fin_jornada_c_clv especifican_dias_c_clv salario_int_clv periodo_sal_int_clv fecha_despido_c_clv lugar_despido_c_clv motivo_despido_c_clv cargo_despide_clv presentado_tiempo_forma_c_clv personalidad_c_clv firma_trabajador_c_clv estatus modo_termino tratamiento fecha_demanda fecha_termino cantidad1 cantidad2 ///
abogado calif_rubro_proemio just_rubro_proemio calif_prestaciones just_prestaciones calif_hechos just_hechos calif_derechos just_derechos calif_puntos_petitorios just_puntos_petitorios total prediccion_a prediccion_b monto

foreach var of varlist just* {
	gen `var'_ = ustrlower(ustrregexra(ustrnormalize(stritrim(trim(itrim(`var'))), "nfd"), "\p{Mark}", "")) 
	drop `var' 
	rename `var'_ `var'
}

order id_actor junta exp anio nombre_actor tipo_abogado reclutamiento giro_empresa trabajador_confianza sueldo_estadistico  periodicidad_sueldo_estadistic tipo_jornada numero_horas_laboradas periodicidad_horas_laboradas reinstalacion indemnizacion_constitucional salarios_caidos prima_antiguedad vacaciones prima_vacacional aguinaldo horas_extra indemnizacion_20_dias_anio_ser prima_dominical descanso_semanal descanso_obligatorio cuotas_sar_imss_info utilidades salarios_devengados_numero_dia nulidad accion_principal tipo_prevencion derecho_propio_c_clv giro_defendant_c_clv num_demandados_totales num_demandados_totales num_demandados_completos num_abogados_proemio num_abogados_proemio_completos incrementos_sal_c_clv contrato_c_clv lugar_trabajo_c_clv horario_inicio_jornada_c_clv horario_fin_jornada_c_clv especifican_dias_c_clv salario_int_clv periodo_sal_int_clv fecha_despido_c_clv lugar_despido_c_clv motivo_despido_c_clv cargo_despide_clv presentado_tiempo_forma_c_clv personalidad_c_clv firma_trabajador_c_clv estatus modo_termino tratamiento fecha_demanda fecha_termino cantidad1 cantidad2 ///
abogado calif_rubro_proemio just_rubro_proemio calif_prestaciones just_prestaciones calif_hechos just_hechos calif_derechos just_derechos calif_puntos_petitorios just_puntos_petitorios total prediccion_a prediccion_b monto

*Cleaning features
drop if inlist(tipo_abogado, 0, 2)
replace nulidad = 1 if inlist(nulidad, 1.2, 11.2)
replace cargo_despide_clv = 1 if inlist(cargo_despide_clv, 2)

foreach var of varlist reinstalacion indemnizacion_constitucional salarios_caidos prima_antiguedad vacaciones prima_vacacional aguinaldo horas_extra indemnizacion_20_dias_anio_ser prima_dominical descanso_semanal descanso_obligatorio cuotas_sar_imss_info utilidades nulidad derecho_propio_c_clv giro_defendant_c_clv incrementos_sal_c_clv contrato_c_clv lugar_trabajo_c_clv horario_inicio_jornada_c_clv horario_fin_jornada_c_clv especifican_dias_c_clv salario_int_clv periodo_sal_int_clv fecha_despido_c_clv lugar_despido_c_clv motivo_despido_c_clv cargo_despide_clv presentado_tiempo_forma_c_clv personalidad_c_clv firma_trabajador_c_clv {
	drop if missing(`var')
}



*Calif pre processing
foreach var of varlist calif* total {
	replace `var' = 1 if `var'==0
}


export delimited using "$directorio\_aux\lawyer_scores_p3.csv", replace quote


eststo : reg total tipo_abogado ///
       reclutamiento giro_empresa trabajador_confianza ///
       sueldo_estadistico periodicidad_sueldo_estadistic tipo_jornada ///
       numero_horas_laboradas periodicidad_horas_laboradas ///
       reinstalacion indemnizacion_constitucional salarios_caidos ///
       prima_antiguedad vacaciones prima_vacacional aguinaldo ///
       horas_extra indemnizacion_20_dias_anio_ser prima_dominical ///
       descanso_semanal descanso_obligatorio cuotas_sar_imss_info ///
       utilidades salarios_devengados_numero_dia nulidad ///
       accion_principal tipo_prevencion derecho_propio_c_clv ///
       giro_defendant_c_clv num_demandados_totales ///
       num_demandados_completos num_abogados_proemio ///
       num_abogados_proemio_completos incrementos_sal_c_clv ///
       contrato_c_clv lugar_trabajo_c_clv horario_inicio_jornada_c_clv ///
       horario_fin_jornada_c_clv especifican_dias_c_clv ///
       salario_int_clv periodo_sal_int_clv fecha_despido_c_clv ///
       lugar_despido_c_clv motivo_despido_c_clv cargo_despide_clv ///
       presentado_tiempo_forma_c_clv personalidad_c_clv ///
       firma_trabajador_c_clv, r
	   
eststo : reg total tipo_abogado ///
       reclutamiento giro_empresa trabajador_confianza ///
       sueldo_estadistico periodicidad_sueldo_estadistic tipo_jornada ///
       numero_horas_laboradas periodicidad_horas_laboradas ///
       reinstalacion indemnizacion_constitucional salarios_caidos ///
       prima_antiguedad vacaciones prima_vacacional aguinaldo ///
       horas_extra indemnizacion_20_dias_anio_ser prima_dominical ///
       descanso_semanal descanso_obligatorio cuotas_sar_imss_info ///
       utilidades salarios_devengados_numero_dia nulidad ///
       accion_principal tipo_prevencion derecho_propio_c_clv ///
       giro_defendant_c_clv num_demandados_totales ///
       num_demandados_completos num_abogados_proemio ///
       num_abogados_proemio_completos incrementos_sal_c_clv ///
       contrato_c_clv lugar_trabajo_c_clv horario_inicio_jornada_c_clv ///
       horario_fin_jornada_c_clv especifican_dias_c_clv ///
       salario_int_clv periodo_sal_int_clv fecha_despido_c_clv ///
       lugar_despido_c_clv motivo_despido_c_clv cargo_despide_clv ///
       presentado_tiempo_forma_c_clv personalidad_c_clv ///
       firma_trabajador_c_clv if strpos(abogado,"laura")!=0, r
	   	   
esttab using "$directorio/Tables/reg_results/vars_calidad.csv", se r2 ${star} b(a2) label replace 
	
	
	   
foreach var in junta exp anio{
tostring `var', gen(`var'_s)
}
gen id_exp = junta_s + "-" + exp_s + "-" + anio_s

bysort id_exp: gen diferencia = (califglobal[1] - califglobal[_N])^2
by id_exp: egen promedio_global_calif = mean(califglobal)

bysort nombre: gen suma_difs = sum(diferencia)
by nombre: replace suma_difs = suma_difs[_N]

bysort id_exp: gen todas_difs = sum(suma_difs)
by id_exp: replace todas_difs = todas_difs[_N]
gen prop_fallas = suma_difs/todas_difs 
gen peso = 1-prop_fallas

gen promedio_global_ponderado = califglobal*peso
bysort id_exp: replace promedio_global_ponderado = sum(promedio_global_ponderado)
by id_exp: replace promedio_global_ponderado = promedio_global_ponderado[_N]



*como se relaciona la total con las inidviduales?

reg total calif_*, r nocons
reg total calif_* if strpos(abogado,"laura")!=0, r nocons
br


reg total tipo_abogado reclutamiento giro_empresa trabajador_confianza sueldo_estadistico  periodicidad_sueldo_estadistic tipo_jornada numero_horas_laboradas periodicidad_horas_laboradas reinstalacion indemnizacion_constitucional salarios_caidos prima_antiguedad vacaciones prima_vacacional aguinaldo horas_extra indemnizacion_20_dias_anio_ser prima_dominical descanso_semanal descanso_obligatorio cuotas_sar_imss_info utilidades salarios_devengados_numero_dia nulidad accion_principal tipo_prevencion derecho_propio_c_clv giro_defendant_c_clv num_demandados_totales num_demandados_totales num_demandados_completos num_abogados_proemio num_abogados_proemio_completos incrementos_sal_c_clv contrato_c_clv lugar_trabajo_c_clv horario_inicio_jornada_c_clv horario_fin_jornada_c_clv especifican_dias_c_clv salario_int_clv periodo_sal_int_clv fecha_despido_c_clv lugar_despido_c_clv motivo_despido_c_clv cargo_despide_clv presentado_tiempo_forma_c_clv personalidad_c_clv firma_trabajador_c_clv 



gen termino = (estatus==3)

reg termino calif*, r
reg termino c.calif*##c.calif*, r
logit termino calif*, r

gen convenio = (modo_termino==2)

reg convenio calif*, r




histogram calif_derechos
histogram calif_rubro

twoway (histogram calif_derechos) (hist calif_rubro)
scatter total sueldo_estadistico if sueldo_estadistico < 20000


