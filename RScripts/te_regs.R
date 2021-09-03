
###############################

# Treatment effect regressions

##############################


df = readRDS('../DB/survey_data.RDS') %>%
  mutate(grupo_tratamiento_main = gsub('[A-Z]', '', grupo_tratamiento),
         grupo_tratamiento_ab = gsub('[0-9]', '', grupo_tratamiento)) %>%
  mutate_at(vars(starts_with('grupo_tratamiento_')), function(x) ifelse(x == '', NA, x)) %>%
  mutate_at(vars(starts_with('grupo_tratamiento_')), as.factor)

covariates = read.csv('../DB/treatment_data.csv') %>%
  select(id_actor, genero, salario_diario, antiguedad, fecha_alta)

df_main = df %>% 
          left_join(covariates)
  

robust_se = function(obj, varlist){
  se = sqrt(diag(vcovHC(obj, type = "HC1")))
  se[varlist]
}


###############################

# Expectations

##############################

# Expected compensation

df_main %>%
  lm(cantidad_ganar ~ grupo_tratamiento_main, data = .) -> ma1
  
df_main %>%
  lm(cantidad_ganar ~ grupo_tratamiento_main + genero + antiguedad + salario_diario, data = .) -> ma1_con



# Compensation: higher than mean

df_main %>%
  lm(cant_mayor ~ grupo_tratamiento_main, data = .) -> ma2

df_main %>%
  lm(cant_mayor ~ grupo_tratamiento_main + genero + antiguedad + salario_diario, data = .) -> ma2_con



# Expected probability

df_main %>%
  lm(prob_ganar ~ grupo_tratamiento_main, data = .) -> ma3

df_main %>%
  lm(prob_ganar ~ grupo_tratamiento_main + genero + antiguedad + salario_diario, data = .) -> ma3_con



# Probability: higher than mean

df_main %>%
  lm(prob_mayor ~ grupo_tratamiento_main, data = .) -> ma4

df_main %>%
  lm(prob_mayor ~ grupo_tratamiento_main + genero + antiguedad + salario_diario, data = .) -> ma4_con



model_se_a = list(ma1, ma1_con, ma2, ma2_con, ma3, ma3_con, ma4, ma4_con) %>%
  lapply(robust_se, varlist = c('(Intercept)', 'grupo_tratamiento_main2', 'grupo_tratamiento_main3'))


stargazer(list(ma1, ma1_con, ma2, ma2_con, ma3, ma3_con, ma4, ma4_con),
          out = '../Tables/te_A.tex',
          keep = c('Constant', 'grupo_tratamiento_main'),
          covariate.labels = c('Treatment 1', 'Treatment 2', 'Treatment 3'),
          column.labels = c('Expected compensation', 'More than 180', 'Expected probability', 'More than 75%'),
          column.separate = rep(2, 4),
          intercept.bottom = F,
          digits = 2,
          float = F,
          se = model_se_a,
          add.lines = list(c('Basic Variable Controls', rep(c('NO', 'YES'), 4))))



###############################

# Knowledge

##############################


df_main %>%
  lm(cantidad_coarse ~ grupo_tratamiento_main, data = .) -> mb1

df_main %>%
  lm(cantidad_coarse ~ grupo_tratamiento_main + genero + antiguedad + salario_diario, data = .) -> mb1_con



df_main %>%
  lm(prob_coarse ~ grupo_tratamiento_main, data = .) -> mb2

df_main %>%
  lm(prob_coarse ~ grupo_tratamiento_main + genero + antiguedad + salario_diario, data = .) -> mb2_con



df_main %>%
  lm(cantidad_num ~ grupo_tratamiento_main, data = .) -> mb3

df_main %>%
  lm(cantidad_num ~ grupo_tratamiento_main + genero + antiguedad + salario_diario, data = .) -> mb3_con



df_main %>%
  lm(prob_num ~ grupo_tratamiento_main, data = .) -> mb4

df_main %>%
  lm(prob_num ~ grupo_tratamiento_main + genero + antiguedad + salario_diario, data = .) -> mb4_con



