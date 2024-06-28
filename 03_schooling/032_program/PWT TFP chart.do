***Date: Jan 24, 2024
***Note: Use Penn World Table to generate TFP relative to the US; ctfp; tfpna to show growth 

global path "${clone}/03_schooling/031_rawdata"
global data "pwt1001.dta"
global save "${clone}/03_schooling/033_output/TFP chart.xlsx"
global save2 "${clone}/03_schooling/033_output/TFP growth chart.xlsx"
global save3 "${clone}/03_schooling/033_output/TFP by region.xlsx"

//merge region code 
	wbopendata, indicator(NY.GDP.MKTP.PP.KD) long clear 
	bys countryname regionname incomelevelname: keep if _n ==1
	keep countryname countrycode regionname incomelevelname 
	gen high_inc = incomelevelname == "High income"

	gen region = "China" if countryname == "China" 
	replace region = "Developing East Asia" if regionname == "East Asia and Pacific" ///
	& high_inc == 0 & countryname != "China"
	replace region = "Other Developing Countries" if regionname != "East Asia and Pacific" ///
	& high_inc == 0
	replace region = "Advanced Economies" if high_inc == 1 & regionname != "East Asia and Pacific"

	keep if !mi(region)

	* Merge country data with pwt 
	merge 1:m countrycode using "${path}/${data}", keep(3) nogen 
	drop if mi(ctfp)

	save "${path}/pwt_data_original.dta", replace 
	
	preserve 

	///TFP 
	//1 - TFP by region
	keep if year >= 1970 /*data until 2019*/
	collapse (mean) ctfp, by(year region)

	sort region year
	reshape wide ctfp, i(region) j(year)
	
	export excel using "${save}", sheet("raw") firstrow(var) sheetreplace 

	restore
	preserve 
	keep if year >= 1970 
	collapse (median) ctfp, by(year region)

	sort region year
	reshape wide ctfp, i(region) j(year)
	export excel using "$save", sheet("raw - med") firstrow(var) sheetreplace 

	restore 
	preserve

	//2 - TFP by EAP country
	keep if year >= 1970
	keep if regionname == "East Asia and Pacific"
	sort countryname year
	keep countryname year ctfp

	reshape wide ctfp, i(countryname) j(year)
	export excel using "$save", sheet("raw 2") firstrow(var) sheetreplace 


	//3 - TFP by WB region 
	restore 
	preserve 

	keep countryname regionname ctfp year
	sort regionname countryname year
	tempfile export 
	save `export', replace 

	levelsof regionname, local(levels)
	foreach level in `r(levels)' {
	
	di "`level'"
	
	use `export', clear 
		keep if regionname == "`level'"
		export excel using "${save3}", sheet("`level'") firstrow(var) sheetreplace 
}


************************************************************
	///TFP growth composition 
	local laysvars "yr_sch_ipolate reading_ipolate growth_rate back_score5_agg back_lays5_agg back_score50_agg back_lays50_agg back_score95_agg back_lays95_agg pop"
	use "${clone}/03_schooling/033_output/lays_simulation.dta", clear
	keep if agefrom == 15
	tempfile lays 
	save `lays', replace
	
	use "$path\pwt_data_original.dta", clear 
	merge 1:1 countrycode year using `lays', keep(matched) keepusing(`laysvars')
	rename rgdpna GDPconst_PWT
	rename rgdpe GDPPPP_PWT
	rename rtfpna TFP_PWT
	rename rkna Capserv_PWT
	rename emp Numworkers_PWT
	rename avh Hourswork_PWT
	rename labsh Laborshare_PWT
	
	
	foreach s in hc back_lays5_agg back_lays50_agg back_lays95_agg  {
		
	preserve 
	
	rename `s' Humancap_PWT
	

	gen Labpro_emp_PWT = GDPconst_PWT / Numworkers_PWT
	gen Labpro_hours_PWT = GDPconst_PWT / Numworkers_PWT / Hourswork_PWT
	gen Cap_lab_PWT = Capserv_PWT / Numworkers_PWT
	gen Cap_lab2_PWT = Capserv_PWT / Numworkers_PWT / Hourswork_PWT
	keep GDP* TFP* Cap* Num* Hours* Human* Lab* countryname countrycode region year 
	egen countryid = group(countrycode)
	xtset countryid year

	foreach var of varlist GDP* TFP* Cap* Num* Hours* Human* Lab* {
	gen g`var' = d.`var'/l.`var'
}
	
	//calculating TFP 
	gen gTFPemp_PWTself = gLabpro_emp_PWT - gCap_lab_PWT * (1-Laborshare_PWT) - gHumancap_PWT * Laborshare_PWT
	gen gTFPhrs_PWTself = gLabpro_hours_PWT - gCap_lab2_PWT * (1-Laborshare_PWT) - gHumancap_PWT * Laborshare_PWT

	//hours worked 
	gen TFP_PWTself = 1 if year ==2010
	bysort countryname (year): replace TFP_PWTself = TFP_PWTself[_n-1]*(1+gTFPhrs_PWTself) if year > 2010
	gsort countryname -year
	bysort countryname: replace TFP_PWTself = TFP_PWTself[_n-1]/(1+gTFPhrs_PWTself[_n-1]) if year < 2010
	corr TFP_PWTself TFP_PWT /*use hours worked, higher correlation */

	//employment 
	gen TFP_PWTself_emp = 1 if year ==2010
	bysort countryname (year): replace TFP_PWTself_emp = TFP_PWTself_emp[_n-1]*(1+gTFPemp_PWTself) if year > 2010
	gsort countryname -year
	bysort countryname: replace TFP_PWTself_emp = TFP_PWTself_emp[_n-1]/(1+gTFPemp_PWTself[_n-1]) if year < 2010

	gen gcap = gCap_lab2_PWT * (1-Laborshare_PWT)
	gen ghc = gHumancap_PWT * Laborshare_PWT


	gen time = " "
	replace time = "2012-19" if year>=2012 & year<=2019
	replace time = "2000-07" if year>=2000 & year<=2007 
	replace time = "1989-96" if year>=1989 & year<= 1996
	drop if time == " "
	keep countryname region year gcap ghc GDPPPP_PWT gTFP_PWT gLabpro_hours_PWT time ghc*

	collapse (mean) gLabpro_hours_PWT gcap ghc gTFP_PWT [w=GDPPPP_PWT], by(region time)
	reshape long g, i(region time) j(v) string
	replace time = "96" if time == "1989-96" 
	replace time = "07" if time == "2000-07"
	replace time = "19" if time == "2012-19"
	reshape wide g, i(region v) j(time) string
	
	gen scen = "`s'"
	order scen region v g96 g07 g19
	
	export excel using "$save2", sheet("pwt_`s'") firstrow(var) sheetreplace 
	* End of loop 
	restore
	}

