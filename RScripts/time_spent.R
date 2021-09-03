medias = c(1, 3.5, 7.5, 12.5, 17.5, 25, 35)

surveys_2m %>% 
  mutate(tiempo_arreglar_asunto = medias[tiempo_arreglar_asunto],
         demando_no_arreglado = if_else((!conflicto_arreglado)*entablo_demanda == 1, 1, 
                                        if_else(conflicto_arreglado*(!entablo_demanda) == 1, 0, 
                                                if_else(conflicto_arreglado*entablo_demanda == 1, 2, 3)))) %>%
  group_by(demando_no_arreglado) %>%
  summarise(x = mean(tiempo_arreglar_asunto, na.rm = T))