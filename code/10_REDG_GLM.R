######## For the Rare edge vs non rare edge  ###############################


## get the data set

func_an_REDG <- read.csv("func_an_REDG.csv")


#### getting that committee suggestion here with the community structure change
# effect on the pattern changes, got the species richness data

sp_rich <- read.csv("sp_rich_dat.csv")

sp_rich$rich_dif <- sp_rich$median_sp_rich_last - sp_rich$median_sp_rich_first

func_an_REDG |> 
  dplyr::relocate(edge_type, .before = change) -> func_an_REDG

func_an_REDG$rich_dif <- sp_rich$rich_dif

sum(is.na(func_an_REDG))
colSums(is.na(func_an_REDG))

## check for the corealtion
GLM_cor <- glm(change ~ primary_habitat + primary_diet + Hand.wing.Index + BodyMass.Value 
               + edge_type + Trend + pc1 + pc2 + rich_dif,
               data = func_an_REDG,
               family = binomial)

car::vif(GLM_cor)

## Body mass has the highest here, so see what is it corelated with

func_an_REDG |> 
  dplyr::select(where(is.numeric)) |> 
  cor() -> cor_matrix


write.csv(cor_matrix, here::here("cor_matrix.csv"))

## body mass valus has a strong corelation between the pc1. 
# pc1 stores lots of information regards to the reproduction 
# which vital in the objectives and range changes as well
# therefore we shall remove the body mass from the dredging
## all the other variables has lower thant 50..

GLM_cor_2 <- glm(change ~ primary_habitat + primary_diet + Hand.wing.Index 
                 + edge_type + Trend + pc1 + pc2 + rich_dif,
                 data = func_an_REDG,
                 family = binomial)

car::vif(GLM_cor_2)
## all are below 2 so seems safe

## try the models

GLM_full <- lme4::glmer(change ~ primary_habitat*primary_diet*Hand.wing.Index 
                        + edge_type + (Trend + I(Trend^2)) + pc1 + pc2 + (1|Family),
                        data = func_an_REDG,
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
                        data = func_an_REDG,family = binomial 
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
                          data = func_an_REDG,family = binomial)

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
                  data = func_an_REDG,family = binomial)


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

write.csv(as.data.frame(sw(sum_avg)), here::here("REDG.AW_akike.csv"))

### so same thing the Trend should be replaced with the (trend + I(trend^2))

##### seems good


## again check with the ranodm intercept for these variable

GLM_filt_cor <- glm(change ~ (Trend + I(Trend^2)) + Hand.wing.Index + pc1 + 
                      edge_type,
                    data = func_an_REDG,
                    family = binomial)

GLM_filt_1 <- lme4::glmer(change ~ (Trend + I(Trend^2)) + Hand.wing.Index + pc1 + 
                            edge_type + 
                            (1|Family),
                          data = func_an_REDG,
                          family = binomial)


GLM_filt_2 <- lme4::glmer(change ~ (Trend + I(Trend^2)) + Hand.wing.Index + pc1 + 
                            edge_type +
                            (pc1|Family),
                          data = func_an_REDG,
                          family = binomial)

GLM_filt_3 <- lme4::glmer(change ~ (Trend + I(Trend^2)) + Hand.wing.Index + pc1 + 
                            edge_type +
                            (BodyMass.Value|Family),
                          data = func_an_REDG,
                          family = binomial)

GLM_filt_4 <- lme4::glmer(change ~ (Trend + I(Trend^2)) + Hand.wing.Index + pc1 + 
                            edge_type +
                            (Hand.wing.Index|Family),
                          data = func_an_REDG,
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
               data = func_an_REDG,
               family = binomial)


summary(model_1)




library(DHARMa)


resid <- simulateResiduals(model_1)

plot(resid)

## better


#### go for the figures ###

## save the images for the load for the figures

model_REDG <- model_1

save(model_REDG,
     func_an_REDG, file = here::here("REDG_selected_model_data_3.RData"))


write.csv(as.data.frame(func_an_REDG |> 
  select(
    aou,
    scientificNameStd,
    Family,
    change_status
  )), here::here("REDG_pattern_change_data.csv"))