model_se_b = list(mb1, mb1_con, mb2, mb2_con, mb3, mb3_con, mb4, mb4_con) %>%
  lapply(robust_se, varlist = c('(Intercept)', 'grupo_tratamiento_main2', 'grupo_tratamiento_main3'))


stargazer(list(mb1, mb1_con, mb2, mb2_con, mb3, mb3_con, mb4, mb4_con),
          out = '../Tables/te_B.tex',
          keep = c('Constant', 'grupo_tratamiento'),
          covariate.labels = c('Treatment 1', 'Treatment 2', 'Treatment 3'),
          column.labels = c('Amount Number', 'Coarse Amount', 'Probability number', 'Coarse probability'),
          column.separate = rep(2, 4),
          intercept.bottom = F,
          digits = 2,
          float = F,
          se = model_se_b,
          add.lines = list(c('Basic Variable Controls', rep(c('NO', 'YES'), 4))))




###############################

# Case outcomes: Main treatment

##############################


randomization = read.csv('../Raw/randomization_arm2.csv') %>%
  select(-X, -tratamiento, - voluntario) %>%
  rename(fecha_alta = fechas,
         grupo_ab = grupo)

df_ab = df %>%
      left_join(covariates) %>%
      left_join(randomization)


# Solved conflict

df_ab %>%
  lm(conflicto_arreglado ~ grupo_tratamiento_main, data = .) -> mc1

df_ab %>%
  lm(conflicto_arreglado ~ grupo_tratamiento_main + genero + antiguedad + salario_diario, data = .) -> mc1_con


# Sued

df_ab %>%
  lm(entablo_demanda ~ grupo_tratamiento_main, data = .) -> mc2

df_ab %>%
  lm(entablo_demanda ~ grupo_tratamiento_main + genero + antiguedad + salario_diario, data = .) -> mc2_con


# Got letter of appointment

df_ab %>%
  lm(tramito_citatorio ~ grupo_tratamiento_main, data = .) -> mc3

df_ab %>%
  lm(tramito_citatorio ~ grupo_tratamiento_main + genero + antiguedad + salario_diario, data = .) -> mc3_con


# Talked to public lawyer

df_ab %>%
  lm(ha_hablado_con_abogado_publico ~ grupo_tratamiento_main, data = .) -> mc4

df_ab %>%
  lm(ha_hablado_con_abogado_publico ~ grupo_tratamiento_main + genero + antiguedad + salario_diario, data = .) -> mc4_con



# Sued w. Public Lawyer

df_ab %>%
  filter(entablo_demanda == 1) %>%
  lm(demando_con_abogado_publico ~ grupo_tratamiento_main, data = .) -> mc5

df_ab %>%
  filter(entablo_demanda == 1) %>%
  lm(demando_con_abogado_publico ~ grupo_tratamiento_main + genero + antiguedad + salario_diario, data = .) -> mc5_con


model_se_c = list(mc1, mc1_con, mc2, mc2_con, mc3, mc3_con, mc4, mc4_con, mc5, mc5_con) %>%
  lapply(robust_se, varlist = c('(Intercept)', 'grupo_tratamiento_main2', 'grupo_tratamiento_main3'))


stargazer(list(mc1, mc1_con, mc2, mc2_con, mc3, mc3_con, mc4, mc4_con, mc5, mc5_con),
          out = '../Tables/te_C.tex',
          keep = c('Constant', 'grupo_tratamiento'),
          covariate.labels = c('Treatment 1', 'Treatment 2', 'Treatment 3'),
          column.labels = c('Solved conflict', 'Sued', 'Got letter', 'Talked to public', 'Sued w. Public'),
          column.separate = rep(2, 5),
          intercept.bottom = F,
          digits = 2,
          float = F,
          se = model_se_c,
          add.lines = list(c('Basic Variable Controls', rep(c('NO', 'YES'), 5))))



###############################

# Case outcomes: A vs. B

##############################




# Solved conflict

df_ab %>%
  lm(conflicto_arreglado ~ grupo_tratamiento_ab, data = .) -> md1

df_ab %>%
  lm(conflicto_arreglado ~ grupo_tratamiento_ab + genero + antiguedad + salario_diario, data = .) -> md1_con


# Sued

