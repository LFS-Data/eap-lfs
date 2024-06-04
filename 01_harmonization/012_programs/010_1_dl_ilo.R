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
projectFolder <- paste0("C:/Users/", user, "/Github/eap-ceo")

# EES_TEES_SEX_OC2_NB_A <- employees by ISCO08
df <- 
  get_ilostat(c("EAP_DWAP_SEX_AGE_RT_A", 'GDP_2HRW_NOC_NB_A'), cache = FALSE)

df <- df %>% select(c(ref_area,indicator, sex,time,classif1, obs_value)) %>% 
  filter((sex!= "SEX_F" & sex != "SEX_M" & classif1=="AGE_AGGREGATE_TOTAL") | is.na(classif1)) %>% filter(time>=2010)
df_label <- label_ilostat(df)

write.csv(paste0(projectFolder, "/01_harmonization/011_rawdata/ilostats.xlsx"))
#df <- df %>% filter(classif1.label=="Age (Aggregate bands): Total" & sex.label=="Sex: Total" & time > 2010)
