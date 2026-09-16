####### Ranges and centres of the data  #############


## get the data sets written from the Data_nad_2.R

abundance_first_dec <- read.csv(here::here("abundance_first_dec.csv"))

abundance_first_dec <- abundance_first_dec[-1]

abundance_last_dec <- read.csv(here::here("abundance_last_dec.csv"))

abundance_last_dec <- abundance_last_dec[-1]

prop_species_all <- read.csv(here::here("det_summary_exp.csv"))

prop_species_all <- prop_species_all[-1]

####################### Packages ###################

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


#Generating the north american overall maps

na_land<-  ne_countries(scale = "medium", returnclass = "sf") |> 
  filter(continent == "North America") |> 
  st_union() |> 
  st_make_valid()  

###### the lakes of withing the north america should be removed as suggested by the martin et al 2024


lakes <- ne_download(scale = "medium", type = "lakes", category = "physical", returnclass = "sf") |> 
  st_make_valid()


na_land_8857 <- st_transform(na_land, 8857) |> 
  st_make_valid()

lakes_8857   <- st_transform(lakes,   8857) |> 
  st_make_valid()


na_land_nolakes <- st_difference(na_land_8857, st_union(lakes_8857)) |> 
  st_make_valid()


## project to ESPG 8857

land_equal_area <- na_land_nolakes




### now we have to create the bins for the range
## what I'm thinking, we can't do as martin et al 2024 in creating the bins
## because, we don't have a higher spatial resoultion or girds as in ebird data
## what we have are the routes locations and it might change with the ranges of
## the species. the sampling bias would be there if we just bin the range by the 
## distance. So What I'm thinking, to get the bins based on the BBS routes number


## get the bbs selected routes to the R

bbs_routes_selected <- read.csv("bbs_routes_select.csv")

bbs_routes_selected |> 
  filter(active == 1) |> 
  distinct(longitude, latitude) |> 
  count()

## the first decade routes

bbs_routes_selected |> 
  filter(year %in% c(1980:1990)) -> bbs_routes_first_dec

bbs_routes_selected |> 
  filter(year %in% c(2013:2023)) -> bbs_routes_last_dec



######### Loop through the species #####################
################################################




species <- as.vector(prop_species_all$Scientific_name)

