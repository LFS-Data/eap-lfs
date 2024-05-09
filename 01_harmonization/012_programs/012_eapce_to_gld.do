*---------------------------------------------------------------- *
*- Task: Harmonize EAPCE files to GLD Format
*- Last Modified: Yi Ning Wong on 4/5/2024
*- eduanalytics@worldbank.org
*------------------------------------------------------------------*
	* EAPCE has data from MYS and VNM not available in GLD- we can attempt to harmonize it similarly to GLD format
	*--------------------------------------------------------*
	* Malaysia												 *
	*--------------------------------------------------------*
	//use "${msteams}/Combined/EAP_LFS_Draft6.dta", clear
	use "${msteams}/Combined/Harmonized/MYS/MYSSWScombined_cleaned.dta", clear
	//use "${msteams}/Combined/Harmonized/MYS/SWScombined_uncleaned.dta", clear 
	replace country = "MYS"
	merge m:m province country using "${clone}/01_harmonization/011_rawdata/Subnational_name.dta", keep(matched master) nogen
	use "${msteams}/Combined/Harmonized/MYS/SWScombined_uncleaned.dta", clear 
	* For now we just care about age, male, skill, formality industry -- to do more in the future
	rename *, lower
	//keep if country == "MYS"
	gen code = "MYS"
	label var code "Country code"
	label var year "Year of survey"
	
	* Skill and industry categorized by standard isco recall defined by GLD, example:
	* https://github.com/worldbank/gld/blob/main/GLD/IDN/IDN_2019_SAKERNAS/IDN_2019_Sakernas_v02_M_v06_A_GLD/Programs/IDN_2019_Sakernas_v02_M_v06_A_GLD_ALL.do
	*-- Skill --*
	* https://isco-ilo.netlify.app/en/isco-08/
	gen occup_skill = occup_code
	replace occup_skill = 1 if occup_skill >= 9000
	replace occup_skill = 2 if occup_skill >= 4000 & occup_skill < 9000
	replace occup_skill = 3 if occup_skill >= 1000 & occup_skill < 4000
	label define lbl_occup_skill 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill lbl_occup_skill
	label var occup_skill "Skill based on ISCO08 standard"
	
	* create an empstat variable (which later gets fed into the formal variable creation when calculating means)
	gen empstat = 1 if employee == 1
	label define lbl_empstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by stat"
	label values empstat lbl_empstat
	
	* Create variable labels for the male variable
	label define lbl_male 0 "Female" 1 "Male"
	label values male lbl_male
		
	* Rename variables to GLD conventions
	rename (earning indus_code id) (wage_no_compen industrycat_isic pid)
	
	* At 1 digit level, MSIC to ISIC Rev 4 are the same:
	* https://jtksm.mohr.gov.my/sites/default/files/2022-12/msic_2008_ver_1.0.pdf (Appendix 2)
	* Industry (10)
	* ISIC Version 4: https://unstats.un.org/unsd/publication/seriesm/seriesm_4rev4e.pdf
	gen industrycat10 = .
	replace industrycat10 = 1 if industrycat_isic < 2000
	forval i=1/10 {
		local j = `i'+1
		replace industrycat10 = `i' if industrycat_isic < `j'000 & industrycat_isic >= `i'000

	}
	
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10 lblindustrycat10
	
	* Industry (4)
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4

 bonus	
	* Create Unit wage
	gen unitwage = 5 // Unit wage is monthly 
	label define lbl_unitwage 5 "Monthly"
	label values unitwage lbl_unitwage
	
	* Hours of work
	gen whours = g6
	
	* Educat4
	
		
	save "${clone}/01_harmonization/011_rawdata/MYS/gld_panel_MYS.dta", replace

	*--------------------------------------------------------*
	* Vietnam												 *
	*--------------------------------------------------------*
	//use "${msteams}/Combined/Harmonized/VNM/LFS_VNM_Harmonized_Limited.dta",clear
	
	use "${msteams}/Combined/Harmonized/VNM/VNM_LFS_master.dta",clear

	rename *, lower
	gen code = "VNM"
	label var code "Country code"
	label var year "Year of survey"
	
	* Skill and industry categorized by standard isco recall defined by GLD, example:
	* https://github.com/worldbank/gld/blob/main/GLD/IDN/IDN_2019_SAKERNAS/IDN_2019_Sakernas_v02_M_v06_A_GLD/Programs/IDN_2019_Sakernas_v02_M_v06_A_GLD_ALL.do
	* Documentation: VSCO is adapted from ISC08 - there are some differences,
	* but at 1 digit level is negligible
	*-- Skill --*
	gen occup_skill = occup_code
	replace occup_skill = 1 if occup_skill >= 9000
	replace occup_skill = 2 if occup_skill >= 4000 & occup_skill < 9000
	replace occup_skill = 3 if occup_skill >= 100 & occup_skill < 4000
	label values occup_skill lbl_occup_skill
	label var occup_skill "Skill based on ISCO08 standard"
	
	* Labor force status 
	gen lstatus = 1 if active == 1
	replace lstatus = 3 if active != 1
	replace lstatus = 2 if active == 1 & (self_employment==1 | employee==1)
	
	* Empstat
	gen empstat =.
	replace empstat = 4 if self_employment == 1
	replace empstat = 2 if (earning == 0 | earning == .) & (employee==1 | self_employment==1)
	replace empstat = 1 if (earning > 0) & (employee==1)
	replace empstat = 5 if empstat == .
	label define lbl_empstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by stat"
	
	* Create variable labels for the male variable
	label define lbl_male 0 "Female" 1 "Male"
	label values male lbl_male
	
	* Create Unit wage
	gen unitwage = 5 // Unit wage is monthly 
	label define lbl_unitwage 5 "Monthly"
	label values unitwage lbl_unitwage
	
	* Make the earnings consistent across survey years some individual questions already include bonuses
	gen wage_no_compen = earning+bonus
	replace wage_no_compen = earning if wage_no_compen == .
	* non-waged employee data not sufficient (according to reports)
	* change them all to missing so they are consistent across years 
	* FORMALITY:
	* INFORMAL = 2 "self-employment" 3 "Family labor "
	* This means informal wages represent self employed where earnings > 0
	replace wage_no_compen = . if wage_no_compen == 0
		
	rename indus_code industrycat_isic
	* Industry Code (10)
	gen industrycat10 = .
	replace industrycat10 = 1 if industrycat_isic < 2000
	forval i=1/10 {
		local j = `i'+1
		replace industrycat10 = `i' if industrycat_isic < `j'000 & industrycat_isic >= `i'000

	}
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10 lblindustrycat10
	
	* Industry (4)
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
	
	* This var is not available in the harmonized, need to go back to the raw to get it 
	gen whours = .
	save "${clone}/01_harmonization/011_rawdata/VNM/gld_panel_VNM.dta", replace