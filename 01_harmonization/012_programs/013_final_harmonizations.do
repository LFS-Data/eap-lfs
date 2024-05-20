*---------------------------------------------------------------- *
*- 013 Final Harmonizations 
*- Task: Add more harmonized variables or make final changes to be added to the descriptive statistics
*- Last Modified: Yi Ning Wong on 4/17/2024
*- 
*------------------------------------------------------------------*

	local countries "MYS" // PHL IDN MNG VNM THA MYS
	//cd "${clone}\01_harmonization\011_rawdata\OTHER"
	//local files: dir . files "*dta"
		*----------------------------------------------------*
		*---   Extra Harmonizations / Variable Creations  ---*
		*----------------------------------------------------*		
		qui foreach cnt in `countries' `files' {
		* The row number in which output will start
		if ("`cnt'" == "THA" | "`cnt'" == "MYS" | "`cnt'" == "PHL"| "`cnt'" ==  "VNM" | "`cnt'" == "IDN" | "`cnt'" == "MNG") {
			//local cnt "PHL"
			local inputdir "${clone}/01_harmonization/011_rawdata/`cnt'"
			local inputfile "gld_panel_`cnt'.dta"
			local outputdir "`inputdir'"
			//append using "`inputdir'/LFS_`cnt'.dta"

		//use "`inputdir'/`inputfile'", clear
			

			}
			else {
				local inputdir "${clone}/01_harmonization/011_rawdata/OTHER"
				local inputfile "`cnt'"
				local outputdir "`inputdir'/harmonized"
			}
		use "`inputdir'/`inputfile'", clear
	
		* Small cleaning
		destring year age, replace
		cap drop migrated_*
		
		cap tab subnatid1 
		if _rc != 0 {
			gen subnatid1 = .
		}
		
		cap tab subnatid2
		if _rc != 0 {
			gen subnatid2 = .
		}
		
		* Remove subnat labeling 
		gen province = subnatid1 
		gen district = subnatid2 
		drop subnatid* 
		rename (province district) (subnatid1 subnatid2)
		
		foreach i in 1 2 {
			tostring subnatid`i', replace
			split subnatid`i', parse(" - ") 
			replace subnatid`i'1 = subinstr(subnatid`i'1, " ", "", .)
			replace subnatid`i'1 = subinstr(subnatid`i'1, "-", "", .)

		}
		
		drop subnatid*2 subnatid1 subnatid2 
		destring subnatid11 subnatid21, replace
		
		rename (subnatid11 subnatid21) (subnatid1 subnatid2)
		noi di "Reading `cnt'"
		
		

		if ("`cnt'" == "PHL" | "`cnt'" == "IDN") {
		
			append using "`inputdir'/LFS_`cnt'.dta"
		}

		* Suspect about harmonized data in IDN 1997 and 2012, remove for now 

		*Subset thailand, datset too big
		if "`cnt'" == "THA" {
			cap gen module = "GLD"
		//keep if inlist(year, 1985, 1990, 1995, 2000, 2005, 2010, 2015,2020,2021,2022)
		}
		
	
		* Harmonize across ISCO versions 
		*<_isco08_4_>*
		iscogen isco08 = isco08(occup_isco) if isco_version=="isco_1988", from(isco88) nolabel
		iscogen isco68 = isco08(occup_isco) if isco_version=="isco_1968", from(isco68) nolabel

		replace isco08 = isco68 if isco_version=="isco_1968"
		tostring isco08, replace
		drop isco68
		replace isco08 = occup_isco if isco_version=="isco_2008"
		cap ren isco08 isco08_4 
		lab var isco08_4 "ISCO-08 at 4 digit level"
		*</_isco08_4_>*

		*<_isco08_2_>*		
		cap gen isco08_2 = substr(isco08_4,1,2)
		lab var isco08_2 "ISCO-08 at 2-digit "
		*</_isco08_2_>*
		
		*<_isicgen_>*
		isicgen
		*</_isicgen_>*
		
		
		*<_industrycat_isic2_>*		
		tostring industrycat_isic, replace
		gen industrycat_isic2 = substr(industrycat_isic,1,2)
		lab var industrycat_isic2 "ISIC at 2 digit"
		*</_industrycat_isic2_>*
