*---------------------------------------------------------------- *
*- Task 024: Analyze O*Net
*- Last Modified: Yi Ning Wong on 4/22/2024
*------------------------------------------------------------------*
	global onet_dir "${clone}/02_onet/023_outputs"
	global onet_ver 24.1
	local countries "THA VNM MYS PHL MNG" // IDN THA VNM MYS PHL MNG
	
	* 1 and a half to 2 page box explanation on how the digital scores were constructed, why it's relevant
	* why certain countries have high scores (occupation composition)

	* Note: Data retrieved from the API through 010_1_dl_ilo.R
	* Make sure to run that file
	* Occupation composition of 

	*------------------------------------------------------*
	** Step a. Get ILO employment shares from ILO stat    **
	*------------------------------------------------------*
	clear
	tempfile temp
	save `temp', emptyok replace
	use "${clone}/02_onet/023_outputs/soc_isco_digital_all_2d.dta", clear
	keep if onet == ${onet_ver}
	ren isco08code isco08_2
	
	destring isco08_2, replace
	
	tempfile isco 
	save `isco', replace
	

	qui foreach cnt in `countries' {
		noi di "Reading `cnt'"
		use "${clone}/01_harmonization/011_rawdata/`cnt'/final_panel_`cnt'.dta", clear

		if "`cnt'" == "MYS" {
			keep if code == "MYS_SWS"
			local vars ""
			local var ""

		} 
		else if "`cnt'" == "VNM" {
			local vars "digital"
			local var "dig_*"
			gen ID = pid 
			merge 1:1 year ID using "${msteams}/Combined/Harmonized/VNM/VNM_LFS_master_April2024.dta", nogen keepusing(Digital)
			drop ID 
			rename Digital digital
			tab digital, gen(dig_)
		}
		else {
			local vars ""
			local var ""
		}

		* Was going to add an urban rural disaggregation but removed it because the ILO doesn't have it. 
		/*
		cap confirm var urban 
		if _rc != 0 {
			local vars ""
		}
		else {
			local vars "urban"
		}
		*/
	
		merge m:1 isco08_2 using `isco', keep(matched master) keepusing(digitalscore aioe automate_pr digitalskill) 
		
		keep code year weight isco08_2 digitalscore aioe automate_pr male annual_wage1 digitalskill `vars' `var'
		destring weight, replace
		cap gen all = "all"
		tab digitalskill, gen(dig_skill)
		
		foreach agg in all male `vars' {
			noi di "`agg'"
			preserve 
			egen agg_group = group(year code `agg' isco08_2), label
			decode agg_group, gen(group)	
			
			
			drop agg_group
			
			collapse (mean) dig_* digitalscore aioe automate_pr `vars' weight [pw=weight], by(group)
			
			append using `temp'
			tempfile temp
			save `temp', replace
			
			restore

	}
	

		
	}
	
	use `temp', replace
	split group, parse(" ")
	drop if group == ""
	drop group digital 

	rename (weight group1 group2 group3 group4) (emp year countrycode sex isco08_2)
	
	replace sex = "0" if sex == "-1"
	
	reshape wide digitalscore aioe automate_pr emp dig_1 dig_2 dig_3 dig_4 dig_skill1 dig_skill2 dig_skill3, i(year countrycode isco08_2) j(sex, string) 
	
	rename (empMale empFemale empall) (emp_m emp_f weight)
	rename (emp0 emp1 emp2 emp3) (emp_0 emp_1 emp_2 emp_3)
	rename dig_skill*all digskill*
	drop *Female *Male 
	drop dig_*0 dig_*1 dig_*2 dig_*3
	drop aioe0 aioe1 aioe2 aioe3 
	drop automate_pr0 automate_pr1 automate_pr2 automate_pr3 
	drop digitalscore0 digitalscore1 digitalscore2 digitalscore3
	
	rename *all *
	rename digskill* dig_skill*
	rename (dig_1 dig_2 dig_3 dig_4) (vnmdig_0 vnmdig_1 vnmdig_2 vnmdig_3)
	e
	use "${onet_dir}/temp.dta", clear
	
	use "${onet_dir}/isco_digital_iscolevel.dta", clear
	* show that taking the mean of the 2 digits is ok because the distribution is similar to 4 digit (figure 7 of the brookings paper) - if you take the mean of different occupations, it's concentrated in a similar range
	* Distribution of 4 Digit and 2 Digit Scores

	* 1. main objective of the box is how we construct the digital score and how it means
	* 2 / 4 digit is the x-axis, digital score is the y axis
	
	
	* rank the highest contributing occupations to digital scores 
	
	* 3. (only do for 2021 Vietnam) we can get percentage of workers who use digital technoglogies in that occupation

	*if there are other interesting things , we can also try them
	* over time or across worker types (for example, by education level or gender) - this may be main report and the box
