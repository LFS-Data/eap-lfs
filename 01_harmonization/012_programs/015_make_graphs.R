#-----------------------------------------------------------------------------------#
# ! Task 03: Create descriptive statistics graphs from the GLD database
# ! Subtasks: 
# 1) Skills by population 
# 2) Wage over time by skills 
# 3) skills by sector 
# 4) skills by formality
# Created by YNW on 3.4.2024
# Last modified by YNW on 3.4.2024
#-----------------------------------------------------------------------------------#


## TO DO: add tree maps, color by industrycat10 and industrycat4, section is ISIC
# chart of share of employer/employee/self-employed…
# add separating manufacturing from industries
# add formal/informal dimensions in all education/skill/industry chart

rm(list=ls())

## Set up (Do not removes)
list.of.packages <- c("tidyverse",
                      "ggplot2",
                      "ggtext",
                      "dplyr",
                      "showtext",
                      "extrafont",
                      "haven",
                      "zoo",
                      "stringr",
                      "ggtext",
                      "stringr",
                      "rmarkdown",
                      "readr",
                      "knitr",
                      "scales",
                      "ggrepel",
                      "data.table",
                      "kableExtra",
                      "readxl", 
                      "ggpubr"
)

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]

# If package doesn't exist on local computer, install them
if(length(new.packages)) install.packages(new.packages)

#load all required packages
lapply(list.of.packages, require, character.only = TRUE)

user <- Sys.getenv("USERNAME")

#projectFolder <- paste0("C:/Users/", user, "/OneDrive - WBG/EAPCE/Technology and Labor Market flagship/5. joint works/STCs/Yi Ning Wong")
projectFolder <- paste0("C:/Users/", user, "/Github/eap-ceo")

# File paths
outputs  <- file.path(projectFolder,"/01_harmonization/013_outputs")

countries <- c("MNG", "PHL", "IDN", "THA", "MYS", "VNM")

#------------#
# Graph 1    #
#------------#
# (1) Skills by Population
# AREA LINE CHART
# Country. Year, color by column, subgroup = national level
plot_area_national <- function(cnt, val) {
  print(val)
  df <- read_excel(paste0(outputs, "/tabstats_subset.xlsx"), sheet = cnt)
  
  # A little clean
  colnames(df) <- gsub("==", "_", colnames(df), perl = T)
  colnames(df) <- gsub(" ", "_", colnames(df), perl = T)
  colnames(df) <- gsub("-", "_", colnames(df), perl = T)
  
  # Subset the interested variables
  subgroup <- df %>% select(c(year, subgroup, countrycode,starts_with(val)))
  
  # Education Level
  if (val=="educat4") {
    subgroup <- gather(subgroup, key="group", value="value", educat4_No_education:educat4_Post_secondary)
    subgroup <- subgroup %>% mutate(group=str_replace(group, paste0(val,"_"), ''))
    subgroup$group <- factor(subgroup$group, levels=c("Post_secondary","Secondary","Primary","No_education"))
    colors <- c("#7DDF64","#C0DF85","#DEB986","#DB6C79")
    lab <- "Education Level"
  }
  
  # Industry
  if (val=="industrycat4") {
    subgroup <- gather(subgroup, key="group", value="value", industrycat4_Agriculture:industrycat4_Other)
    subgroup <- subgroup %>% mutate(group=str_replace(group, paste0(val,"_"), ''))
    subgroup$group <- factor(subgroup$group, levels=c("Agriculture","Industry","Services","Other"))
    colors <- c("#E84855","#F9DC5C","#3185FC","#EFBCD5")
    lab <- "Industry"
  }
  
  
  if (val=="occup_skill") {
    subgroup <- gather(subgroup, key="group", value="value", occup_skill_Low_skill:occup_skill_High_skill)
    subgroup <- subgroup %>% mutate(group=str_replace(group, paste0(val,"_"), ''))
    subgroup$group <- factor(subgroup$group, levels=c("High_skill","Medium_skill","Low_skill"))
    colors <- c("#A3BCF9","#7796CB","#576490")
    lab <- "Occupation Skill"
  }
  
  if (val=="lstatus") {
    subgroup <- gather(subgroup, key="group", value="value", lstatus_Employed:lstatus_Non_LF)
    subgroup <- subgroup %>% mutate(group=str_replace(group, paste0(val,"_"), ''))
    subgroup$group <- factor(subgroup$group, levels=c("Non_LF","Unemployed","Employed"))
    colors <- c("#FFFFFF","#7B6D8D","#593F62")
    lab <- "Labor Force Status"
  }
  
  pl <- ggplot(subgroup %>% filter(subgroup=="National"), aes(x=year, y=value*100, fill=group)) + 
    geom_area() +
    labs(y="%", x="", subtitle=paste0("National ", lab)) +
    theme_minimal() +
    scale_fill_manual(values=colors) +
    theme(legend.position = "bottom")
  
  return(pl)
  
  
}
for (i in countries) {
  print(i)
  g1 <- plot_area_national(i, "lstatus")
  g2 <- plot_area_national(i, "educat4")
  g3 <- plot_area_national(i, "occup_skill")
  g4 <- plot_area_national(i, "industrycat4")
  
  
  
  g <- ggarrange(g1,g2,g3, g4, common.legend = FALSE)
  g <- annotate_figure(g,top = text_grob(i, face = "bold"))
  ggsave(paste0(outputs,"/1_",i,"_population.png"), width=10,height=10, bg="white")
}

