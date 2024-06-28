***Date: Feb 6, 2024
***Note: Use APO data to calculate productivity growth, 1) EAP average 2) for each
***country, China, Fiji, Indonesia, Laos, Malaysia, Mongolia, Philippines, Thailand

global data "${clone}/03_schooling/031_rawdata/APO-Productivity-Database-2023v1.xlsx"
global save "${clone}/03_schooling/033_output"
global out "${save}/TFP growth composition.xlsx"
local country "BHR BAN BTN BRN CAM CHN FIJ IND IDN JPN KOR KWT LAO MAL MGL MYA NEP OMN PAK PHL QAT SAU SIN SRI THA TUR UAE VIE"
clear
foreach x of local country {
	 
	save "temp.dta", emptyok replace 
	//local x "BHR"
	import excel using "$data", sheet("`x'") cellrange(B4) firstrow case(lower) clear 
	gen country = "`x'"
	drop if mi(code)
	
	replace country = "BGD" if country == "BAN" 
	replace country = "KHM" if country == "CAM"
	replace country = "FIJ" if country == "FJI"
	replace country = "MYS" if country == "MAL"
	replace country = "MNG" if country == "MGL"
	replace country = "MMR" if country == "MYA"
	replace country = "NPL" if country == "NEP"
	replace country = "SGP" if country == "SIN"
	replace country = "LKA" if country == "SRI"
	replace country = "ARE" if country == "UAE"
	replace country = "VNM" if country == "VIE"
	
	append using "temp.dta"
	save "$save\original.dta", replace 
}

*****************************************************************
/*
//TFP growth FOR EACH COUNTRY 
use "$save\original.dta", clear 

foreach v of varlist e-bd {
   local x : variable label `v'
   rename `v' year`x'
}
drop if inlist(variable,"Agriculture，hunting，forestry and fishing","Mining and quarrying","Manufacturing","Electricity, gas and water supply")

keep if inlist(code, 40100)
reshape long year, i(country) j(period)
rename (year period) (tfp year)
keep country year tfp
sort country
by country: gen tfp_g = (tfp[_n]-tfp[_n-1])/tfp[_n-1]
gen time = " "
replace time = "2012-19" if year>=2012 & year<=2019
replace time = "2000-07" if year>=2000 & year<=2007 
replace time = "1989-96" if year>=1989 & year<= 1996
drop if time == " "
keep if inlist(country, "CHN", "FIJ", "IDN", "LAO", "MAL", "MGL") | inlist(country, "PHL", "THA", "MYA", "CAM", "VIE")
collapse (mean) tfp_g, by(country time)
replace time = "96" if time == "1989-96" 
replace time = "07" if time == "2000-07"
replace time = "19" if time == "2012-19"
reshape wide tfp_g, i(country) j(time) string
order country tfp_g96 tfp_g07 tfp_g19
*export excel using "C:\Users\wb621649\WBG\Ergys Islamaj - charts\Yuntian\TFP growth rates.xlsx", sheet("raw - apo") firstrow(var) sheetreplace 

//EACH COUNTRY 10-YEAR moving avg 
use "$save\original.dta", clear 

foreach v of varlist e-bd {
   local x : variable label `v'
   rename `v' year`x'
}
drop if inlist(variable,"Agriculture，hunting，forestry and fishing","Mining and quarrying","Manufacturing","Electricity, gas and water supply")

keep if inlist(code, 40100)
reshape long year, i(country) j(period)
rename (year period) (tfp year)
keep country year tfp
sort country
by country: gen tfp_g = (tfp[_n]-tfp[_n-1])/tfp[_n-1]
keep if inlist(country, "CHN", "FIJ", "IDN", "LAO", "MAL", "MGL") | inlist(country, "PHL", "THA", "MYA", "CAM", "VIE")

encode country, gen(country1)
xtset country1 year 
tsegen ma = rowmean(L(0/9).tfp_g)
keep country year ma 
reshape wide ma, i(country) j(year)
*export excel using "C:\Users\wb621649\WBG\Ergys Islamaj - charts\Yuntian\TFP growth rates.xlsx", sheet("raw - apo - ma") firstrow(var) sheetreplace 
*/
//BY REGION 
wbopendata, indicator(NY.GDP.MKTP.PP.KD) long clear 
rename (ny_gdp_mktp_pp_kd countrycode) (gdp country)

