*---------------------------------------------------------------- *
*- 013 Final Harmonizations 
*- Task: Add more harmonized variables or make final changes to be added to the descriptive statistics
*- Last Modified: Yi Ning Wong on 4/17/2024
*- 
*------------------------------------------------------------------*

	local countries "" //"MYS PHL IDN MNG VNM THA"  
	cd "${clone}\01_harmonization\011_rawdata\OTHER"
	local files: dir . files "*dta"
		*----------------------------------------------------*
		*---   Extra Harmonizations / Variable Creations  ---*
		*----------------------------------------------------*		
		qui foreach cnt in `countries' `files' {
		* The row number in which output will start
		if ("`cnt'" == "THA" | "`cnt'" == "MYS" | "`cnt'" == "PHL"| "`cnt'" ==  "VNM" | "`cnt'" == "IDN" | "`cnt'" == "MNG") {
			local inputdir "${clone}/01_harmonization/011_rawdata/`cnt'"
			local inputfile "gld_panel_`cnt'.dta"
			local outputdir "`inputdir'"
			}
			else {
				local inputdir "${clone}/01_harmonization/011_rawdata/OTHER"
				local inputfile "`cnt'"
				local outputdir "`inputdir'/harmonized"
			}
		use "`inputdir'/`inputfile'", clear
		
		* Suspect about harmonized data in IDN 1997 and 2012, remove for now 
		if "`cnt'" == "IDN" {
			destring year, replace
			drop if year == 1997 | year == 2012
		}
		
		*Subset thailand, datset too big
		if "`cnt'" == "THA" {
		keep if inlist(year, 1985, 1990, 1995, 2000, 2005, 2010, 2015,2020,2021,2022)
		}
		
		noi di "Reading `cnt'"
	

		* Create a national level variable (no disaggregations)
		gen all2 = "National"
		lab var all2 "National"
		encode all2, gen(all) 
	
		* Small cleaning
		destring year age, replace
		
		* Employment rate variable (Some EAPCE adjustments)
		if ("`cnt'" == "MYS" | "`cnt'" == "VNM") { 
			gen emprt = 1 if empstat != .
		}
		else {
			clonevar emprt = lstatus 
			replace emprt = . if lstatus == 3
			gen higher_educ = 1 if educat4 > 3
			replace higher_educ = 0 if educat4 <= 3
		}
		

		lab var higher_educ "Higher Education"
		label define highereduc 0 "No" 1 "Yes", modify
		label values higher_educ highereduc
			
		*Create a new indsutry variable that separates manufacutring
		gen industrycat5 = industrycat4 
		replace industrycat5 = 5 if industrycat10 == 3
		label define inducat5 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other" 5 "Manufacturing", modify
		label values industrycat5 inducat5
		
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
		
		* Young, middle, and older age variable 
		gen agegroup2 = "15 to 24" if age >= 15 & age <= 24
		replace agegroup2 = "25 to 54" if age >= 25 & age <= 54
		replace agegroup2 = "55+" if age >= 55
		lab var agegroup2 "Age Group"
		encode agegroup2, gen(agegrp2)
		
		* If variable doesnt exist (for example, south africa)
		cap gen wage_no_compen = .
		cap gen unitwage = .
		* Wage to Annual 
		rename (wage_no_compen unitwage whours) (wage_no_compen_1 unitwage_1 whours_1)
		gen annual_wage1 = wage_no_compen_1
		cap replace unit_wage_2 = 0 if unit_wage_2 == .

		cap gen annual_wage2 = wage_no_compen_2
		
		if _rc != 0 {
			cap gen annual_wage2 = 0 
			cap gen wage_no_compen_2 = 0
			cap gen unitwage_2 = 0 
		}
		
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


		* formal vs informal var 
		destring empstat, replace 
	
		gen formal = 1 if inlist(empstat, 1,3)
		replace formal = 0 if inlist(empstat, 2,4)
		lab var formal "Formal employment"
		label define form 0 "Informal" 1 "Formal", modify
		label values formal form

		missings dropvars, force
		
		save "`outputdir'/final_panel_`cnt'", replace
	* Next country
	}
