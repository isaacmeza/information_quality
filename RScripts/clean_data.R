setwd('C:/Users/xps-seira/Dropbox/Apps/ShareLaTeX/pilot3/Pilot_3/RScripts')

source('setup-toolbox.R', encoding = 'utf8')
source('varnames_codebook.R')
source('selected_vars.R')
source('ingest.R')

# Variables privadas para anonimizar datos
private_vars = c('compania_cel', 'companiia_cel', 'companiia_celular', 
                 'comentarios_contacto', 'valido', 'telefono_celular_para_recarga',                                                     
                 'companiia_celular_para_recarga')

source('clean_treatment_data.R')
source('clean_survey_data_.R')
