###### post descriptive analysis  ######


############################# Packages ####################

library(tidyverse)


hyp_DF <- read.csv(here::here("hyp_final_df.csv"))

hyp_DF <- hyp_DF[-1]


## get the proportions of changes in the hypothesis patterns



hyp_DF |> 
  mutate(change = hypothesis_first == hypothesis_last) |> 
  summarise(
    count = n(),
    unchanged_n = sum(change),
    changed_n = count - unchanged_n,
    perc_change = (changed_n/count)*100
  )


## almost 39 % showed a differences in their hypothesis pattern between the time periods


hyp_DF |> 
  mutate(change = paste0(hypothesis_first, "_", hypothesis_last),
         is_change = hypothesis_first != hypothesis_last) |> 
  mutate(trans_type = map_chr(
    str_split(change, "_"),
    ~paste(sort(.x), collapse = "&")
  )) -> trans_df



## connecting the speciesList to get proper names befire going for the functional trait extraction

species_list <- read.csv(here::here("SpeciesList.csv"))

species_list |> 
  rename("aou" = "AOU") -> species_list


trans_df |> 
  left_join(species_list, by = "aou") |> 
  select(!c(Seq,
            English_Common_Name,
            French_Common_Name,
            Genus,
            Species
  )) |> 
  relocate(Order:Family) -> trans_df_2



## get the data set out to the functional analysis


write.csv(trans_df_2, here::here("trans_df_2.csv"))
