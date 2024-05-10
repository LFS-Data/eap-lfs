*==============================================================================*
*!  PROGRAM 019 masco_isco: Convert MASCO to ISCO08
*==============================================================================*

/* The use case of this program is:
    Crosswalk MASCO98, 08 and 13 versions to ISCO08
	* Harmonized variables are:
	- occup_code (the original MASCO coding)
	- isco08_2
	- isco08_4
	- occup_isco (the )

*/

cap program drop masco_isco
program  define  masco_isco, rclass

  version 18

  local syntaxerror 2222

  quietly {

 	*<_occup_code_>	
	* Get the original occupation code, and harmonize an isco code 
	clonevar occup_code = masco_4d 
	label var occup_code "Original occupation record primary job 7 day recall (MASCO)"
	*</_occup_code_>		

	
	*<_occup_isco4_>	
	* Now we can replicate crosswalk from "Harmonize LFS MYS.do" file but keep information
	* Acknowledge that we lose information here
	gen masco98_4D = masco_4d  if year ==2010
	gen masco08_4D = masco_4d  if year > 2010 & year < 2016
	gen masco13_4D = masco_4d  if year > 2015
	destring masco13_4D, replace

	merge m:m masco98_4D using "${msteams}/Combined/Harmonized/MYS/MASCOcrosswalk/crosswalk_1998_2013_ISCO.dta", keep(matched master) nogen keepusing(isco08_4D)
	ren isco08_4D isco08_4D98
	
	merge m:m masco08_4D using "${msteams}/Combined/Harmonized/MYS/MASCOcrosswalk/crosswalk_2008_2013_ISCO.dta", update keep(matched master) nogen keepusing(isco08_4D)
	ren isco08_4D isco08_4D08

	merge m:m masco13_4D using "${msteams}\Combined\Harmonized\MYS\MASCOcrosswalk\MASCO13_ISCO08.dta", keep(matched master) nogen keepusing(isco08_4D)
	
	replace isco08_4D = isco08_4D98 if isco08_4D == .
	replace isco08_4D = isco08_4D08 if isco08_4D == .
	rename isco08_4D isco08_4
	lab var isco08_4 "ISCO code of primary job 7 day recall (4 digits)"
	*</_occup_isco4_>	
	
	drop isco08_4D*8

	* Also get the 2d MASCO which will correspond with ISCO08 at 2d level	
	*<_isco08_2_>
	foreach v in 98 08 13 {
		tostring masco`v'_4D, replace force
		gen masco`v'_2d = substr(masco`v'_4D,1,2)
	}
	
	preserve
	use "${msteams}/Combined/Harmonized/MYS/MASCOcrosswalk/crosswalk_1998_2013_ISCO.dta", clear 
	gen masco98_2d = substr(masco98_4D,1,2)
	tempfile f98
	save `f98', replace
	
	use "${msteams}/Combined/Harmonized/MYS/MASCOcrosswalk/crosswalk_2008_2013_ISCO.dta", clear
	gen masco08_2d = substr(masco08_4D,1,2)
	tempfile f08
	save `f08', replace	

	use "${msteams}/Combined/Harmonized/MYS/MASCOcrosswalk/MASCO13_ISCO08.dta", clear
	tostring masco13_4D, replace
	gen masco13_2d = substr(masco13_4D,1,2)
	tempfile f13
	save `f13', replace	
	
	restore 

	merge m:m masco98_2d using `f98', keep(matched master) nogen keepusing(isco08_4D)
	ren isco08_4D isco08_4D98
	
	merge m:m masco08_2d using `f08', update keep(matched master) nogen keepusing(isco08_4D)
	ren isco08_4D isco08_4D08

	merge m:m masco13_2d using `f13', keep(matched master) nogen keepusing(isco08_4D)
	
	tostring isco08_4*, replace
	replace isco08_4D = isco08_4D98 if isco08_4D == "."
	replace isco08_4D = isco08_4D08 if isco08_4D == "."
	replace isco08_4D = substr(isco08_4D,1,2)
	ren isco08_4D isco08_2
	replace isco08_2 = "" if isco08_2 == "."
	drop isco08_4D*
	lab var isco08_2 "ISCO code of primary job 7 day recall (2 digits)"	
	*</_isco08_2_>	
	

	* We choose the isco with more matches 
	* This variable is here to conform with GLD harmonization of ISCO, where they might have multiple versions in a panel
	* In MYS case isco08 variable is likely to be identical with occup_isco
	*<_occup_isco_>
	clonevar occup_isco = isco08_2
	*</_occup_isco_>

  }
   
end