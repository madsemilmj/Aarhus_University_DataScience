rm(list=ls())

is.installed <- function(mypkg) is.element(mypkg, installed.packages()[,1]) 

.libPaths("C:/Users/alu/OneDrive - Copenhagen Economics A S/Documents/R_library")

if(!is.installed("rstudioapi")) install.packages("rstudioapi")
if(!is.installed("stringr"))    install.packages("stringr")
if(!is.installed("tidyverse"))  install.packages("tidyverse")
if(!is.installed("readxl"))   install.packages("readxl")


library("rstudioapi")    
library("stringr")
library("tidyverse")
library("readxl")


get_script_path <- function() {
  path <- rstudioapi::getActiveDocumentContext()$path
  return(str_sub(path,1,max(str_locate_all(path,"/")[[1]][,"end"])))
}

ScriptPath <- get_script_path()

# Set working directory
setwd(ScriptPath)

df  <- read_xlsx("Input/regionsopdelt-postnummer-06-19.xlsx")  # Load the data

df  <- df %>% rename(Region_Nr = AMTS_NR)
df  <- df %>% rename(Region = ADRESSERINGSNAVN)
df  <- df %>% rename(Kommune_Nr = KOMMUNE_NR)
df  <- df %>% rename(Kommune = ADRESSERINGSNAVN_1)
df  <- df %>% rename(Post_Nr = POSTNR)

UseStores <- c("Netto","Fakta","ALDI","REMA 1000","Lidl")

for (useStore in UseStores){
  
  mydata <- readRDS(file = str_c("Input/",useStore,".rds"))
  
  tbl <- tibble( 
                Post_Nr = str_trim(str_extract(mydata$address, " \\d\\d\\d\\d ")),
              ) %>% 
          group_by(Post_Nr) %>% 
          summarise(!!useStore :=  n())
  
  df  <- df %>% left_join(tbl,by=c("Post_Nr"))
}

df1  <- df %>% replace(., is.na(.), 0) %>% group_by(Kommune) %>%
        summarise(Region_Nr = mean(Region_Nr),
                  Kommune_Nr = mean(Kommune_Nr),
                  Netto = sum(Netto),
                  Fakta = sum(Fakta),
                  ALDI  = sum(ALDI),
                  REMA  = sum(`REMA 1000`),
                  Lidl  = sum(Lidl)
  )

df1  <-  distinct(df[,1:2]) %>% right_join(df1,by=c("Region_Nr"))

df1$Region <- unlist(select(df1, Region)) %>% str_sub(8,)

saveRDS(df1, file = paste0("Input/DiscountStores.rds"))