#------------#
# Graph 2    #
#------------#
# (2) Wages by Skill
plot_wages <- function(cnt,grp, yvar, measure) {
  
  
  if (grp=="all") {
    tha <- read_excel(paste0(outputs, "/tabstats_",measure,".xlsx"), sheet = "THA")
    vnm <- read_excel(paste0(outputs, "/tabstats_",measure,".xlsx"), sheet = "VNM")
    idn <- read_excel(paste0(outputs, "/tabstats_",measure,".xlsx"), sheet = "IDN")
    mys <- read_excel(paste0(outputs, "/tabstats_",measure,".xlsx"), sheet = "MYS")
    phl <- read_excel(paste0(outputs, "/tabstats_",measure,".xlsx"), sheet = "PHL")
    mng <- read_excel(paste0(outputs, "/tabstats_",measure,".xlsx"), sheet = "MNG")
    
    df <- rbind(tha,vnm)
    df <- rbind(df,idn)
    df <-rbind(df,mys)
    df <- rbind(df,phl)
    df <- rbind(df, mng)
  }
  else {
    df <- read_excel(paste0(outputs, "/tabstats_",measure,".xlsx"), sheet = cnt)
    
    # Put the source
    if (cnt=="MYS") {
      cap <- "Source: Calculations using SWS (EAPCE), limited to waged workers" 
    } else if (cnt=="VNM") {
      cap <- "Source: Calculations using LFS (EAPCE), limited to waged workers"
    } else {
      cap <- "Source: Calculations using LFS (GLD)"
    }
    # Set base year for inflation adjustment
    # earliest year available for vnm is 2011
    if (cnt=="VNM") {
      baseyear <- 2011
      #df <- df %>% filter(year!=2011 & year != 2013)
    } else {
      baseyear <- 2010
    }
    
  }

  df <- df %>% filter(year >= 2005)
  
  # A little clean
  colnames(df) <- gsub("==", "_", colnames(df), perl = T)
  colnames(df) <- gsub(" ", "_", colnames(df), perl = T)
  colnames(df) <- gsub("-", "_", colnames(df), perl = T)
  print("Check point 1 ")
  
  if (cnt=="IDN") {
    df <- df %>% filter(year!=2001 & year != 2005)
    
    # Education Level
    if (grp=="educat4") {
      colors <- c("#7DDF64","#C0DF85","#DEB986","#DB6C79")
      lab <- "Education Level"
      subgroup$subgroup <- factor(subgroup$subgroup, levels=c("Post-secondary","Secondary","Primary","No education"))
      ylab <- paste0("Wages (1=2010, No Education)")
      title <- ""
      caption <- ""   
      # Choose group to deflate
      base <- subgroup %>% filter(year==baseyear & subgroup=="No education")
    }
    # Occupation Skill
    if (grp=="occup_skill") {
      colors <- c("#A3BCF9","#7796CB","#576490")
      lab <- "Occupation Skill"
      subgroup$subgroup <- factor(subgroup$subgroup, levels=c("Low skill","Medium skill","High skill"))
      ylab <-  paste0("Wages (1=2010, Low Skill)")
      title <- ""
      caption <- ""     
      base <- subgroup %>% filter(year==baseyear & subgroup=="Low skill")
      
    }
    
    # Industry
    if (grp=="industrycat4") {
      subgroup$group <- factor(subgroup$subgroup, levels=c("Agriculture","Industry","Services","Other"))
      lab <- "Industry"
      colors <- c("#E84855","#F9DC5C","#3185FC","#EFBCD5")
      ylab <-  paste0("Wages (1=2010, Agriculture)")
      title <- ""
      caption <- ""     
      base <- subgroup %>% filter(year==baseyear & subgroup=="Agriculture")
    }
    
    # Age Group
    if (grp=="agegrp") {
      subgroup$group <- factor(subgroup$subgroup, levels=c("15 to 19","20 to 29","40 to 49", "50 to 59", "60 to 65", "65+"))
      lab <- "Age Group (detail)"
      colors <- c("#E84855","#E49633", "#F9DC5C","#F0f033","#3185FC", "#7796CB") #,"#EFBCD5")
      ylab <- ""
      title <- ""
      caption <- ""   
      base <- subgroup %>% filter(year==baseyear & subgroup=="15 to 19")
      
    }
    
    if (grp=="agegrp2") {
      subgroup$subgroup <- factor(subgroup$subgroup, levels=c("15 to 24","25 to 54","55+"))
      lab <- "Age Group"
      colors <- c("#E84855","#F9DC5C","#3185FC") #,"#EFBCD5")
      ylab <-  paste0("Wages (1=2010, Age 15 to 24)")
      title <- ""
      caption <- "" 
      base <- subgroup %>% filter(year==baseyear & subgroup=="15 to 24")
      
    }
    
    # Formal
    if (grp=="formal") {
      subgroup$group <- factor(subgroup$subgroup, levels=c("Formal","Informal"))
      lab <- "Formality"
      colors <- c("#264b96", "#27b376") #,"#EFBCD5")
      ylab <- paste0("Wages (1=2010, Formal)")
      title <- ""
      caption <- ""    
      base <- subgroup %>% filter(year==baseyear & subgroup=="Formal")
      
    }
    
    # Sex
    if (grp=="male") {
      subgroup$group <- factor(subgroup$subgroup, levels=c("Female","Male"))
      lab <- "Sex"
      colors <- c("#B3E9C7","#8367C7") #,"#EFBCD5")
      ylab <- paste0("Annual Wage (1=2010, Female)")
      title <- cnt
      caption <- ""
      base <- subgroup %>% filter(year==baseyear & subgroup=="Female")
      
    }
    
    # Higher Ed
    if (grp=="higher_educ") {
      colors <- c("#7DDF64","#C0DF85")
      lab <- "Education Level"
      subgroup <- subgroup %>% mutate(subgroup=ifelse(subgroup=="Yes", "Post-secondary", "Less than post-secondary"))
      subgroup$subgroup <- factor(subgroup$subgroup, levels=c("Post-secondary","Less than post-secondary"))
      ylab <- paste0("Annual Wage (1=2010, less than post-secondary)")
      title <- ""
      caption <- cap   
      base <- subgroup %>% filter(year==baseyear & subgroup=="Less than post-secondary")
      
    }
  }
  
  
  # Subset the interested variables
  subgroup <- df %>% select(c(year,group,subgroup, countrycode,yvar, fp.cpi.totl, annual_wage1)) %>% filter(group==grp)
  
  print("Check point 2 ")
  
  subgroup <- subgroup %>% mutate(annual_wage1=(annual_wage1/(fp.cpi.totl/100))/base$annual_wage1)
  ymax <- max(subgroup[[yvar]], na.rm = TRUE)
  ymin <- min(subgroup[[yvar]], na.rm = TRUE)
  
  pl <- ggplot(subgroup %>% filter(!is.na(yvar))) + 
    ylim(ymin,ymax)+
    geom_line(aes(x=year, y=get(yvar), group=as.factor(subgroup),color=subgroup), linewidth=1.5) +
    labs(y=ylab, x="", subtitle=lab, title=title,caption=caption) +
    theme_minimal() +
    scale_color_manual(values=colors) +
    theme(legend.position = "bottom")
  print("Check point 3 ")
  
  return(pl)
  
  
}

