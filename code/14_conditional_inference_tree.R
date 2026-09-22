#### run for the decision tree

library(partykit)
library(ggparty) 
library(tidyverse)

## firs for the REDG

load(here::here("REDG_selected_model_data_3.RData"))

load(here::here("ACE_selected_model_data_3.RData"))


summary(model_REDG)



summary(model_ACE)


# for the REDG i would need the 

## change status
#Trens
#HWI
## pc1
## and aou

func_an_REDG |> 
  dplyr::select(aou,
                Trend,
                Hand.wing.Index,
                pc1,
                edge_type,
                change_status) -> REDG_DC_DF

str(REDG_DC_DF)
unique(REDG_DC_DF$change_status)
## convert the character variables for the factors

REDG_DC_DF |> 
  dplyr::mutate(edge_type = factor(edge_type, levels = c("coastline", "inland"))) |> 
  dplyr::mutate(change_status = factor(change_status, 
                                       levels = c("REDG_REDG",
                                                  "NRG_NRG",
                                                  "NRG_REDG",
                                                  "REDG_NRG"))) |> 
  dplyr::mutate(Trend_NL = (Trend^2))-> REDG_DC_DF


str(REDG_DC_DF)
### note that the hand wing index is log transformed
table(REDG_DC_DF$change_status)

## the section of the REDG and NRG has a smaller observations
# compared to the others and personally I think this should be weighted


class_counts_REDG <- table(REDG_DC_DF$change_status)

## I would use the inverse frequency weighting to make sure that the
# optimizing procedure will effectively done

weights_REDG <- nrow(REDG_DC_DF) / 
  (nlevels(REDG_DC_DF$change_status) * 
     class_counts_REDG[REDG_DC_DF$change_status])

## let's see the weights

round(nrow(REDG_DC_DF) / (4 * class_counts_REDG), 2)

weights_REDG

cw_REDG <- as.integer(round(weights_REDG * 10))

REDG_ctree <- ctree(
  change_status ~ Hand.wing.Index + pc1 + Trend_NL + edge_type,
  data    = REDG_DC_DF,
  weights = cw_REDG,
  control = ctree_control(
    alpha        = 0.05,   
    mincriterion = 0.95,   
    minsplit     = 20,
    minbucket    = 10,
    maxdepth     = 3       
  )
)

plot(REDG_ctree)           
print(REDG_ctree)   



set.seed(123)
folds_REDG <- caret::createFolds(REDG_DC_DF$change_status, k = 10)

grid_REDG <- expand.grid(
  maxdepth  = c(2, 3, 4, 5),
  minbucket = c(5, 10, 15, 20),
  minsplit  = c(10, 20,30,  40)
)

grid_REDG$acc <- NA

for (i in 1:nrow(grid_REDG)) {
  accs <- c()
  for (f in folds_REDG) {
    train <- REDG_DC_DF[-f, ]; test <- REDG_DC_DF[f, ]
    w <- cw_REDG[-f]
    
    fit <- ctree(
      change_status ~ Hand.wing.Index + pc1 + Trend_NL + edge_type,
      data = train, weights = w,
      control = ctree_control(
        maxdepth  = grid_REDG$maxdepth[i],
        minbucket = grid_REDG$minbucket[i],
        minsplit  = grid_REDG$minsplit[i]
      )
    )
    pred <- predict(fit, newdata = test)
    accs <- c(accs, mean(pred == test$change_status))
  }
  grid_REDG$acc[i] <- mean(accs)
}


grid_REDG[order(-grid_REDG$acc), ] 


## what we would do here, to increase the interpretability of the data, we shall stick with the
## maxdepth 3 and keep misplit ad min bucket with the suggested values


REDG_ctree_opt <- ctree(
  change_status ~ Hand.wing.Index + pc1 + Trend_NL + edge_type,
  data    = REDG_DC_DF,
  weights = cw_REDG,
  control = ctree_control(
    alpha        = 0.05,   
    mincriterion = 0.95,   
    minsplit     = 10,
    minbucket    = 5,
    maxdepth     = 3       
  )
)


plot(REDG_ctree_opt)

REDG_leaf_data <- REDG_DC_DF |>
  dplyr::mutate(
    leaf_node = predict(REDG_ctree_opt, type = "node"),
    weight = cw_REDG
  )


