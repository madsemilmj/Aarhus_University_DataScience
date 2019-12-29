rm(list=ls())

is.installed <- function(mypkg) is.element(mypkg, installed.packages()[,1]) 

.libPaths("C:/Users/alu/OneDrive - Copenhagen Economics A S/Documents/R_library")

if(!is.installed("rstudioapi")) install.packages("rstudioapi")
if(!is.installed("stringr"))    install.packages("stringr")
if(!is.installed("tidyverse"))  install.packages("tidyverse")

library("rstudioapi")    
library("stringr")
library("tidyverse")

get_script_path <- function() {
  path <- rstudioapi::getActiveDocumentContext()$path
  return(str_sub(path,1,max(str_locate_all(path,"/")[[1]][,"end"])))
}

ScriptPath <- get_script_path()

# Set working directory
setwd(ScriptPath)


if(!require("devtools")) install.packages("devtools")
library("devtools")
#install_github("rOpenGov/dkstat")
library(dkstat)

useTab <- "FOLK1C"
meta   <- dst_meta(table = useTab, lang = "da")

tmp1 <- dst_get_data(table = useTab, 
                     OMRÅDE = "*",
                     HERKOMST = "*",
                     TID = "2019K3", 
                     lang = "da", 
                     meta_data = meta)

(tmp1 <- tibble(
                Område = tmp1$OMRÅDE,
                Herkomst = tmp1$HERKOMST,
                Antal  = tmp1$value,
              )
)

tmp2 <- meta$values$OMRÅDE

(tmp2 <- tibble(
                Område = tmp2$text,
                Id     = tmp2$id,
              )
)

(Pop_data = tmp1 %>% inner_join(tmp2, by = "Område") %>% arrange(Id) %>% select(Id, Område, Herkomst, Antal))

Pop_data <- Pop_data %>% spread(key = Herkomst, value = Antal)
Pop_data <- select(Pop_data,-c(Efterkommere))

names(Pop_data) <- c("Id","Område","Total","Indvandrere","Dansk_oprindelse")

saveRDS(Pop_data, file = paste0("Input/Population_Herkomst.rds"))
