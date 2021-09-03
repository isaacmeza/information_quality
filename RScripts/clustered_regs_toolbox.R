clustered_se = function(model, p_data, cluster_var = 'fecha_alta', varlist){
  
  G = length(unique(p_data[[cluster_var]]))
  N = length(p_data[[cluster_var]])
  dfa = (G/(G - 1)) * (N - 1)/model[['df.residual']]
  
  vcov_clust = dfa * vcovHC(model, type = 'HC0', cluster = 'group', adjust = T)
  
  se = sqrt(diag(vcov_clust))
  return(se[varlist])
}


plm_reg = function(p_data, dep_var, rename_dep_var = F, new_name = NULL, treatment_var, controls = NULL){
  
  pdata = p_data
  
  if(rename_dep_var){
    pdata = pdata %>%
            select_(paste0('-', new_name)) %>%
            rename_(.dots = setNames(dep_var, new_name))
    
    y = new_name
  } else{
    y = dep_var 
  }
  
  text_formula = paste0(y, '~', treatment_var)
  
  if(!is.null(controls)){
    text_formula = paste0(text_formula, '+', paste(controls, collapse = ' + '))
  }
    
  model = plm(formula = as.formula(text_formula), data = p_data, model = 'pooling')
  
  return(model)
}


plm_clustered = function(data, dep_var, treatment_var, ...){
  
  if(treatment_var == 'grupo_tratamiento_main'){
    varlist = c('(Intercept)', 'grupo_tratamiento_main2', 'grupo_tratamiento_main3')
  } else {
    varlist = c('(Intercept)', 'grupo_tratamiento_abB')
  }
  
  model = plm_reg(p_data = data, dep_var = dep_var, treatment_var = treatment_var, ...)
  se = clustered_se(model = model, p_data = data, varlist = varlist)
  n_obs = model$model %>% 
          count_(treatment_var) %>% 
          select(n) %>% 
          unlist() %>% 
          paste(., collapse = '-')
  num_clusters = data %>% 
                  mutate(clust = index(data)[['fecha_alta']]) %>%
                  group_by_(treatment_var, 'clust') %>%
                  summarise(n = 1) %>% 
                  ungroup() %>%
                  group_by_(treatment_var) %>%
                  summarise(nclust = sum(n)) %>%
                  select(nclust) %>%
                  unlist() %>%
                  paste(., collapse = '-')
  
  lista = list('modelo' = model,
               'se' = se,
               'n' = n_obs,
               'n_clust' = num_clusters)
  
  return(lista)
}
