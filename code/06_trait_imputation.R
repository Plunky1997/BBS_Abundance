##### Imputing the data set to have the completed data set to analysis data

library(tidyverse)
library(mice)
library(Amelia)
library(missMDA)
library(Hmisc)
library(norm)

func_trait_df <- read.csv(here::here("func_trait_df.csv"))


func_trait_df |> 
  select(-X) -> func_trait_df


## for the imputation we shall remove the hypothesis assesment variables
## to prevent the imputing of data based on these

func_trait_df |> 
  select(-(aou:trans_type)) -> impute_df


impute_df |> 
  select(where(is.numeric)) -> func_num

#mice:
  
  m <- 1000

imp <- mice(func_num,  m  =  m, method="pmm")


agglomerate.data<-function(data,imp,Mimp,Method="mice"){
  
  Moy<-Mimp+1
  redata<-as.matrix(data)
  ximp<-array(redata,dim=c(nrow(redata),ncol(redata),Moy))
  #####################
  
  if(any(is.na(redata))==TRUE){
    if(Method=="mice" || Method=="amelia" || Method=="missmda" || Method=="hmisc" || Method=="norm"){
      #####################MICE
      if(Method=="mice"){
        
        for(i in 1:Mimp){
          ximp[,,i]<-as.matrix(complete(imp,i))
          
        }
        ##Averaged dataset
        ximp[,,Moy]<-apply(ximp[,,1:Mimp],c(1,2),mean)
      }
      #####################
      #####################Amelia
      if(Method=="amelia"){
        for(i in 1:Mimp){
          ximp[,,i]<-as.matrix(imp$imputations[[i]])
          
        }
        ##Averaged dataset
        ximp[,,Moy]<-apply(ximp[,,1:Mimp],c(1,2),mean)
      }
      #####################
      #####################
      #####################NORM
      if(Method=="norm"){
        for(i in 1:Mimp){
          ximp[,,i]<-as.matrix(imp[[i]])
          
        }
        ##Averaged dataset
        ximp[,,Moy]<-apply(ximp[,,1:Mimp],c(1,2),mean)
      }
      #####################
      #####################MDA
      if(Method=="missmda"){
        
        for(i in 1:Mimp){
          ximp[,,i]<-as.matrix(imp$res.MI[,,i])
          
        }
        ##Averaged dataset
        ximp[,,Moy]<-apply(ximp[,,1:Mimp],c(1,2),mean)
      }
      ####################
      ####################Hmisc
      if(Method=="hmisc"){
        ##Extract the m data imputed for each variables
        ximp<-array(redata, dim=c(nrow(redata),ncol(redata),Moy))
        col<-1:ncol(redata)
        for(j in 1:ncol(redata)){
          if(sum(is.na(redata[,j]))==0){
            col<-col[-which(col==j)]
            next
          }
        }
        for(m in 1:Mimp){
          for(g in col){
            ximp[,,m][!complete.cases(ximp[,,m][,g]),g]<-imp$imputed[[g]][,m]
          }
        }
        ##Averaged dataset
        ximp[,,Moy]<-apply(ximp[,,1:Mimp],c(1,2),mean)
        
      }
    }else{
      ####################
      ##Warning messages
      cat("Error! You must indicate if you are using Mice, Amelia, missMDA, NORM, or Hmisc package","\n")
    }}else{
      ## Warning messages
      cat("There is no missing value in your dataset","\n")
    }
  #return(ximp)
  tabM<-ximp[,,Moy]
  colnames(tabM)<-colnames(redata)
  list("ImpM"=tabM,"Mi"=ximp[,,1:Mimp],"nbMI"=Mimp, "missing"=as.data.frame(redata))
}

IM <- agglomerate.data(data = func_num, imp = imp, Mimp = m, Method = "mice")

complete_func <- IM$ImpM


func_trait_df |> 
  select(Order:trans_type,
         primary_habitat,
         primary_diet) |> 
  bind_cols(complete_func) -> func_trait_complete


write.csv(func_trait_complete, here::here("func_trait_complete.csv"))
