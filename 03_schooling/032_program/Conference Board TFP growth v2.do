***Date: Feb 8, 2024
***Note: Use conference board data

global data "C:\Users\wb621649\Downloads\export.xlsx"
global comp "C:\Users\wb621649\Downloads\export (1).xlsx"
global cb "C:\Users\wb621649\OneDrive - WBG\Desktop\Conference Board"
global pwt "C:\Users\wb621649\OneDrive - WBG\Desktop\PWT\pwt1001.dta"
global out "C:\Users\wb621649\WBG\Ergys Islamaj - charts\Yuntian\TFP growth rates v2.xlsx"

//TFP
import excel using "$data", sheet("Annual") cellrange(A6) firstrow case(lower) clear 
rename a year 
drop if year == "Date"
reshape long ted2_, i(year) j(value) string 

*save "C:\Users\wb621649\OneDrive - WBG\Desktop\Conference Board\original_data.dta", replace 

//productivity 
import excel using "$comp", sheet("Annual") cellrange(A6) firstrow case(lower) clear 
rename a year 
drop if year == "Date"
reshape long ted1_, i(year) j(value) string 
save "$cb\original_data2.dta", replace 

//append to one dataset 
use "$cb\original_data2.dta", clear 
rename ted1_ ted2_ 
append using "$cb\original_data.dta"
save "$cb\original_data_merged.dta"

//get composition variables 
use "$cb\original_data_merged.dta", clear 
keep if strpos(value, "tfp") | strpos(value, "lsh") | strpos(value, "kserv_g") | strpos(value, "lp_l_g") ///
|strpos(value, "lp_h_g") | strpos(value, "lq_g") | strpos(value, "labor_g") | strpos(value, "hour_g") | strpos(value, "eks") 
destring year, replace 
split value, p("_")
replace value1 = strupper(value1)
destring ted2_, replace
gen indicator = value2+value3+value4
drop if ind == "ictkservg" | ind == "nictkservg" | ind == "gdpeksc" | ind == "pceks" | ind == "lpeksh" | ind == "lpeksl"
replace value = "GDPreal_CB" if indicator == "gdpeks"
replace value = "gTFP_CB" if indicator == "tfpg" 
replace value = "gLabpro_hours_CB" if indicator == "lphg"
replace value = "gLabpro_emp_CB" if indicator == "lplg"
replace value = "gCapserv_CB" if indicator == "kservg"
replace value = "gNumworkers_CB" if indicator == "laborg"
replace value = "gLabquality_CB" if indicator == "lqg"
replace value = "Laborshare_CB" if indicator == "lsh"
replace value = "gHourswork_CB" if indicator == "hourg"
drop value2-value4 indicator
rename (value ted2_ value1) (indicator value country)
reshape wide value, i(year country) j(indicator) string 
rename value* *
replace Laborshare_CB = Laborshare_CB/100
gen gCap_lab_CB = gCapserv_CB - gNumworkers_CB
gen gCap_lab2_CB = gCapserv_CB - gHourswork_CB
/*
//calculating TFP 
gen gTFPemp_CBself = gLabpro_emp_CB - gCap_lab_CB * (1-Laborshare_CB) - gLabquality_CB * Laborshare_CB
gen gTFPhrs_CBself = gLabpro_hours_CB - gCap_lab2_CB * (1-Laborshare_CB) - gLabquality_CB * Laborshare_CB

//hours worked 
gen TFP_CBself = 1 if year ==2010
bysort country (year): replace TFP_CBself = TFP_CBself[_n-1]*(1+gTFPhrs_CBself) if year > 2010
gsort country -year
bysort country: replace TFP_CBself = TFP_CBself[_n-1]/(1+gTFPhrs_CBself[_n-1]) if year < 2010

//employment 
gen TFP_CBself_emp = 1 if year ==2010
bysort country (year): replace TFP_CBself_emp = TFP_CBself_emp[_n-1]*(1+gTFPemp_CBself) if year > 2010
gsort country -year
bysort country: replace TFP_CBself_emp = TFP_CBself_emp[_n-1]/(1+gTFPemp_CBself[_n-1]) if year < 2010

corr TFP_CBself TFP_CB*/

//use emp 
gen gcap_emp = (1-Laborshare_CB)*gCap_lab_CB
gen ghc = gLabquality_CB*Laborshare_CB
gen gTFP_self = gLabpro_emp_CB - gcap_emp - ghc
corr gTFP_self gTFP_CB 

//use hours worked 
gen gcap_hrs = (1-Laborshare_CB)*gCap_lab2_CB
gen gTFP_self_hrs = gLabpro_hours_CB - gcap_hrs - ghc
corr gTFP_self_hrs gTFP_CB /*use this*/

drop if country == "CHN2" | country == "USA2"
save "$cb\analysis_ready.dta", replace 

**************************************************
wbopendata, indicator(NY.GDP.MKTP.PP.KD) long clear 
rename ny_gdp_mktp_pp_kd gdp_ppp 
bys countryname regionname incomelevelname: keep if _n ==1
keep countryname countrycode regionname incomelevelname gdp_ppp
gen high_inc = incomelevelname == "High income"

gen region = "China" if countryname == "China" 
replace region = "Developing East Asia" if regionname == "East Asia and Pacific" ///
& high_inc == 0 & countryname != "China"
replace region = "Other Developing Countries" if regionname != "East Asia and Pacific" ///
& high_inc == 0
replace region = "Advanced Economies" if high_inc == 1 & regionname != "East Asia and Pacific" /*does not include developed EAP*/
keep if !mi(region)
rename countrycode country
tempfile wdi 
save `wdi', replace 

use "C:\Users\wb621649\OneDrive - WBG\Desktop\Conference Board\original_data_merged.dta", clear 
keep if strpos(value, "tfp") | strpos(value, "gdp_eks")
destring year, replace 
split value, p("_")
replace value1 = strupper(value1)
destring ted2_, replace
drop if value3 == "eksc"
drop value value3
rename (ted2_ value1 value2) (value country indicator)
reshape wide value, i(country year) j(indicator) string
rename value* *
drop if country == "CHN2"

drop if country == "USA2"

drop if mi(tfpg)
merge m:1 country using `wdi', keep(3) nogen 
rename country countrycode 
merge 1:1 countrycode year using "$pwt", keep (1 3) nogen
replace cgdpe = gdp if mi(cgdpe)

keep if year >= 1971 /*Uzbekistan does not have 1971-1993*/
gen ob = 1 
sort countrycode
by countrycode: egen total = total(ob)
egen max = max(total) 
drop if max != total 
drop max total ob 
replace region = region[_n-1] if mi(region)

preserve 
//BY COUNTRY 
keep if region == "China" | region == "Developing East Asia" /* 7 EAP countries exd. China*/
keep tfpg country year
reshape wide tfpg, i(country) j(year)
*export excel using "$out", sheet("con - c") firstrow(var) sheetreplace 
restore 

preserve 
//BY REGION - unweighted
collapse (mean) tfpg, by(year region)
reshape wide tfpg, i(region) j(year)
*export excel using "$out", sheet("con - r -uw") firstrow(var) sheetreplace 
restore 

preserve 
//BY REGION - weighted
collapse (mean) tfpg [w=cgdpe], by(year region)
reshape wide tfpg, i(region) j(year)
export excel using "$out", sheet("con - r -w") firstrow(var) sheetreplace 
restore 
