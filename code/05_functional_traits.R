######### Functional data DF structure ###############


###### Get the trait data from the t

library(traitdata)
library(tidyverse)

trans_df_2 <- read.csv(here::here("trans_df_2.csv"))



AvianBodySize <- AvianBodySize

avonet <- avonet

bird_behav <- traitdata::bird_behav

elton_birds <- traitdata::elton_birds

HWI <- traitdata::globalHWI

amniota <- traitdata::amniota


#### summarise the avonet 

avonet |> 
  select(!c(Genus,
            Species)) |> 
  group_by(scientificNameStd) |>
  summarise(across(Beak.Length_Culmen:Tail.Length, \(x) mean(x, na.rm = T))) -> sum_avonet


sum(is.na(sum_avonet$Hand.wing.Index))

trans_df_2 |> 
  rename("scientificNameStd" = "species") |> 
  left_join(sum_avonet, by = "scientificNameStd") -> trans_df_3


## see the species which doesn't have the data

trans_df_3 |> 
  filter(if_all(.cols = Beak.Length_Culmen:Tail.Length, is.na)) |> 
  distinct(scientificNameStd) |> 
  pull()-> species_with_NA


sum_avonet |> 
  filter(scientificNameStd == "Accipiter cooperii")

# this means they are inside the data set
## get the common names for these 10 species

English_names <- c("Cooper's Hawk", 
                   "Evening Grosbeak", 
                   "Hairy Woodpecker",
                   "Bullock's Oriole",
                   "American Three-toed Woodpecker",
                   "Mountain Quail",
                   "Henslow's Sparrow",
                   "White-headed Woodpecker",
                   "Baird's Sparrow",
                   "Red-cockaded Woodpecker")


## use amniotes to get the scientific name used here

amniota |> 
  dplyr::filter(common_name %in% English_names) |> 
  pull(scientificNameStd) -> missing_scientific_names


## now we shall replace these in the transfer_DF_2
species_with_NA

trans_df_2 |> 
  rename("scientificNameStd" = "species") |>
  mutate(scientificNameStd = case_when(
    scientificNameStd == "Astur cooperii" ~ "Accipiter cooperii",
    scientificNameStd == "Coccothraustes vespertinus" ~ "Hesperiphona vespertina",
    scientificNameStd == "Dryobates villosus" ~ "Picoides villosus",
    scientificNameStd == "Icterus bullockii" ~ "Icterus bullockii",
    scientificNameStd == "Picoides dorsalis" ~ "Picoides dorsalis",
    scientificNameStd == "Oreortyx pictus" ~ "Oreortyx picta",
    scientificNameStd == "Centronyx henslowii" ~ "Ammodramus henslowii",
    scientificNameStd == "Dryobates albolarvatus" ~ "Picoides albolarvatus",
    scientificNameStd == "Centronyx bairdii" ~ "Ammodramus bairdii",
    scientificNameStd == "Dryobates borealis" ~ "Picoides dorsalis",
    TRUE ~ scientificNameStd
  )) -> trans_df_2


trans_df_2 |> 
  left_join(sum_avonet, by = "scientificNameStd") -> trans_df_3

#### these because the joining issue, Need to match the scientific names and see

trans_df_3 |> 
  filter(if_all(.cols = Beak.Length_Culmen:Tail.Length, is.na)) |> 
  select(scientificNameStd, aou)



## hairy woodpecker

sum_avonet |> 
  filter(scientificNameStd == "Leuconotopicus villosus")

## Bullock's oriole
sum_avonet |> 
  filter(scientificNameStd == "Icterus bullockiorum")

## there were two dorsalis 
sum_avonet |> 
  filter(scientificNameStd == "Picoides dorsalis")

## red cockaded woodpecker 3950
sum_avonet |> 
  filter(scientificNameStd == "Leuconotopicus borealis")


## this is the three toed woodpecker 4010
## former eurassian three toed, not american three toed
sum_avonet |> 
  filter(scientificNameStd == "Picoides tridactylus")



sum_avonet |> 
  filter(scientificNameStd == "Centronyx henslowii")


