source('surveys_sample.R')

# Plot initial expectations

data %>%
  select(starts_with('prob_ganar')) %>%
  mutate(prob_ganar_2w = prob_ganar_2w*100) %>%
  mutate_all(as.numeric) %>%
  mutate_all(function(x) if_else(x>1, x/100, x)) %>%
  gather(var, value) %>%
  ggplot() +
  geom_density(aes(value, y = ..scaled.., color = var), size = 1.2) +
  scale_color_manual(values = c('steelblue4', 'tomato4', 'cornsilk3'), 
                     name = 'Variable',
                     breaks = c('prob_ganar', 'prob_ganar_2w', 'prob_ganar_2m'),
                     labels = c('Baseline', '2 Weeks', '2 Months')) +
  labs(x = '', y = '') +
  scale_y_continuous(labels = scales::percent) +
  theme_classic()

ggsave('../Figuras/prob_ganar_comparison.tiff')


data %>%
  select(starts_with('cantidad_ganar')) %>%
  mutate_all(as.numeric) %>%
  gather(var, value) %>%
  ggplot() +
  geom_density(aes(value, y = ..scaled.., color = var), size = 1.2) +
  scale_color_manual(values = c('steelblue4', 'tomato4', 'cornsilk3'), 
                     name = 'Variable',
                     breaks = c('cantidad_ganar', 'cantidad_ganar_2w', 'cantidad_ganar_2m'),
                     labels = c('Baseline', '2 Weeks', '2 Months')) +
  labs(x = '', y = '') +
  scale_y_continuous(labels = scales::percent) +
  theme_classic()


ggsave('../Figuras/cantidad_ganar_comparison.tiff')

facetlabs <- c(
  `prob_ganar` = "Baseline",
  `prob_ganar_2w` = "Two Weeks",
  `prob_ganar_2m` = "Two Months",
  `cantidad_ganar` = "Baseline",
  `cantidad_ganar_2w` = "Two Weeks",
  `cantidad_ganar_2m` = "Two Months",
  `update_2w` = "Two Weeks",
  `update_2m` = "Two Months"
)


data %>%
  select(starts_with('prob_ganar')) %>%
  mutate(prob_ganar_2w = prob_ganar_2w*100) %>%
  mutate_all(as.numeric) %>%
  mutate_all(function(x) if_else(x>1, x/100, x)) %>%
  gather(var, value) %>%
  ggplot() +
  geom_histogram(aes(value)) +
  facet_grid(.~ var, labeller = as_labeller(facetlabs), scales = 'free') +
  labs(x = '', y = '') +
  theme_gdocs()


ggsave('../Figuras/prob_ganar_histograms.tiff')

aux = function(x){
  as.numeric(x)/1000
}

data %>%
  select(starts_with('cantidad_ganar')) %>% 
  mutate_all(as.numeric) %>% 
  mutate_all(aux) %>%
  gather(var, value) %>%
  ggplot() +
  geom_histogram(aes(value)) +
  facet_grid(.~ var, labeller = as_labeller(facetlabs)) +
  labs(x = '', y = '') +
  theme_gdocs()


ggsave('../Figuras/cantidad_ganar_histograms.tiff')

aux_prob = function(x){if_else(x>1, x/100, x)}

data %>%
  mutate_all(as.numeric) %>% 
  select(starts_with('prob')) %>%
  mutate_all(aux_prob) %>%
  # filter(prob_ganar >= 0,
  #        prob_ganar_2w >= 0,
  #        prob_ganar_2m >= 0) %>%
  mutate(prob_ganar_2w = prob_ganar_2w*100) %>%
  transmute(update_2w = (prob_ganar_2w - prob_ganar)/prob_ganar,
         update_2m = (prob_ganar_2m - prob_ganar)/prob_ganar) %>% 
  gather(var, value) %>%
  ggplot() +
  geom_histogram(aes(value)) +
  facet_grid(.~ var, labeller = as_labeller(facetlabs), scales = 'free') +
  labs(x = '', y = '') +
  theme_gdocs()

ggsave('../Figuras/prob_relupdate_histograms.tiff')


data %>%
  mutate_all(as.numeric) %>% 
  select(starts_with('cantidad_ganar')) %>%
  mutate_all(aux_prob) %>%
  transmute(update_2w = (cantidad_ganar_2w - cantidad_ganar)/cantidad_ganar,
            update_2m = (cantidad_ganar_2m - cantidad_ganar)/cantidad_ganar) %>% 
  gather(var, value) %>% 
  ggplot() +
  geom_histogram(aes(value)) +
  facet_grid(.~ var, labeller = as_labeller(facetlabs), scales = 'free') +
  labs(x = '', y = '') +
  theme_gdocs()

ggsave('../Figuras/cant_relupdate_histograms.tiff')


data %>% select(starts_with('prob_ganar'), starts_with('cantidad_ganar')) %>%
  mutate(prob_ganar_2w = prob_ganar_2w*100) %>%
  stargazer(out = '../Tables/expectations_ss.tex', float = F, digits = 2)
  