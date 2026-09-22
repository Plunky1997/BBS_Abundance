library(tidyverse)


### get the family, scientific, aou, hypothesis_first, hypothesis_dec

func_trait_df <- read.csv("func_trait_df.csv")

func_trait_df |> 
  select(Family,
         scientificNameStd,
         aou,
         hypothesis_first,
         hypothesis_last) -> func_trait_df_2


## get the resolved daata for the analysis

func_an <- read.csv("func_an.csv")

func_an <- func_an[-1]


func_trait_df_2 |> 
  select(-c(Family)) |> 
  left_join(func_an, by = "aou") -> func_an_2


func_an_2 |> 
  relocate(c(Family,
             scientificNameStd,
             aou), .before = 1) |> 
  mutate(Family = if_else(Family == "Icteridae", "Icteriidae", Family))-> func_an_3

func_an_3 |> 
  mutate(hypothesis_first = case_when(
    hypothesis_first %in% c("ACE", "REDG") ~ "REDG",
    TRUE ~ "NRG"
  )) |> 
  mutate(hypothesis_last = case_when(
    hypothesis_last %in% c("ACE", "REDG") ~ "REDG",
    TRUE ~ "NRG"
  )) |> 
  mutate(change = hypothesis_first == hypothesis_last) |> 
  mutate(change = if_else(change, 0, 1)) |> 
  mutate(change_status = paste0(hypothesis_first, "_", hypothesis_last)) -> desc_REDG

desc_REDG |> 
  group_by(hypothesis_first) |> 
  summarise(
    count = n()
  ) |> 
  mutate(perc = count/sum(count)*100)


desc_REDG |> 
  group_by(hypothesis_last) |> 
  summarise(
    count = n()
  ) |> 
  mutate(perc = count/sum(count)*100)

#### for the first analysis, we will consider the  


#### let's create the rare edge vs not rare edge to assess how the rare edge changes over the years###
## note in ACE you have the special case of the rare edge

func_an_3 |> 
  mutate(hypothesis_first = case_when(
    hypothesis_first %in% c("ACE", "REDG") ~ "REDG",
    TRUE ~ "NRG"
  )) |> 
  mutate(hypothesis_last = case_when(
    hypothesis_last %in% c("ACE", "REDG") ~ "REDG",
    TRUE ~ "NRG"
  )) |> 
  mutate(change = hypothesis_first == hypothesis_last) |> 
  mutate(change = if_else(change, 0, 1)) |> 
  mutate(change_status = paste0(hypothesis_first, "_", hypothesis_last)) |> 
  select(Family:aou,
         primary_habitat:BodyMass.Value,
         pc1:change_status,
         Trend) |> 
  relocate(abs_Trend:change_status, .before = change)-> func_an_REDG


### go for the descriptive first



## summaries for the change status

func_an_REDG |> 
  group_by(change) |> 
  summarise(
    count = n()
  ) |> 
  mutate(perc = count/sum(count)*100)

## so rare edge has changed betweeen the two windows around 23 % of the studied species (48)


func_an_REDG |> 
  group_by(change_status) |> 
  summarise(
    count = n()
  ) |> 
  mutate(perc = count/ sum(count)*100)

### families

desc_REDG |> 
  filter(hypothesis_first == "REDG" & hypothesis_last == "REDG") |>
  group_by(Family) |> 
  summarise(
    count = n()
  ) |> 
  arrange(desc(count)) |> 
  left_join(desc_REDG |> 
              group_by(Family) |> 
              summarise(
                count_2 = n()
              )) |> 
  mutate(prop_perc = count/count_2*100) |> 
  arrange(desc(prop_perc)) |> 
  filter(count_2 > 5)


desc_REDG |> 
  filter(hypothesis_first == "NRG" & hypothesis_last == "REDG") |>
  group_by(Family) |> 
  summarise(
    count = n()
  ) |> 
  arrange(desc(count)) |> 
  left_join(desc_REDG |> 
              group_by(Family) |> 
              summarise(
                count_2 = n()
              )) |> 
  mutate(prop_perc = count/count_2*100) |> 
  arrange(desc(prop_perc)) |> 
  filter(count_2 > 5)