hyp_fun <- function(
    decade_df,
    prop_species_all,
    bbs_route_df,
    land_map,
    species
){
  
  g <- st_sfc(st_point(), crs = 8857)
  
  pts_in_all <- NULL
  
  routes_in_range_lst <- list()
  
  bin_abundance_summary_all <- NULL
  
  failed_species <- character(0)
  
  for(sp in species) {
    
    
    cat("\n", sp, "- ")
    
    tryCatch({
      
      sf::sf_use_s2(FALSE)
      
      decade_df |> 
        filter(aou == prop_species_all$aou[prop_species_all$Scientific_name == paste(sp)]) |> 
        mutate(abundance = species_total) -> dat_sp
      
      
      dat_sp |> 
        filter(abundance > 0) -> occ
      
      occ_points <- st_as_sf(occ, coords = c("longitude", "latitude"), crs = 4326, remove = F)
      
      
      
      ## as we are going to calculate the distances the crs is set to 8857
      
      occ_equal_earth <- st_transform(occ_points, crs = 8857)
      
      ebirdst_download_status(sp,
                              download_ranges = T,
                              download_abundance = F)
      
      load_ranges(species = sp,
                  resolution = "27km") |> 
        dplyr::filter(season == "breeding") -> range_map
      
      
      if(nrow(range_map) == 0){
        load_ranges(species = sp,
                    resolution = "27km")  -> range_map 
        
      }
      
      
      range_map |> 
        st_transform(8857) |> 
        st_make_valid() |> 
        sf::st_perimeter() |> 
        st_drop_geometry() |> 
        as.numeric() -> perimeter
      
      buf <- perimeter*(1/100)
      
      range_map |> 
        st_union() |> 
        st_make_valid() |> 
        st_transform(8857) |> 
        st_buffer(buf) |> 
        st_make_valid() -> range_buffer_100Km 
      
      
      
      buffer_kept <- st_within(occ_equal_earth, range_buffer_100Km, sparse = F)[, 1]
      
      occ_equal_earth <- occ_equal_earth[buffer_kept, ]
      
      
      coords <- st_coordinates(occ_equal_earth)
      
      distance <- as.matrix(dist(coords))
      
      
      range_polygon <- concaveman(occ_equal_earth, concavity = 2, length_threshold = 0) |>
        st_make_valid() |>
        st_set_precision(1) |>
        st_make_valid() |>
        st_buffer(40000) |>
        st_make_valid() |>
        st_buffer(0) |>  ## I did this to remove the collapsed rings
        st_make_valid() 
      
      
      #### now erase the range of the species from the land without the lakes
      
      land_minus_range <- st_difference(land_equal_area, range_polygon) |> 
        st_make_valid()
      
      
      
      ### points should be inside the range devoloped, but to make sure
      
      inside <- st_within(occ_equal_earth, range_polygon, sparse = F)[, 1]
      
      pts_in <- occ_equal_earth[inside, ]
      
      
      ## cliiping the range to land to take the coastal edge as a boundary
      
      range_land <- st_intersection(range_polygon, land_equal_area) |> 
        st_make_valid() |> 
        st_union()
      
      
      plot(range_land)                                                                            
      
      ## creat the line geomtetries of the boundaries
      
      range_bnd <- st_boundary(range_land) |> 
        st_make_valid()
      
      coast_ln <- st_boundary(land_equal_area) |> 
        st_make_valid()
      
      
      ##### coastline segments
      
      tol_m <- 2000
      coast_zone <- st_buffer(coast_ln, tol_m)
      
      
      #### now the coast edge for the data
      
      coast_edge <- st_intersection(range_bnd, coast_zone) |> 
        st_make_valid()
      
      inland_edge <- st_difference(range_bnd, coast_zone) |> 
        st_make_valid()
      
      
      ## create the function to evade the errors under the loop if there
      ## is no geometry for the coastals
      
      
      dist_nearest_km <- function(pts, geom){
        if(length(geom) == 0) return(rep(NA_real_, nrow(pts)))
        d <- st_distance(pts, geom)
        dmin <- if(is.matrix(d)) apply(d, 1, min) else as.vector(d)
        as.numeric(dmin)/1000
      }
      
      ## distance to the coastline edge
      
      d_coast_km <- dist_nearest_km(pts_in, coast_edge)
      d_inland_km <- dist_nearest_km(pts_in, inland_edge)
      
      pts_in$dist_coast_km  <- d_coast_km
      pts_in$dist_inland_km <- d_inland_km
      pts_in$dist_edge_km   <- pmin(d_coast_km, d_inland_km, na.rm = TRUE)
      pts_in$edge_type      <- ifelse(d_coast_km <= d_inland_km, "coastline", "inland")
      
      ### Now we shall get the centres of the data
      
      
      q95 <- quantile(pts_in$dist_edge_km, probs = 0.95, na.rm = TRUE)
      
      
      pts_in$centre95 <- pts_in$dist_edge_km >= q95
      
      pts_in$species <- sp
      
      pts_in_all <- dplyr::bind_rows(pts_in_all, pts_in)
      
      
      ### we will see what is there
      ### now we have to create the bins for the range
      ## what I'm thinking, we can't do as martin et al 2024 in creating the bins
      ## because, we don't have a higher spatial resoultion or girds as in ebird data
      ## what we have are the routes locations and it might change with the ranges of
      ## the species. the sampling bias would be there if we just bin the range by the 
      ## distance. So What I'm thinking, to get the bins based on the BBS routes number
      
      
      #### wihing range route centre and bins
      
      
      bbs_routes_pts <- st_as_sf(bbs_route_df,
                                 coords = c("longitude", "latitude"),
                                 crs = 4326, remove = F)
      
      bbs_routes_equal_earth <- st_transform(bbs_routes_pts, crs = 8857)
      
      
      ### getting the route which is in the species range polygon
      
      inside_routes <- st_within(bbs_routes_equal_earth, range_polygon, sparse = F)[, 1]
      routes_in_range <- bbs_routes_equal_earth[inside_routes, ]
      
      
      ## distance for the range edges
      
      d_coast_routes_km <- dist_nearest_km(routes_in_range, coast_edge)
      
      d_inland_routes_km <- dist_nearest_km(routes_in_range, inland_edge)
      
      routes_in_range$dist_edge_route_km <- pmin(d_coast_routes_km, d_inland_routes_km, 
                                                 na.rm = T)
      
      routes_in_range$edge_type_route <- ifelse(d_coast_routes_km <= d_inland_routes_km, "coastline", "inland")
      
      
      ## binning for the unique routes
      
      route_levels <- routes_in_range |> 
        st_drop_geometry() |> 
        group_by(country_num, state_num,route) |> 
        summarise(
          dist_edge_route_km = first(dist_edge_route_km),
          edge_type_route = first(edge_type_route),
          .groups = "drop"
        )
      
      ## centre for the BBS routes within range
      
      q95_routes <- quantile(route_levels$dist_edge_route_km, probs = 0.95, na.rm = T)
      
      route_levels$centre95_routes <- route_levels$dist_edge_route_km >= q95_routes
      
      ## binning and joins the binssss
      
      route_levels$bin20 <- dplyr::ntile(route_levels$dist_edge_route_km, 20)
      
      route_levels$bin20_label <- paste0((route_levels$bin20 - 1) * 5, "-", route_levels$bin20 * 5, "%")
      
      routes_in_range <- routes_in_range |>
        left_join(route_levels |> select(country_num, state_num,route, bin20, bin20_label, centre95_routes),
                  by = c("country_num","state_num","route"))
      
      
      
      routes_in_range_lst[[sp]] <- routes_in_range
      
      
      ### get the undetetected routes to have zero
      
      
      routes_in_range_tbl <- routes_in_range |>
        st_drop_geometry() |>
        select(country_num, state_num, route, year, bin20, bin20_label, centre95_routes)
      
      
      det_first_dec <- decade_df |>
        filter(aou == prop_species_all$aou[prop_species_all$Scientific_name == sp]) |>
        select(aou,
               country_num,
               state_num,
               route,
               year,
               species_total)
      
      routes_in_range_tbl |> 
        left_join(det_first_dec, by = c("country_num","state_num", "route", "year")) |> 
        mutate(species_total = replace_na(species_total, 0)) -> abund_full_first_dec
      
      
      
      ### Summarize the abundance per each bin
      
      
      route_median_abund <- abund_full_first_dec |>
        group_by(country_num,state_num, route, bin20, bin20_label) |>
        summarise(
          median_species_total = median(species_total, na.rm = TRUE),
          .groups = "drop"
        )
      
      bin_abundance_summary <- route_median_abund |> 
        group_by(bin20, bin20_label) |>
        summarise(
          n_routes = n(),
          mean_abundance = mean(median_species_total, na.rm = TRUE),
          .groups = "drop"
        ) |>
        arrange(bin20)
      
      bin_abundance_summary$species <- rep(sp, nrow(bin_abundance_summary))
      bin_abundance_summary$aou <- prop_species_all$aou[prop_species_all$Scientific_name == sp] 
      
      
      bin_abundance_summary |>
        arrange(bin20) |>
        mutate(
          hypothesis = {
            edge   <- sum(mean_abundance[bin20 %in%  1:5],  na.rm = TRUE)
            Q2     <- sum(mean_abundance[bin20 %in%  6:10], na.rm = TRUE)
            Q3     <- sum(mean_abundance[bin20 %in% 11:15], na.rm = TRUE)
            center <- sum(mean_abundance[bin20 %in% 16:20], na.rm = TRUE)
            
            label <- dplyr::case_when(
              (edge < center) & (Q2 < center) & (Q3 < center) &
                (Q2 > edge) & (Q3 > edge) & (center > edge) ~ "ACE",
              
              (center > edge) & (Q2 > edge) & (Q3 > edge) ~ "REDG",
              
              (edge < center) & (Q2 < center) & (Q3 < center) ~ "CEPE",
              
              TRUE ~ "CORE"
            )
            
            rep(label, dplyr::n())
          }
        ) |> 
        relocate(species:aou, .before = bin20) -> bin_abundance_summary
      
      
      bin_abundance_summary_all <- dplyr::bind_rows(bin_abundance_summary_all, bin_abundance_summary)
      
    }, error = function(e) {
      
      message("\n ERROR for species: ", sp)
      message("   ", conditionMessage(e))
      
      failed_species <<- c(failed_species, sp)
      
      # skip to next species
      return(NULL)
    })
  }
  
  return(list(
    g = g,
    
    pts_in_all = pts_in_all,
    
    routes_in_range_lst = routes_in_range_lst,
    
    bin_abundance_summary_all = bin_abundance_summary_all,
    
    failed_species = failed_species
  ))
  
}