tempfile gdp 
save `gdp', replace 

use "$save\original.dta", clear 

foreach v of varlist e-bd {
   local x : variable label `v'
   rename `v' year`x'
}
drop if inlist(variable,"Agriculture，hunting，forestry and fishing","Mining and quarrying","Manufacturing","Electricity, gas and water supply")

keep if inlist(code, 40100)
reshape long year, i(country) j(period)
rename (year period) (tfp year)
keep country year tfp
drop if mi(tfp) /*drop BHR, KWT, OMN, QAT, SAU, UAE*/
sort country
by country: gen tfp_g = (tfp[_n]-tfp[_n-1])/tfp[_n-1]

gen region = "China"
replace region = "EAP excluding China" if inlist(country, "FJI", "IDN", "LAO", "MYS", "MNG") | inlist(country, "PHL", "THA", "MMR", "KHM", "VNM")
replace region = "Other EMDEs" if inlist(country, "BGD", "BTN", "IND", "IRN", "NPL", "PAK") | inlist(country, "LKA", "TUR")
replace region = "Advanced economies" if inlist(country, "BRN", "ROC", "HKG", "JPN", "KOR") | inlist(country, "SGP")
merge 1:1 country year using `gdp'
keep if _merge == 1 | _merge == 3
drop _merge

tempfile region 
save `region', replace 

use `region', clear 
gen time = " "
replace time = "2012-19" if year>=2012 & year<=2019
replace time = "2000-07" if year>=2000 & year<=2007 
replace time = "1989-96" if year>=1989 & year<= 1996
drop if time == " "
keep country year tfp tfp_g region gdp time 
collapse (mean) tfp_g [aweight=gdp], by(region time)
replace time = "96" if time == "1989-96" 
replace time = "07" if time == "2000-07"
replace time = "19" if time == "2012-19"
reshape wide tfp_g, i(region) j(time) string
order region tfp_g96 tfp_g07 tfp_g19

*export excel using "C:\Users\wb621649\WBG\Ergys Islamaj - charts\Yuntian\TFP growth rates.xlsx", sheet("raw - apo - r") firstrow(var) sheetreplace  

use "${clone}/03_schooling/031_rawdata/pwt1001.dta", clear 
rename country countryname 
rename countrycode country 

merge 1:1 country year using `region', keep(using matched) nogen

replace gdp = cgdpe if year<=2019

*use `region', clear 
keep country year tfp tfp_g region gdp
encode country, gen(country1)
xtset country1 year 
tsegen ma = rowmean(L(0/9).tfp_g)
collapse (mean) ma [aweight=gdp], by(year region)

reshape wide ma, i(region) j(year)

export excel using "$out", sheet("raw - apo - ma - r") firstrow(var) sheetreplace 


*******************************************************
//Check productivity data 
use "$save\original.dta", clear 
foreach v of varlist e-bd {
   local x : variable label `v'
   rename `v' y`x'
}

keep if inlist(code, 40100,40200,40300,40400,50300,60400,22700,60100,60200) | inlist(code, 11900,30100) 
drop if inlist(variable,"Agriculture，hunting，forestry and fishing","Mining and quarrying","Manufacturing","Electricity, gas and water supply")
replace variable="TFP_APO" if code ==40100
replace variable="GDPconst_APO" if code ==22700
replace variable="Labpro_hours_APO" if code ==40200 // hours worked
replace variable="Labpro_emp_APO" if code ==40300 // number of employment
replace variable="Capprod_APO" if code ==40400
replace variable="Capserv_APO" if code ==50300
replace variable="Numworkers_APO" if code ==60100
replace variable="Hourswork_APO" if code ==60200
* This one to change
replace variable="Labquality_APO" if code ==60400 // labor quality
replace variable="GDPcurrent_APO" if code ==11900
replace variable="Compensation_APO" if code ==30100
keep variable y* country 
reshape long y, i(country variable) j(year)
rename y value
reshape wide value, i(country year) j(variable) string
rename value* *
gen Laborshare_APO = Compensation_APO / GDPcurrent_APO
drop GDPcurrent_APO Compensation_APO 
save "$save\APO_prod_data.dta", replace