desc_REDG |> 
  filter(hypothesis_first == "REDG" & hypothesis_last == "NRG") |>
  group_by(Family) |> 
  summarise(
    count = n()
  ) |> 
  arrange(desc(count)) |> 
  left_join(desc_REDG |> 
              group_by(Family) |> 
              summarise(
                count_2 = n()
              )) |> 
  mutate(prop_perc = count/count_2*100) |> 
  arrange(desc(prop_perc)) |> 
  filter(count_2 > 5)

### without proportional sclaing for the percentage based on the species present
## in the data

desc_REDG |> 
  filter(hypothesis_first == "REDG" & hypothesis_last == "REDG") |>
  group_by(Family) |> 
  summarise(
    count = n()
  ) |> 
  mutate(
    perc = (count/sum(count))*100
  ) |> 
  arrange(desc(perc))


desc_REDG |> 
  filter(hypothesis_first == "NRG" & hypothesis_last == "REDG") |>
  group_by(Family) |> 
  summarise(
    count = n()
  ) |> 
  mutate(
    perc = (count/sum(count))*100
  ) |> 
  arrange(desc(perc))


desc_REDG |> 
  filter(hypothesis_first == "REDG" & hypothesis_last == "NRG") |>
  group_by(Family) |> 
  summarise(
    count = n()
  ) |> 
  mutate(
    perc = (count/sum(count))*100
  ) |> 
  arrange(desc(perc))


desc_REDG |> 
  filter(hypothesis_first == "REDG") |>
  group_by(Family) |> 
  summarise(
    count = n()
  ) |> 
  mutate(
    perc = count/sum(count)*100
  ) |> 
  arrange(desc(perc))



desc_REDG |> 
  filter(hypothesis_last == "REDG") |>
  group_by(Family) |> 
  summarise(
    count = n()
  ) |> 
  mutate(
    perc = count/sum(count)*100
  ) |> 
  arrange(desc(perc))






## the changes were occured mostly from non rare edge to rare edge than the rare edge to not rare edge
## group

### let's do this for the abundance centre as well

func_an_3 |> 
  mutate(hypothesis_first = case_when(
    hypothesis_first %in% c("ACE") ~ "ACE",
    TRUE  ~ "NACE"
  )) |> 
  mutate(hypothesis_last = case_when(
    hypothesis_last %in% c("ACE") ~ "ACE",
    TRUE  ~ "NACE"
  )) |> 
  mutate(change = hypothesis_first == hypothesis_last) |> 
  mutate(change = if_else(change, 0, 1)) |> 
  mutate(change_status = paste0(hypothesis_first, "_", hypothesis_last)) -> desc_ACE




desc_ACE |> 
  group_by(hypothesis_first) |> 
  summarise(
    count = n()
  ) |> 
  mutate(perc = count/sum(count)*100)


desc_ACE |> 
  group_by(hypothesis_last) |> 
  summarise(
    count = n()
  ) |> 
  mutate(perc = count/sum(count)*100)







func_an_3 |> 
  mutate(hypothesis_first = case_when(
    hypothesis_first %in% c("ACE") ~ "ACE",
    TRUE  ~ "NACE"
  )) |> 
  mutate(hypothesis_last = case_when(
    hypothesis_last %in% c("ACE") ~ "ACE",
    TRUE  ~ "NACE"
  )) |> 
  mutate(change = hypothesis_first == hypothesis_last) |> 
  mutate(change = if_else(change, 0, 1)) |> 
  mutate(change_status = paste0(hypothesis_first, "_", hypothesis_last)) |> 
  select(Family:aou,
         primary_habitat:BodyMass.Value,
         pc1:change_status,
         Trend) |> 
  relocate(abs_Trend:change_status, .before = change)-> func_an_ACE




## summaries for the change status

func_an_ACE |> 
  group_by(change) |> 
  summarise(
    count = n()
  ) |> 
  mutate(perc = count/sum(count)*100)

## so rare edge has changed betweeen the two windows around 23 % of the studied species (48)


func_an_ACE |> 
  group_by(change_status) |> 
  summarise(
    count = n()
  ) |> 
  mutate(perc = count/ sum(count)*100)


### extract the families for the ACE in both decades