avonet |> 
  filter(Species == "henslowii")

## seems to be very old name here
#Passerculus henslowii
## Henslow's sparrow

sum_avonet |> 
  filter(scientificNameStd == "Passerculus henslowii")

## white heasded woodpecker

sum_avonet |> 
  filter(scientificNameStd == "Leuconotopicus albolarvatus")


trans_df_2 |> 
  mutate(scientificNameStd = case_when(
    scientificNameStd == "Picoides villosus" ~ "Leuconotopicus villosus",
    scientificNameStd == "Icterus bullockii" ~ "Icterus bullockiorum",
    scientificNameStd == "Picoides dorsalis" & 
      aou == 4010 ~ "Picoides tridactylus",
    scientificNameStd == "Ammodramus henslowii" ~ "Passerculus henslowii",
    scientificNameStd == "Picoides albolarvatus" ~ "Leuconotopicus albolarvatus",
    scientificNameStd == "Picoides dorsalis" & 
      aou == 3950 ~ "Leuconotopicus borealis",
    TRUE ~ scientificNameStd
  )) -> trans_df_2


trans_df_2 |> 
  left_join(sum_avonet, by = "scientificNameStd") -> avonet_finalized


avonet_finalized |> 
  filter(if_all(.cols = Beak.Length_Culmen:Tail.Length, is.na)) |> 
  select(scientificNameStd, aou)




### let's keep it here and try the elton and see 


trans_df_2 -> elton_trans

##### change the elton again and make sure that you are keeping the aou intact so we can 
## join the data later based on the aou


elton_trans |> 
  left_join(elton_birds, by = "scientificNameStd") -> trans_df_elton

trans_df_elton |> 
  filter(if_all(.cols = SpecID:BodyMass.SpecLevel, is.na)) |> 
  select(scientificNameStd, aou,
         English) |> 
  pull(aou) -> elton_missing_aou



avonet_finalized |> 
  filter(aou %in% elton_missing_aou)

trans_df_elton |> 
  filter(if_all(.cols = SpecID:BodyMass.SpecLevel, is.na)) |> 
  select(scientificNameStd, aou)


## use the common names to find the relevant scientific names used in the 
## data set

elton_missing_common <- c("Henslow's Sparrow",
                          "Downy Woodpecker",
                          "Hairy Woodpecker",
                          "Red-cockaded Woodpecker",
                          "White-headed Woodpecker",
                          "Calliope Hummingbird",
                          "Ladder-backed Woodpecker",
                          "Nuttall's Woodpecker",
                          "Carolina Chickadee",
                          "Chestnut-backed Chickadee",
                          "Pacific Wren",
                          "Blue-winged Warbler",
                          "Canyon Towhee",
                          "Bullock's Oriole",
                          "Evening Grosbeak",
                          "Northern Parula"
)  


elton_birds |> 
  filter(English %in% elton_missing_common) |> 
  select(scientificNameStd,
         English)

### pacific wren was not found due to that it was considered as the winter
## wren here

elton_birds |> 
  filter(Family == "Troglodytidae") |> 
  pull(English)

trans_df_2 |> 
  filter(scientificNameStd == "Troglodytes hiemalis")



elton_trans |> 
  filter(Family == "Troglodytidae")

elton_birds |> 
  filter(English == "Winter Wren")

elton_birds |> 
  filter(scientificNameStd == "Troglodytes hiemalis")

## The winter wren and pacific wren was splitted in 2010 and the data couldn't find for
## this one. Let's keep this here and fill the missing data using the 
## winter wren as they are almost similar in the dietary patterns and the habitats


