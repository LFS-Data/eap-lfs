*---------------------------------------------------------------- *
*- 022 Task: Tabulate Skill level using LFS data
*- Last Modified: Yi Ning Wong on 3/28/2024
*------------------------------------------------------------------*
	
	*------------------------------------------------------*
	** Step 1. Different Disaggregations and tabulations  **
	*----------------------------------------------------*
	local disaggregations "all" //  male occup_skill agegrp2 empstat formal emprt higher_educ agegrp industrycat5 // educat4 industrycat4 industrycat10 ocusec
	local factortabs "" //  
	local meantabs "score_mean* score_p50* score_min* score_max*"
	local countries "THA MYS PHL IDN MNG VNM"
	cd "${clone}\01_harmonization\011_rawdata\OTHER\harmonized"
	local files: dir . files "*dta"
	local measure "mean" //
	*----------------------------------------------------*
	** Pt 1. Different Disaggregations and tabulations  **
	*----------------------------------------------------*
	foreach m in `measure' {
		noi di "`m'"
	qui foreach cnt in `countries' `files' {
		noi di "Reading `cnt'"

		* The row number in which output will start
		if ("`cnt'" == "THA" | "`cnt'" == "MYS" | "`cnt'" == "PHL"| "`cnt'" ==  "VNM" | "`cnt'" == "IDN" | "`cnt'" == "MNG") {
			
		use "${clone}/01_harmonization/011_rawdata/`cnt'/final_panel_`cnt'.dta", clear
		}
		else {
			use "${clone}\01_harmonization\011_rawdata\OTHER/harmonized/`cnt'", clear
			cap gen occup_code = .
			
		}
		
		
		* File size too big, subset hte years
		if "`cnt'" == "PHL" {
			keep if year >= 2010 | year == 2000 | year == 2005
		}
		
		cap gen isco08_2d = substr(occup_isco,1,2)
		if _rc != 0 {
			tostring occup_code, gen(isco08_2d) format("%19.0f")
			replace isco08_2d =substr(isco08_2d,1,2)
		}
		keep code year weight isco08_2d `disaggregations' 
		
		destring weight, replace
		merge m:1 isco08_2d using "${clone}/02_onet/023_outputs/isco_digitalscore_2d.dta", keep(matched master) keepusing(score_*)
		
		* Start Row Number (for saving to excel later)
		local i = 1
		* Run analysis for each selected subgroup 
		foreach agg in `disaggregations' {
			preserve
			noi di "trying `agg'.."
				local agg "all"

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
				//local agg "all"

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
				collapse (`m')  val* `meantabs' [pw=weight], by(group)
				* Replace the labels after collapse 
				foreach v of var val* `meantabs' {
					label var `v' `"`l`v''"'
				}
				}
				else {
				collapse (`m') `meantabs' [pw=weight], by(group)	
				* Replace the labels after collapse 
				foreach v of var  `meantabs' {
					label var `v' `"`l`v''"'
				}
				}
					

				* Split parse the year and the subgroup into two columns
				noi di "checkpoint"
				drop if group == ""
				split group, parse("_")
				noi di "checkpoint2"
				
				* Get the number of unique levels of subgroup-year
				* Use this to calculate number of rows to add in the excel append
				qui unique group
				mat num=r(unique)
				local num = `r(unique)'
				di "`num'"
					
				* Cleaning
				sort group
				gen valdummy = .

				keep  val* `meantabs' group1 group2
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

					if "`agg'" == "all" {
						local saveopt "firstrow(varlabels)"
					}
					else {
						local saveopt ""
					}
					order countrycode year subgroup group

								
					* Save the file 
					noi di "`cnt'"


					export excel using "${clone}/02_onet/023_outputs/onet.xlsx", `saveopt' sheet("`cnt'", modify) cell(A`i')
					
				* Next subgroup				
				restore
				local i= `i'+`num'
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
	e
	*--------------------------------------------------------*
	** Pt 2. share brdown of isic by year, with industry10  **
	*--------------------------------------------------------*
	local countries "IDN THA MNG PHL" 

	
	qui foreach cnt in `countries' {
		
		noi di "Reading `cnt'"
		
		use "${clone}/01_harmonization/011_rawdata/gld_panel_`cnt'.dta", clear
		* Get a grouped aggregate by year and by subgroup
		replace industrycat_isic = industrycat_isic + "_"
		
		tostring year, replace
		replace year = year + "_"
						
		egen agg_group = group(year industrycat_isic industrycat10), label
		decode agg_group, gen(group)

		gen dummy = 1

		collapse (sum) dummy [w=weight], by(group)
				
		* Split parse the year and the subgroup into two columns
		drop if group == ""
		split group, parse("_")
		
		* Small clean
		rename (group1 group2 group3 dummy) (year isic ind10 count)
		drop group
		
		* Convert count to share per year
		tempfile aggs 
		save `aggs', replace
		
		collapse (sum) count, by(year)
		
		rename count total
		
		merge 1:m year using `aggs', nogen

		gen share = (count / total) * 100
		
		* Get the industry labels
		gen code = substr(isic, 2,2)
		merge m:1 code using "${clone}/01_harmonization/011_rawdata/ISIC4_2digits.dta", nogen
		
		* Cleaning
		drop if year == ""
		replace description = "other" if code == ""
		
		gen countrycode = "`cnt'"
		
		keep countrycode year code description ind10 share 
		order countrycode year code description ind10 share 
		
		* Export results
		export excel using "${clone}/03_output/tabstats.xlsx", firstrow(varlabels) sheet("ind_`cnt'", modify) 

	* Next country
	}
	