countries <- c("MNG")
countries <- c("MNG", "PHL", "IDN", "THA", "MYS", "VNM")

# WAGE
for (i in countries) {
  g1 <- plot_wages(i,"all", "annual_wage1", "mean")  
  g2 <- plot_wages(i,"all", "annual_wage1", "median")
  
  g <- ggarrange(g1,g2, common.legend = FALSE, ncol=2)
  

}
for (i in countries) {
  print(i)
  g1 <- plot_wages(i,"male", "annual_wage1", "mean")
  g2 <- plot_wages(i,"agegrp", "annual_wage1", "mean")
  g3 <- plot_wages(i,"agegrp2", "annual_wage1", "mean")
  g4 <- plot_wages(i,"occup_skill", "annual_wage1",  "mean")
  g5 <- plot_wages(i,"formal", "annual_wage1", "mean")
  g6 <- plot_wages(i,"higher_educ", "annual_wage1", "mean")
  
  #g1 <- plot_wages(i,"educat4", "annual_wage")
  #g2 <- plot_wages(i, "occup_skill", "annual_wage")
  #g3 <- plot_wages(i, "industrycat4", "annual_wage")
  
  
  g <- ggarrange(g1,g3,g4,g5,g6, common.legend = FALSE, ncol=5)
  ggsave(paste0(outputs,"/2_",i,"_realwage_mean.png"), width=18,height=4, bg="white")
  
  
  g1 <- plot_wages(i,"male", "annual_wage1", "median")
  g2 <- plot_wages(i,"agegrp", "annual_wage1", "median")
  g3 <- plot_wages(i,"agegrp2", "annual_wage1", "median")
  g4 <- plot_wages(i,"occup_skill", "annual_wage1",  "median")
  g5 <- plot_wages(i,"formal", "annual_wage1", "median")
  g6 <- plot_wages(i,"higher_educ", "annual_wage1", "median")
  
  #g1 <- plot_wages(i,"educat4", "annual_wage")
  #g2 <- plot_wages(i, "occup_skill", "annual_wage")
  #g3 <- plot_wages(i, "industrycat4", "annual_wage")
  
  
  g <- ggarrange(g1,g3,g4,g5,g6, common.legend = FALSE, ncol=5)
  ggsave(paste0(outputs,"/2_",i,"_realwage_median.png"), width=18,height=4, bg="white")
}