desc_ACE |> 
  filter(hypothesis_first == "ACE"& hypothesis_last == "ACE") |>
  group_by(Family) |> 
  summarise(
    count = n()
  ) |> 
  mutate(
    perc = count/sum(count)*100
  ) |> 
  arrange(desc(perc))

(30/203)*100

desc_ACE |> 
  filter(hypothesis_first == "ACE"& hypothesis_last == "ACE") |>
  group_by(Family) |> 
  summarise(
    count = n()
  ) |> 
  arrange(desc(count)) |> 
  left_join(desc_REDG |> 
              group_by(Family) |> 
              summarise(
                count_2 = n()
              )) |> 
  mutate(prop_perc = count/count_2*100) |> 
  arrange(desc(prop_perc)) |> 
  filter(count_2 > 5)





desc_ACE |> 
  filter(hypothesis_first == "ACE") |>
  group_by(Family) |> 
  summarise(
    count = n()
  ) |> 
  mutate(
    perc = count/sum(count)*100
  ) |> 
  arrange(desc(perc))


desc_ACE |> 
  filter(hypothesis_last == "ACE") |>
  group_by(Family) |> 
  summarise(
    count = n()
  ) |> 
  mutate(
    perc = count/sum(count)*100
  ) |> 
  arrange(desc(perc))


desc_ACE |> 
  filter(hypothesis_first == "NACE"| hypothesis_last == "NACE") |>
  group_by(Family) |> 
  summarise(
    count = n()
  ) |> 
  mutate(
    perc = count/sum(count)*100
  ) |> 
  arrange(desc(perc))



### Exctract the changed families from NACE to ACE

desc_ACE |> 
  filter(hypothesis_first == "NACE" & hypothesis_last == "ACE") |> 
  group_by(Family) |> 
  summarise(
    count = n()
  ) |> 
  mutate(
    perc = count/sum(count)*100
  ) |> 
  arrange(desc(perc))


desc_ACE |> 
  filter(hypothesis_first == "NACE" & hypothesis_last == "ACE") |> 
  group_by(Family) |> 
  summarise(
    count = n()
  ) |> 
  left_join(desc_ACE |> 
              group_by(Family) |> 
              summarise(
                count_all = n()
              )) |> 
  mutate(
    perc = count/count_all*100
  ) |> 
  arrange(desc(perc))


desc_ACE |> 
  filter(hypothesis_first == "ACE" & hypothesis_last == "NACE") |> 
  group_by(Family) |> 
  summarise(
    count = n()
  ) |> 
  mutate(
    perc = count/sum(count)*100
  ) |> 
  arrange(desc(perc))


desc_ACE |> 
  filter(hypothesis_first == "ACE" & hypothesis_last == "NACE") |> 
  group_by(Family) |> 
  summarise(
    count = n()
  ) |> 
  left_join(desc_ACE |> 
              group_by(Family) |> 
              summarise(
                count_all = n()
              )) |> 
  mutate(
    perc = count/count_all*100
  ) |> 
  arrange(desc(perc))


desc_ACE |> 
  filter(hypothesis_first == "NACE" & hypothesis_last == "ACE") |> 
  pull(scientificNameStd) |> 
  intersect(desc_REDG |> 
              filter(hypothesis_first == "NRG" & hypothesis_last == "REDG") |> 
              pull(scientificNameStd))





### proportions of species 


prop_species <- read.csv(here::here("prop_species_all_final.csv"))


prop_species |> 
  filter(aou %in% (func_trait_df_2 |> 
                     pull(aou))) -> prop_species_2


func_trait_df_2 |> 
  select(aou) |> 
  left_join(prop_species, by ="aou") |> 
  select(aou,
         Common_name,
         Scientific_name,
         percentage) -> prop_species_3
  

write.csv(prop_species_3, here::here("prop_species_3.csv"))

prop_species_2 |> 
  arrange(percentage)

desc_ACE |> 
  filter(aou %in% (prop_species_2 |> 
                     filter(percentage == 100) |> 
                     pull(aou)))
  
func_an_ACE |> 
  arrange(desc(pc1))




desc_ACE |> 
  filter(Trend > 0) |> 
  filter(hypothesis_first == "NACE" & hypothesis_last == "ACE")

## let's see the species list for the REDG

func_an_REDG |> 
  filter(change == 1) |> 
  select(scientificNameStd) |> 
  pull(scientificNameStd) -> REDG_sp