elton_trans |> 
  mutate(scientificNameStd = case_when(
    scientificNameStd == "Setophaga americana" ~ "Pyrola americana",
    scientificNameStd == "Dryobates pubescens" ~ "Picoides bubescens",
    scientificNameStd == "Hesperiphona vespertina" ~ "Coccothraustes viopertinus",
    scientificNameStd == "Leuconotopicus villosus" ~ "Picoides villosus",
    scientificNameStd == "Vermivora cyanoptera" ~ "Setophaga pinus",
    scientificNameStd == "Dryobates scalaris" ~ "Picoides scalaris",
    scientificNameStd == "Icterus bullockiorum" ~ "Icterus bullockii",
    scientificNameStd == "Melozone fusca" ~ "Papilio fuscus",
    scientificNameStd == "Poecile carolinensis" ~ "Pagurus carolinensis",
    scientificNameStd == "Dryobates nuttallii" ~ "Picoides nuttallii",
    scientificNameStd == "Poecile rufescens" ~ "Pyrus rufescens",
    scientificNameStd == "Passerculus henslowii" ~ "Ammodramus henslowii",
    scientificNameStd == "Leuconotopicus albolarvatus" ~ "Picoides albolarvatus",
    scientificNameStd == "Leuconotopicus borealis" ~ "Picoides borealis",
    scientificNameStd == "Selasphorus calliope" ~ "Stellula calliope",
    TRUE ~ scientificNameStd
    
  )) -> elton_trans_2
## again keep it here and see the amniota

## change the winter wren into pacific wren here



elton_trans_2 |> 
  left_join((elton_birds |> 
               mutate(scientificNameStd = if_else(English == "Winter Wren", "Troglodytes pacificus", scientificNameStd)) |> 
               mutate(English = if_else(English == "Winter Wren", "Pacific Wren", English))),
            by = "scientificNameStd") -> trans_df_elton_2





trans_df_elton_2 |> 
  filter(duplicated(aou)) |> 
  select(scientificNameStd,
         aou,
         English)


## let's filter these and see

trans_df_elton_2 |> 
  filter(aou %in% c(5190, 6710, 6410, 5180))



##############not working try again #######
elton_birds |> 
  filter(duplicated(scientificNameStd))


trans_df_elton_2 |> 
  filter(duplicated(scientificNameStd))


#House Finch, Cassin's Finch, Blue-winged Warbler, Pine Warbler

## let's remov the dapple throat and leaf-love

trans_df_elton_2 |> 
  filter(!English %in% c("Dapple-throat", "Leaf-love")) |> 
  filter(duplicated(aou))

trans_df_elton_2 |> 
  filter(!English %in% c("Dapple-throat", "Leaf-love")) |> 
  filter(aou %in% c(6710, 6410))


# get the spec IDs and remove these
#12668 - Blue winged warbler
#12706 - Pine warbler

trans_df_elton_2 |> 
  filter(!English %in% c("Dapple-throat", "Leaf-love")) -> trans_df_elton_3


trans_df_elton_3 |> 
  filter(!duplicated(aou)) -> trans_df_elton_3


trans_df_elton_3 |> 
  filter(if_all(.cols = SpecID:BodyMass.SpecLevel, is.na))

trans_df_elton_3 |> 
  filter(English == "Pacific Wren")


trans_df_elton_3 |> 
  filter(duplicated(scientificNameStd))

trans_df_elton_3 |> 
  filter(duplicated(English))

trans_df_elton_3 |> 
  filter(aou == 6410)

trans_df_elton_3 |> 
  filter(English == "Blue-winged Warbler")

trans_df_elton_3 |> 
  mutate(scientificNameStd = if_else(aou == 6710, "Setophaga pinus", scientificNameStd),
         scientificNameStd = if_else(aou == 6410, "Vermivora cyanoptera", scientificNameStd)) |> 
  mutate(English = case_when(
    aou == 6710 ~ "Pine Warbler",
    TRUE ~ English
  )) -> trans_df_elton_3



trans_df_elton_3 |> 
  filter(if_any(.cols = SpecID:BodyMass.SpecLevel, is.na))

### nice we have a complete data set for the elton as well


elton_finalized <- trans_df_elton_3

###### Amniota #####

## select the relevant functional data for the resproduction measures

amniota_trans <- trans_df_2

amniota_trans |> 
  left_join(amniota, by = "scientificNameStd") -> trans_df_amniota

str(trans_df_amniota)