# Employment
for (i in countries) {
  g1 <- plot_wages(i,"male", "emprt_Employed")
  g2 <- plot_wages(i,"agegrp", "emprt_Employed")
  g3 <- plot_wages(i,"agegrp2", "emprt_Employed")
  g4 <- plot_wages(i,"occup_skill", "emprt_Employed")
  g5 <- plot_wages(i,"formal", "emprt_Employed")
  g6 <- plot_wages(i,"higher_educ", "emprt_Employed")
  
  g <- ggarrange(g1,g3,g4,g5,g6, common.legend = FALSE, ncol=5)
  ggsave(paste0(outputs,"/2_",i,"_employmentrate.png"), width=12,height=12, bg="white")
  
}

#------------------#
# Graph 3 and 4    #
#------------------#
# (3) Skills by sector over time, formality
# fill by skill, grp is the sector, facet grid year
plot_stack <- function(cnt, grp, xvar) {
  
  df <- read_excel(paste0(outputs, "/tabstats_mean.xlsx"), sheet = cnt)
  
  # A little clean
  colnames(df) <- gsub("==", "_", colnames(df), perl = T)
  colnames(df) <- gsub(" ", "_", colnames(df), perl = T)
  colnames(df) <- gsub("-", "_", colnames(df), perl = T)
  
  # Subset the interested variables
  subg <- df %>% select(c(countrycode,year, group, subgroup,starts_with(xvar))) %>% filter(group==grp)
  
  # Education Level
  if (xvar=="educat4") {
    subg <- gather(subg, key="group", value="value", educat4_No_education:educat4_Post_secondary)
    subg <- subg %>% mutate(group=str_replace(group, paste0(xvar,"_"), ''))
    subg$group <- factor(subg$group, levels=c("Post_secondary","Secondary","Primary","No_education"))
    colors <- c("#7DDF64","#C0DF85","#DEB986","#DB6C79")
    lab <- "Education Level"
  }
  
  # Industry
  if (xvar=="occup_skill") {
    if (cnt != "IDN") {
      subg <- subg %>% select(-occup_Skilled_agricultural)
    }
    subg <- gather(subg, key="group", value="value", occup_skill_Low_skill:occup_skill_High_skill)
    subg <- subg %>% mutate(group=str_replace(group, paste0(xvar,"_"), ''))
    subg$group <- factor(subg$group, levels=c("High_skill","Medium_skill","Low_skill"))
    colors <- c("#A3BCF9","#7796CB","#576490")
    lab <- "Occupation Skill"
  }
  
  if (grp=="empstat") {
    subg$subgroup <- factor(subg$subgroup, levels=c("Employer","Paid employee","Self-employed", "Non-paid employee", "Other, workers not classifiable by status"))
    
  }
  pl <- ggplot(subg, aes(x=year, y=value, fill=group)) + 
    geom_bar(position="fill", stat="identity") +
    labs(y="%", x="", subtitle=lab) +
    theme_minimal() +
    scale_fill_manual(values=colors) +
    theme(legend.position = "bottom") + 
    facet_grid(~subgroup)
  
  return(pl)
  
  
}
for (i in countries) {
  print(i)
  g1 <- plot_stack(i, "industrycat4", "occup_skill")
  g2 <- plot_stack(i, "industrycat4", "educat4")
  g3 <- plot_stack(i, "empstat", "occup_skill")
  g4 <- plot_stack(i, "empstat", "educat4")
  
  # Skills by sector
  g <- ggarrange(g1,g2, common.legend = FALSE)
  g <- annotate_figure(g,top = text_grob(paste0(i, " Skills by sector"), face = "bold"))
  ggsave(paste0(outputs,"/3_",i,"_skill_sector.png"), width=15,height=6, bg="white")
  
  # skills by formality
  g <- ggarrange(g3,g4, common.legend = FALSE)
  g <- annotate_figure(g,top = text_grob(paste0(i, " Skills by Formality"), face = "bold"))
  ggsave(paste0(outputs,"/4_",i,"_skill_formality.png"), width=15,height=6, bg="white")
}


