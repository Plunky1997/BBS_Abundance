############################ Data structuring for the analysis ############################################

####getting the BBS data to the R which is downloaded from the BBS site from 1966 to 2023

## read the csvs into a list of data frames
#################### packages ##################
library(tidyverse)
library(bbsBayes2)
library(ebirdst)
library(sf)
library(terra)
library(leaflet)
library(rnaturalearth)
library(rnaturalearthdata)
library(concaveman)
library(lwgeom)
library(units)

#devtools::install_github("BrandonEdwards/bbsBayes2")

#bbsBayes2::fetch_bbs_data(level = "state")


bbs_data <- load_bbs_data()


## extract the full data set

bbs_counts <- bbs_data$birds

### get the data for routes

bbs_routes <- bbs_data$routes

## adding the cprdimnates to the count data


bbs_counts |> 
  left_join(bbs_routes |> 
              distinct(country_num, state_num, route, .keep_all = T) |> 
              select(country_num, state_num, route, latitude, longitude, obs_n, run_type), 
            by = c("country_num", "state_num", "route")) |> 
  relocate(latitude, longitude, .before = year) -> bbs_counts_coord


## select the routes accepted under the BBS criteria

bbs_counts_coord |> 
  filter(rpid == 101 & run_type == 1) -> bbs_counts_coord



### select the core species from all the data
## get the data set created for the core species of the Breeding bird survey
library(readxl)

species_list <- bbs_data$species

selected_bird_list <- readxl::read_xlsx(here::here("all_birds_merged.xlsx"))

species_list |> 
  mutate(Scientific_name = paste(genus, species)) |> 
  distinct(aou, Scientific_name) |> 
  print(n = 763)


selected_bird_list |> 
  rename(Common_name = `Common name`,
         Scientific_name = `Scientific name`) |> 
  inner_join(species_list |> 
               mutate(Scientific_name = paste(genus, species)) |> 
               rename(Common_name = english) |>  distinct(aou, Scientific_name), 
             by = "Scientific_name") -> join_scientific_birds



selected_bird_list |> 
  rename(Common_name = `Common name`,
         Scientific_name = `Scientific name`) |> 
  anti_join(join_scientific_birds, by = c("Scientific_name", "Common_name")) |> 
  inner_join(
    species_list |> 
      rename(Common_name = english) |> 
      distinct(aou, Common_name),
    by = "Common_name"
  ) -> join_common_birds


selected_bird_list_2 <- bind_rows(join_common_birds, join_scientific_birds)



selected_bird_list |> 
  rename(Common_name = `Common name`,
         Scientific_name = `Scientific name`) |> 
  anti_join(selected_bird_list_2, by ="Scientific_name") |> 
  mutate(aou = NA) |> 
  bind_rows(selected_bird_list_2) |> 
  mutate(aou = case_when(
    Common_name == "Lucy’s Warbler" ~ 6430,
    Common_name == "Virginia’s Warbler" ~ 6440,
    Common_name == "Baird’s Sparrow" ~ 5450,
    Common_name == "Henslow’s Sparrow" ~ 5470,
    Common_name == "Le Conte’s Sparrow" ~ 5480,
    Common_name == "Nelson’s Sparrow" ~ 5491,
    TRUE ~ aou
  )) -> selected_bird_list_3

## the core species

selected_bird_list_3 |> 
  filter(Core == "Core") -> bbs_core_species


bbs_core_species |> 
  filter(Scientific_name == "Astur atricapillus")

bbs_core_species |> 
  filter(Common_name == "American Crow")


### We will get rid of the nothern gashawk and replace the northstern crow with the american crow
## 


## check for the northwestern crow for the species list

species_list |> 
  filter(english == "Northwestern Crow")

species_list |> 
  mutate(scientific_name = paste(genus, species)) |> 
  filter(scientific_name == "Corvus caurinus")

## we cannot find this in the orginal data set, so we assum that it is being updated already,
## therefore no need to worry just stick with the updated data set





######## now select the codes in the full data set to get the selected species only


bbs_core_species_2 <- na.omit(bbs_core_species)

bbs_counts_coord |> 
  filter(country_num == 840) |> 
  filter(aou %in% as.vector(bbs_core_species_2$aou)) -> bbs_core_counts


## The north american map

na_map <- ne_countries(continent = "north america", returnclass = "sf", scale = "medium")



##### Getting the range of the selected birds


### let's try for one species in the data

sum(ebirdst_runs$scientific_name %in% bbs_core_species_2$Scientific_name)

#390

intersect(ebirdst_runs$scientific_name, bbs_core_species_2$Scientific_name)

setdiff(bbs_core_species_2$Scientific_name, ebirdst_runs$scientific_name)

### these names should be checked rename to have in the analysis