args(hyp_fun)

first_dec_hyp <-hyp_fun(decade_df = abundance_first_dec,
                        prop_species_all = prop_species_all,
                        bbs_route_df = bbs_routes_first_dec,
                        land_map = land_equal_area,
                        species = species)



last_dec_hyp <-hyp_fun(decade_df = abundance_last_dec,
                       prop_species_all = prop_species_all,
                       bbs_route_df = bbs_routes_last_dec,
                       land_map = land_equal_area,
                       species = species)



first_dec_hyp$bin_abundance_summary_all


last_dec_hyp$bin_abundance_summary_all


first_dec_hyp$bin_abundance_summary_all |> 
  left_join(last_dec_hyp$bin_abundance_summary_all, by = "aou") -> test_df



first_dec_hyp$bin_abundance_summary_all |> 
  left_join(last_dec_hyp$bin_abundance_summary_all, by = c("aou","species"),
            relationship = "many-to-many",
            suffix = c("_first", "_last")) -> full_hyp_df


full_hyp_df |> 
  select(species,
         aou,
         hypothesis_first,
         hypothesis_last) |> 
  distinct(species, aou, hypothesis_first, hypothesis_last) -> hyp_final_df

first_dec_hyp$pts_in_all |> 
  dplyr::filter(aou == 6883)