use "$save\APO_prod_data.dta", clear 
gen Cap_lab_APO = Capserv_APO / Numworkers_APO
gen Cap_lab2_APO = Capserv_APO / Numworkers_APO / Hourswork_APO

egen countryid = group(country)
xtset countryid year

foreach var of varlist TFP* Cap* Num* Hours* Lab* {
	gen g`var' = d.`var'/l.`var'
}

//calculating TFP 
gen gTFPemp_APOself = gLabpro_emp_APO - gCap_lab_APO * (1-Laborshare_APO) - gLabquality_APO * Laborshare_APO
gen gTFPhrs_APOself = gLabpro_hours_APO - gCap_lab2_APO * (1-Laborshare_APO) - gLabquality_APO * Laborshare_APO

//hours worked 
gen TFP_APOself = 1 if year ==2010
bysort country (year): replace TFP_APOself = TFP_APOself[_n-1]*(1+gTFPhrs_APOself) if year > 2010
gsort country -year
bysort country: replace TFP_APOself = TFP_APOself[_n-1]/(1+gTFPhrs_APOself[_n-1]) if year < 2010

//employment 
gen TFP_APOself_emp = 1 if year ==2010
bysort country (year): replace TFP_APOself_emp = TFP_APOself_emp[_n-1]*(1+gTFPemp_APOself) if year > 2010
gsort country -year
bysort country: replace TFP_APOself_emp = TFP_APOself_emp[_n-1]/(1+gTFPemp_APOself[_n-1]) if year < 2010

*twoway line TFP_APOself_emp TFP_APO year if country=="IDN"
corr TFP_APOself_emp TFP_APO /*use employment*/


//create chart of decomposition labor p = tfp + capital + human 
gen region = "China" if country == "CHN"
replace region = "EAP excluding China" if inlist(country, "CAM", "IDN", "LAO", "MAL", "MGL", "MYA", "PHL") ///
| inlist(country, "THA", "VIE", "FIJ")
replace region = "Other EMDEs" if inlist(country, "BAN", "BTN", "IND", "IRN", "NEP", "PAK") | inlist(country, "SRI", "TUR")
replace region = "Advanced economies" if inlist(country, "BRN", "ROC", "HKG", "JPN", "KOR") | inlist(country, "SIN")
drop if mi(region)
gen time = " "
replace time = "2012-19" if year>=2012 & year<=2019
replace time = "2000-07" if year>=2000 & year<=2007 
replace time = "1989-96" if year>=1989 & year<= 1996
drop if time == " "

keep country year gLabpro_emp_APO gTFP_APO gCap_lab_APO Laborshare_APO gLabquality_APO region time GDPconst_APO
gen gcap = (1-Laborshare_APO)*gCap_lab_APO 
gen ghc = gLabquality_APO*Laborshare_APO

preserve 
collapse (mean) ghc gcap gTFP_APO gLabpro_emp_APO [w=GDPconst_APO], by(time region)
order region time gLabpro_emp_APO gcap ghc gTFP_APO
sort region time 
reshape long g, i(region time) j(v) string
replace time = "96" if time == "1989-96" 
replace time = "07" if time == "2000-07"
replace time = "19" if time == "2012-19"
reshape wide g, i(region v) j(time) string
order region v g96 g07 g19
export excel using "$out", sheet("raw - apo - r") firstrow(var) sheetreplace 
restore 

preserve 
keep if region == "China" | region == "EAP excluding China"
collapse (mean) ghc gcap gTFP_APO gLabpro_emp_APO [w=GDPconst_APO], by(time region)
order region time gLabpro_emp_APO gcap ghc gTFP_APO
sort region time 
reshape long g, i(region time) j(v) string
replace time = "96" if time == "1989-96" 
replace time = "07" if time == "2000-07"
replace time = "19" if time == "2012-19"
reshape wide g, i(region v) j(time) string
order region v g96 g07 g19
export excel using "$out", sheet("China - v") firstrow(var) sheetreplace 
restore 