# Weighted counts and percentages per leaf node
REDG_leaf_percentages <- REDG_leaf_data |>
  group_by(leaf_node, change_status) |>
  summarise(weighted_n = sum(weight), .groups = "drop") |>
  group_by(leaf_node) |>
  mutate(
    total_weighted_n = sum(weighted_n),
    percentage = weighted_n / total_weighted_n * 100
  ) |>
  arrange(leaf_node, desc(percentage))


write.csv(as.data.frame(print(REDG_leaf_percentages, n= 23)), here::here("REDG_con_inf_perc_df.csv"))



colors_REDG <- c("REDG_REDG" = "#410000",
                 "REDG_NRG" = "#7a3700",
                 "NRG_NRG" = "#ba6d00",
                 "NRG_REDG" = "#ffa500")

leaf_nodes_REDG <- as.character(unique(REDG_leaf_percentages$leaf_node))


list_leaf_REDG = list()

for(name in leaf_nodes_REDG){
  
  list_leaf_REDG[[name]] =  REDG_leaf_percentages |> 
    filter(leaf_node == name) |> 
    ggplot(aes(x = "",y = percentage, fill = change_status))+
    geom_col()+
    coord_flip()+
    scale_fill_manual(values = colors_REDG)+
    theme(panel.background = element_blank(),
          axis.line = element_line(colour = "black"),
          axis.text.x = element_text(size = 34),
          axis.title = element_text(size = 35),
          axis.title.y = element_blank(),
          axis.line.y = element_blank(),
          legend.position = "none")
}




library(purrr)

purrr::imap(list_leaf_REDG, ~ ggsave(here::here(paste0("Figures/Leaf_nodes/REDG/", .y, ".pdf")),
                                     dpi = 300,
                                     plot = .x,
                                     device = cairo_pdf,
                                     units = "in",
                                     width = 10,
                                     height = 7))



set.seed(123)
B <- 500

boot_splits <- replicate(B, {
  idx <- sample(nrow(REDG_DC_DF), replace = TRUE)
  boot_data <- REDG_DC_DF[idx, ]
  boot_wts  <- cw_REDG[idx]
  
  tryCatch({
    bt <- ctree(
      change_status ~ Hand.wing.Index + pc1 + Trend_NL + edge_type,
      data    = boot_data,
      weights = boot_wts,
      control = ctree_control(
        alpha        = 0.05,   
        mincriterion = 0.95,   
        minsplit     = 30,
        minbucket    = 5,
        maxdepth     = 3
      )
    )
    # Extract root split variable
    as.character(bt$node$split$varid |> 
                   (\(id) names(boot_data)[id])())
  }, error = function(e) NA_character_)
})

# How often does each variable win the root?
table(boot_splits) / B * 100



### for the ACE

summary(model_ACE)

func_an_ACE |> 
  dplyr::select(aou,
                Trend,
                Hand.wing.Index,
                pc1,
                edge_type,
                change_status) -> ACE_DC_DF

str(ACE_DC_DF)
unique(ACE_DC_DF$change_status)
## convert the character variables for the factors

ACE_DC_DF |> 
  dplyr::mutate(edge_type = factor(edge_type, levels = c("coastline", "inland"))) |> 
  dplyr::mutate(change_status = factor(change_status, 
                                       levels = c("ACE_ACE",
                                                  "NACE_NACE",
                                                  "NACE_ACE",
                                                  "ACE_NACE"))) |> 
  dplyr::mutate(Trend_NL = (Trend^2))-> ACE_DC_DF


str(ACE_DC_DF)
### note that the hand wing index is log transformed
table(ACE_DC_DF$change_status)

## better to weight this one as well


class_counts_ACE <- table(ACE_DC_DF$change_status)

## I would use the inverse frequency weighting to make sure that the
# optimizing procedure will effectively done

weights_ACE <- nrow(ACE_DC_DF) / 
  (nlevels(ACE_DC_DF$change_status) * 
     class_counts_ACE[ACE_DC_DF$change_status])

## let's see the weights

round(nrow(ACE_DC_DF) / (4 * class_counts_ACE), 2)

weights_ACE

cw_ACE <- as.integer(round(weights_ACE * 10))

ACE_ctree <- ctree(
  change_status ~ Hand.wing.Index + pc1 + Trend_NL + edge_type,
  data    = ACE_DC_DF,
  weights = cw_ACE,
  control = ctree_control(
    alpha        = 0.05,
    mincriterion = 0.95,
    minsplit     = 20,
    minbucket    = 10,
    maxdepth     = 4
  )
)




plot(ACE_ctree)
print(ACE_ctree)


set.seed(123)
folds <- caret::createFolds(ACE_DC_DF$change_status, k = 10)

