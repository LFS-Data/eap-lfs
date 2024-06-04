*---------------------------------------------------------------- *
*- Task: Download list of interested microdata from datalibweb and save to local computer 
*- Last Modified: Yi Ning Wong on 2/26/2024
*- Note: This routine requires datalibweb to be installed on the WB computer, to be able to retrieve data harmonized by teams.
*------------------------------------------------------------------*

	global overwrite 0 // 	Set 1 if you are running the data from scratch or would like to check for updates in dlw.

	cap which datalibweb
	if _rc != 0 {
    noi disp as error _n `"{phang}Datalibweb package not found. Please go to "datalibweb/" and download the package to your ado folder. This will only work for WB computers. {p_end}"'
    error 2222
  }
	
	* Download cpi data
	if ${overwrite} == 1 {
	* Note: datalibweb has cpi (2017=100) compiled from household surveys (GMD) which is more granular. However, we don't currently need it and will use WDI instead (2010=100)
	* Commented below is the command to retrieve this.
	//datalibweb, country(Support) year(2005) type(GMD) surveyid(Support_2005_CPI_v10_M_v01_A_GMD) filename(Support_2005_CPI_v10_M_v01_A_GMD_CPIICP.dta)
	
	wbopendata, indicator(fp.cpi.totl) long clear
	keep if year >= 1985
	
	save "${clone}/01_harmonization/011_rawdata/cpiicp.dta", replace 

	
	clear
	* Save an empty file to append the surveys to
	save "${clone}/01_harmonization/011_rawdata/IDN/gld_panel_IDN.dta", replace emptyok
	save "${clone}/01_harmonization/011_rawdata/MNG/gld_panel_MNG.dta", replace emptyok
	save "${clone}/01_harmonization/011_rawdata/PHL/gld_panel_PHL.dta", replace emptyok
	save "${clone}/01_harmonization/011_rawdata/THA/gld_panel_THA.dta", replace emptyok
	}
	
	* Catalog_GMD
	* -- Step 1. Read the Catalog of all interested Data -- *
	import excel "${clone}/00_documentation/EAP_Data_catalog.xlsx", clear firstrow sheet("Catalog_GLD") cellrange(A2:I220)

//	keep if country == "MNG"
	keep if datalibweb == 1 & Public == "Yes" 

	* -- Step 2. Run each of the surveys in the catalog -- *
	levelsof id, local(surveyid)
	
	noi	foreach survey of local surveyid {
	
		* makes sure we check all of the files 
		preserve 

		noi di "Running `survey'.."
	
		* Parsing region year and assessment from survey
		gettoken cnt aux_token  : survey,    parse("_")
		gettoken trash  aux_token  : aux_token, parse("_")
		gettoken year   aux_token  : aux_token, parse("_")
		gettoken trash  sur : aux_token, parse("_")
		
		noi di "`sur'"
		
		if ("`cnt'" == "THA" | "`cnt'" == "IDN" | "`cnt'" == "MNG" | "`cnt'" == "PHL") {
		* Set the directory that saves the file
		local outputdir "${clone}/01_harmonization/011_rawdata/`cnt'/`sur'_`year'"
		* Check if folder exists
		mata : st_numscalar("exists", direxists("${clone}/01_harmonization/011_rawdata/`cnt'/`sur'_`year'"))
		
		* Create a folder if it doesn't 
		if scalar(exists) == 0 {
			mkdir "${clone}/01_harmonization/011_rawdata/`cnt'/`sur'_`year'"
			noi di "Created New Folder for `survey'"
		}
		else {
			noi di ""
		}
	* End of condition for EAP countries
	}
	else {
		* This is where non eap data will be saved
		local outputdir "${clone}/01_harmonization/011_rawdata/OTHER"
		
	}
		
		keep if id == "`survey'" 
		
		* Run each of the files of the given survey
		cap dlw, coun(`cnt') y(`year') t(GLD) mod(ALL) verm(01) vera(07) sur(`sur')
		* If you can read the file on datalibweb, save it.
			if _rc == 0 {
			cap save "`outputdir'/`survey'", replace
			tostring *, replace

			noi di "{phang}Saving survey (ver6) {p_end}"
		} 
		* If ver 6 not available, try earlier version
		else if _rc != 0 {
			noi di "trying 5"
			cap dlw, coun(`cnt') y(`year') t(GLD) mod(ALL) verm(01) vera(05) sur(`sur')
			* Save version 4 if that's the latest available 
			if _rc == 0 {
			cap save "`outputdir'/`sur'", replace
			tostring *, replace

			noi di "{phang}Saving survey (ver5) {p_end}"
			}
			else if _rc != 0 {
				noi di "trying 4"

				cap dlw, coun(`cnt') y(`year') t(GLD) mod(ALL) verm(01) vera(04) sur(`sur')
				* Save version 3 if that's the latest available 
				if _rc == 0 {
					cap save "`outputdir'/`survey'", replace
					tostring *, replace

					noi di "{phang}Saving survey (ver4) {p_end}"
					} 
				* Save version 3 if that's the latest available 
					else if _rc != 0 {
				noi di "trying 3"
					
						cap dlw, coun(`cnt') y(`year') t(GLD) mod(ALL) verm(01) vera(03) sur(`sur')

						if _rc == 0 {
							cap save "`outputdir'/`survey'", replace
							tostring *, replace

							noi di "{phang}Saving survey (ver3) {p_end}"
							}
					* Ver 2	
					else if _rc != 0 {
						
				noi di "trying 2"

						cap dlw, coun(`cnt') y(`year') t(GLD) mod(ALL) verm(01) vera(02) sur(`sur')


						if _rc == 0 {
							cap save "`outputdir'/`survey'", replace
							tostring *, replace

							noi di "{phang}Saving survey (ver2) {p_end}"
							}
					* Ver 1
					else if _rc != 0 {
				noi di "trying 1"

						cap dlw, coun(`cnt') y(`year') t(GLD) mod(ALL) verm(01) vera(01) sur(`sur')

						if _rc == 0 {
							cap save "`outputdir'/`survey'", replace
							tostring *, replace

							noi di "{phang}Saving survey (ver1) {p_end}"
							}
							else {
							* If you cannot read any of the vers , either you need permission (it's a private file, or you need to double check the file name).
							noi di "{phang}File not found, skipping{p_end}"
							}
						}
					}
				}
			}
		}
		
		* For now, we're only interested in getting panel data from EAP countries in GLD
		if ("`cnt'" == "THA" | "`cnt'" == "IDN" | "`cnt'" == "MNG" | "`cnt'" == "PHL") {
				
		* -- Step 3: Append to existing dataset -- *
		cap drop relationcs 
		
		cap tostring *, format("%12.0f") replace
		* This was not properly harmonized, make it consistent
		cap destring year, replace
		cap destring occup_skill, replace
		cap destring wage_no_compen, replace
		cap destring whours, replace
		cap destring wave, replace
		cap destring wage_no_compen_2, replace
		cap destring industrycat10_2_year, replace
		cap destring wage_no_compen_2_year, replace
		cap destring weight, replace
		cap destring whours_2, replace
		cap destring industry_orig, replace
		cap destring industry_orig_2, replace
		cap destring industry_orig_year, replace
		cap destring industry_orig_2_year, replace
		cap destring int_month, replace
		cap destring migrated_years, replace
		cap destring unempldur_*, replace
		cap destring psu, replace
		cap destring relationcs, replace	
		cap drop migrated_from_code
		destring age, replace
		
		gen module = "LFS"

		cap drop country B id module Public datalibweb eap_ceo
		
		append using "${clone}/01_harmonization/011_rawdata/`cnt'/gld_panel_`cnt'.dta"
		save "${clone}/01_harmonization/011_rawdata/`cnt'/gld_panel_`cnt'.dta", replace	
		}
		else {
		* End of if else OTHER countries
		* Won't get saved if we dont find the data
		cap save "`outputdir'/`survey'", replace
		}
		* Next surveyid
		restore
		}


	