func_an_ACE |> 
  filter(change == 1) |> 
  select(scientificNameStd) |> 
  pull(scientificNameStd) -> ACE_sp


intersect(REDG_sp, ACE_sp)

setdiff(REDG_sp, ACE_sp)

## that's fine




###### create the bar graph for the change status


desc_ACE |> 
  group_by(change_status) |> 
  summarise(
    count = n()
  ) |> 
  mutate(
    perc = count/sum(count)*100
  ) |> 
  ggplot(aes(x = reorder(change_status,  -perc), y = perc, fill = change_status))+
  geom_col()+
  geom_text(
    aes(label = paste0(round(perc, 1), "%")),
    hjust = 1.1,          
    color = "white",
    size = 5,
    fontface = "bold"
  )+
  coord_flip()+
  ylab("changed percentage (%)")+
  xlab("pattern change")+
  theme(
    panel.background = element_blank(),
    axis.line = element_line(color = "black"),
    axis.title = element_text(size = 21),
    axis.text = element_text(size = 19),
    legend.position = "none"
  )+
  scale_fill_manual(values = c("ACE_ACE" = "#410000",
                               "ACE_NACE" = "#7a3700",
                               "NACE_NACE" = "#ba6d00",
                              "NACE_ACE" = "#ffa500"))
  

ggsave(here::here("Figures/hyp_change_status.pdf"),
       dpi = 600,
       device = cairo_pdf,
       units = "in",
       width = 8,
       height = 12)






desc_REDG |> 
  group_by(change_status) |> 
  summarise(
    count = n()
  ) |> 
  mutate(
    perc = count/sum(count)*100
  ) |> 
  ggplot(aes(x = reorder(change_status,  -perc), y = perc, fill = change_status))+
  geom_col()+
  geom_text(
    aes(label = paste0(round(perc, 1), "%")),
    hjust = 1.1,          
    color = "white",
    size = 5,
    fontface = "bold"
  )+
  coord_flip()+
  ylab("changed percentage (%)")+
  xlab("pattern change")+
  theme(
    panel.background = element_blank(),
    axis.line = element_line(color = "black"),
    axis.title = element_text(size = 21),
    axis.text = element_text(size = 19),
    legend.position = "none"
  )+
  scale_fill_manual(values = c("REDG_REDG" = "#410000",
                               "REDG_NRG" = "#7a3700",
                               "NRG_NRG" = "#ba6d00",
                               "NRG_REDG" = "#ffa500"))


ggsave(here::here("Figures/hyp_change_status_REDG.pdf"),
       dpi = 600,
       device = cairo_pdf,
       units = "in",
       width = 8,
       height = 12)





#pie chart


desc_ACE |> 
  group_by(change_status) |> 
  summarise(
    count = n()
  ) |> 
  mutate(
    perc = count / sum(count) * 100
  ) |> 
  ggplot(aes(x = "", y = perc, fill = change_status)) +
  geom_col(width = 1,
           color = "black",
           linewidth = 0.9) +
  geom_text(
    aes(label = paste0(round(perc, 1), "%")),
    position = position_stack(vjust = 0.5),
    color = "white",
    size = 5,
    fontface = "bold"
  ) +
  coord_polar(theta = "y") +
  theme_void() +
  theme(
    legend.position = "none"
  ) +
  scale_fill_manual(values = c("ACE_ACE" = "#410000",
                               "ACE_NACE" = "#7a3700",
                               "NACE_NACE" = "#ba6d00",
                               "NACE_ACE" = "#ffa500"))


ggsave(here::here("Figures/hyp_change_status_pie.pdf"),
       dpi = 600,
       device = cairo_pdf,
       units = "in",
       width = 10,
       height = 10)


## get the edge type for the data

edge_type_dat <- read.csv("edge_type_dat.csv")

edge_type_dat <- edge_type_dat[-1]

func_an_ACE |> 
  left_join(edge_type_dat, by = "aou") -> func_an_ACE


func_an_REDG |> 
  left_join(edge_type_dat, by = "aou") -> func_an_REDG


## use these data to go for the models

write.csv(func_an_ACE, "func_an_ACE.csv", row.names = F)

write.csv(func_an_REDG, "func_an_REDG.csv", row.names = F)


