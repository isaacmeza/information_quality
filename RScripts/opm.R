library(readstata13)

aux_dummy = function(x){
  ifelse(x == 1, 0, 
          ifelse(x == 2, 1, NA))
}


td = read.csv('../DB/treatment_data.csv')

corte_exp = function(x_cont, corte, x_cat){
  num = as.numeric(x_cont)
  aux = if_else(num >  corte, 1, 0)
  cat = as.numeric(x_cat)
  ifelse(!is.na(aux), 
         aux,
         ifelse(!is.na(cat), cat, NA))
}



emp = read.dta13('../Raw/encuesta_empresa.dta') %>%
      select(id_actor = q_a,
             estatus_encuesta = q_d,
             nivel_de_felicidad = q_1,
             conflicto_arreglado = q_2,
             #entablo_demanda = q2a_i,
             monto_del_convenio = q2a_ii,
             fecha_arreglo = q2a_iii,
             se_registro_el_acuerdo_ante_la_junta = q2a_iv,
             demando_con_abogado_publico = q_3b,
             tramito_citatorio = q_3b_ii,
             prob_ganar_2m = q3h,
             prob_mayor_2m = q3h_i,
             cantidad_ganar_2m = q3i,
             cant_mayor_2m = q3i_i,
             enojo_con_la_empresa = q3g,
             busca_trabajo = q7b,
             ultimos_3_meses_ha_dejado_de_pagar_servicio_basico = q4,
             ultimos_3_meses_le_ha_faltado_dinero_para_comida = q5,
             ultimo_mes_alguien_del_hogar_a_comprado_casa_o_terreno_o_vehiculo = q6_O1,
             ultimo_mes_alguien_del_hogar_a_comprado_electrodomestico_o_dispositivo_electronico = q6_O2,
             tiempo_arreglar_asunto = q8,
             tiempo_trayecto_h = Q9hh, 
             tiempo_trayecto_m = Q9mm) %>%
  mutate_at(vars(conflicto_arreglado, #entablo_demanda, 
                 se_registro_el_acuerdo_ante_la_junta, 
                 demando_con_abogado_publico, 
                 tramito_citatorio, 
                 busca_trabajo,
                 ultimos_3_meses_ha_dejado_de_pagar_servicio_basico, 
                 ultimos_3_meses_le_ha_faltado_dinero_para_comida,
                 ultimo_mes_alguien_del_hogar_a_comprado_casa_o_terreno_o_vehiculo,
                 ultimo_mes_alguien_del_hogar_a_comprado_electrodomestico_o_dispositivo_electronico), aux_dummy) %>%
  left_join(td) %>%
  mutate(sabemos_cantidad = !is.na(monto_del_convenio)*conflicto_arreglado,
         sabemos_fecha_arreglo = !is.na(fecha_arreglo)*conflicto_arreglado,
         tiempo_arreglo = as.numeric(fecha_arreglo - as.Date(fecha_alta)),
         prob_ganar_2m = if_else(prob_ganar_2m > 1, prob_ganar_2m/100, prob_ganar_2m),
         dias_sal = cantidad_ganar_2m/salario_diario,
         mas_6m_aux = corte_exp(dias_sal, 180, cant_mayor_2m),
         mas_75_aux = corte_exp(prob_ganar_2m, .75, prob_mayor_2m),
         prob_num = !is.na(prob_ganar_2m),
         prob_coarse = !is.na(mas_75_aux),
         cantidad_num = !is.na(cantidad_ganar_2m),
         cantidad_coarse = !is.na(mas_6m_aux),
         update_prob = (prob_ganar_2m - prob_ganar)/prob_ganar,
         update_comp = (cantidad_ganar_2m - cantidad_ganar)/cantidad_ganar,
         switched_prob = prob_mayor > mas_75_aux,
         switched_comp = cant_mayor > mas_6m_aux) %>% 
  select(-prob_mayor, -cant_mayor, -prob_ganar, -cantidad_ganar) %>%
  rename(prob_ganar = prob_ganar_2m,
         cantidad_ganar = cantidad_ganar_2m,
         prob_mayor = mas_75_aux,
         cant_mayor = mas_6m_aux) %>%
  select(one_of(vars_2m)) %>%
  mutate_at(vars(-starts_with('fecha')), as.numeric) %>%
  summarize_survey('_opm')


s_2m = read.csv('../DB/survey_2m.csv') %>%
  mutate_at(vars(-starts_with('fecha')), as.numeric) %>%
  select(one_of(vars_2m)) %>%
  summarize_survey('_2m') 

data = left_join(s_2m, emp) %>%
  mutate(var = recode_var(var))

stargazer(data, out = '../Tables/opm_vs_mjl.tex',
          summary = F, float = F, rownames = F)