bbs_core_species_2 |> 
  mutate(Scientific_name = case_when(
    Scientific_name == "Oreothlypis luciae" ~ "Leiothlypis luciae",
    Scientific_name == "Oreothlypis virginiae" ~ "Leiothlypis virginiae",
    Scientific_name == "Ammodramus bairdii" ~ "Centronyx bairdii",
    Scientific_name == "Ammodramus henslowii" ~ "Centronyx henslowii",
    Scientific_name == "Ammodramus leconteii" ~ "Ammospiza leconteii",
    Scientific_name == "Ammodramus nelsoni" ~ "Ammospiza nelsoni",
    Scientific_name == "Anas strepera" ~ "Mareca strepera",
    Scientific_name == "Anas americana" ~ "Mareca americana",
    Scientific_name == "Anas discors" ~ "Spatula discors",
    Scientific_name == "Anas cyanoptera" ~ "Spatula cyanoptera",
    Scientific_name == "Anas clypeata" ~ "Spatula clypeata",
    Scientific_name == "Phalacrocorax auritus" ~ "Nannopterum auritum",
    Scientific_name == "Phalacrocorax pelagicus" ~ "Urile pelagicus",
    Scientific_name == "Grus canadensis" ~ "Antigone canadensis",
    Scientific_name == "Picoides pubescens" ~ "Dryobates pubescens",
    Scientific_name == "Picoides villosus" ~ "Leuconotopicus villosus",
    Scientific_name == "Picoides borealis" ~ "Leuconotopicus borealis",
    Scientific_name == "Picoides albolarvatus" ~ "Leuconotopicus albolarvatus",
    Scientific_name == "Regulus calendula" ~ "Corthylio calendula",
    Scientific_name == "Oreothlypis peregrina" ~ "Leiothlypis peregrina",
    Scientific_name == "Oreothlypis celata" ~ "Leiothlypis celata",
    Scientific_name == "Oreothlypis ruficapilla" ~ "Leiothlypis ruficapilla",
    Scientific_name == "Ixobrychus exilis" ~ "Botaurus exilis",
    Scientific_name == "Bubulcus ibis" ~ "Ardea ibis",
    Scientific_name == "Accipiter cooperii" ~ "Astur cooperii",
    Scientific_name == "Porphyrio martinicus" ~ "Porphyrio martinica",
    Scientific_name == "Charadrius montanus" ~ "Anarhynchus montanus",
    Scientific_name == "Larus argentatus" ~ "Larus smithsonianus",
    Scientific_name == "Tyto alba" ~ "Tyto furcata",
    Scientific_name == "Colaptes auratus auratus" ~ "Colaptes auratus",
    Scientific_name == "Troglodytes aedon" ~ "Troglodytes aedon",
    Scientific_name == "Setophaga coronata coronata" ~ "Setophaga coronata",
    Scientific_name == "Junco hyemalis hyemalis" ~ "Junco hyemalis",
    TRUE ~ Scientific_name
  )) -> bbs_core_species_3


bbs_core_species_3 |> 
  filter(Scientific_name %in% setdiff(bbs_core_species_3$Scientific_name, ebirdst_runs$scientific_name))

setdiff(bbs_core_species_3$Scientific_name, ebirdst_runs$scientific_name)


ebirdst_runs |> 
  filter(common_name %in% c("Hairy Woodpecker",
                            "Red-cockaded Woodpecker",
                            "White-headed Woodpecker",
                            "Northern/Southern House Wren")) |> 
  select(scientific_name)



ebirdst_runs |> 
  filter(str_detect(common_name, "Wren")) |> 
  print(n = 53)


## identified the scientific names and re assign those to the data set

bbs_core_species_3 |> 
  mutate(Scientific_name = case_when(
    Scientific_name == "Leuconotopicus villosus" ~ "Dryobates villosus",
    Scientific_name == "Leuconotopicus borealis" ~ "Dryobates borealis",
    Scientific_name == "Leuconotopicus albolarvatus" ~ "Dryobates albolarvatus",
    Scientific_name == "Troglodytes aedon" ~ "Troglodytes aedon/musculus",
    TRUE ~ Scientific_name
  )) -> bbs_core_species_3


setdiff(bbs_core_species_3$Scientific_name, ebirdst_runs$scientific_name)


### now go for the range maps for each species in the bbs data

##### Using ebird data to create the range map for each species to see the 
# overlap percentage of the range with the BBS data routes

#set_ebirdst_access_key("6qck2tr7e3me")



ne_countries(
  scale = "medium",
  returnclass = "sf",
  
) |> 
  filter(continent %in% c("North America", "South America")) |> 
  st_transform(crs = 4326) |> 
  st_union() -> americas


### BBS polygon
# Remove routes outside of spatial boundary 
# (Mexico, Alaska, Northwest Territories, Newfoundland and Labrador, Nunavut, 
# Nova Scotia, Prince Edward Island, Yukon)
bbs_routes |> 
  filter(run_type == 1 & rpid == 101) |> 
  filter(country_num != 484) |>  
  filter(!state_num %in% c(03, 43, 57, 62, 65, 75, 93)) |> 
  filter(year %in% c(1980:2023)) -> bbs_routes_select

