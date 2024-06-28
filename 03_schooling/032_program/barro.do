	 //https://github.com/barrolee/BarroLeeDataSet/blob/master/BLData/BL_v3_MF.dta
	 local method "SCORE" // options are SCORE or LAYS 
	 
	*----------------------------------------------------------------------------*
	* Step 1. Merging and Cleaning the data
	*----------------------------------------------------------------------------*
	import delimited "${clone}/03_schooling/031_rawdata/pisa_scores.csv", clear
	
	* Some countrycode corrections
	replace countrycode = "NZL" if countryname == "New Zealand"
	drop if countrycode == "BEL"

	* Cleaning 
	foreach v of varlist *_score {
	replace `v' = "" if `v' == "—"
	destring `v', replace
	}


	//reshape wide math_score reading_score science_score, i(countryname countrycode) j(year)


	tempfile pisa_scores
	save `pisa_scores', replace

	* Merge the barro lee dataset 
	use "${clone}/03_schooling/031_rawdata/BL_v3_MF.dta", clear

	keep year WBcode pop agefrom ageto yr_sch yr_sch_sec 

	rename WBcode countrycode
	
	encode countrycode, gen(code)
	
	sort countrycode year agefrom
	by countrycode agefrom, sort: gen n = _n
	
	* Create a new row of the data so that we can merge PISA scores 
	* (the eyrs data won't show up, but just so we get the complete picture)
	expand 2 if n== 1, gen(new)
	
	replace year = 2022 if n==1 & new == 1
	foreach var in yr_sch yr_sch_sec pop {
		replace `var' = . if year == 2022
	}
	
	drop n new
	
	* Fill in missing years in between the 5 year intervals and make sure the country metadata isa dded
	levelsof agefrom, local(age)
	foreach a in `age' {
		preserve
		keep if agefrom == `a'
		xtset code year 
		tsfill 
		foreach var in countrycode agefrom ageto {
			bysort code: fillmissing `var', with(any)
		}
		tempfile age`a'
		save `age`a'', replace
		
		restore
	}
	
	use `age15', clear
	foreach r in 25 35 45 55 {
		append using `age`r''
	}

	* Now we are ready to merge the PISA scores
	merge m:1 countrycode year using `pisa_scores', keep(matched master) nogen

	* Drop countries countries have no PISA scores
	merge m:m countrycode using `pisa_scores', keep(matched) nogen

	* Some initial cleaning and filtering
	drop countryname 
	order year countrycode agefrom ageto yr_* reading*score* math*score* scie*score*
	keep if year >= 1960

	*----------------------------------------------------------------------------*
	* Step 2: Interpolate data
	*----------------------------------------------------------------------------*
	* Interpolate missing years of schooling 
	by code agefrom, sort: ipolate yr_sch year, generate(yr_sch_ipolate)
	order yr_sch_ipolate

	*----------------------------------------------------------------------------*
	* Method A. Calculate LAYS for the corresponding PISA assessment year, based on interpolated EYRS values
	*----------------------------------------------------------------------------*
	if "`method'" == "LAYS" {
		global outcome "lays_ipolate"

		* Create a LAYS Variable based on interpolated EYRS value
		gen lays_ipolate = yr_sch_ipolate*(reading_score/625)

		* Interpolate lays
		by code agefrom, sort: ipolate lays_ipolate year, generate(lays_ipolate2)
		
		drop lays_ipolate 
		rename lays_ipolate2 lays_ipolate
		
		* Calculate the LAYS growth rate per year 
		bysort code agefrom (year): g growth_rate=(lays_ipolate[_n]-lays_ipolate[_n-1])/lays_ipolate[_n-1] if _n!=1 & lays_ipolate!=. 

	}
	else if "`method'" == "SCORE" {
	*----------------------------------------------------------------------------*
	* Method B. Interpolate Reading Score (And use that to calculate LAYS)
	*----------------------------------------------------------------------------*
	* Interpolate Reading
	global outcome "reading_ipolate"
	
	by code agefrom, sort: ipolate reading_score year, generate(reading_ipolate)
	
	bysort code agefrom (year): g growth_rate=(reading_ipolate[_n]-reading_ipolate[_n-1])/reading_ipolate[_n-1] if _n!=1 & reading_ipolate!=. 

	* Calculate one version that includes all the countries
	summarize growth_rate if growth_rate >0  & agefrom == 15, d 
	foreach p in 50 5 95 {
		local full`p' = r(p`p')
		gen full_p`p' = `full`p''
	}
 
 }

	order countrycode code year agefrom ageto yr_sch yr_sch_sec reading_score math_score science_score code *_ipolat* growth_rate
		
	sort countrycode year agefrom
	
	* Create the variables that will store the backward calculated results
	foreach r in gr95 gr50 grmean grmin grmax {
		gen `r' = growth_rate
		gen back_score`r' = reading_ipolate
		gen back_lays`r' = .
	}	
	
	foreach r in 50 95 5 {
		gen back_score`r'_agg = reading_ipolate
		gen back_lays`r'_agg = .
	}
	
	levelsof countrycode, local(cnt)
	levelsof agefrom, local(age)
	
	* We want to make sure only 1 row is filled in each time for the backward calculation to work
	qui foreach a in `age' {
		noi di "Age from `a'"
		foreach c in `cnt' {
			noi di "`c'" 
		
			* Get different growth rates of the given country/agegroup for backward calculation
			quietly: summarize growth_rate if countrycode=="`c'" & agefrom == `a',d
			foreach g in 95 50 min mean max {
				if "`g'" == "95" | "`g'" ==  "50" {
					local p "p"
				}
				else {
					local p ""
				}
				local g`g' = r(`p'`g')
				replace gr`g' = `g`g'' if gr`g' == .
			}
			* Starting year to use as interpolation reference is where first PISA data was available (eg.,2000), then it will filling backward per 1 year
			local j = 0
			
			* Starting year to get interpolated by is the first PISA year minus 1, then it will keep going backward 
			forval i = 1/40 {		
			
			* (Get the first year where data available and the year to be filled in)
			quietly: summarize year if countrycode=="`c'" & agefrom == `a' & ${outcome} != .
			local min_yr = r(min)-`i'
			local min_yr_inter = r(min)-`j'
			local newnew = `min_yr_inter'+1
/*

*/


			* Get the value of the year in the loop (there should only be 1 obs)			
			foreach r in gr95 gr50 grmean grmin grmax {
			quietly: summarize back_score`r' if countrycode=="`c'" & agefrom == `a' & year == `min_yr_inter'
				local score = r(mean)
				noi di "`score'"
			
				replace back_score`r' = `score'*(1-`r') if year == `min_yr' & countrycode=="`c'" & agefrom == `a' 
				replace back_lays`r' = yr_sch_ipolate*(back_score`r'/625) if year == `min_yr' & countrycode=="`c'" & agefrom == `a' 
			}
			
			* Calculate one version that includes all the countries
			 foreach p in 50 5 95 {
				quietly: summarize back_score`p'_agg if countrycode=="`c'" & agefrom == `a' & year == `min_yr_inter' 
				local score = r(mean)
				noi di "`score'"
			
				replace back_score`p'_agg = `score'*(1-full_p`p') if year == `min_yr' & countrycode=="`c'" & agefrom == `a' 
				replace back_lays`p'_agg = yr_sch_ipolate*(back_score`p'_agg/625) if year == `min_yr' & countrycode=="`c'" & agefrom == `a' 
			}
			
			local j = `j'+1
			local i = `i'+1
		}

}
}
	* Calculate remaining LAYS 
	foreach r in gr95 gr50 grmean grmin grmax {
		replace back_lays`r' = yr_sch_ipolate*(reading_ipolate/625) if back_lays`r' == .
	}

	foreach r in 50 95 5 {
		replace back_lays`r'_agg = yr_sch_ipolate*(reading_ipolate/625) if back_lays`r'_agg == .
	}
	
	wbopendata, match(countrycode)
	drop regionname adminregion adminregionname incomelevelname lendingtype lendingtypename countryname code
	
	* Updating scenarios - we don't need min max and mean, but we'll keep the country level just to see the difference
	drop grmax back_laysgrmin back_scoregrmax back_laysgrmax back_scoregrmin grmin back_laysgrmean back_scoregrmean grmean
	
	order countrycode region incomelevel year agefrom ageto yr_sch yr_sch_sec reading_score math_score science_score yr_sch_ipolate reading_ipolate growth_rate gr95 back_scoregr95 back_laysgr95 gr50 back_scoregr50 back_laysgr50 full_p5 back_score5_agg back_lays5_agg full_p50 back_score50_agg back_lays50_agg full_p95 back_score95_agg back_lays95_agg pop
	
	save "${clone}/03_schooling/lays_simulation.dta", replace
	
	*----------------------------------------------------------------------------*
	* Step 3: Get matrix
	*----------------------------------------------------------------------------*
	use "${clone}/03_schooling/lays_simulation.dta", replace
	
	keep countrycode region year agefrom ageto yr_sch_ipolate pop back_lays* back_score*
	
	* Interpolate in-between population numbers (we will end up dropping the in between years, but this is to have a full routine)
	by countrycode agefrom, sort: ipolate pop year, generate(pop_ipolate)	
	replace pop_ipolate = round(pop_ipolate)
	
	* Get a year of birth variable so we can backward calculate by cohort
	gen yob = year - agefrom
	order countrycode region year yob agefrom
	foreach v in score lays {
		foreach s in gr50 gr95 5_agg 50_agg 95_agg {
			replace back_`v'`s' = . if agefrom > 15
		}
	}
	bys countrycode yob: fillmissing back_scoregr95 back_laysgr95 back_scoregr50 back_laysgr50 back_score5_agg back_lays5_agg back_score50_agg back_lays50_agg back_score95_agg back_lays95_agg

	sort countrycode year agefrom
	
	* Group the ages 
	gen agegrp = "15t24" if agefrom == 15
	replace agegrp = "25t44" if inlist(agefrom, 25,35,45)
	replace agegrp = "55+" if agefrom == 55
	
	drop agefrom ageto pop
	

	egen agg_group = group(countrycode year agegrp), label

	* Mean of the grouped ages
	collapse (mean) yr_sch_ipolate back_scoregr95 back_laysgr95 back_scoregr50 back_laysgr50 back_score5_agg back_lays5_agg back_score50_agg back_lays50_agg back_score95_agg back_lays95_agg [fw=pop_ipolate], by(agg_group)
	
	decode agg_group, gen(group)
	split group, parse(" ")
	
	drop group agg_group
	rename (group1 group2 group3) (countrycode year agegrp)
	
	* Turn into a matrix
	reshape wide yr_sch_ipolate back_scoregr95 back_laysgr95 back_scoregr50 back_laysgr50 back_score5_agg back_lays5_agg back_score50_agg back_lays50_agg back_score95_agg back_lays95_agg, i(countrycode agegrp) j(year,string)
	
	order countrycode agegrp yr_sch_ipolate* back_scoregr95* back_scoregr50* back_score5_* back_score50* back_score95* back_laysgr95* back_laysgr50* back_lays5_* back_lays50* back_score95*
	
	keep countrycode agegrp *19*0  *20*0 
	