df_ab %>%
  lm(entablo_demanda ~ grupo_tratamiento_ab, data = .) -> md2

df_ab %>%
  lm(entablo_demanda ~ grupo_tratamiento_ab + genero + antiguedad + salario_diario, data = .) -> md2_con


# Got letter of appointment

df_ab %>%
  lm(tramito_citatorio ~ grupo_tratamiento_ab, data = .) -> md3

df_ab %>%
  lm(tramito_citatorio ~ grupo_tratamiento_ab + genero + antiguedad + salario_diario, data = .) -> md3_con


# Talked to public lawyer

df_ab %>%
  lm(ha_hablado_con_abogado_publico ~ grupo_tratamiento_ab, data = .) -> md4

df_ab %>%
  lm(ha_hablado_con_abogado_publico ~ grupo_tratamiento_ab + genero + antiguedad + salario_diario, data = .) -> md4_con



# Sued w. Public Lawyer

df_ab %>%
  filter(entablo_demanda == 1) %>%
  lm(demando_con_abogado_publico ~ grupo_tratamiento_ab, data = .) -> md5

df_ab %>%
  filter(entablo_demanda == 1) %>%
  lm(demando_con_abogado_publico ~ grupo_tratamiento_ab + genero + antiguedad + salario_diario, data = .) -> md5_con


model_se_d = list(md1, md1_con, md2, md2_con, md3, md3_con, md4, md4_con, md5, md5_con) %>%
  lapply(robust_se, varlist = c('(Intercept)', 'grupo_tratamiento_main2', 'grupo_tratamiento_main3'))


stargazer(list(md1, md1_con, md2, md2_con, md3, md3_con, md4, md4_con, md5, md5_con),
          out = '../Tables/te_D.tex',
          keep = c('Constant', 'grupo_tratamiento'),
          covariate.labels = c('Treatment 1', 'Treatment 2', 'Treatment 3'),
          column.labels = c('Solved conflict', 'Sued', 'Got letter', 'Talked to public', 'Sued w. Public'),
          column.separate = rep(2, 5),
          intercept.bottom = F,
          digits = 2,
          float = F,
          se = model_se_d,
          add.lines = list(c('Basic Variable Controls', rep(c('NO', 'YES'), 5))))



# 14. all the variable for updating of expectations, both probability and amount.


###############################

# Updating

##############################


df_main %>%
  lm(update_comp ~ grupo_tratamiento_main, data = .) -> me1

df_main %>%
  lm(update_comp ~ grupo_tratamiento_main + genero + antiguedad + salario_diario, data = .) -> me1_con


df_main %>%
  lm(switched_comp ~ grupo_tratamiento_main, data = .) -> me2

df_main %>%
  lm(switched_comp ~ grupo_tratamiento_main + genero + antiguedad + salario_diario, data = .) -> me2_con


df_main %>%
  lm(update_prob ~ grupo_tratamiento_main, data = .) -> me3

df_main %>%
  lm(update_prob ~ grupo_tratamiento_main + genero + antiguedad + salario_diario, data = .) -> me3_con



df_main %>%
  lm(switched_prob ~ grupo_tratamiento_main, data = .) -> me4

df_main %>%
  lm(switched_prob ~ grupo_tratamiento_main + genero + antiguedad + salario_diario, data = .) -> me4_con



model_se_e = list(me1, me1_con, me2, me2_con, me3, me3_con, me4, me4_con) %>%
  lapply(robust_se, varlist = c('(Intercept)', 'grupo_tratamiento_main2', 'grupo_tratamiento_main3'))


stargazer(list(me1, me1_con, me2, me2_con, me3, me3_con, me4, me4_con),
          out = '../Tables/te_B.tex',
          keep = c('Constant', 'grupo_tratamiento'),
          covariate.labels = c('Treatment 1', 'Treatment 2', 'Treatment 3'),
          column.labels = c('Amount updating', 'Switched amount', 'Probability updating', 'Switched probability'),
          column.separate = rep(2, 4),
          intercept.bottom = F,
          digits = 2,
          float = F,
          se = model_se_e,
          add.lines = list(c('Basic Variable Controls', rep(c('NO', 'YES'), 4))))

