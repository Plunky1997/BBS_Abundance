######## For the Rare edge vs non rare edge  ###############################


## get the data set

func_an_ACE <- read.csv("func_an_ACE.csv")

#### getting that committee suggestion here with the community structure change
# effect on the pattern changes, got the species richness data

sp_rich <- read.csv("sp_rich_dat.csv")

sp_rich$rich_dif <- sp_rich$median_sp_rich_last - sp_rich$median_sp_rich_first

func_an_ACE |> 
  dplyr::relocate(edge_type, .before = change) -> func_an_ACE

func_an_ACE$rich_dif <- sp_rich$rich_dif

sum(is.na(func_an_ACE))
colSums(is.na(func_an_ACE))

## check for the corealtion
GLM_cor <- glm(change ~ primary_habitat + primary_diet + Hand.wing.Index + BodyMass.Value 
               + edge_type + Trend + pc1 + pc2 + rich_dif,
               data = func_an_ACE,
               family = binomial)

car::vif(GLM_cor)

#Body mass

## try the models

GLM_full <- lme4::glmer(change ~ primary_habitat*primary_diet*Hand.wing.Index
                        + edge_type + (Trend + I(Trend^2)) + pc1 + pc2 + (1|Family),
                        data = func_an_ACE,
                        family = binomial)

## too much for handling the interactions so we shall consider only the reproductive pc and others interactions
## which make sense to keep the full model befoe dredging

GLM_full <- lme4::glmer(change ~
                          primary_habitat + primary_diet + Hand.wing.Index + pc1 + pc2 + edge_type +
                          (Trend + I(Trend^2)) +
                          rich_dif +
                          primary_habitat:pc1 +
                          primary_diet:pc1 +
                          Hand.wing.Index:pc1 +
                          (Trend + I(Trend^2)):pc1 +
                          edge_type:pc1 +
                          (1|Family), 
                        data = func_an_ACE,family = binomial 
)

## seems like the family variance is not explaining, try incorperating the pc1 in the family

GLM_full_2 <- lme4::glmer(change ~
                            primary_habitat + primary_diet + Hand.wing.Index + pc1 + pc2 + edge_type +
                            (Trend + I(Trend^2)) +
                            rich_dif +
                            primary_habitat:pc1 +
                            primary_diet:pc1 +
                            Hand.wing.Index:pc1 +
                            (Trend + I(Trend^2)):pc1 +
                            edge_type:pc1 +
                            (pc1|Family), 
                          data = func_an_ACE,family = binomial)

## still not much effect because singular boundary fit
##

GLM_full_3 <- glm(change ~
                    primary_habitat + primary_diet + Hand.wing.Index + pc1 + pc2 + edge_type +
                    (Trend + I(Trend^2)) +
                    rich_dif +
                    primary_habitat:pc1 +
                    primary_diet:pc1 +
                    Hand.wing.Index:pc1 +
                    (Trend + I(Trend^2)):pc1 +
                    edge_type:pc1,
                  data = func_an_ACE,family = binomial)


bbmle::AICctab(GLM_full,
               GLM_full_2,
               GLM_full_3)

## without the family as the random intercept seems to be doing fine for the full model. But, we shall keep the 
## family as the random intercept while dredging to select the variables as we never know which variable
## acounts for the family varability


options(na.action = "na.fail")

library(MuMIn)


mod_select <- MuMIn::dredge(GLM_full,trace = TRUE,evaluate = TRUE,rank = "AICc")
#32767 

sum_avg <- summary(MuMIn::model.avg(mod_select, rank = "AICc"))

sum_avg$msTable

sw(sum_avg)

write.csv(as.data.frame(sw(sum_avg)), here::here("ACE_SW_AKike.csv"))

### seems like the edge type and the PC1 are the good predictors on the abundant centre
## unlike the rare edge scenario...
## I shall keep the moderate variables as well, because these are biologically
## meaningful as well



## again check with the ranodm intercept for these variable

GLM_filt_cor <- glm(change ~ (Trend + I(Trend^2)) + Hand.wing.Index + pc1 + 
                      edge_type,
                    data = func_an_ACE,
                    family = binomial)

GLM_filt_1 <- lme4::glmer(change ~ (Trend + I(Trend^2)) + Hand.wing.Index + pc1 + 
                            edge_type + 
                            (1|Family),
                          data = func_an_ACE,
                          family = binomial)


GLM_filt_2 <- lme4::glmer(change ~ (Trend + I(Trend^2)) + Hand.wing.Index + pc1 + 
                            edge_type +
                            (pc1|Family),
                          data = func_an_ACE,
                          family = binomial)

GLM_filt_3 <- lme4::glmer(change ~ (Trend + I(Trend^2)) + Hand.wing.Index + pc1 + 
                            edge_type +
                            (BodyMass.Value|Family),
                          data = func_an_ACE,
                          family = binomial)

GLM_filt_4 <- lme4::glmer(change ~ (Trend + I(Trend^2)) + Hand.wing.Index + pc1 + 
                            edge_type +
                            (Hand.wing.Index|Family),
                          data = func_an_ACE,
                          family = binomial)

## test for the random variable

bbmle::AICctab(GLM_filt_1,
               GLM_filt_2,
               GLM_filt_4,
               GLM_filt_cor)



#### So without the random structure the model do better, so we will use that

## now test the best model for the vallidation


model_1 <- glm(change ~ (Trend + I(Trend^2)) + Hand.wing.Index + pc1 +
                 edge_type,
               data = func_an_ACE,
               family = binomial)


summary(model_1)



library(DHARMa)


resid <- simulateResiduals(model_1)

plot(resid)

## fine


#### go for the figures ###

## save the images for the load for the figures

model_ACE <-  model_1

save(model_ACE,
     func_an_ACE,file = here::here("ACE_selected_model_data_3.RData"))

write.csv(as.data.frame(func_an_ACE |> 
                          select(
                            aou,
                            scientificNameStd,
                            Family,
                            change_status
                          )), here::here("ACE_pattern_change_data.csv"))
