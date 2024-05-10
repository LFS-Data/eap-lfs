*---------------------------------------------------------------- *
*- Task: Harmonize EAPCE files to GLD Format
*- Last Modified: Yi Ning Wong on 4/5/2024
*- eduanalytics@worldbank.org
*------------------------------------------------------------------*
	* EAPCE has data from MYS and VNM not available in GLD- we can attempt to harmonize it similarly to GLD format
	*--------------------------------------------------------*
	* Malaysia												 *
	*--------------------------------------------------------*
	use "${msteams}/Combined/Harmonized/MYS/SWScombined_uncleaned.dta", clear

	use "${msteams}/Combined/Harmonized/MYS/SWScombined_uncleaned.dta", clear
	rename *, lower
	gen code = "MYS"
	label var code "Country code"
	label var year "Year of survey"
	
	*<_subnatid1_>
	gen country = "MYS"
	merge m:m province country using "${clone}/01_harmonization/011_rawdata/Subnational_name.dta", keep(matched master) keepusing(provincename) nogen
	labmask province, values(provincename)
	rename province subnatid1
	label var subnatid1 "Subnational ID at First Administrative Level"
	drop provincename
	*</_subnatid1_>
	

	*<_occup_orig_>	
	* Get the original occupation code, and harmonize an isco code 
	clonevar occup_orig = masco_4d 
	label var occup_orig "Original occupation record primary job 7 day recall"
	*</_occup_orig_>	
	
	*<_occup_isco_>	
	* Also get the 2d MASCO which will correspond with ISCO08 at 2d level
	gen occup_isco = substr(occup_orig,1,2)
	lab var occup_isco "ISCO code of primary job 7 day recall"	
	*</_occup_orig_>	

	*<_occup_isco4_>	
	* Now we can replicate crosswalk from "Harmonize LFS MYS.do" file but keep information
	* Acknowledge that we lose information here
	gen masco98_4D = masco_4d  if year ==2010
	gen masco08_4D = masco_4d  if year > 2010 & year < 2016
	gen masco13_4D = masco_4d  if year > 2015
	destring masco13_4D, replace

	merge m:m masco98_4D using "${msteams}/Combined/Harmonized/MYS/MASCOcrosswalk/crosswalk_1998_2013_ISCO.dta", keep(matched master) nogen keepusing(isco08_4D)
	ren isco08_4D isco08_4D98
	
	merge m:m masco08_4D using "${msteams}/Combined/Harmonized/MYS/MASCOcrosswalk/crosswalk_2008_2013_ISCO.dta", update keep(matched master) nogen keepusing(isco08_4D)
	ren isco08_4D isco08_4D08

	merge m:m masco13_4D using "${msteams}\Combined\Harmonized\MYS\MASCOcrosswalk\MASCO13_ISCO08.dta", keep(matched master) nogen keepusing(isco08_4D)
	
	replace isco08_4D = isco08_4D98 if isco08_4D == .
	replace isco08_4D = isco08_4D08 if isco08_4D == .
	rename isco08_4D occup_isco4
	lab var occup_isco4 "ISCO code of primary job 7 day recall (4 digits)"
	*</_occup_isco4_>	

	*<_occup_skill_>		
	* Skill and industry categorized by standard isco recall defined by GLD, example:
	* https://github.com/worldbank/gld/blob/main/GLD/IDN/IDN_2019_SAKERNAS/IDN_2019_Sakernas_v02_M_v06_A_GLD/Programs/IDN_2019_Sakernas_v02_M_v06_A_GLD_ALL.do
	*-- Skill --*
	* https://isco-ilo.netlify.app/en/isco-08/
	gen occup_skill = occup_isco
	destring occup_skill, replace
	replace occup_skill = 1 if occup_skill >= 90
	replace occup_skill = 2 if occup_skill >= 40 & occup_skill < 90
	replace occup_skill = 3 if occup_skill >= 10 & occup_skill < 40
	label define lbl_occup_skill 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill lbl_occup_skill
	label var occup_skill "Skill based on ISCO08 standard"
	*</_occup_skill_>		
	
	*<_isco_version_>
	gen isco_version = "isco_2008"
	label var isco_version "Version of ISCO used"
	*</_isco_version_>

	*<_empstat_>		
	* create an empstat variable (which later gets fed into the formal variable creation when calculating means)
	* Malaysia only surveys salaried workers
	gen empstat = 1 if employee == 1
	replace empstat = 4 if self_employment==1 
	label define lbl_empstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by stat"
	label values empstat lbl_empstat
	*</_empstat_>		
	
	*<_male_>		
	* Create variable labels for the male variable
	label define lbl_male 0 "Female" 1 "Male"
	label values male lbl_male
	*</_male_>		
		
	* Rename variables to GLD conventions
	rename (earning indus_code id) (wage_no_compen industrycat_isic pid)
	
	*<_industrycat10_>		
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
	*</_industrycat10_>		
	
	*<_industrycat4_>		
	* Industry (4)
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
	*</_industrycat4_>		

	*<_unitwage_>		
	* Create Unit wage
	gen unitwage = 5 // Unit wage is monthly 
	label define lbl_unitwage 5 "Monthly"
	label values unitwage lbl_unitwage
	*</_unitwage_>		
	
	*<_whours_>		
	* Hours of work
	gen whours = g6
	destring whours, replace
	*</_whours_>		
	
	*<_educat4_>		
	gen educat4 = group_pt
	la de lbleducat4 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values educat4 lbleducat4
	*</_educat4_>		
	
	local idvars "code subnatid1 weight pid ssu male year age"
	local harmonized "educat* occup_orig occup_isco occup_skill empstat industrycat* whours unitwage wage_no_compen"
	
	keep `idvars' `harmonized'
	order `idvars' `harmonized'
		
	save "${clone}/01_harmonization/011_rawdata/MYS/gld_panel_MYS.dta", replace

	*--------------------------------------------------------*
	* Vietnam												 *
	*--------------------------------------------------------*
	//use "${msteams}/Combined/Harmonized/VNM/LFS_VNM_Harmonized_Limited.dta",clear
	
	use "${msteams}/Combined/Harmonized/VNM/VNM_LFS_master_April2024.dta",clear
	gen code = "VNM"
	label var code "Country code"
	label var year "Year of survey"
	
	drop higher_educ
	rename *, lower

	*<_subnatid1_>
	gen country = "VNM"
	merge m:1 province district country using "${clone}/01_harmonization/011_rawdata/Subnational_name.dta", keep(matched master) keepusing(provincename districtname) nogen
	labmask province, values(province_name)
	rename province subnatid1
	label var subnatid1 "Subnational ID at First Administrative Level"
	drop provincename province_name
	*</_subnatid1_>
	
	*<_subnatid2_>
	labmask district, values(districtname)
	rename district subnatid2
	lab var subnatid2 "Subnational ID at Second Administrative Level"
	*</_subnatid2_>

	*<_occup_skill_>		
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
	*</_occup_skill_>		
	
	*<_lstatus_>		
	* Labor force status 
	gen lstatus = 1 if active == 1
	replace lstatus = 3 if active != 1
	replace lstatus = 2 if active == 1 & (self_employment==1 | employed==1)
	*</_lstatus_>		
	
	*<_empstat_>		
	* Empstat
	gen empstat =.
	replace empstat = 4 if self_employment == 1
	replace empstat = 2 if (earning == 0 | earning == .) & (employed==1 | self_employment==1)
	replace empstat = 1 if (earning > 0) & (employed==1)
	replace empstat = 5 if empstat == .
	label define lbl_empstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by stat"
	lab values empstat lbl_empstat
	*</_empstat_>		
	
	*<_male_>		
	* Create variable labels for the male variable
	label define lbl_male 0 "Female" 1 "Male"
	label values male lbl_male
	*</_male_>		
	
	*<_unitwage_>		
	* Create Unit wage
	gen unitwage = 5 // Unit wage is monthly 
	label define lbl_unitwage 5 "Monthly"
	label values unitwage lbl_unitwage
	*</_unitwage_>		
	
	*<_wage_no_compen_>		
	* Make the earnings consistent across survey years some individual questions already include bonuses
	gen wage_no_compen = earning+bonus
	replace wage_no_compen = earning if wage_no_compen == .
	* non-waged employee data not sufficient (according to reports)
	* change them all to missing so they are consistent across years 
	* FORMALITY:
	* INFORMAL = 2 "self-employment" 3 "Family labor "
	* This means informal wages represent self employed where earnings > 0
	replace wage_no_compen = . if wage_no_compen == 0
	*</_wage_no_compen_>		
		
	*<_industrycat10_>		
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
	*</_industrycat10_>		
	
	*<_industrycat4_>		
	* Industry (4)
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
	*</_industrycat4_>		
	
	*<_whours_>
	gen whours = hours1
	*</_whours_>		
	
	*<_educat4_>		
	gen educat4 = education
	replace educat4 = 4 if educat4 ==3 
	replace educat4 = 3 if educat4 == 2
	replace educat4 = 2 if educat4 <=2 & u_primary ==0
	la de lbleducat4 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values educat4 lbleducat4
	*</_educat4_>		
	

	rename id pid
	local idvars "code subnatid* weight pid male year age"
	local harmonized "educat* occup_code occup_skill empstat industrycat* whours unitwage wage_no_compen"
	
	keep `idvars' `harmonized'
	order `idvars' `harmonized'
	
	save "${clone}/01_harmonization/011_rawdata/VNM/gld_panel_VNM.dta", replace