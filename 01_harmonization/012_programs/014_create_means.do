*---------------------------------------------------------------- *
*- Task: Tabulate interested means from the GLD, by breakdown 
*- Last Modified: Yi Ning Wong on 3/28/2024
*- Step 1: Define
*------------------------------------------------------------------*
	
	*------------------------------------------------------*
	** Step 1. Different Disaggregations and tabulations  **
	*----------------------------------------------------*
	local disaggregations "all male occup occup_skill educat4 agegrp2 empstat formal emprt higher_educ industrycat10 industrycat4 industrycat5 agegrp ocusec marital " // 
	local factortabs "lstatus educat4 industrycat10 industrycat4 industrycat5 empstat" //  
	local meantabs "annual_wage1 hourly_wage*"
	local sumtabs "obs_* weight_emp"
	//local mediantabs "annual_wage1 hourly_wage"
	local countries "IDN MYS PHL MNG THA VNM"  // MYS PHL   
	local measure "mean" // 
	*----------------------------------------------------*
	** Pt 1. Different Disaggregations and tabulations  **
	*----------------------------------------------------*
	foreach m in `measure' {
		noi di "`m'"
	qui foreach cnt in `countries' {
		* The row number in which output will start
		//local cnt "MYS"
		use "${clone}/01_harmonization/011_rawdata/`cnt'/final_panel_`cnt'.dta", clear
		noi di "Reading `cnt'"
		gen weight_emp = weight if module != "SWS"
		
		
		* Start Row Number (for saving to excel later)
		local i = 1
	
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
			//local agg "all"
			//local m "median"
			//local meantabs "annual_wage1 hourly_wage*"
			//local sumtabs "obs_* weight_emp"			
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
				collapse (`m')  val* (median) `meantabs' (rawsum) `sumtabs' [pw=weight], by(group)
				* Replace the labels after collapse 
				foreach v of var val* `meantabs' `sumtabs'  {
					label var `v' `"`l`v''"'
				}
				}
				else {
				collapse (median) `meantabs' (rawsum) `sumtabs' [pw=weight], by(group)	
				* Replace the labels after collapse 
				foreach v of var  `meantabs' `sumtabs' {
					label var `v' `"`l`v''"'
				}
				}
					

				* Split parse the year and the subgroup into two columns
				drop if group == ""
				split group, parse("_")
				
				* Get the number of unique levels of subgroup-year
				* Use this to calculate number of rows to add in the excel append
				qui unique group
				mat num=r(unique)
				local num = `r(unique)'
				di "`num'"
					
				* Cleaning
				sort group
				gen valdummy = .
				keep val* `meantabs' `sumtabs' group1 group2
				drop valdummy 
				
				destring group1, replace
				rename group1 year
				rename group2 subgroup
					
				gen countrycode = "`cnt'"

				* Denote the subgroup
				gen group = "`agg'"

					if "`agg'" == "all" {
						local saveopt "firstrow(varlabels)"
					}
					else {
						local saveopt ""
					}
					order countrycode year subgroup group
					
			* Convert nominal wage to real wage
			merge m:1 countrycode year using "${clone}/01_harmonization/011_rawdata/cpiicp.dta", keep(matched) keepusing(fp_cpi_totl) nogen
			
			noi di "Step 2 Done: Merge CPI from WDI"
			
		
	
	
					* Save the file 
					export excel using "${clone}/01_harmonization/013_outputs/tabstats_`m'.xlsx", `saveopt' sheet("`cnt'_data", modify) cell(A`i')
					
				* Next subgroup				
				restore
				if "`agg'"=="all" {
				local i= `i'+`num'+1
				}
				else {
				local i= `i'+`num'
	
				}
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
	