grid <- expand.grid(
  maxdepth  = c(2, 3, 4, 5),
  minbucket = c(5, 10, 15, 20),
  minsplit  = c(10, 20,30,  40)
)

grid$acc <- NA

for (i in 1:nrow(grid)) {
  accs <- c()
  for (f in folds) {
    train <- ACE_DC_DF[-f, ]; test <- ACE_DC_DF[f, ]
    w <- cw_ACE[-f]
    
    fit <- ctree(
      change_status ~ Hand.wing.Index + pc1 + Trend_NL + edge_type,
      data = train, weights = w,
      control = ctree_control(
        maxdepth  = grid$maxdepth[i],
        minbucket = grid$minbucket[i],
        minsplit  = grid$minsplit[i]
      )
    )
    pred <- predict(fit, newdata = test)
    accs <- c(accs, mean(pred == test$change_status))
  }
  grid$acc[i] <- mean(accs)
}

grid[order(-grid$acc), ] 


ACE_ctree <- ctree(
  change_status ~ Hand.wing.Index + pc1 + Trend_NL + edge_type,
  data    = ACE_DC_DF,
  weights = cw_ACE,
  control = ctree_control(
    alpha        = 0.05,
    mincriterion = 0.95,
    minsplit     = 10,
    minbucket    = 5,
    maxdepth     = 3
  )
)



plot(ACE_ctree)
print(ACE_ctree)


ACE_leaf_data <- ACE_DC_DF |>
  dplyr::mutate(
    leaf_node = predict(ACE_ctree, type = "node"),
    weight = cw_ACE
  )
# Weighted counts and percentages per leaf node
ACE_leaf_percentages <- ACE_leaf_data |>
  group_by(leaf_node, change_status) |>
  summarise(weighted_n = sum(weight), .groups = "drop") |>
  group_by(leaf_node) |>
  mutate(
    total_weighted_n = sum(weighted_n),
    percentage = weighted_n / total_weighted_n * 100
  ) |>
  arrange(leaf_node, desc(percentage))

write.csv(as.data.frame(print(ACE_leaf_percentages, n = 23)), here::here("ACE_cond_inf_perc_df.csv"))



set.seed(123)
B <- 500

boot_splits_ACE <- replicate(B, {
  idx <- sample(nrow(ACE_DC_DF), replace = TRUE)
  boot_data <- ACE_DC_DF[idx, ]
  boot_wts  <- cw_ACE[idx]
  
  tryCatch({
    bt <- ctree(
      change_status ~ Hand.wing.Index + pc1 + Trend_NL + edge_type,
      data    = boot_data,
      weights = boot_wts,
      control = ctree_control(
        alpha        = 0.05,
        mincriterion = 0.95,
        minsplit     = 10,
        minbucket    = 5,
        maxdepth     = 3
      )
    )
    # Extract root split variable
    as.character(bt$node$split$varid |> 
                   (\(id) names(boot_data)[id])())
  }, error = function(e) NA_character_)
})

# How often does each variable win the root?
table(boot_splits_ACE) / B * 100





### stacked bars for the tree###
##ACE##


colors_ACE <- c("ACE_ACE" = "#410000",
                "ACE_NACE" = "#7a3700",
                "NACE_NACE" = "#ba6d00",
                "NACE_ACE" = "#ffa500")

leaf_nodes_ACE <- as.character(unique(ACE_leaf_percentages$leaf_node))


list_leaf_ACE = list()

for(name in leaf_nodes_ACE){
  
  list_leaf_ACE[[name]] =  ACE_leaf_percentages |> 
    filter(leaf_node == name) |> 
    ggplot(aes(x = "",y = percentage, fill = change_status))+
    geom_col()+
    coord_flip()+
    scale_fill_manual(values = colors_ACE)+
    theme(panel.background = element_blank(),
          axis.line = element_line(colour = "black"),
          axis.text.x = element_text(size = 34),
          axis.title = element_text(size = 35),
          axis.title.y = element_blank(),
          axis.line.y = element_blank(),
          legend.position = "none")
}


list_leaf_ACE


library(purrr)

purrr::imap(list_leaf_ACE, ~ ggsave(here::here(paste0("Figures/Leaf_nodes/ACE/", .y, ".pdf")),
                                    dpi = 300,
                                    plot = .x,
                                    device = cairo_pdf,
                                    units = "in",
                                    width = 10,
                                    height = 7))

save.image(file = here::here("14_conditional_inference_tree.RData"))