## so it should be inland

first_dec_hyp$pts_in_all |> 
  sf::st_drop_geometry() |> 
  mutate(aou = as.character(aou)) |> 
  group_by(aou) |> 
  summarise(edge_type) |> 
  group_by(aou, edge_type) |> 
  summarise(
    count = n()
  ) |> 
  ungroup() |> 
  group_by(aou) |> 
  filter(count == max(count, na.rm = T)) |> 
  select(edge_type) |> 
  ungroup() -> edge_type_dat

edge_type_dat |> 
  mutate(edge_type = if_else(aou == 6883, "inland", edge_type)) -> edge_type_dat

sum(is.na(edge_type_dat))
write.csv(edge_type_dat, "edge_type_dat.csv")


## Unique routes

bbs_routes_selected |> 
  distinct(latitude, longitude) |> 
  count()

# 4780

## addressing some comments from the committee, Bo mentioned about how
## would the other species composition affect these pattern changes
## with this structure only way of doing is getting the number of 
## species observed at that route where the species was detected and 
## get the median species richness around the relevant species and get the
## difference between the two windows

first_dec_hyp$pts_in_all |> 
  sf::st_drop_geometry() |> 
  dplyr::group_by(aou) |> 
  summarise(
    median_sp_rich_first = median(stop_total)
  ) -> sp_rich_first_dec


last_dec_hyp$pts_in_all |> 
  sf::st_drop_geometry() |> 
  dplyr::group_by(aou) |> 
  summarise(
    median_sp_rich_last = median(stop_total)
  ) -> sp_rich_last_dec


sp_rich_first_dec |> 
  left_join(sp_rich_last_dec, by = "aou") -> sp_rich_dat


write.csv(sp_rich_dat, here::here("sp_rich_dat.csv"), row.names = F)

write.csv(hyp_final_df, here::here("hyp_final_df.csv"))

save.image(file = here::here("03_pattern_classification.RData"))
### 
