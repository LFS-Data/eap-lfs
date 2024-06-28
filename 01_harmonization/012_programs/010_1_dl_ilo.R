rm(list=ls())

## Set up (Do not removes)
list.of.packages <- c("tidyverse",
                      "ggplot2",
                      "Rilostat",
                      "readxl"
)

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]

# If package doesn't exist on local computer, install them
if(length(new.packages)) install.packages(new.packages)

#load all required packages
lapply(list.of.packages, require, character.only = TRUE)

user <- Sys.getenv("USERNAME")
projectFolder <- paste0("C:/Users/", user, "/Github/eap-lfs")

## Add on to the list as needed
vars <- "EES_TEES_SEX_OC2_NB_A"

# EES_TEES_SEX_OC2_NB_A <- employees by ISCO08

# Retrieve the data from the API
df <- get_ilostat(vars, cache=FALSE)

# Save it 
write.csv(df, paste0(projectFolder, "/01_harmonization/011_rawdata/ilostats.csv"))

