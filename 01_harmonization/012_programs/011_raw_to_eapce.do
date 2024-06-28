*---------------------------------------------------------------- *
*- Task: RE-Harmonize Certain Raw Files with Issues
* There are some issues with harmonized EAPCE data, these are some modifications made to the codes from:
* C:/User/(WBUPI)/OneDrive - WBG/Data from Poverty team/Labor Force Survey/Combined/Codes and results
*- Last Modified: Yi Ning Wong on 4/16/2024
*- eduanalytics@worldbank.org
*------------------------------------------------------------------*
	* WIP *
	
	*--------------------------------------------------------*
	* Globals to Each CNT									 *
	*--------------------------------------------------------*
	global idn_raw "${msteams}/IDN"
	global vnm_raw "${msteams}/VNM/Raw ID"
	global phl_raw "${msteams}/PHL"

	*--------------------------------------------------------*
	* Indonesia
	* See corresponding questionnaire:
	* ${idn_raw}/LFS-2023/Kuesioner SAK.AGS23-AK_edit.id.en.pdf
	*--------------------------------------------------------*
	use "${idn_raw}/LFS-2023/sak23aug_coding.dta", clear
	local idvars "code year harmonization module psu strata weight pid subnatid*"
	local demovars "male age educat4"
	local lfsvars "whours empstat industry* isic* wage* *wage occup_* lstatus"
	
	*----------------------*
	* ID Vars 
	*----------------------*
	*<_code_>*
	gen code = "IDN"
	*</_code_>*

	*<_harmonization_>*
	gen harmonization = "EAP-LFS"
	*</_harmonization_>*
	
	*<_module_>*
	gen module = "LFS"
	*</_module_>*

	*<_subnatid1_>*	
	rename (kode_prov kode_kab rowindex) (subnatid1 subnatid2 pid)
	*</_subnatid1_>*	
	
	
	*----------------------*
	* Demographic vars
	*----------------------*
	*<_male_>*
	* Male / Female
	gen male = 1 if k4 == 1 
	replace male = 0 if k4 == 2
	*</_male_>*

	* Age (already harmonized in this dataset)
