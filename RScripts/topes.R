inpc = read.csv('../Raw/inpc.csv')
  

p01 = function(x){quantile(x, .01, type = 4, na.rm = T)}
p99 = function(x){quantile(x, .99, type = 4, na.rm = T)}
nobs = function(x){sum(!is.na(x))}

present = inpc$inpc[inpc$anio == 2017 & inpc$mes == 07]

def = df %>%
  filter(modo_termino == 3, liq_total > 0) %>% 
  mutate(giro_short = str_sub(giro_empresa, 1, 1),
         anio = as.numeric(as.character(anio)),
         mes = lubridate::month(fecha_termino)) %>%
  left_join(inpc) %>% 
  filter(!is.na(giro_short)) %>%
  mutate(liq_total_def = liq_total_tope*(present/inpc),
         giro_short = if_else(giro_short == '8', '3', giro_short)) %>%
  group_by(giro_short) %>% 
  summarize_at(vars(liq_total_def), funs(p01, p99, nobs))

