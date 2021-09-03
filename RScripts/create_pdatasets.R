covariates = readRDS('../DB/treatment_data.RDS') %>%
  select(id_actor, genero, antiguedad, salario_diario, fecha_alta, starts_with('grupo_tratamiento'))


df_2m = readRDS('../DB/survey_data_2m.RDS') %>%
  filter(!is.na(id_actor)) %>%
  select(-status_encuesta, -especifique, -especifique2, -especifique_cobro, -ultimo_mes_base) %>%
  left_join(covariates) %>%
  mutate(cantidad_ganar_survey = cantidad_ganar_survey/1000)

df_2m_main = df_2m %>%
  filter(!is.na(grupo_tratamiento_main)) %>%
  mutate(grupo_tratamiento_main = as.factor(grupo_tratamiento_main)) %>%
  pdata.frame(., index = c('fecha_alta', 'id_actor'), drop.index = F)

df_2m_ab = df_2m %>%
  filter(!is.na(grupo_tratamiento_ab)) %>%
  mutate(grupo_tratamiento_ab = as.factor(grupo_tratamiento_ab)) %>%
  pdata.frame(., index = c('fecha_alta', 'id_actor'), drop.index = F)


df_2w = readRDS('../DB/survey_data_2w.RDS') %>%
  filter(!is.na(id_actor)) %>%
  left_join(covariates) %>%
  mutate(cantidad_ganar_survey = cantidad_ganar_survey/1000)

df_2w_main = df_2w %>%
  filter(!is.na(grupo_tratamiento_main)) %>%
  mutate(grupo_tratamiento_main = as.factor(grupo_tratamiento_main)) %>%
  pdata.frame(., index = c('fecha_alta', 'id_actor'), drop.index = F)

df_2w_ab = df_2w %>%
  filter(!is.na(grupo_tratamiento_ab)) %>%
  mutate(grupo_tratamiento_ab = as.factor(grupo_tratamiento_ab)) %>%
  pdata.frame(., index = c('fecha_alta', 'id_actor'), drop.index = F)

sued_2m = df_2m_main %>% 
  filter(entablo_demanda == 1) %>%
  pdata.frame(., index = c('fecha_alta', 'id_actor'), drop.index = F)

sued_2m_ab = df_2m_ab %>% 
  filter(entablo_demanda == 1) %>%
  pdata.frame(., index = c('fecha_alta', 'id_actor'), drop.index = F)

save(df_2m_main, df_2m_ab, df_2w_main, df_2w_ab, sued_2m, sued_2m_ab, file = 'pdatasets.RData')
