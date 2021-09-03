library(dplyr)
library(ggplot2)
library(tidyr)

mu_y_range = seq(0.2, 0.7, 0.1)

namecol_df = function(df, nm){
  df %>%
    mutate(mu_fs = nm,
           n = seq(100, 3000, 100))
}

# Load all simulation matrices, set mu_FS values as names

sims = dir('../Simulations', pattern = 'pwr.*.csv', full.names = T) %>%
setNames(., paste0('mu_fs_', mu_y_range)) %>%
lapply(read.csv, header = F) %>%
lapply(setNames, nm = paste0('mu_att_', seq(0, .95, .05)))

sims_mutated = lapply(seq_along(sims), function(i){namecol_df(sims[[i]], mu_y_range[i])}) 


# Gather data the right way
data = bind_rows(sims_mutated[[1]], sims_mutated[[2]]) %>%
      gather(mu_att, power, -mu_fs, -n) %>%
      mutate(mu_att = as.numeric(gsub('mu_att_', '', mu_att)))
  
rm(sims, sims_mutated)


# Create simulation plots

ggplot(data, aes(n, mu_att)) +
  geom_raster(aes(fill = power), hjust = 0.5, vjust = 0.5) +
  labs(x = 'N', y = expression(mu[ATT]), title = 'Power simulations: baseline', subtitle =  expression(mu[FS])) +
  scale_fill_gradient(name = 'Power \n', high = "#132B43", low = "#56B1F7") +
  facet_grid(.~mu_fs) +
  theme_classic()

ggsave('../Figuras/power_simulations_mosaic.tiff')