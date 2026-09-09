######## Filtering of  sepecies 2 #########


library(tidyverse)

## get the specieas all data set

species <- read.csv("prop_species_all_final.csv")

species <- species[-1]


## get the first decade and last decadae data

first_dec <- read.csv("abundance_first_dec.csv")


last_dec <- read.csv("abundance_last_dec.csv")


## remove the waterbirds, owls, nightjars, dipper, Kingfishers


species |> 
  filter(!aou <= 2880) |> 
  filter(!(aou >= 3650 & aou <= 3810)) |> 
  filter(!(aou >= 3900 & aou <= 3910)) |> 
  filter(!(aou >= 4160 & aou <= 4210)) |> 
  filter(!aou == 7010) -> species_filter_1


## go for the detection in the two data sets

first_dec |> 
  group_by(aou) |> 
  summarise(count_F = n(),
            mean_det_F = mean(stop_total/50)*100) |> 
  mutate(perc_F = (count_F/sum(count_F))*100) -> first_dec_routes_det


last_dec |> 
  group_by(aou) |> 
  summarise(count_L = n(),
            mean_det_L = mean(stop_total/50)*100) |> 
  arrange(count_L) |> 
  mutate(perc_L = (count_L/sum(count_L))*100) -> last_dec_routes_det


first_dec_routes_det |> 
  left_join(last_dec_routes_det, by = "aou") |> 
  mutate(perc_diff = perc_L - perc_F) |>
  mutate(det_diff = (mean_det_L - mean_det_F)) |> 
  arrange(desc(abs(perc_diff))) |> 
  right_join(species_filter_1) |> 
  relocate(Common_name:percentage, .before = aou) |> 
  relocate(aou, .before = percentage) -> det_summary



### extract the needed species

det_summary |> 
  select(Common_name,
         Scientific_name,
         Core,
         aou,
         percentage) -> det_summary_exp


write.csv(det_summary_exp, here::here("det_summary_exp.csv"))
