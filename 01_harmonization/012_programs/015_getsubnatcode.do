
	use "${clone}/01_harmonization/011_rawdata/subnational_name.dta", clear
	
	keep if country == "VNM"
	
	labmask district, val(districtname)
	labmask province, val(provincename)
	
	tempfile lfs 
	save `lfs', replace
	
	use "${clone}/01_harmonization/011_rawdata/subnational_name.dta", clear
	
	keep if country == "MYS"
	
	labmask province, val(provincename)
	
	append using `lfs'
	
	rename country code 
	rename (province district) (subnatid1 subnatid2)
	keep code subnatid*
	tempfile lfs 
	save `lfs', replace
	
	
	
	qui foreach c in IDN THA PHL MNG { 
		noi di "`c'"
		clear
		tempfile subnat 
		save `subnat', replace emptyok
		use "${clone}/01_harmonization/011_rawdata/`c'/gld_panel_`c'.dta", clear
		
		cap duplicates drop subnatid1 subnatid2 year, force
		if _rc != 0 {
			duplicates drop subnatid1 year, force
		}
		
		keep code year subnatid*
		
		cap confirm numeric variable subnatid1
		if _rc != 0 {
				if "`c'" == "THA" | "`c'" == "MNG" {
					local prov_no 1 
					local dist_no 2
					* too much lack of harmony for thailand, subnat not availabl
					drop if year <= 2000
				}
				else {
					local prov_no 2 
					local dist_no 4
				}
			
			levelsof year, local(yr)
			
			
			foreach y in `yr' {

				noi di "currently `y'"
				preserve 
				keep if year == `y'
				gen province = substr(subnatid1,1,`prov_no')
				gen district = substr(subnatid2,1,`dist_no')
				destring province district, replace
				
				labmask province , val(subnatid1)
				labmask district, val(subnatid2)
				
				append using `subnat'
				save `subnat', replace
				restore
			}
			
			use `subnat', clear
			
			drop subnatid* 
			rename (province district) (subnatid1 subnatid2)
			
		}
		
		append using `lfs'
		tempfile lfs 
		save `lfs', replace

	}