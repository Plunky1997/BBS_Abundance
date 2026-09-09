
### Phylogenetic PCA to get the reproductive slowness and fastness usisng 
## life history data



library(tidyverse)
library(ape)
library(phytools)


func_trait_complete <- read.csv(here::here("func_trait_complete.csv"))


## read the trends 

trends <-read.csv(here::here("Trends_df.csv"))


func_trait_complete |> 
  left_join(trends, by = "aou") -> func_trait_complete_2


## read the tree

phyl_tree <- ape::read.tree("AllBirdsHackett1.tre")


class(phyl_tree)
length(phyl_tree)

phyl_tree[[1]]

## get one tree

tree1 <- phyl_tree[[1]]


## check the species names with this


intersect(func_trait_complete_2$scientificNameStd, tree1$tip.label)


## let's create the data set for the PCA

names(func_trait_complete_2)

func_trait_complete_2 |> 
  select(scientificNameStd,
         aou,
         female_maturity_d:longevity_y) |> 
  mutate(across(female_maturity_d:longevity_y, log1p)) |> 
  mutate(scientificNameStd = str_replace_all(scientificNameStd, " ", "_")) -> rep_df


intersect(rep_df$scientificNameStd, tree1$tip.label)

library(geiger)


name.check(tree1, rep_df)


miss_sp <- setdiff(rep_df$scientificNameStd, tree1$tip.label)


## try det summary



miss_sp <- str_replace_all(miss_sp, "_", " ")

birdlife_v3_lookup <- c(
  "Haemorhous mexicanus" = "Carpodacus mexicanus",
  "Hesperiphona vespertina" = "Coccothraustes vespertinus",
  "Haemorhous purpureus" = "Carpodacus purpureus",
  "Haemorhous cassinii" = "Carpodacus cassinii",
  "Spinus tristis" = "Carduelis tristis",
  "Spinus lawrencei" = "Carduelis lawrencei",
  "Dryobates pubescens" = "Picoides pubescens",
  "Dryobates scalaris" = "Picoides scalaris",
  "Dryobates nuttallii" = "Picoides nuttallii",
  "Leuconotopicus villosus" = "Picoides villosus",
  "Leuconotopicus albolarvatus" = "Picoides albolarvatus",
  "Leuconotopicus borealis" = "Picoides borealis",
  "Poecile gambeli" = "Parus gambeli",
  "Poecile carolinensis" = "Parus carolinensis",
  "Poecile rufescens" = "Parus rufescens",
  "Poecile atricapillus" = "Parus atricapillus",
  "Poecile hudsonicus" = "Parus hudsonicus",
  "Passerculus henslowii" = "Ammodramus henslowii",
  "Peucaea aestivalis" = "Aimophila aestivalis",
  "Melozone crissalis" = "Pipilo crissalis",
  "Melozone fusca" = "Pipilo fuscus",
  "Melozone aberti" = "Pipilo aberti",
  "Rhynchophanes mccownii" = "Calcarius mccownii"
)

rep_df |> 
  mutate(scientificNameStd = str_replace_all(scientificNameStd, "_", " ")) |> 
  mutate(scientificNameStd = recode(
    scientificNameStd,
    !!!birdlife_v3_lookup,
    .default = scientificNameStd)) |> 
  mutate(scientificNameStd = str_replace_all(scientificNameStd, " ", "_")) -> rep_df_2


intersect(rep_df_2$scientificNameStd, tree1$tip.label)    

setdiff(rep_df_2$scientificNameStd, tree1$tip.label)

rep_df_2 |> 
  mutate(scientificNameStd = case_when(
    scientificNameStd == "Troglodytes_pacificus" ~ "Troglodytes_troglodytes",
    scientificNameStd == "Oreortyx_picta" ~ "Oreortyx_pictus",
    scientificNameStd == "Icterus_bullockiorum" ~ "Icterus_bullockii",
    TRUE ~ scientificNameStd
  )) -> rep_df_2

