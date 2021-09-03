source('clean_data.R')


drop = c('fecha_alta', 'grupo_tratamiento', 'giro',  'sueldo', 'sueldo_per', 
  'id_main', 'id_actor', 'email', 'telefono_cel', 'compania_cel', 'comentarios', 
  'reclutamiento', 'categoria', 'dummy_confianza', 'fecha_entrada', 'id_domicilio', 
  'prob_ganar_act', 'cantidad_ganar_act', 'confirmo_cita', 'genero',
  'c_salario_per', 'c_jornada', 'prob_ganar_no_sabe', 'cantidad_ganar_no_sabe', 
  'prob_ganar_act_no_sabe', 'cantidad_ganar_act_no_sabe', 'tomo_Uber', 
  'c_min_indem', 'c_min_prima_antig', 'c_min_ag', 'c_salario',
  'c_min_vac', 'c_min_prima_vac', 'capturista', 'nombre_actor', 'nivel_enojo',
  'tratamiento_voluntario', 'c_categoria', 'c_fecha_entrada', 'telefono_fijo',
  'cita_fecha', 'cita_hora', 'conciliador', 'fecha_salida', 'nivel_educativo',
  'id_convenio', 'convenio_previo_cita', 'tipo_jornada', 'dias_sal_dev',
  'cantidad_convenio_previo_cita', 'observaciones_main', 'dummy_convenio')


# Read data
balance = read.csv('../DB/treatment_data.csv') %>%
  mutate(fecha_alta = ymd(fecha_alta),
         mujer = ifelse(tolower(genero) == 'mujer', 1, 0),
         after = fecha_alta > '2017-09-19',
         prob_num = !is.na(prob_ganar),
         prob_coarse = !is.na(prob_mayor),
         cantidad_num = !is.na(cantidad_ganar),
         cantidad_coarse = !is.na(cant_mayor),
         top_demandado = if_else(top_demandado == '' | top_demandado == 'NINGUNO', 0, 1),
         jornada_diurna = tipo_jornada == 'Diurno',
         mas_secundaria = nivel_educativo > 2,
         muy_enojado = nivel_enojo < 2) %>%
  filter(!is.na(id_actor), id_actor > 16) %>%
  select(-one_of(drop)) %>%
  mutate_all(as.numeric) %>%
  gather(var, valor, -after) %>% 
  group_by(var) %>%
  do(tidy(t.test(valor ~ after, data = .))) %>%
  select(var, estimate1, estimate2, p.value) %>%
  setNames(nm = c('Variable', 'Before', 'After', 'P-value')) %>%
  ungroup() %>%
  mutate(Variable = recode(Variable, 'antigüedad' = 'antiguedad'),
          Variable = recode_var(Variable)) %>%
  mutate_at(vars(-Variable), format_strings) 
          
  

stargazer(balance, out = '../Tables/balance_19s.tex', 
          header = F, summary = F, digits = 2, 
          rownames = F, float = F)


# Gráfica de distribuciones de giro 
