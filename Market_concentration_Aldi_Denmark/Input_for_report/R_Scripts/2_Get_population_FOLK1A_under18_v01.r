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


useTab <- "FOLK1A"
meta   <- dst_meta(table = useTab, lang = "da")

folk1a_meta <- dst_meta(table = useTab, lang = "da")

tmp1 <- dst_get_data(table = useTab, 
                     OMRÅDE = "*",
                     ALDER = "*",
                     TID = "2019K3", 
                     lang = "da", 
                     meta_data = meta)

(tmp1 <- tibble(
                Område = tmp1$OMRÅDE,
                Alder  = tmp1$ALDER,
                Antal  = tmp1$value,
              )
)

tmp2 <- meta$values$OMRÅDE

(tmp2 <- tibble(
                Område = tmp2$text,
                Id     = tmp2$id,
              )
)

(Pop_data = tmp1 %>% inner_join(tmp2, by = "Område") %>% arrange(Id) %>% select(Id, Område, Alder, Antal))

Pop_data <- Pop_data %>% spread(key = Alder, value = Antal)

ages <- names(select(Pop_data, ends_with("år"))) %>% str_split(" ", simplify = TRUE)

Pop_data <- add_column(Pop_data, ArbStrk = (as.matrix(select(Pop_data, ends_with("år")))%*%matrix(as.numeric(ages[,1])<18 | as.numeric(ages[,1])>65))[,1])

Pop_data <- Pop_data %>% select(Id, Område, ArbStrk) 

saveRDS(Pop_data, file = paste0("Input/Population_ArbStrk.rds"))