birdlife_v3_lookup_2 <- c("Setophaga_americana" = "Parula_americana",
                          "Setophaga_pinus" = "Dendroica_pinus",
                          "Setophaga_citrina" = "Wilsonia_citrina",
                          "Setophaga_discolor" = "Dendroica_discolor",
                          "Geothlypis_formosa" = "Oporornis_formosus",
                          "Cardellina_canadensis" = "Wilsonia_canadensis",
                          "Geothlypis_tolmiei" ="Oporornis_tolmiei",
                          "Vermivora_cyanoptera" = "Vermivora_pinus",
                          "Setophaga_dominica" = "Dendroica_dominica",
                          "Setophaga_caerulescens" = "Dendroica_caerulescens",
                          "Setophaga_fusca" = "Dendroica_fusca",
                          "Setophaga_virens" = "Dendroica_virens",
                          "Setophaga_nigrescens" = "Dendroica_nigrescens",
                          "Setophaga_cerulea" = "Dendroica_cerulea",
                          "Leiothlypis_virginiae" = "Vermivora_virginiae",
                          "Parkesia_motacilla" = "Seiurus_motacilla",
                          "Leiothlypis_ruficapilla" = "Vermivora_ruficapilla",
                          "Setophaga_pensylvanica" = "Dendroica_pensylvanica",
                          "Setophaga_occidentalis" = "Dendroica_occidentalis",
                          "Geothlypis_philadelphia" = "Oporornis_philadelphia",
                          "Selasphorus_calliope"  = "Stellula_calliope")

rep_df_2 |> 
  mutate(scientificNameStd = recode(
    scientificNameStd,
    !!!birdlife_v3_lookup_2,
    .default = scientificNameStd)) -> rep_df_3


intersect(rep_df_3$scientificNameStd, tree1$tip.label)


setdiff(rep_df_3$scientificNameStd, tree1$tip.label)


## matching the scientific names


## get an analysis data set without the aou so later I can join them with the PC scores

rep_df_3 |> 
  select(-aou) -> rep_df_4


rownames(rep_df_4) <- rep_df_4$scientificNameStd

rep_df_4 |> 
  select(-scientificNameStd) -> rep_df_4


class(phyl_tree)
length(phyl_tree)

tree1


## again to be confirm
## match the tree with the rownames

all(rownames(rep_df_4) %in% tree1$tip.label)

## nice

## reorder this 

rep_df_4[match(tree1$tip.label, rownames(rep_df_4)), ]

## shows lots of NA' SO I need to prune the tree to get the remaining 203 

shared_species <- intersect(tree1$tip.label, rownames(rep_df_4))

## now prune


tree_sub <- ape::drop.tip(
  tree1,
  setdiff(tree1$tip.label, shared_species)
)


## now try reorderingt the data related to the tree

rep_df_sub <- rep_df_4[match(tree_sub$tip.label,
                             rownames(rep_df_4)), ]


all(tree_sub$tip.label == rownames(rep_df_sub))

### good

ppca <- phyl.pca(
  tree = tree_sub,
  Y = rep_df_sub,
  method = "lambda",
  mode = "corr"
)


ppca$Eval

## get the percentages

ppca$Eval / sum(ppca$Eval) * 100

write.csv(as.data.frame(ppca$Eval / sum(ppca$Eval) * 100),
          here::here("ppca_pc_perc.csv"))

ppca$L

## the PC1 and PC2 shows a about 53 % of the variance

### PC1 tells that longer reproduction while
# PC2 explains mostly higher clutch size and lower life length

## I would say PC1 and PC2 would be enough to explain these


ppca$S

## this seems fine so I will loop through the whole trees.



### let's create a function to conduct the ppca for my data

