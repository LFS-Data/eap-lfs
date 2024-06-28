*---------------------------------------------------------------- *
*- Task 023: 
* Step a. Get the ILO employment shares from ILO stat
* Step b. Append latest data to get the digital score X income level
*- Last Modified: Yi Ning Wong on 4/22/2024
*------------------------------------------------------------------*
	
	*------------------------------------------------------*
	** Step 0. Set up 									  **
	*------------------------------------------------------*
	
	global onet_dir "${clone}/02_onet/023_outputs"
	global onet_file "onet.xlsx"
	global ilo_dir "${clone}/01_harmonization/011_rawdata"
	global onet_ver 24.1
	
	* Empty file 
	save "${onet_dir}/onet_gdppc.dta", replace emptyok
	
	*------------------------------------------------------*
	** Step a. Get ILO employment shares from ILO stat    **
	*------------------------------------------------------*
	use "${clone}/02_onet/023_outputs/soc_isco_digital_all_2d.dta", clear
	keep if onet == ${onet_ver}
	ren isco08code isco08_2
	
	destring isco08_2, replace
	
	tempfile isco 
	save `isco', replace
	
	* Note: Data retrieved from the API through 010_1_dl_ilo.R
	* Make sure to run that file
	import delimited "${clone}/01_harmonization/011_rawdata/ilostats.csv", clear
	
	keep ref_area sex classif1 time obs_value
	
	* Get the isco 2 digit values 
	gen isco08_2 = substr(classif1, -2,2)
	destring isco08_2, force replace
	drop if isco08_2 == .
	
	* cleaning 
	destring obs_value, force replace
	drop classif1
	rename (ref_area time obs_value) (countrycode year employed)
	reshape wide employed, i(countrycode year isco08_2) j(sex, string)
	ren (employedSEX_T employedSEX_F employedSEX_M) (emp_t emp_f emp_m) 
	
	* Keep the latest available
	bysort countrycode: egen n = max(year)
	keep if year == n
	drop employedSEX_O n
	
	* Convert to share 
	foreach s in t m f {
		egen share_`s' = total(emp_`s'), by(countrycode)
		replace share_`s' = (emp_`s'/share_`s')*100
	}
	
	* Merge with digital score 
	merge m:1 isco08_2 using `isco', nogen keep(matched) 
	sort countrycode year isco08_2
	
	ren emp_t weight
	
	* We are interested in share of digital skill also
	tab digitalskill, gen(dig_skill)
	
	* Save a non-aggregated level
	save "${onet_dir}/isco_digital_iscolevel.dta", replace
	
	preserve
	* get the national average digital score (there will only be one year so we only need to gorup by country)
	collapse (mean) digitalscore onet aioe dig_skill* automate_pr year weight [w=share_t], by(countrycode)
	
	gen source = "ILO"
	
	rename dig_skill* valdigitalskill* 
	gen subgroup = "National"
	gen group = "all"
	
	append using "${onet_dir}/isco_digital_aggs.dta"
	save "${onet_dir}/isco_digital_aggs.dta", replace
	
	restore
	
	* Collapse by digital skill
	egen agg_group = group(countrycode digitalskill), label
	decode agg_group, gen(group)

	collapse (mean) digitalscore onet aioe dig_skill* automate_pr year weight [w=share_t], by(group)
	
	split group, parse(" ")
	
	gen source = "ILO"
	
	rename dig_skill* valdigitalskill* 

	rename group2 subgroup
	rename group1 countrycode
	drop group
	gen group = "digitalskill"

	append using "${onet_dir}/isco_digital_aggs.dta"
	save "${onet_dir}/isco_digital_aggs.dta", replace
	
					
	*----------------------------------------------------------*
	** Step 2. Merge with the gdppc of the corresponding year **
	* Includes select years (2018 to 2022)					   *
	*----------------------------------------------------------*
	*  Name: GDP per capita, PPP (constant 2017 international $)
	wbopendata, indicator(ny.gdp.pcap.pp.kd) clear long
 
	keep countrycode region year ny_gdp_pcap_*
	
	* Create a variable that keeps year constant 
	foreach y in 2018 2019 2020 2021 2022 {
		gen gdppc_`y' = ny_gdp_pcap_pp_kd if year == `y'
		bysort countrycode: fillmissing gdppc_`y'
	}
	merge 1:m countrycode year using "${onet_dir}/isco_digital_aggs.dta", keep(matched using)
	
	save "${onet_dir}/isco_digital_aggs.dta", replace
