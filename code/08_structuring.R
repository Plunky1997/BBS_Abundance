##### Analysis ####

library(tidyverse)
library(lme4)

func_pca <- read.csv("func_pca.csv")


## select the analysis variables

names(func_pca)

func_pca |> 
  select(scientificNameStd,
         Family,
         aou,
         is_change,
         primary_habitat,
         primary_diet,
         Hand.wing.Index,
         BodyMass.Value,
         Trend,
         pc1,
         pc2) -> func_pca_2

### get the corelations between the variables 

## cramers V for the two categorical variables



func_pca_2 |> 
  select(primary_habitat,
         primary_diet) |> 
  table() -> table_cat

table_cat <- as.matrix(table_cat)


library(rcompanion)


rcompanion::cramerV(table_cat)

## not a greater association between the habitat type and the diet
## so initially it is fine to be in the model

func_pca_2 |> 
  select(where(is.numeric)) |> 
  select(-aou) |> 
  pairs()

## seems fine 

func_pca_2 |> 
  select(where(is.numeric)) |> 
  select(-aou) |> 
  cor()

## good

## but it is better to transform the hand wing index and body mass value in log

func_pca_2 |> 
  mutate(Hand.wing.Index = log1p(Hand.wing.Index),
         BodyMass.Value = log1p(BodyMass.Value)) -> func_pca_2


hist(func_pca_2$Hand.wing.Index)

hist(func_pca_2$BodyMass.Value)


## seems fine

## good to go for the analysis

names(func_pca_2)
str(func_pca_2)

## is_change should be converted
#character variables should be converted to factors

unique(func_pca_2$primary_habitat)

## too much categories

table(func_pca_2$primary_habitat)
## better to re categorize theses

func_pca_2 |> 
  mutate(primary_habitat = case_when(
    primary_habitat %in% c("Forest", "Woodland", "Shrub") ~ "Forest",
    primary_habitat %in% c("Grassland", "Plains", "Savanna") ~ "Open_terrestrial",
    primary_habitat %in% c("Wetland", "Riparian", "Coastal") ~ "Wet",
    primary_habitat %in% c("Desert", "Rocky") ~ "Xeric",
    TRUE ~ primary_habitat
  )) |> 
  group_by(primary_habitat) |> 
  summarise(count = n())


## the smallest is artificial and it is unavoidable, so this looks better that the last

func_pca_2 |> 
  mutate(primary_habitat = case_when(
    primary_habitat %in% c("Forest", "Woodland", "Shrub") ~ "Forest",
    primary_habitat %in% c("Grassland", "Plains", "Savanna") ~ "Open_terrestrial",
    primary_habitat %in% c("Wetland", "Riparian", "Coastal") ~ "Wet",
    primary_habitat %in% c("Desert", "Rocky") ~ "Xeric",
    TRUE ~ primary_habitat
  )) -> func_pca_2


## let's look at the diet

length(table(func_pca_2$primary_diet))
# 10 categories
## this will leads to problems so, better to go with fewer categories

func_pca_2 |> 
  mutate(primary_diet = case_when(
    primary_diet %in% c("Invertebrate", "Carnivore", "Scavenger", "Vertebrate") ~ "Animal",
    primary_diet %in% c("Fruit", "Seed") ~ "Granivore",
    primary_diet %in% c("Herbivore", "Plant", "Nectar") ~ "Plant",
    TRUE ~ primary_diet
  )) |> 
  group_by(primary_diet) |> 
  summarise(count = n())

# looks good and I have four guild now better

func_pca_2 |> 
  mutate(primary_diet = case_when(
    primary_diet %in% c("Invertebrate", "Carnivore", "Scavenger", "Vertebrate") ~ "Animal",
    primary_diet %in% c("Fruit", "Seed") ~ "Granivore",
    primary_diet %in% c("Herbivore", "Plant", "Nectar") ~ "Plant",
    TRUE ~ primary_diet
  )) -> func_pca_2



## let's for further collinearity


func_pca_2 |> 
  select(primary_habitat,
         primary_diet) |> 
  table() -> table_cat
table_cat <- as.matrix(table_cat)

rcompanion::cramerV(table_cat)
## no change so good

str(func_pca_2)

unique(func_pca_2$primary_habitat)

unique(func_pca_2$primary_diet)


## I would choose forest as base for the habitat and omnivore as base for the diet
# it would me more meaningful to compare

func_pca_2 |> 
  mutate(primary_habitat = relevel(factor(primary_habitat), ref = "Forest")) |> 
  mutate(primary_diet = relevel(factor(primary_diet), ref = "Omnivore")) |> 
  mutate(change = if_else(is_change, 1, 0)) |> 
  select(-is_change) -> func_pca_2

mosaicplot(table(func_pca_2$change, func_pca_2$primary_diet))

boxplot(func_pca_2$Trend~factor(func_pca_2$change))

## seems not much change showed, but let's see on the model


## more collinearity

func_pca_2 |> 
  select(-scientificNameStd) |> 
  mutate(abs_Trend = abs(Trend)) -> func_an


write.csv(func_an, "func_an.csv", col.names = NA)