/*
		*<_industrycat_isic2_2_>*
		qui cap sum industrycat_isic_2 
		if _rc == 0 {
		gen industrycat_isic2_2 = substr(industrycat_isic_2,1,2)
		lab var industrycat_isic2_2 "Second ISIC at 2 digit"
		}
		*</_industrycat_isic2_2_>*
*/		
		* Create a national level variable (no disaggregations)
		gen all2 = "National"
		lab var all2 "National"
		encode all2, gen(all) 
		
		* Tag all the modules as LFS surveys, except for malaysia 
		cap gen module = "LFS" if module != "SWS"
		* Get a weight as an outcome variable that can be used to proxy employment
		*<_weight_emp_>	
		gen weight_emp = weight if module != "SWS"
		*</_weight_emp_>	


		
		* Employment rate variable (Some EAPCE adjustments)
		if ("`cnt'" == "MYS" | "`cnt'" == "VNM") { 
			gen emprt = 1 if empstat != .
		}
		else {
			clonevar emprt = lstatus 
			replace emprt = . if lstatus == 3

		}
		
		*<_educat3_>		
		gen educat3 = educat4
		replace educat3 = 1 if educat4==2
		replace educat3 = 2 if educat4==3
		replace educat3 = 3 if educat4==4
		la de lbleducat3 1 "Primary or Below" 2 "Secondary" 3 "Post-secondary"
		label values educat3 lbleducat3
		*</_educat3_>		
		
		*<_higher_educ_>			
		gen higher_educ = 1 if educat4 > 3
		replace higher_educ = 0 if educat4 <= 3
		lab var higher_educ "Higher Education"
		label define highereduc 0 "No" 1 "Yes", modify
		label values higher_educ highereduc
		*</_higher_educ_>			
		
		*<_industrycat5_>			
		*Create a new indsutry variable that separates manufacutring
		gen industrycat5 = industrycat4 
		replace industrycat5 = 5 if industrycat10 == 3
		label define inducat5 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other" 5 "Manufacturing", modify
		label values industrycat5 inducat5
		*</_industrycat5_>	
		
		*<_agegroup_>					
		* Create an age group variable 
		gen agegroup = "15 to 19" if age >= 15 & age <= 18
		replace agegroup = "20 to 29" if age  >= 19 & age <= 29
		replace agegroup = "30 to 39" if age >= 30 & age <= 39
		replace agegroup = "40 to 49" if age >= 30 & age <= 39
		replace agegroup = "50 to 59" if age >= 50 & age <= 59
		replace agegroup = "60 to 65" if age >= 60 & age <= 65
		replace agegroup = "65+" if age > 65
		lab var agegroup "Age Group"
		encode agegroup, gen(agegrp)
		*</_agegroup_>				
		
		*<_agegroup2_>					
		* Young, middle, and older age variable 
		gen agegroup2 = "15 to 24" if age >= 15 & age <= 24
		replace agegroup2 = "25 to 54" if age >= 25 & age <= 54
		replace agegroup2 = "55+" if age >= 55
		lab var agegroup2 "Age Group"
		encode agegroup2, gen(agegrp2)
		*</_agegroup2_>					
		
		* If variable doesnt exist (for example, south africa)
		cap gen wage_no_compen = .
		cap gen unitwage = .
		

		*<_annual_wage_>					
		* Wage to Annual 
		destring wage_* unitwa* whour*, replace
		rename (wage_no_compen unitwage whours) (wage_no_compen_1 unitwage_1 whours_1)
		gen annual_wage1 = wage_no_compen_1
		replace annual_wage1 = . if annual_wage1 == 0
		cap replace unit_wage_2 = 0 if unit_wage_2 == .
		

		cap gen annual_wage2 = wage_no_compen_2
		
		if _rc != 0 {
			cap gen annual_wage2 = 0 
			cap gen wage_no_compen_2 = 0
			cap gen unitwage_2 = 0 
			cap gen whours_2 = 0
		}
		
		cap gen whours_2 = 0
		destring whour*, replace

		destring annual_wage* wage_no_*, replace
		foreach w in 1 2 {
		replace annual_wage`w' = (wage_no_compen_`w')*365 if unitwage_`w' == 1 // daily case
		replace annual_wage`w' = (wage_no_compen_`w'/7)*365 if unitwage_`w' == 2 // weekly case
		replace annual_wage`w' = (wage_no_compen_`w'/14)*365 if unitwage_`w' == 3 // biweekly case
		replace annual_wage`w' = (wage_no_compen_`w'/61)*365 if unitwage_`w' == 4 // bimonthly case
		replace annual_wage`w' = (wage_no_compen_`w'/30.5)*365 if unitwage_`w' == 5 // monthly case
		replace annual_wage`w' = (wage_no_compen_`w'/92)*365 if unitwage_`w' == 6 // quarterly case
		replace annual_wage`w' = (wage_no_compen_`w'/180)*365 if unitwage_`w' == 7 // every six months
		replace annual_wage`w' = wage_no_compen_`w' if unitwage_`w'== .
		}
		
		replace annual_wage2 = 0 if annual_wage2 == .
		
		gen annual_wage =(annual_wage1 + annual_wage2)
		*</_annual_wage_>					
		
		*<_hourly_wage_>	
		gen hourly_wage1 = .
		gen hourly_wage2 = .
		* Wage to Hourly		
		destring hourly_wage*, replace
		foreach w in 1 2 {
		replace hourly_wage`w' = annual_wage`w'/(whours_`w'*52)
		}
		
		replace hourly_wage2 = 0 if hourly_wage2 == .
		
		* don't gen if already exists (eg., idn)
		cap gen hourly_wage =(hourly_wage1 + hourly_wage2)
		*</_hourly_wage_>	

		*<_obs_annual_>	
		gen obs_annual = 1 if annual_wage1 != .
		replace obs_annual = 0 if obs_annual == .
		lab var obs_annual "Whether data on annual wage exists"
		*</_obs_annual_>	
		
		*<_obs_hourly_>	
		gen obs_hourly = 1 if hourly_wage1 != .
		replace obs_hourly = 0 if obs_hourly == .
		lab var obs_hourly "Whether data on hourly wage exists"
		*</_obs_hourly_>	

		*<_formal_>	
		* formal vs informal var 
		destring empstat, replace 
	
		gen formal = 1 if inlist(empstat, 1,3)
		replace formal = 0 if inlist(empstat, 2)
		replace formal = 2 if inlist(empstat,4)
		lab var formal "Formal employment"
		label define form 0 "Informal" 1 "Formal" 2 "Self-Employed", modify
		label values formal form
		*</_formal_>	

		missings dropvars, force
		
		cap tostring pid wave, replace
		destring isco08_4 isco08_2 isic4_2 isic4_4, replace
		destring occup_code, replace
		replace isic4_4 = "" if isic4_4 == "." | isic4_4 == ".a"
		replace isic4_2 = "" if isic4_2 == "." | isic4_2 == ".a"
		
		cap drop n3_2 n31_2 n3 
		save "`outputdir'/final_panel_`cnt'", replace
	* Next country
	}
	
	* Append a cross-country dataset
	use "${clone}/01_harmonization/011_rawdata/THA/final_panel_THA", clear
	gen is_lfs = 1 
	tostring pid, replace
	keep code pid year weight age male educat3 educat4 lstatus empstat industrycat10 industrycat5 occup_skill wage_no_compen_1 unitwage_1 whours_1 subnatid1 isco08_4 isco08_2 isic4_4 isic4_2 weight_emp higher_educ annual_wage1 hourly_wage1 
	
	save "${clone}/01_harmonization/011_rawdata/final_panel_full", replace
	

	foreach c in VNM MYS MNG IDN PHL {
		noi di "`c'"
		use "${clone}/01_harmonization/011_rawdata/`c'/final_panel_`c'", clear
		gen is_lfs = 1 if module != "SWS"
		cap drop survey
		tostring pid, replace
		keep code pid year weight age male educat3 educat4 lstatus empstat industrycat10 industrycat5 occup_skill wage_no_compen_1 unitwage_1 whours_1 subnatid1 isco08_4 isco08_2 isic4_4 isic4_2 weight_emp higher_educ annual_wage1 hourly_wage1 

		append using "${clone}/01_harmonization/011_rawdata/final_panel_full.dta"
		save "${clone}/01_harmonization/011_rawdata/final_panel_full.dta", replace

	}
	
	preserve 
	
	drop if year <= 2000
	
	order code year pid subnatid1 weight weight_emp age male educat3 educat4 higher_educ lstatus empstat wage_no_compen_1 unitwage_1 whours_1 annual_wage1 hourly_wage1 isco08_2 isco08_4 occup_skill isic4_4 isic4_2 weight_emp industrycat5 industrycat10 