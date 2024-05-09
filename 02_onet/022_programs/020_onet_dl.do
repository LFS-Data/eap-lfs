*---------------------------------------------------------------- *
*- 020 O*NEt Download
*- Task: Download all the ONET database versions and append them
*- Last Modified: Yi Ning Wong on 4/17/2024
*------------------------------------------------------------------*

	* The directory in which the net downloads are to be saved
	cd "${clone}/02_onet/021_rawdata"
	
	* The onet version links
	local onet_ver "51 60 70 80 90 10_0 11_0 12_0 14_0 15_0 15_1 16_0 17_0 18_0 18_1 19_0 20_0"
	local onet_ver2 "20_1_text 20_2_text 20_3_text 21_0_text 21_1_text 21_2_text 21_3_text 22_0_text 22_1_text 22_2_text 22_3_text 23_0_text 23_1_text 23_2_text 23_3_text 24_0_text 24_1_text 24_2_text 24_3_text 25_0_text 25_1_text 25_1_text 25_2_text 25_3_text 26_0_text 26_1_text 26_2_text 27_0_text 27_1_text 27_2_text 27_3_text 28_0_text 28_1_text 28_2_text"
	
	* Install the files 
	foreach ver in `onet_ver' {
		copy https://www.onetcenter.org/dl_files/db_`ver'.zip db_`ver'.zip, replace
		unzipfile db_`ver'.zip, replace
	}
	* (Later files have a different link)
	foreach ver in `onet_ver2' {
		copy https://www.onetcenter.org/dl_files/database/db_`ver'.zip db_`ver'.zip, replace
		unzipfile db_`ver'.zip, replace
	}


	* Save an empty database for the two comopnents we're interested in 
	* Knowledge
	clear
	save "${clone}/01_harmonization/013_outputs/onet_knowledge.dta", emptyok replace
	* Work Activity
	clear
	save "${clone}/01_harmonization/013_outputs/onet_workactivity.dta", emptyok replace

	* Get all the unzipped knowledge files and append them
	foreach ver in `onet_ver' `onet_ver1' {
		clear
		import delimited "${clone}/01_harmonization/011_rawdata/onet/db_`ver'/Knowledge.txt", delimiter(tab)

		gen onet_ver = "`ver'"
		append using "${clone}/01_harmonization/013_outputs/onet_full.dta"
		save "${clone}/01_harmonization/013_outputs/onet_full.dta", replace

	}

	foreach ver in `onet_ver' `onet_ver1' {
		clear
		cap import delimited "${clone}/01_harmonization/011_rawdata/onet/db_`ver'/Work Activities.txt", delimiter(tab)
		
		* Some work activity files are named differently
		if _rc != 0 {
		cap import delimited "${clone}/01_harmonization/011_rawdata/onet/db_`ver'/WorkActivity.txt", delimiter(tab)

		}

		gen onet_ver = "`ver'"
		append using "${clone}/01_harmonization/013_outputs/onet_workactivity.dta"
		save "${clone}/01_harmonization/013_outputs/onet_workactivity.dta", replace

	}