ppca_conduct <- function(tree, data){
  
  
  shared_species <- intersect(tree$tip.label, rownames(data))
  
  ## now prune
  
  
  tree_sub <- ape::drop.tip(
    tree,
    setdiff(tree$tip.label, shared_species)
  )
  
  
  ## now try reorderingt the data related to the tree
  
  rep_df_sub <- data[match(tree_sub$tip.label,
                           rownames(data)), ]
  
  
  if(!all(tree_sub$tip.label == rownames(rep_df_sub))){
    message("species not aligned")
  }
  
  
  ## ppca
  
  ppca <- phyl.pca(
    tree = tree_sub,
    Y = rep_df_sub,
    method = "lambda",
    mode = "corr"
  )
  
  load_pc1 <- ppca$L[, 1]
  load_pc2 <- ppca$L[, 2]
  score_pc1 <- ppca$S[, 1]
  score_pc2 <- ppca$S[, 2]
  
  
  
  #### sign correction should be done to prevent it from cancelling the negatives and positives
  ## here the maturity, incubation and fledgings_age relate to slower rate of reproduction
  ## the first tree1 analysis showed that PC1 has higher loadings for these
  
  anchor_pc1 <- c(
    "female_maturity_d",
    "incubation_d",
    "fledging_age_d"
  )
  
  if (sum(load_pc1[anchor_pc1], na.rm = TRUE) < 0) {
    load_pc1 <- -load_pc1
    score_pc1 <- -score_pc1
  }
  
  ## in PC2 litter has higher loadings so larger clutch size
  
  if (load_pc2["litter_or_clutch_size_n"] < 0) {
    load_pc2 <- -load_pc2
    score_pc2 <- -score_pc2
  }
  
  
  ## the longevity also goes with the PC2
  
  if (load_pc2["longevity_y"] < 0) {
    load_pc2 <- -load_pc2
    score_pc2 <- -score_pc2
  }
  
  eval_vec <- diag(ppca$Eval)
  eval_vec <- eval_vec/sum(eval_vec)
  
  
  list(
    scores = tibble(
      species = names(score_pc1),
      pc1_score = as.numeric(score_pc1),
      pc2_score = as.numeric(score_pc2)
    ),
    loadings = tibble(
      trait = names(load_pc1),
      pc1_loading = as.numeric(load_pc1),
      pc2_loading = as.numeric(load_pc2)
    ),
    eval = eval_vec,
    lambda = ppca$lambda
  )  
}


## use the map to ge this done

# extract 5 and see

#phyl_tree_test <- phyl_tree[1:2]

all_ppca <- purrr::imap(phyl_tree_test, ~{
  message("Running tree", .y)
  ppca_conduct(tree = .x, data = rep_df_4)})


##for the whole


all_ppca <- purrr::imap(phyl_tree, ~{
  message("Running tree", .y)
  ppca_conduct(tree = .x, data = rep_df_4)})

score_df <- map_dfr(
  seq_along(all_ppca),
  ~ all_ppca[[.x]]$scores |> 
    mutate(tree_id = .x)
)

score_summary <- score_df |> 
  group_by(species) |> 
  summarise(
    pc1 = mean(pc1_score),
    pc2 = mean(pc2_score)
  )


loading_df <- map_dfr(
  seq_along(all_ppca),
  ~ all_ppca[[.x]]$loadings |> 
    mutate(tree_id = .x)
)


loading_summary <- loading_df  |> 
  group_by(trait) |> 
  summarise(
    pc1_load = mean(pc1_loading),
    pc2_load = mean(pc2_loading)
    
  )


write.csv(loading_summary, here::here("pc_loading_summary.csv"))

eval_df <- purrr::map_dfr(
  seq_along(all_ppca),
  ~ tibble::tibble(
    tree_id = .x,
    pc = paste0("PC", seq_along(all_ppca[[.x]]$eval)),
    prop_var = all_ppca[[.x]]$eval
  )
)


eval_summary <- eval_df |>
  dplyr::group_by(pc) |>
  dplyr::summarise(
    mean_prop = mean(prop_var),
    .groups = "drop"
  ) |>
  dplyr::mutate(
    mean_percent = mean_prop * 100
  )



score_summary |>
  arrange(desc(pc1)) |>
  head(10)

### nice works well. So get these in to the main data set

names(rep_df_3)

score_summary |> 
  mutate(scientificNameStd = species) |> 
  left_join(rep_df_3, by = "scientificNameStd") |> 
  select(-species) |> 
  relocate(scientificNameStd, .before = pc1) |> 
  select(scientificNameStd,
         aou,
         pc1,
         pc2) |> 
  rename("species" = "scientificNameStd" ) |> 
  left_join(func_trait_complete_2, by = "aou") |> 
  select(-species) |> 
  relocate(scientificNameStd, .before = aou) |> 
  relocate(pc1:pc2, .after = last_col()) -> func_trait_complete_3


write.csv(func_trait_complete_3, "func_pca.csv")

save(all_ppca, file = here::here("all_ppca.RData"))


## i have a problem with getting the species matched in the later loop so i will need the aou

## so

rep_df_3 |> 
  select(scientificNameStd,
         aou) -> species_name_aou

write.csv(species_name_aou, "species_pc_name_aou.csv")


write.csv(score_df, "pc_score_df.csv")
