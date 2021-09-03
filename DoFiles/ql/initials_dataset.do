

*Cleaning

*-------------------------------------------------------------------------------
*Rubro y Proemio
import excel "$directorio\Raw\dem_lab.xls", sheet("rubro_proemio") firstrow clear

*Name cleaning
foreach var of varlist nombre_plaintiff_c apellido_plaintiff_c nombre_def_c ///
					derecho_propio nombre_law_c apellido_law_c ///
					calle_plaintiff num_plaintiff_c col_plaintiff_c ///
					mun_plaintiff_c  {
	qui do "$directorio\DoFiles\basic_name_clean.do" ///
		 `var'
	rename `var' `var'_clv	 
	 }

gen derecho_propio_c_=(strpos(upper(derecho_propio_c_clv), "REPRESENTACION"))==0
drop derecho_propio_c_clv
rename derecho_propio_c_ derecho_propio_c_clv
	 
*Code non-missing values	 
foreach	var of varlist  giro_defendant_c calle_defendant_c num_defendant_c col_defendant_c mun_defendant_c cp_defendant{
	gen `var'_=!missing(`var')
	drop `var'
	rename `var'_ `var'_clv
	}
	
duplicates drop	
tempfile temp_rubro_proemio	
save `temp_rubro_proemio'
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Prestaciones
import excel "$directorio\Raw\dem_lab.xls", sheet("prestaciones") firstrow clear

*Code non-missing values	 
foreach	var of varlist  indem_const_c reinstalacion_c ad_cautelam sal_caidos_c ///
		incrementos_sal_c sal_devengados_c dias20_c antiguedad_c vacaciones_c ///
		prima_vac_c aguinaldo_c nulidad imss ptu declaracion_junta {
	gen `var'_=!missing(`var')
	drop `var'
	rename `var'_ `var'_clv
	}

duplicates drop	
tempfile temp_prestaciones
save `temp_prestaciones'
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Hechos
import excel "$directorio\Raw\dem_lab.xls", sheet("hechos") firstrow clear

*Code non-missing values	 
foreach	var of varlist fecha_contratacion_c giro_c contrato_c categoria_c ///
		lugar_trabajo_c horario_inicio_jornada_c horario_fin_jornada_c ///
		especifican_dias_c salario_base_c periodo_salario_c salario_int ///
		periodo_sal_int fecha_despido_c hora_despido lugar_despido_c ///
		motivo_despido_c nombre_despide_c cargo_despide narracion_despide_c  {
	gen `var'_=!missing(`var')
	drop `var'
	rename `var'_ `var'_clv
	}

duplicates drop	
tempfile temp_hechos
save `temp_hechos'
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Petitorios
import excel "$directorio\Raw\dem_lab.xls", sheet("petitorios_final") firstrow clear

*Code non-missing values	 
foreach	var of varlist admitir_escrito_c presentado_tiempo_forma_c personalidad_c firma_trabajador_c  {
	gen `var'_=!missing(`var')
	drop `var'
	rename `var'_ `var'_clv
	}

duplicates drop	
tempfile temp_petitorios_final
save `temp_petitorios_final'
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Subjetiva
import excel "$directorio\Raw\dem_lab.xls", sheet("sub_score") firstrow clear

egen calificacion_sub=rowtotal(c_* sub_extras)

duplicates drop	demanda, force
tempfile temp_subjective
save `temp_subjective'
*-------------------------------------------------------------------------------


use `temp_rubro_proemio', clear	 
merge 1:1  demanda	using `temp_prestaciones', nogen
merge 1:1  demanda	using `temp_hechos', nogen
merge 1:1  demanda	using `temp_petitorios_final', nogen
merge 1:m  demanda  using `temp_subjective', nogen
	 
egen calificacion_obj=rowtotal(c_*)

******

split demanda, parse(-)
destring demanda1, gen(junta) ignore("J")
destring demanda2, gen(exp) 
destring demanda3, gen(anio) 
drop demanda*


*String coding
foreach var of varlist *_clv {
	qui su `var'
	if `r(N)'==0 {
		gen `var'_=!missing(`var')
		drop `var'
		rename `var'_ `var'
		}
	}	

	

merge 1:m junta exp anio using  "$directorio\DB\lawyer_dataset.dta", nogen keep(1 3)

