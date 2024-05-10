*---------------------------------------------------------------- *
*- Task: Harmonize EAPCE files to GLD Format
*- Last Modified: Yi Ning Wong on 4/5/2024
*- eduanalytics@worldbank.org
*------------------------------------------------------------------*
	* EAPCE has data from MYS and VNM not available in GLD- we can attempt to harmonize it similarly to GLD format
	*--------------------------------------------------------*
	* Malaysia												 *
	*--------------------------------------------------------*
	* LFS Survey (All workers)
	use "${msteams}/Combined/Harmonized/MYS/combined_uncleaned.dta", clear
	rename *, lower
	rename province subnatid1
	rename hmis hhid 
	rename id pid
	
	gen module = "LFS"
	
	keep subnatid1 age male grp_tp s3 s15 pid psu grp_pt indus_code masco_4d weight weightd year s8 hhid year
	
	*<_empstat_>		
	* Employment Status
	gen empstat = 1 if inlist(s15,2,3) // public or private workers 
	replace empstat = 2 if s15 == 5 // unpaid family workers 
	replace empstat = 3 if s15 == 1 // employer 
	replace empstat = 4 if s15 == 4 // self employed
	*</_empstat_>		

	
	*<_industrycat10_>		
	ren indus_code industrycat_isic
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
	*</_industrycat10_>		
	
	*<_whours_>		
	* Hours of work
	gen whours = s3
	destring whours, replace
	*</_whours_>		
	
	*<_educat4_>		
	gen educat4 = grp_pt
	*</_educat4_>		
	
	*<_lstatus_>		
	gen lstatus = 3 if s8 == "" & (!inlist(s8, "06","10")) // s8 = reason for not seeking work
	replace lstatus = 2 if s8 != "" & s15 == . 
	replace lstatus = 1 if s15 != . 
	*</_lstatus_>	
	
	
	*<_isco08_4_>	
	* Now we can replicate crosswalk from "Harmonize LFS MYS.do" file but keep information
	* Acknowledge that we lose information here
	masco_isco
	*</_isco08_4_>	
	*<_occup_code_>	
	*</_occup_code_>	
	*<_occup_isco_>	
	*</_occup_isco_>		
	

	tempfile myslfs 
	save `myslfs', replace
	
	*--------------------------------------------------------------------------*

	use "${msteams}/Combined/Harmonized/MYS/SWScombined_uncleaned.dta", clear
	rename *, lower
	gen code = "MYS"
	gen module = "SWS"
	rename province subnatid1
	
	*<_subnatid1_>
/*	gen country = "MYS"
	merge m:m province country using "${clone}/01_harmonization/011_rawdata/Subnational_name.dta", keep(matched master) keepusing(provincename) nogen
	labmask province, values(provincename)
	rename province subnatid1
	label var subnatid1 "Subnational ID at First Administrative Level"
	drop provincename
	*</_subnatid1_>
*/


	
	*<_isco08_4_>	
	* Now we can replicate crosswalk from "Harmonize LFS MYS.do" file but keep information
	* Acknowledge that we lose information here
	masco_isco
	*</_isco08_4_>	
	*<_occup_code_>	
	*</_occup_code_>	
	*<_occup_isco_>	
	*</_occup_isco_>		



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
	*</_empstat_>		
	
	*<_male_>
	*</_male_>		
		
	* Rename variables to GLD conventions
	rename (earning indus_code id) (wage_no_compen industrycat_isic pid)
	tostring pid, replace force
	
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
	*</_industrycat10_>		
	
	*<_industrycat4_>		
	* Industry (4)
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	*</_industrycat4_>		
	
	*<_isic_version_>
	gen isic_version = "isic_4"
	label var isco_version "Version of ISIC used"
	*</_isic_version_>

	*<_unitwage_>		
	* Create Unit wage
	gen unitwage = 5 // Unit wage is monthly 
	*</_unitwage_>		
	
	*<_whours_>		
	* Hours of work
	gen whours = g6
	destring whours, replace
	*</_whours_>	

	*<_educat4_>		
	gen educat4 = group_pt
	*</_educat4_>		
	
	append using  `myslfs'
	
	gen harmonization = "EAP-LFS"
	
	
	local idvars "code harmonization module subnatid1 pid ssu male year age hhid"
	local harmonized "educat* empstat isco_version occup_* isco08_2 isco08_4 isic_version industrycat* whours unitwage wage_no_compen weight"
	
	keep `idvars' `harmonized'
	order `idvars' `harmonized'
	
	
	* Label values 
	lab_vals
	

	save "${clone}/01_harmonization/011_rawdata/MYS/gld_panel_MYS.dta", replace

	*--------------------------------------------------------*
	* Vietnam												 *
	*--------------------------------------------------------*
	import excel "${msteams}/Combined/ISCO-ISIC/ISCO-08 EN Structure and definitions.xlsx", clear firstrow

	ren ISCO08Code occup_isco
	tempfile iscos 
	save `iscos', replace
	
	use "${msteams}/Combined/Harmonized/VNM/VNM_LFS_master_April2024.dta",clear
	
	gen harmonization = "EAP-LFS"
	gen module = "LFS"
	lab var harmonization "Source of the original data"
	lab var module "Whether it is labor force survey or salaried worker survey"
	gen code = "VNM"

	drop higher_educ
	rename *, lower

	*<_subnatid1_>	
	rename (province district) (subnatid1 subnatid2)
	label var subnatid1 "Subnational ID at First Administrative Level"
	lab var subnatid2 "Subnational ID at Second Administrative Level"

	
	/*
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
	*/
	gen isco_version = "isco_2008"
	
	tostring occup_code, gen(occup_isco) force
	replace occup_isco = "0" + occup_isco if occup_code < 400

	merge m:1 occup_isco using `iscos', keep(matched master) keepusing(occup_isco)
	replace occup_isco = "" if _merge == 1
	
	lab var occup_code "Harmonized VSCO occupation code"
	lab var occup_isco "Harmonized ISCO occupation code"
	
	clonevar isco08_4 = occup_isco
	gen isco08_2 = substr(isco08_4,1,2)
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
	lab values empstat lbl_empstat
	*</_empstat_>		
	
	*<_male_>		
	* Create variable labels for the male variable
	label values male lbl_male
	*</_male_>		
	
	*<_unitwage_>		
	* Create Unit wage
	gen unitwage = 5 // Unit wage is monthly 
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
		
	gen isic_version="isic_4"
	*<_industrycat10_>		
	rename indus_code industrycat_isic
	* Industry Code (10)
	gen industrycat10 = .
	replace industrycat10 = 1 if industrycat_isic < 2000
	forval i=1/10 {
		local j = `i'+1
		replace industrycat10 = `i' if industrycat_isic < `j'000 & industrycat_isic >= `i'000

	}
	label values industrycat10 lblindustrycat10
	*</_industrycat10_>		
	
	*<_industrycat4_>		
	* Industry (4)
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
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
	label values educat4 lbleducat4
	*</_educat4_>		
	

	rename id pid
	
	local idvars "code harmonization module subnatid1 pid male year age"
	local harmonized "educat* empstat isco_version occup_* isco08_2 isco08_4 isic_version industrycat* whours unitwage wage_no_compen weight"
	
	
	keep `idvars' `harmonized'
	order `idvars' `harmonized'
		
	save "${clone}/01_harmonization/011_rawdata/VNM/gld_panel_VNM.dta", replace