bbs_routes_select |> 
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326, remove = F) -> bbs_sf


write.csv(bbs_routes_select, here::here("bbs_routes_select.csv"))


## equal area fot the global

bbs_ea <- st_transform(bbs_sf, crs = 8857)



## concave hull around all routes selected

concaveman(bbs_ea, concavity = 2, length_threshold = 0) |> 
  st_make_valid() -> routes_boundary


## buffer to the sampling points

routes_boundary |> 
  st_buffer(5000) |> 
  st_union() |> 
  st_make_valid() -> routes_boundary


plot(routes_boundary)

ggplot()+
  geom_sf(data = americas)+
  geom_sf(data = st_transform(routes_boundary, crs = 4326))

### good to go

## let's do this for one species

#Leiothlypis luciae Lucy's warbler

species <- "Agelaius tricolor"

ebirdst_download_status(species,
                        download_ranges = T,
                        download_abundance = F)


load_ranges(species = species,
            resolution = "27km") |> 
  dplyr::filter(season == "breeding") -> range 

if(nrow(range) == 0){
  load_ranges(species = species,
              resolution = "27km")  -> range 
  
}

range |> 
  st_transform(8857) |> 
  st_make_valid() -> range_equal_area


range_area <- sum(st_area(range_equal_area))

plot(range)

st_intersection(range_equal_area, routes_boundary) |> 
  st_area() |> 
  sum() -> overap_area


range_perc <- as.numeric(overap_area/range_area)*100


### checking whether it is working

ggplot()+
  geom_sf(data = americas)+
  geom_sf(data = st_transform(routes_boundary, crs = 4326))+
  geom_sf(data = st_transform(range, crs = 4326), fill = "red")


## this is going well with the plot as well so now we can loop the obove for subset of species

set.seed(345)

bbs_core_species_3 |> 
  arrange(Scientific_name) |> 
  pull(Scientific_name) -> species_all

perc_data <- data.frame(species = character(),
                        percentage = numeric(),
                        stringsAsFactors = F)

for(sp in species_all){
  
  cat(sp, "\nStart\n")
  
  ebirdst_download_status(sp,
                          download_ranges = T,
                          download_abundance = F)
  
  load_ranges(species = sp,
              resolution = "27km") |> 
    dplyr::filter(season == "breeding") -> range
  
  if(nrow(range) == 0){
    load_ranges(species = species,
                resolution = "27km")  -> range 
    
  }
  
  range |> 
    st_transform(8857) |> 
    st_make_valid() -> range_equal_area
  
  
  range_area <- sum(st_area(range_equal_area))
  
  st_intersection(range_equal_area, routes_boundary) |> 
    st_area() |> 
    sum() -> overlap_area
  
  range_perc <- as.numeric(overlap_area/range_area)*100
  
  out <- data.frame(species = sp, percentage = range_perc)
  
  perc_data <- rbind(perc_data, out)
  
  cat("\nFinished\n", sp, "\n")
  
}


## there were NaNs for some of the species in the first loop and it was due to the residency status of the
## species. THerefore for those species we used the whole range map
## the looping

## this is due to their resident status and won't filter as breeding. Now we need to give a
## if function in the loop to include full range if the length is equal to 0

####################### select the species which has the percentage greater than the 
## 80 %


bbs_core_species_3 |> 
  filter(Scientific_name %in% species_all) -> prop_species_all



prop_species_all |> 
  inner_join((perc_data |> 
                rename("Scientific_name" = "species")),
             by = "Scientific_name"
  ) |> 
  filter(percentage > 80) ->  prop_species_all

write.csv(prop_species_all, here::here("prop_species_all_final.csv"))

## what propotion

(nrow(prop_species_all)/nrow(bbs_core_species_3))*100
#56.16114
bbs_counts_coord |> 
  filter(aou %in% as.double(prop_species_all$aou)) |> 
  filter(rpid == 101 & run_type == 1) |> 
  filter(country_num != 484) |>  
  filter(!state_num %in% c(03, 43, 57, 62, 65, 75, 93)) |> 
  filter(year %in% c(1980:1990)) -> abundance_first_dec

write.csv(abundance_first_dec, here::here("abundance_first_dec.csv"))




bbs_counts_coord |> 
  filter(aou %in% as.double(prop_species_all$aou)) |> 
  filter(rpid == 101 & run_type == 1) |> 
  filter(country_num != 484) |>  
  filter(!state_num %in% c(03, 43, 57, 62, 65, 75, 93)) |> 
  filter(year %in% c(2013:2023)) -> abundance_last_dec

write.csv(abundance_last_dec, here::here("abundance_last_dec.csv"))



############################# Next script FInding range edges and centres ###################################


