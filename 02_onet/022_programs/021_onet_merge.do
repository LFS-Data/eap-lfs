*---------------------------------------------------------------- *
*- 021_ONET MERGE Task: Calculate Digital Score using ONET and Transform SOC to ISCO
*- Created by: Yi Ning Wong on 4/17/2024
*- Last Modified: Yi Ning Wong on 4/17/2024
* Step 1. Calculate digital score with Brookings paper method
* Step 2. SOC different year to 2010
* Step 3. SOC 2010 ISCO-08
* Step 4. Beautification
* Step 5. Average the scores to 2-digit ISCO
*------------------------------------------------------------------*
	*- Note: run 020_onet_dl to get the input files (onet_knowledge and onet_workactivity)
	* However, to save computation time, a .csv version of the file exists on the repo to allow skipping the download steps
	* Save a .dta version of the files if they do not exist on the local machine 
	cap confirm "${clone}/02_onet/021_rawdata/onet_knowledge.dta"
	
	if _rc != 0 {
		use "${flagship}/5. joint works/STCs/Yi Ning Wong/03_outputs/onet/onet_knowledge.dta", clear
		save "${clone}/02_onet/021_rawdata/onet_knowledge.dta", replace
		
		use "${flagship}/5. joint works/STCs/Yi Ning Wong/03_outputs/onet/onet_workactivity.dta", clear
		save "${clone}/02_onet/021_rawdata/onet_workactivity.dta", replace
	}
	
	*-----------------------------------------------------------*
	** 1. Calculate digital score using Brookings methodology  **
	*-----------------------------------------------------------*
	* https://www.brookings.edu/articles/digitalization-and-the-american-workforce/

	* 1. Knowledge
	use "${clone}/02_onet/021_rawdata/onet_knowledge.dta", clear

	* Keep only "Computers and Electronics" Element
	keep if elementname == "Computers and Electronics"
	keep onetsoccode scaleid date datavalue onet_ver

	rename datavalue knowledge
	
	reshape wide knowledge, i(onetsoccode date onet_ver) j(scaleid, string)
	
	* Standardized to a scale of 1 to 100
	* Importance scale is from 1 to 5 
	* Level scale is from 0 to 7
	* S = ((O - L)/(H - L))
	gen kn_im_scale = ((knowledgeIM-1)/(5-1))*100
	gen kn_lv_scale = ((knowledgeLV-0)/(7-0))*100
	
	tempfile kn 
	save `kn', replace
	
	* 2. Work Activity
	use "${clone}/02_onet/021_rawdata/onet_workactivity.dta", clear

	* Keep only Interacting With Computers element
	keep if elementname == "Interacting With Computers"
	keep onetsoccode scaleid date datavalue onet_ver

	rename datavalue workactivity
	
	reshape wide workactivity, i(onetsoccode date onet_ver) j(scaleid, string)
	
	* Standardized to a scale of 1 to 100
	* S = ((O - L)/(H - L))
	gen wa_im_scale = ((workactivityIM-1)/(5-1))*100
	gen wa_lv_scale = ((workactivityLV-0)/(7-0))*100
	
	* Merge work activity with knowledge
	merge 1:1 onetsoccode onet_ver using `kn' , nogen keep(matched)
	
	* MOST IMPORTANT: Calculate the digital score
	gen digitalscore = (sqrt(kn_lv_scale*kn_im_scale)+sqrt(wa_lv_scale*wa_im_scale))/2
		
	* Get a unique identifier for both onet version and year
	gen year = substr(date,-4,.)
	gen year_onet = year + "_" + onet_ver 
	drop onet_ver date
	
	* make IM and LV better to identify 
	rename *, lower
	rename (knowledgeim knowledgelv workactivityim workactivitylv) (kn_im_raw kn_lv_raw wa_im_raw wa_lv_raw)
	
	* Categorize digital by levels 
	gen digitalskill = 0 if digitalscore < 33
	replace digitalskill = 1 if digitalscore >= 33 & digitalscore <= 60
	replace digitalskill = 2 if digitalscore >60
	label define lbl_dig 0 "Low" 1 "Medium" 2 "High"
	label values digitalskill lbl_dig
		
	gen soccode = substr(onetsoccode,1,7)	
	
	* Create a year variable based on the release
	destring year, replace
	
	* Make a numeric version of the ONET releases
	gen onet = substr(year_onet,6,4)
	replace onet = subinstr(onet,"_",".",.)
	destring onet, replace
	* The oldest are 5.0,6.0,etc. but they were saved as 50+
	replace onet = onet/10 if onet > 40
	
	* Remove trailing spaces
	replace soccode = ustrtrim(soccode)
	replace onetsoccode = ustrtrim(onetsoccode)
	
	* Save 5 Sets of O*Nets based on the version SOC classifications
	preserve 
	
	* Version 1 (SOC 2000)
	keep if onet < 10.0
	
	tempfile onet2000
	save `onet2000', replace 
	
	restore 
	preserve
	
	* Version 2 (SOC 2006)
	keep if onet >= 10 & onet < 14 
	replace soccode = onetsoccode
	tempfile onet2006
	save `onet2006', replace 
	
	restore 
	preserve
	
	* Version 3 (SOC 2009)
	keep if onet >= 14 & onet < 15.1
	replace soccode = onetsoccode
	tempfile onet2009
	save `onet2009', replace 
	
	restore 
	preserve
		
	* Version 4 (SOC 2010)
	keep if onet >= 15.1 & onet < 25.0
	tempfile onet2010
	save `onet2010', replace 
	
	restore 
	preserve
	
	* Version 4 (SOC 2018)
	keep if onet >= 25
	replace soccode = onetsoccode

	tempfile onet2018
	save `onet2018', replace 

	restore 
		
	*--------------------------------------------------------*
	** 2. SOC different year to 2010 				 		**
	*--------------------------------------------------------*
	* Taxonomy history: https://www.onetcenter.org/taxonomy.html#history
	
	*---------------------*
	* a. SOC 2000 to 2010 *
	*---------------------*
	* Data versions 5.0 to <10.0 are from SOC 2000
	import excel "${clone}/02_onet/021_rawdata/soc_2000_to_2010_crosswalk.xls", clear cellrange(A7:D868) firstrow
	
	rename *, lower 
	drop if soccode == ""
	
	* Remove leading and trailing spaces
	replace soccode = ustrtrim(soccode)
	
	* Replace some SOC 00 up to version 9.0 (2004)
	replace soccode = "11-3040" if soccode == "11-3049"
	
	rename (soccode c) (soc00 soc10)
	rename soc00 soccode
	drop soctitle d
	
	* CROSSWALKING SOC 2000 AND 2010
	merge m:m soccode using `onet2000', keep(matched using) nogen

	gen original_soc = 2000

	tempfile onet2000
	save `onet2000', replace 

	*-----------------------------*
	* b. SOC 2006 to 2009 to 2010 *
	*-----------------------------*
	* Data versions 10.0 to <14.0 are from SOC 2006
	import excel "${clone}/02_onet/021_rawdata/2006_to_2009_Crosswalk.xlsx", clear cellrange(A4:D953) firstrow
	
	rename *, lower
	keep onet*code

	* Remove leading and trailing spaces
	replace onetsoc2006code = ustrtrim(onetsoc2006code)
	replace onetsoc2009code = ustrtrim(onetsoc2009code)
	
	tempfile soc0609 
	save `soc0609', replace
	
	import excel "${clone}/02_onet/021_rawdata/2009_to_2010_Crosswalk.xlsx", clear cellrange(A4:D1114) firstrow
	
	rename *, lower
	keep onet*code
	
	replace onetsoc2010code = ustrtrim(onetsoc2010code)
	replace onetsoc2009code = ustrtrim(onetsoc2009code)
	
	merge m:m onetsoc2009code using `soc0609', nogen keep(matched using)
	
	rename onetsoc20*code soc* 
	rename soc06 soccode

	merge m:m soccode using `onet2006', nogen keep(matched using)
	
	drop soc09
	
	gen original_soc = 2006

	tempfile onet2006
	save `onet2006', replace 

	*-----------------------------*
	* c. SOC 2009 to 2010  		  *
	*-----------------------------*
	* Data versions 14.0 to 15.0 are from SOC 2009
	import excel "${clone}/02_onet/021_rawdata/2009_to_2010_Crosswalk.xlsx", clear cellrange(A4:D1114) firstrow
	
	rename *, lower
	keep onet*code
	rename onetsoc20*code soc* 
	rename soc09 soccode
	
	replace soccode = ustrtrim(soccode)
	replace soc10 = ustrtrim(soc10)
	

	merge m:m soccode using `onet2009', nogen keep(matched using)
	
	gen original_soc = 2009

	tempfile onet2009
	save `onet2009', replace 
	
	*------------------------------ *
	* d. SOC 2010 (No Change Needed)*
	*------------------------------ *
	* Data versions 15.1 to <25.0 are from SOC 2010
	use `onet2010', clear
	
	gen soc10 = soccode 
	gen original_soc = 2010
	
	tempfile onet2010 
	save `onet2010', replace
	
	
	*------------------------------ *
	* e. SOC 2018 to 2010 			*
	*------------------------------ *
	* Data versions 25.0 onward are from SOC 2018 
	import excel "${clone}/02_onet/021_rawdata/2010_to_2019_Crosswalk.xlsx", clear cellrange(A4:D1168) firstrow
	
	rename *, lower
	keep onet*code
	rename onetsoc20*code soc* 
	rename soc19 soccode
	
	replace soccode = ustrtrim(soccode)
	replace soc10 = ustrtrim(soc10)
		
	* CROSSWALKING SOC 2018 AND 2010
	merge m:m soccode using `onet2018' , nogen keep(matched)
	
	gen original_soc = 2018
	
	append using `onet2000'
	append using `onet2006'
	append using `onet2009'
	append using `onet2010'
	
	order year_onet year onet soc10 *raw *scale digitalscore digitalskill
	
	gen soc10_6d = substr(soc10,1,7)

	tempfile temp 
	save `temp', replace
	e
	*--------------------------------------------------------*
	** 3. SOC 2010 to ISCO-08 							 	**
	*--------------------------------------------------------*
	
	import excel "${clone}/02_onet/021_rawdata/ISCO_SOC_Crosswalk.xls", clear firstrow sheet("2010 SOC to ISCO-08") cellrange(A7:F1131)
	
	rename *, lower
	
	replace soccode = ustrtrim(soccode)
	
	keep soccode isco08code 
	rename soccode soc10_6d

	merge m:m soc10_6d using `temp' , keep(matched) nogen
	
	** ---------------- **
	* 4. Beautification  *
	** ---------------- **
	lab var year_onet "Year and O*Net Version"
	lab var year "Year of O*Net Release"
	lab var onet "O*Net Version"
	lab var wa_im_scale "Work Activity Importance Scale (1 to 5)"
	lab var wa_lv_scale "Work Activity Level Scale (0 to 7)"
	lab var kn_im_scale "Knowledge Importance Scale (1 to 5)"
	lab var kn_lv_scale "Knowledge Level Scale (0 to 7)"
	lab var digitalscore "Digital Score (0 to 100)"
	lab var digitalskill "Digital Skill (Low Medium High)"
	lab var onetsoccode "Original SOC Code (All Taxonomies)"
	lab var original_soc "ONET Taxonomy Year"
	sort isco08code soc10_6d year_onet original_soc 
	
	order year_onet year onet original_soc isco* soc10* onetsoccode
	drop soccode
	replace isco08code = ustrtrim(isco08code)
	
	save "${clone}/02_onet/023_outputs/soc_isco_digitalscore.dta", replace

	** ---------------- ------**
	* 5. 2 digit classification*
	** ---------------------- **
	import excel "${clone}/02_onet/021_rawdata/ISCO-08 EN Structure and definitions.xlsx", clear firstrow
	
	rename *, lower
	
	destring isco08code, replace
	drop if isco08code > 99
	tostring isco08code, replace
	
	rename isco08code isco08_2d
	tempfile title 
	save `title', replace
	
	use "${clone}/02_onet/023_outputs/soc_isco_digitalscore.dta", clear
	

	keep digitalscore digitalskill onet isco* 

	egen agg_group = group(onet isco08code), label
	decode agg_group, gen(group)
	
	collapse (mean) digitalscore, by(group)
	split group, parse(" ")
	
	drop group 
	
	rename (group1 group2) (onet isco08)
	
	gen isco08_2d= substr(isco08,1,2)
	
	egen agg_grp = group(onet isco08_2d), label
	decode agg_grp, gen(group)
	
	collapse (mean) digitalscore_mean=digitalscore (median) digitalscore_p50=digitalscore (max) digitalscore_max=digitalscore (min) digitalscore_min=digitalscore, by(group)
	split group, parse(" ")
	
	drop group 
	
	rename (group1 group2) (onet isco08_2d)
	rename digitalscore* score*
	
	order onet isco* score* 
	sort onet isco08*
	
	lab var onet "O*Net Release Version"
	
	* Categorize digital by levels 
	
	foreach measure in mean p50 min max {
	gen skill_`measure' = 0 if score_`measure' < 33
	replace skill_`measure' = 1 if score_`measure' >= 33 & score_`measure' <= 60
	replace skill_`measure' = 2 if score_`measure' >60
	label values skill_`measure' lbl_dig
	}
	
	replace onet = subinstr(onet,".", "_",.)

	reshape wide score_mean score_p50 score_max score_min skill_mean skill_p50 skill_min skill_max, i(isco08_2d) j(onet, string)
	
			
	* Drop versions where all are missing (the earliest SOC)
	 foreach var of varlist _all {

		 capture assert mi(`var')
		 if !_rc {
			drop `var'
		 }
	 }
	 
	rename *p50* *p50_*
	rename *min* *min_*
	rename *max* *max_*
	rename *mean* *mean_*
	
	foreach measure in p50 min max mean {
		gen level_`measure' = score_`measure'_5_1
		gen level_s_`measure' = score_`measure'_5_1
	}
	* Turn everything into a factor of the first, so it is easier to merge back to the large dataset after
	/*
	foreach measure in p50 min max mean {
	
		unab m : score_`measure'* 
	
		foreach v of local m { 
			replace `v'= `v'/level_`measure'
			replace `v' = 0 if `v' == .
			}
			
	unab m : skill_`measure'* 
	
		foreach v of local m { 
			replace `v'= `v'/level_s_`measure'
			replace `v' = 0 if `v' == .
			}
		}
		*/
	merge m:m isco08_2d using `title', keepusing(titleen) keep(master matched)
	sort isco08_2d
	order isco08* title*
	save "${clone}/02_onet/023_outputs/isco_digitalscore_2d.dta", replace

	* save onet 24.1 version 
	global select_ver "24_1"
	
	keep isco08_2d titleen *_${select_ver}
	
	save "${clone}/02_onet/023_outputs/isco_digitalscore_2d_${select_ver}.dta", replace

	** ---------------- ----------------------------------------------------**
	* 6. 4 digit classification + merge with AI aExposure and Automatability *
	** -------------------------------------------------------------------- **
	global ai "C:/Users/`c(username)'/Github/AIOE"
	global automatability "${flagship}/5. joint works/STCs/Karan Singh/02 Data/Karan_data"
	cap confirm file "${clone}/02_onet/021_rawdata/AIOE_DataAppendix_A.dta"
	if _rc != 0 {
	
	* soccode 
	import excel using "${ai}/AIOE_DataAppendix.xlsx", sheet("Appendix A") clear firstrow
	
	rename *, lower 
	
	save "${clone}/02_onet/021_rawdata/AIOE_DataAppendix_A.dta", replace
		
	import excel using "${automatability}/Frey_Osborne_2017.xlsx", sheet("Table 16") clear firstrow
	
	rename *, lower
	
	save "${clone}/02_onet/021_rawdata/frey_osborne_2017_table16.dta", replace
	* soccode 
	
	}
	
	use "${clone}/02_onet/023_outputs/soc_isco_digitalscore.dta", clear
	
	ren soc10_6d soccode
	
	merge m:1 soccode using "${clone}/02_onet/021_rawdata/AIOE_DataAppendix_A.dta", nogen keep(matched master) keepusing(aioe)
	merge m:1 soccode using "${clone}/02_onet/021_rawdata/frey_osborne_2017_table16.dta", nogen keep(matched master) keepusing(probability)
	
	ren soccode soc10_6d
	ren probability automate_pr
	lab var aioe "AI Exposure"
	lab var automate_pr "Automatability"
	
	sort year_onet year isco08code

	save "${clone}/02_onet/023_outputs/soc_isco_digital_all.dta", replace

	
	
	/* WIP
	** ---------------- --------------------------**
	* 5. Wide Version to be Merged with Microdata  *
	** ------------------------------------------ **
	use "${clone}/02_onet/023_outputs/soc_isco_digitalscore.dta", clear

	replace isco08code = ustrtrim(isco08code)

	keep digitalscore digitalskill year_onet isco*
	
	egen agg_group = group(year_onet isco08code), label
	decode agg_group, gen(group)
	
	collapse (mean) digitalscore, by(group)
	split group, parse(" ")
	
	* Categorize digital by levels 
	gen digitalskill = 0 if digitalscore < 33
	replace digitalskill = 1 if digitalscore >= 33 & digitalscore <= 60
	replace digitalskill = 2 if digitalscore >60
	label values digitalskill lbl_dig
	
	drop group 
	
	rename (group1 group2) (year_onet isco08)
	
	reshape wide digitalscore digitalskill, i(isco08) j(year_onet, string)

	rename *_text *
	
	* Remove versions that don't really have data 
	drop dig*2002_12* dig*2002_15* dig*2002_15* dig*2002_18* dig*2002_20* dig*2002_21* dig*2002_22* dig*2002_23* dig*2002_24* 