//	gen age = k9
	
	*<_educat4_>*
	* Educat4
	gen educat4 = r6a 
	recode educat4 (1 =1) (2=2) (3 4 5 =3) (6 7 8 9 10 11 12=4)
	*</_educat4_>*
	
	*----------------------*
	* LFS Vars
	*----------------------
	
	*<_whours_>*
	* Working hours 
	gen whours = r28c
	*</_whours_>*
	
	*<_empstat_>*
	* Employment status
	gen empstat = r13a
	recode empstat (4 = 1) (5 7 =2) (3=3) (1 2 =4) (6 =5)
	*</_empstat_>*
	
	*<_wage_no_compen_>*
	* Wages 
	gen wage_no_compen = mwage 
	*</_wage_no_compen_>*
	
	*<_unitwage_>*
	* Unit of wage 
	gen unitwage = 5 // monthly (based on mwage construction)
	*</_unitwage_>*

	*<_hourly_wage_>*
	* Hourly wage
	gen hourly_wage = hrwage
	*</_hourly_wage_>*
	
	*<_isco_version_>*
	gen isco_version = "isco_2008"
	*</_isco_version_>*

	
	* Occupation 
	foreach var in occup_code occup_isco {
	gen `var'= worktype 
	}
	
	* Labor force status 
	* r31a - 1) looked for work in the past week 2) didnt 
	gen lstatus = 3 if r31a == 2 & empstat == . 
	replace lstatus = 1 if empstat != .
	replace lstatus = 2 if lstatus ==.
	

	* Occupation Skill (occup_skill)
	gen occup_skill = occup_isco
	destring occup_skill, replace
	replace occup_skill = 1 if occup_isco >= 9
	replace occup_skill = 2 if occup_isco >= 4 & occup_isco < 9
	replace occup_skill = 3 if occup_isco >= 1 & occup_isco < 4
	
	gen isic_version="isic_4"
	*<_industrycat10_>		
	label drop sector9
	ren sector9 industrycat_isic
	* Industry Code (10)
	gen industrycat10 = industrycat_isic
	*</_industrycat10_>		
	
	*<_industrycat4_>		
	* Industry (4)
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	*</_industrycat4_>		
	
	*----------------------*
	* Cleaning Step
	*----------------------*
	
	keep `idvars' `demovars' `lfsvars'
	order `idvars' `demovars' `lfsvars'
	
	* Label values 
	lab_vals
	
	* Consistency with GLD
	tostring pid industrycat_isic occup_isco, replace
	tostring industrycat_isic, replace force
	replace industrycat_isic = "" if industrycat_isic == "."
	
	save "${clone}/01_harmonization/011_rawdata/IDN/LFS_IDN.dta", replace
	
	*--------------------------------------------------------*
	* Philippines
	* See corresponding questionnaires:
	* ${phl_raw}/questionaires								 *
	*--------------------------------------------------------*
	use "${phl_raw}/LFS-2020/April/Data/LFS APR2020.dta", clear
	append using "${phl_raw}/LFS-2020/Jan/Data/LFS Jan2020.dta"
	append using "${phl_raw}/LFS-2020/July/LFS July 2020.dta"
	append using "${phl_raw}/LFS-2020/October/LFS Oct 2020.dta"
	
	gen year = 2020 
	append using "${phl_raw}/LFS-2021/LFS APR 2021.dta"
	append using "${phl_raw}/LFS-2021/LFS FEB 2021.dta"
	append using "${phl_raw}/LFS-2021/LFS JAN 2021.dta"
	append using "${phl_raw}/LFS-2021/LFS MAR 2021.dta"
	replace year = 2021 if year != 2020
	
	local idvars "code year harmonization module psu weight hhsize hhid pid"
	local demovars "male age educat4"
	local lfsvars "whours empstat industry* isic* isco* wage* *wage occup_* lstatus"
	
	*----------------------*
	* ID vars
	*----------------------
	gen code = "PHL"
	gen harmonization = "EAP-LFS"
	gen module = "LFS"
	gen weight = pufpwgtprv
	
	gen hhid = pufhhnum 
	rename pufc01_lno pid
	gen subnatid1 = pufreg
	gen wave = pufsvymo  
	rename pufpsu psu
	
	*----------------------*
	* Demographic vars
	*----------------------
	
	rename pufhhsize hhsize 
	rename pufc05_age age
	* Male 
	gen male = pufc04_sex
	recode male (2=0) (1=1)
	
	*----------------------*
	* LFS Vars
	*----------------------
	gen isic_version = "isic_4"
	gen industrycat_isic = pufc16_pkb
	*<_industrycat10_>		
	* Industry Code (10)
	gen industrycat10 = industrycat_isic
	replace industrycat10 = 1 if industrycat_isic < 20
	forval i=1/10 {
		local j = `i'+1
		replace industrycat10 = `i' if industrycat_isic < `j'0 & industrycat_isic >= `i'0

	}
	*</_industrycat10_>		
	
	*<_industrycat4_>		
	* Industry (4)
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	*</_industrycat4_>			
	

	
	gen isco_version = "isco_2008"
	gen occup_code = pufc14_procc
	tostring occup_code, gen(occup_isco)
	replace occup_isco = "0" + occup_isco if occup_code <= 3
	
	//gen isco08_2 = occup_isco 
	//gen isco08_4 = .
	
	* Occupation Skill (occup_skill)
	gen occup_skill = . 
	destring occup_isco, gen(temp)
	replace occup_skill = 1 if temp >= 90
	replace occup_skill = 2 if temp >= 40 & temp < 90
	replace occup_skill = 3 if temp >= 10 & temp < 40
	drop temp

	
	* Lstatus 
	gen lstatus = 1 if pufc11_work ==1 
	replace lstatus = 2 if pufc11_work == 2 
	replace lstatus = 3 if lstatus == 2 & pufc36_avail ==2
	
	gen whours = pufc19_phours
	gen wage_no_compen = pufc25_pbasic
	gen unitwage = 1 // daily
	
	* Empstat 
	gen empstat = pufc23_pclass+1
	replace empstat = 4 if inlist(pufc23_pclass, 4,6)
	replace empstat = 1 if inlist(pufc23_pclass,2,3) | (pufc23_pclass==1 & wage_no_compen > 0)
	replace empstat = 2 if inlist(pufc23_pclass, 7) | (pufc23_pclass==1 & wage_no_compen == 0)
	replace empstat = 3 if pufc23_pclass == 5

	* Education (4)
	gen educat4 = pufc07_grade
	replace educat4 = 1 if pufc07_grade < 10011
	replace educat4 = 2 if pufc07_grade  < 24011
	replace educat4 = 3 if pufc07_grade < 40001 
	replace educat4 = 4 if pufc07_grade >= 40001
	
	keep `idvars' `demovars' `lfsvars'
	order `idvars' `demovars' `lfsvars'
	
	* Label values 
	lab_vals
	
	* Consistency with GLD
	tostring hhid pid industrycat_isic occup_isco, replace
	
	save "${clone}/01_harmonization/011_rawdata/PHL/LFS_PHL.dta", replace
	
	
	*--------------------------------------------------------*
	* Vietnam	
	* See corresponding questionnaires:
	* ${vnm_raw}/questionaires								 *
	*--------------------------------------------------------*
	