trans_df_amniota |> 
  select(Order.x:common_name,
         female_maturity_d,
         litter_or_clutch_size_n,
         litters_or_clutches_per_y,
         maximum_longevity_y,
         incubation_d,
         fledging_age_d,
         longevity_y) |> 
  select(!Subspecies) -> trans_df_amniota_select


trans_df_amniota_select |> 
  filter(if_all(.cols = female_maturity_d:longevity_y, is.na))


amniota_trans |> 
  mutate(scientificNameStd = case_when(
    scientificNameStd == "Dryobates pubescens" ~ "Picoides bubescens",
    scientificNameStd == "Leuconotopicus villosus" ~ "Picoides villosus",
    scientificNameStd == "Dryobates scalaris" ~ "Picoides scalaris",
    scientificNameStd == "Icterus bullockiorum" ~ "Icterus bullockii",
    scientificNameStd == "Dryobates nuttallii" ~ "Picoides nuttallii",
    scientificNameStd == "Passerculus henslowii" ~ "Ammodramus henslowii",
    scientificNameStd == "Leuconotopicus albolarvatus" ~ "Picoides albolarvatus",
    scientificNameStd == "Leuconotopicus borealis" ~ "Picoides borealis",
    TRUE ~ scientificNameStd) 
  ) -> amniota_trans_2


amniota_trans_2 |> 
  left_join(amniota, by = "scientificNameStd") -> trans_df_amniota_2

str(trans_df_amniota_2)

trans_df_amniota_2 |> 
  select(Order.x:common_name,
         female_maturity_d,
         litter_or_clutch_size_n,
         litters_or_clutches_per_y,
         maximum_longevity_y,
         incubation_d,
         fledging_age_d,
         longevity_y) |> 
  select(!Subspecies) -> trans_df_amniota_select_2


trans_df_amniota_select_2 |> 
  filter(if_all(.cols = female_maturity_d:longevity_y, is.na))

#nice

trans_df_amniota_select_2 |> 
  filter(if_any(.cols = female_maturity_d:longevity_y, is.na)) |> 
  summarise(count = n())


## for 68 species we don't have complete cases here

trans_df_amniota_select_2 |> 
  filter(if_any(.cols = female_maturity_d:longevity_y, is.na)) |>
  distinct(scientificNameStd)




## let's try the birdbase before dealing with the missing values


Bird_base_2 <- readxl::read_xlsx(here::here("Data", "Bird_base_2.xlsx"), sheet = "Data")


Bird_base_2 |> 
  janitor::clean_names() -> Bird_base_2



## let's join this with the trans_df_2



bird_base_trans <-trans_df_2



bird_base_trans |> 
  left_join((Bird_base_2 |> 
               rename("scientificNameStd" = "latin_bird_life_ioc_clements_avi_list")), 
            by = "scientificNameStd") -> Bird_base_trans_2

Bird_base_trans_2 |> 
  filter(if_all(.cols = ioc_15_1:sed, is.na))


Bird_base_2 |> 
  filter(english_name_bird_life_ioc_clements_avi_list == "Pileated Woodpecker")

##Hylatomus pileatus


Bird_base_2 |> 
  filter(english_name_bird_life_ioc_clements_avi_list == "Mountain Quail")

#Oreortyx pictus

Bird_base_2 |> 
  filter(english_name_bird_life_ioc_clements_avi_list == "Yellow-billed Magpie")

#Pica nutalli

Bird_base_2 |> 
  filter(english_name_bird_life_ioc_clements_avi_list == "Baird's Sparrow")



bird_base_trans |> 
  mutate(scientificNameStd = case_when(
    
    scientificNameStd == "Dryocopus pileatus" ~ "Hylatomus pileatus",
    scientificNameStd == "Oreortyx picta" ~ "Oreortyx pictus",
    scientificNameStd == "Pica nuttalli" ~ "Pica nutalli",
    scientificNameStd == "Ammodramus bairdii" ~ "Passerculus bairdii",
    TRUE ~ scientificNameStd
  )) -> Bird_base_trans_3



Bird_base_trans_3 |> 
  left_join((Bird_base_2 |> 
               rename("scientificNameStd" = "latin_bird_life_ioc_clements_avi_list")), 
            by = "scientificNameStd") -> Bird_base_trans_4


