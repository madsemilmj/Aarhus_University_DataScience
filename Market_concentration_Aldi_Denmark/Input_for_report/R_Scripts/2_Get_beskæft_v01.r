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

see <- dst_search(string = "AKU131A", field = "id")

useTab <- "RAS310"
meta   <- dst_meta(table = useTab, lang = "da")

tmp1 <- dst_get_data(table = useTab, 
                     OMR�DE = "*",
                     UDDANNELSE = "I alt",
                     BRANCHE07 = "TOT Erhverv i alt",
                     ALDER = "Alder i alt",
                     K�N = "I alt",
                     Tid = "2018", 
                     lang = "da", 
                     meta_data = meta)

(tmp1 <- tibble(
                Omr�de = tmp1$OMR�DE,
                Besk   = tmp1$value
              )
)

tmp2 <- meta$values$OMR�DE

(tmp2 <- tibble(
                  Omr�de = tmp2$text,
                  Id     = tmp2$id,
                )
)


(Besk_data = tmp1 %>% inner_join(tmp2, by = "Omr�de") %>% arrange(Id) %>% select(Id, Omr�de, Besk))


saveRDS(Besk_data, file = paste0("Input/Besk_data.rds"))

