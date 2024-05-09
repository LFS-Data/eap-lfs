*---------------------------------------------------------------- *
*- Task 023: Append latest data to get the digital score X income level
*- Last Modified: Yi Ning Wong on 4/22/2024
*------------------------------------------------------------------*
	
	*------------------------------------------------------*
	** Step 1. Set up 									  **
	*------------------------------------------------------*
	
	local countries "THA MYS PHL IDN MNG VNM "  
	local other "bgd bol bra chl col eth ind lka mex npl pak rwa sle tur tza zaf"
	global onet_dir "${clone}/02_onet/023_outputs"
	global onet_file "onet.xlsx"
	
	* Empty file 
	save "${onet_dir}/onet_gdppc.dta", replace emptyok
	
	*------------------------------------------------------*
	** Step 2. Append the latest year of digital scores	  **
	*------------------------------------------------------*
		
	foreach cnt in `countries' `other' {

	import excel "${onet_dir}/${onet_file}", sheet("`cnt'") clear firstrow
	
	keep if subgroup == " National"
	drop if score_mean == .
	bysort countrycode (year) : keep if _n == _N
	
	replace countrycode = strupper(countrycode)
	
	append using "${onet_dir}/onet_gdppc.dta"
	save "${onet_dir}/onet_gdppc.dta", replace
	}
	
	*----------------------------------------------------------*
	** Step 3. Merge with the gdppc of the corresponding year **
	*----------------------------------------------------------*
	*  Name: GDP per capita, PPP (constant 2017 international $)
	wbopendata, indicator(ny.gdp.pcap.pp.kd) clear long
 
	keep countrycode region year ny_gdp_pcap_*
	merge 1:1 countrycode year using "${onet_dir}/onet_gdppc.dta", keep(matched using)
	
	save "${onet_dir}/onet_gdppc.dta", replace
	export excel using "${onet_dir}/${onet_file}", firstrow(varlabels) sheet("GDPPC", modify)