Bird_base_trans_4 |> 
  filter(if_all(.cols = ioc_15_1:sed, is.na))


# now select the needed variables
Bird_base_trans_4 |> 
  select(Order:trans_type,
         primary_habitat,
         primary_diet,
         clutch_min,
         clutch_max,
         incu1,
         incu2,
         fldg1,
         fldg2) -> Bird_base_trans_select



### get the averges of the minimum and the maximu of the clutch size, fledgings,
## and the incubation periods then this will be checked with the missing values of the
## amniotic data and try to replace those. If not go for the imputation
## of the missing traits

Bird_base_trans_select |> 
  mutate(avg_clutch = rowMeans(cbind(clutch_min, clutch_max))) |> 
  mutate(avg_clutch = case_when(
    is.na(avg_clutch) ~ clutch_min,
    is.na(avg_clutch) ~ clutch_max,
    TRUE ~ avg_clutch)
  ) |> 
  mutate(avg_incu = rowMeans(cbind(incu1, incu2))) |> 
  mutate(avg_incu = case_when(
    is.na(avg_incu) ~ incu1,
    is.na(avg_incu) ~ incu2,
    TRUE ~ avg_incu)
  ) |> 
  mutate(avg_fldg = rowMeans(cbind(fldg1, fldg2))) |> 
  mutate(avg_fldg = case_when(
    is.na(avg_fldg) ~ fldg1,
    is.na(avg_fldg) ~ fldg2,
    TRUE ~ avg_fldg)
  ) -> Bird_base_trans_select_2


trans_df_amniota_select_2 |> 
  filter(if_any(.cols = c(litter_or_clutch_size_n,
                          incubation_d,
                          fledging_age_d)))

## there are missing values
## check one column by one

trans_df_amniota_select_2 |> 
  filter(is.na(litter_or_clutch_size_n))
## all have the data for the clutch size

trans_df_amniota_select_2 |> 
  filter(is.na(incubation_d))


## let's get these species out and see these are there bird_base
## incubation days

Bird_base_trans_select_2 |> 
  filter(aou %in% (trans_df_amniota_select_2 |> 
                     filter(is.na(incubation_d)) |> 
                     pull(aou))) |> 
  select(aou,
         avg_incu) |> 
  right_join(trans_df_amniota_select_2, by = "aou") |> 
  mutate(incubation_d = if_else(is.na(incubation_d), avg_incu, incubation_d)) -> trans_df_amniota_select_2


### fledging age


Bird_base_trans_select_2 |> 
  filter(aou %in% (trans_df_amniota_select_2 |> 
                     filter(is.na(fledging_age_d)) |> 
                     pull(aou))) |> 
  select(aou,
         avg_fldg) |> 
  right_join(trans_df_amniota_select_2, by = "aou") |> 
  mutate(fledging_age_d = if_else(is.na(fledging_age_d), avg_fldg, fledging_age_d)) -> trans_df_amniota_select_2


bird_base_finalized <- Bird_base_trans_select_2


amniota_finalized <- trans_df_amniota_select_2

## let's start with the avonet finalized

#### extract only the Hand_wing_index


avonet_finalized |> 
  select(Order:trans_type,
         Hand.wing.Index) -> avonet_finalized_select


### elton data set
# get the body mass value


elton_finalized |> 
  select(aou,
         BodyMass.Value) -> elton_finalized_select



## amniotic data set


amniota_finalized |> 
  select(aou,
         female_maturity_d,
         litter_or_clutch_size_n,
         incubation_d,
         fledging_age_d,
         longevity_y) -> amniota_finalized_select


### bird_base

bird_base_finalized |> 
  select(aou,
         primary_habitat,
         primary_diet) -> bird_base_finalized_select


## now join the data sets


slected_data <- list(avonet_finalized_select,
                     elton_finalized_select,
                     amniota_finalized_select,
                     bird_base_finalized_select)


slected_data |> 
  reduce(left_join, by = "aou") -> func_trait_df


write.csv(func_trait_df, here::here("func_trait_df.csv"))
