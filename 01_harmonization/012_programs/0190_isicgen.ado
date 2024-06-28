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

cap program drop isicgen
program  define  isicgen, rclass

  version 18

  local syntaxerror 2222

  noi {
		
	*<_occup_isco4_>	
	* Now we can replicate crosswalk from "Harmonize LFS MYS.do" file but keep information
	* Acknowledge that we lose information here
	gen temp = industrycat_isic
	destring temp, replace
	destring industrycat_isic, replace
	//tostring industrycat_isic, replace 
	replace industrycat_isic = . if industrycat_isic== -1 | industrycat_isic == 0
	//replace test = "0" + industrycat_isic if temp < 1000
	drop temp
	gen rev2 = industrycat_isic  if isic_version == "isic_2"
	gen rev3 = industrycat_isic if isic_version == "isic_3"
	gen rev31 = industrycat_isic if isic_version == "isic_3.1"
	
	gen rev2_2 = rev2 / 100
	gen rev3_2 = rev3 / 100
	gen rev31_2 = rev31 / 100
	
	foreach v in rev2_2 rev3_2 rev31_2 {
		replace `v' = floor(`v')
	}
	//gen rev2_2 = substr(rev2,1,2)
	//gen rev3_2 = substr(rev3,1,2)
	//gen rev31_2 = substr(rev31,1,2)
	

	preserve 
	
	import delimited "${clone}/01_harmonization/011_rawdata/ISIC_REV_2-ISIC_Rev_3_1_correspondence.csv", clear
	replace rev2 = "" if rev2 == "n/a"
	destring rev2, replace
	destring rev31, replace
	gen rev2_2 = rev2 / 100
	gen rev31_2 = rev31 / 100
	
	foreach v in rev2_2 rev31_2 {
		replace `v' = floor(`v')
	}
	//tostring rev31, gen(isic31)
	//drop rev31 
	//rename isic31 rev31
	//gen rev2_2 = substr(rev2,1,2)
	//gen rev31_2 = substr(rev31,1,2)
	bysort rev2: gen n2 = _N
	bysort rev2_2: gen n2_2 = _n
	
	tempfile rev2t31
	save `rev2t31', replace

	import delimited "${clone}/01_harmonization/011_rawdata/ISIC_Rev_3_ISIC_Rev_3_1_correspondence.csv", clear
	//tostring rev31, gen(isic31)
	//drop rev31 
	//rename isic31 rev31
	//gen rev3_2 = substr(rev3,1,2)
	//gen rev31_2 = substr(rev31,1,2)
	replace rev3 = "" if rev3 == "n/a"
	destring rev3, replace
	destring rev31, replace
	
	gen rev3_2 = rev3 / 100
	gen rev31_2 = rev31 / 100
	
	foreach v in rev3_2 rev31_2 {
		replace `v' = floor(`v')
	}
	
	bysort rev3: gen n3 = _N
	bysort rev3_2: gen n3_2 = _N


	tempfile rev3t31
	save `rev3t31', replace
	
	import delimited "${clone}/01_harmonization/011_rawdata/ISIC31_ISIC4.csv", clear
	rename (isic31code isic4code) (rev31 rev4)
	
	destring rev4, replace
	destring rev31, replace
	
	gen rev31_2 = rev31 / 100
	gen rev4_2 = rev4 / 100
	
	foreach v in rev4_2 rev31_2 {
		replace `v' = floor(`v')
	}
	
	//tostring rev31 rev4, replace
	//gen rev31_2 = substr(rev31,1,2)
	//gen rev4_2 = substr(rev4,1,2)
	bysort rev31: gen n31 = _N
	bysort rev31_2: gen n31_2 = _N
	
	tempfile rev31t4
	save `rev31t4', replace
	
	restore 
		
	*<_isicr4_4_>*
	* Ver 2 to 31 
	merge m:m rev2 using `rev2t31', keep(matched master) nogen keepusing(rev31 n2)
	merge m:m rev31 using `rev31t4', keep(matched master) nogen keepusing(rev4 n31)
	
	drop rev2 rev31 
	rename (rev4 n31) (rev4_1 n_1)
	
	* Ver 3 to 31 
	merge m:m rev3 using `rev3t31', keep(matched master) nogen keepusing(rev31 n3)
	merge m:m rev31 using `rev31t4', keep(matched master) nogen keepusing(rev4 n31)
	drop rev3 
	rename (rev4 n31) (rev4_2 n_2)
	
	* Ver 31 to 4
	merge m:m rev31 using `rev31t4', keep(matched master) nogen keepusing(rev4 n31)
	drop rev31 
	
	gen isic4_4 = rev4_1 
	replace isic4_4 = rev4_2 if isic4_4 == .
	replace isic4_4 = rev4 if isic4_4 == .
	replace isic4_4 = industrycat_isic if isic_version == "isic_4"
	
	replace n31 = n_2 if n31 == .
	replace n31 = n_1 if n31 == .
	
//	replace isic4_4 = substr(isic4_4, 1,3)  + "9" if n31 >1
	
	drop rev4_1 rev4_2 rev4 n31 n_*
	*</_isicr4_4_>*

	*<_isicr4_2_>*
	* Ver 2 to 31 
	merge m:m rev2_2 using `rev2t31', keep(matched master) nogen keepusing(rev31_2 n2_2)
	merge m:m rev31_2 using `rev31t4', keep(matched master) nogen keepusing(rev4_2 n31_2)
	
	drop rev2_2 rev31_2 
	rename (rev4_2 n31_2) (rev4_2a n_1)
	
	* Ver 3 to 31 
	merge m:m rev3_2 using `rev3t31', keep(matched master) nogen keepusing(rev31_2 n3_2)
	merge m:m rev31_2 using `rev31t4', keep(matched master) nogen keepusing(rev4_2 n31_2)
	drop rev3_2 
	rename (rev4_2 n31_2) (rev4_2b n_2)
	
	* Ver 31 to 4
	merge m:m rev31_2 using `rev31t4', keep(matched master) nogen keepusing(rev4_2 n31_2)
	
	gen isic4_2 = rev4_2
	replace isic4_2 = rev4_2a if isic4_2 == . //""
	replace isic4_2 = rev4_2b if isic4_2 == . //""
	replace isic4_2 = isic4_4/100 if isic_version == "isic_4" // substr(isic4_4,1,2)
	replace isic4_2 = floor(isic4_2)
	
	replace n31_2 = n_2 if n31_2 == .
	replace n31_2 = n_1 if n31_2 == .
	
//	replace isic4_2 = substr(isic4_2, 1,1)  + "9" if n31_2 >1
	*</_isicr4_2_>*
	
	gen isic4_1 = isic4_4/1000 //substr(isic4_4,1,1) 
	replace isic4_1 = floor(isic4_1)

	replace isic4_1 = 0 if isic4_4 < 1000
	drop n_* rev*	
	
	lab var isic4_4 "ISIC 4 digits (Rev 4)"
	lab var isic4_2 "ISIC 2 digits (Rev 4)"
	lab var isic4_1 "ISIC 1digits (Rev 4)"
	
	cap replace isic4_4 = . if isic4_4 == . | isic4_4 == .a
	cap replace isic4_2 = . if isic4_2 == . | isic4_2 == .a
  }
   
end