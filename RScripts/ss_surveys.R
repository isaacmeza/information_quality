
source('clean_data.R')

# Read data
base_2s = read.csv('../DB/survey_2w.csv')
base_2m = read.csv('../DB/survey_2m.csv')

treatment_data = read.csv('../DB/treatment_data.csv') %>% 
  mutate(fecha_alta = ymd(fecha_alta),
         mujer = ifelse(tolower(genero) == 'mujer', 1, 0))



success_base = data.frame(var = 'exitoso', mean_base = '100', n_base = nrow(treatment_data))


# Stats de baseline survey 
base = treatment_data %>%
  transmute_at(vars(one_of(vars_t)), as.numeric) %>%
  mutate_at(vars(-one_of(vars_t_nofix)), arregla_na) %>% 
  summarise_all(funs(mean, aux_n), na.rm = T) %>%
  gather(var, stat) %>%
  mutate(mean = grepl('_mean', var),
         var = aux_varname(var)) %>%
  spread(mean, stat) %>%
  rename('n_base' = 'FALSE', 'mean_base' = 'TRUE') %>%
  mutate(mean_base = format_strings(mean_base))


# Stats de 2 semanas
success_2w = mutate(base_2s, exitoso = as.numeric(status_encuesta == 1)) %>% 
  summarise_at(vars(exitoso), mean, na.rm = T) %>%
  gather(var, mean_2w) %>%
  mutate(n_2w = nrow(base_2s),
         mean_2w = format_strings(mean_2w))


s_2w = base_2s %>%
  filter(status_encuesta == 1) %>%
  select(one_of(vars_2s)) %>%
  summarize_survey('_2w')


# Stats de 2m

success_2m = mutate(base_2m, exitoso = as.numeric(status_encuesta == 1)) %>% 
  summarise_at(vars(exitoso), mean, na.rm = T) %>%
  gather(var, mean_2m) %>%
  mutate(n_2m = nrow(base_2m),
         mean_2m = format_strings(mean_2m))


s_2m = base_2m %>%
  filter(status_encuesta == 1) %>%
  select(one_of(vars_2m)) %>%
  summarize_survey('_2m')


cols_base = bind_rows(success_base, base) 
cols_2w = bind_rows(success_2w, s_2w)
cols_2m = bind_rows(success_2m, s_2m)

data = full_join(cols_base, cols_2w) %>% full_join(cols_2m) %>%
        mutate(var = recode_var(var))


names(data) = c('Variable', rep(c('Mean', 'N'), 3))


stargazer(data, out = '../Tables/ss_surveys.tex',
          summary = F, float = F, rownames = F)
