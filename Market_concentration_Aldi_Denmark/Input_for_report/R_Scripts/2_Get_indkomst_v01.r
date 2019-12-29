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

#see <- dst_search(string = "INDKF1", field = "id")

useTab <- "INDKF132"
meta   <- dst_meta(table = useTab, lang = "da")

tmp1 <- dst_get_data(table = useTab, 
                     OMRÅDE = "*",
                     ENHED  = "Gennemsnit for familier i gruppen (kr.)",
                     FAMTYP = "Familier i alt",
                     INDKINTB = "*",
                     Tid = "2018", 
                     lang = "da", 
                     meta_data = meta)

(tmp1 <- tibble(
                Område = tmp1$OMRÅDE,
                IndkGr = tmp1$INDKINTB,
                GnIndk = as.double(tmp1$value),
              )
)

tmp2 <- meta$values$OMRÅDE

(tmp2 <- tibble(
                Område = tmp2$text,
                Id     = tmp2$id,
              )
)

(Data1 <- tmp1 %>% 
            inner_join(tmp2, by = "Område") %>% 
            arrange(Id) %>% 
            select(Id, Område, IndkGr, GnIndk) %>% 
            spread(key = IndkGr, value = GnIndk))

##################

tmp1 <- dst_get_data(table = useTab, 
                     OMRÅDE = "*",
                     ENHED  = "Familier i gruppen (Antal)",
                     FAMTYP = "Familier i alt",
                     INDKINTB = "*",
                     Tid = "2018", 
                     lang = "da", 
                     meta_data = meta)

(tmp1 <- tibble(
            Område = tmp1$OMRÅDE,
            IndkGr = tmp1$INDKINTB,
            Antal  = as.double(tmp1$value),
          )
)

tmp2 <- meta$values$OMRÅDE

(tmp2 <- tibble(
                Område = tmp2$text,
                Id     = tmp2$id,
              )
)

(Data2 <- tmp1 %>% 
    inner_join(tmp2, by = "Område") %>% 
    arrange(Id) %>% 
    select(Id, Område, IndkGr, Antal) %>% 
    spread(key = IndkGr, value = Antal))


Indk_data <- add_column(Data2, tmp = rowSums(as.matrix(select(Data1, ends_with("kr."))) * as.matrix(select(Data2, ends_with("kr.")))))

Indk_data <- Indk_data %>% 
                select(Id, Område, tmp, `I alt`) %>% 
                add_column(Indkomst = Indk_data$tmp/Indk_data$`I alt`) %>% 
                select(-c(tmp,`I alt`))

head(Indk_data)

saveRDS(Indk_data, file = paste0("Input/Income_Average.rds"))
