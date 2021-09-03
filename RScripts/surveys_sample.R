source('setup-toolbox.R')
source('selected_vars.R')

# Read data
base_2s = read.csv('../DB/survey_2w.csv')
base_2m = read.csv('../DB/survey_2m.csv')

treatment_data = read.csv('../DB/treatment_data.csv') %>%
  mutate(fecha_alta = ymd(fecha_alta),
         mujer = ifelse(tolower(genero) == 'mujer', 1, 0))



# Stats de baseline survey 
base = treatment_data %>%
  mutate(prob_num = !is.na(prob_ganar),
         prob_coarse = !is.na(prob_mayor),
         cantidad_num = !is.na(cantidad_ganar),
         cantidad_coarse = !is.na(cant_mayor)) %>%
  transmute_at(vars(one_of(vars_t), id_actor), as.numeric) %>%
  mutate_at(vars(-one_of(vars_t_nofix)), arregla_na) 


s_2w = base_2s %>%
  setNames(., nm = paste0(names(.), '_2w')) %>%
  setNames(., nm = gsub('id_actor_2w', 'id_actor', names(.)))


s_2m = base_2m %>%
  setNames(., nm = paste0(names(.), '_2m')) %>%
  setNames(., nm = gsub('id_actor_2m', 'id_actor', names(.)))


data = base %>%
        filter(!is.na(id_actor)) %>%
        left_join(s_2w) %>%
        left_join(s_2m)


write.csv(data, '../DB/survey_sample.csv', na = '', row.names = F)
