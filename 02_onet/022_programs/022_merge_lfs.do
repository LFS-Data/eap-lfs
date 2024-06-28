*---------------------------------------------------------------- *
*- 022 Task: Tabulate Skill level using LFS data
*- Last Modified: Yi Ning Wong on 3/28/2024
*------------------------------------------------------------------*
	
	*------------------------------------------------------*
	** Step 1. Different Disaggregations and tabulations  **
	*----------------------------------------------------*
	local disaggregations "all digitalskill" //  male occup_skill agegrp2 empstat formal emprt higher_educ agegrp industrycat5 // educat4 industrycat4 industrycat10 ocusec
	local factortabs "digitalskill" //  
	local meantabs "digitalscore aioe automate_pr"
	local countries "THA VNM MYS PHL MNG" // IDN THA VNM MYS PHL MNG
	cd "${clone}\01_harmonization\011_rawdata\OTHER\harmonized"
	local files: dir . files "*dta"
	local measure "mean" //
	global onet_dir "${clone}/02_onet/023_outputs"
	global onet_ver 24.1
	
	* Empty file 
	clear 
	save "${onet_dir}/isco_digital_aggs.dta", replace emptyok
	
	*------------------------------------------------------*
	** Step a. Get ILO employment shares from ILO stat    **
	*------------------------------------------------------*
	use "${clone}/02_onet/023_outputs/soc_isco_digital_all_2d.dta", clear
	keep if onet == ${onet_ver}
	ren isco08code isco08_2
	
	destring isco08_2, replace
	
	tempfile isco 
	save `isco', replace
	
	foreach m in `measure' {
		noi di "`m'"
	qui foreach cnt in `countries' { // `files' `ilo'
		noi di "Reading `cnt'"

		* The row number in which output will start
		if ("`cnt'" == "THA" | "`cnt'" == "MYS" | "`cnt'" == "PHL"| "`cnt'" ==  "VNM" | "`cnt'" == "IDN" | "`cnt'" == "MNG") {
		use "${clone}/01_harmonization/011_rawdata/`cnt'/final_panel_`cnt'.dta", clear
		}
		else if "`cnt'"  == "ilo" {
			use `ilo', replace
		}
		else {
			use "${clone}\01_harmonization\011_rawdata\OTHER/harmonized/`cnt'", clear
			cap gen occup_code = .
			
		}
		if "`cnt'" == "MYS" {
			keep if code == "MYS_SWS"
		}
		
		cap gen all = "all"
	
		merge m:1 isco08_2 using `isco', keep(matched master) keepusing(`meantabs' `factortabs') 
		
		keep code year weight isco08_2 `disaggregations' `meantabs' `factortabs' annual_wage1
		destring weight, replace


		* Run analysis for each selected subgroup 
		foreach agg in `disaggregations' {
			preserve
			noi di "trying `agg'.."

			* Tabstat per result (factor variable)
			if "`factortabs'" != "" {
				foreach result in `factortabs' {
					* Check if this variable exists in the dataset
					cap confirm variable `result'
					
					if _rc == 0 {
						* Reshape factors to wide
						noi di "`result'"
						tab `result', gen(val`result')
					}
					else noi di "variable `result' not available, skipping"
				}
			}
			
			* Get a grouped aggregate by year and by subgroup
			cap decode `agg', gen(grp)
				
			if _rc == 0 {
				tostring year, replace
				replace year = year + "_"
							
				egen agg_group = group(year grp), label
				decode agg_group, gen(group)
				
				* Copy variable labels
				foreach v of var * {
					local l`v' : variable label `v'
					if `"`l`v''"' == "" {
					local l`v' "`v'"
				}
			  }

				* Get the mean
				if "`factortabs'" != "" {			
				collapse (`m')  val* `meantabs' annual_wage1 weight [pw=weight], by(group)
				* Replace the labels after collapse 
				foreach v of var val* `meantabs' {
					label var `v' `"`l`v''"'
				}
				}
				else {
				collapse (`m') `meantabs' weight annual_wage1 [pw=weight], by(group)	
				* Replace the labels after collapse 
				foreach v of var  `meantabs' {
					label var `v' `"`l`v''"'
				}
				}
					

				* Split parse the year and the subgroup into two columns
				drop if group == ""
				split group, parse("_")
					
				* Cleaning
				sort group
				gen valdummy = .
				keep val* `meantabs' annual_wage1 group1 group2 weight 
				drop valdummy 
				
				destring group1, replace
				rename group1 year
				rename group2 subgroup
				
				gen countrycode = "`cnt'"
				
				if ("`cnt'" == "THA" | "`cnt'" == "MYS" | "`cnt'" == "PHL"| "`cnt'" ==  "VNM" | "`cnt'" == "IDN" | "`cnt'" == "MNG") {
					noi di "Saving `cnt'"
				}
				else {
				local cnt = substr("`cnt'", 13,3)
				replace countrycode = substr(countrycode, 13,3)
}
				* Denote the subgroup
				gen group = "`agg'"

				order countrycode year subgroup group

								
					* Save the file 
					noi di "`cnt'"
					
					gen source = "LFS"
					
					append using "${onet_dir}/isco_digital_aggs.dta"
					save "${onet_dir}/isco_digital_aggs.dta", replace
					
				* Next subgroup				
				restore
				noi di "Finished aggregating `agg'"
				}
				else {
					noi di "skipping `agg'"
					restore
				* end of if-else
				}
		* next aggregate
		}
	 noi di "Step 3 done: Got descriptive stats for selected variables"
	* Next country
	}
	* Next measure
	}
	
	* Final cleaning
	use "${onet_dir}/isco_digital_aggs.dta", clear
	drop if digitalscore == .
	
	sort countrycode year group 
	
	save "${onet_dir}/isco_digital_aggs.dta", replace
