*---------------------------------------------------------------- *
*- Task: Subset interested outcomes for graphs
*- Last Modified: Yi Ning Wong on 5/28/2024
*------------------------------------------------------------------*

	local countries "IDN VNM MYS THA PHL MNG" 
	foreach cnt in `countries' {
		noi di "`cnt'"
	//local cnt "IDN"
	import excel "${clone}/01_harmonization/013_outputs/tabstats_mean.xlsx", sheet("`cnt'_data") firstrow clear
	
	rename *, lower
	keep countrycode year subgroup group annual_wage1 hourly_wage1 whetherdataonannualwageexis whetherdataonhourlywageexis weight_emp fpcpitotl
	
	rename (whetherdataonannualwageexis whetherdataonhourlywageexis) (n_annual n_hourly)
	
	keep if inlist(group, "all", "educat4", "industrycat5", "male", "occup_skill")
	
	summarize year if annual_wage1 != . & hourly_wage1 != .
	local min_year = `r(min)'
	summarize annual_wage1 if year==`min_year' & group == "all"
	local awage = `r(mean)'
	
	
	summarize hourly_wage1 if year==`min_year' & group == "all"
	local hwage = `r(mean)'
	
	summarize fpcpitotl if year==`min_year' & group == "all"
	local cpi = `r(mean)'
	
	noi di "`min_year' `awage' `hwage'"

	
	foreach w in hwage awage { //  
		if "`w'"=="hwage" {
			local v "hourly_wage1"
		} 
		else {
			local v "annual_wage1"
		}
	
	replace `v' = . if `v' == 0
	
	gen rebase1 = 1 if year == `min_year' 
	bysort subgroup (year): replace rebase1 = (fpcpitotl/fpcpitotl[_n-1])*rebase1[_n-1] if rebase1 ==. 
	summarize year if rebase1 == . 
	local min_year2 = `r(min)'
	replace rebase1 = fpcpitotl/`cpi' if year==`min_year2'
	bysort subgroup (year): replace rebase1 = (fpcpitotl/fpcpitotl[_n-1])*rebase1[_n-1] if rebase1 ==. 

	gen rebase2 = `v'*(rebase1)/`v'
	
	//local min_year 1989
	gen rebase3 = `v'/rebase2
	gen `w'_inf = rebase3/``w''
	
	drop rebase*
	}
	sort group subgroup year
	
	drop if hwage_inf == .
	export excel "${clone}/01_harmonization/013_outputs/tabstats_mean.xlsx", sheet("`cnt'", modify) firstrow(variable) 
	
	}