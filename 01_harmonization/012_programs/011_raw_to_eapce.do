*---------------------------------------------------------------- *
*- Task: RE-Harmonize Certain Raw Files with Issues
* There are some issues with harmonized EAPCE data, these are some modifications made to the codes from:
* C:/User/(WBUPI)/OneDrive - WBG/Data from Poverty team/Labor Force Survey/Combined/Codes and results
*- Last Modified: Yi Ning Wong on 4/16/2024
*- eduanalytics@worldbank.org
*------------------------------------------------------------------*
	* WIP *
	
	*--------------------------------------------------------*
	* Globals to Each CNT									 *
	*--------------------------------------------------------*
	global vnm_raw "${msteams}/VNM/Raw ID"
	/*
	*--------------------------------------------------------*
	* Vietnam	
	* See corresponding questionnaires:
	* ${vnm_raw}/questionaires								 *
	*--------------------------------------------------------*
	* Questionnaire File: Phieu_LDVL_2011.pdf
	*2011
	use "${vnm_raw}/LFS_2011.dta", clear

	* Basic Demographic
	gen province					= tinh 
	gen district					= huyen
	gen gender						= c3 // Male or female? Male (1) Female (2)
	gen education 					= c11 // Highest level of education (formal and non-formal) completed
	gen education_field				= .
	gen age							= c5 // How old is [name] according to the solar calendar?
	gen birthyear					= c4n // which calendar year is [name] born?
	gen marital_status				= c12 // what is your current marital status? (1: No spouse) (2: Have a spouse) (3: Widow) (4: Divorce/Separated)	

	* Employment
	gen employment_status						= c13 // In the past 7 days, did you do any job to generate income? (Y/N)
	gen secondary_job				= c55 // In the past 7 days, did you do any other job other than the main job to generate income? 
	gen type_contract				= c42  // For the first job, did you sign an indefinite labor contract, fixed term contract, verbal agreement, or no contract? (Option 1 to 5)
	gen experience					= c46 // How long have you been doing this job? (1: Less than a year) (2: From 1 to <5 years) (3: 5 to <10 years) (4: 10+ years)
	gen indus_code					= c38 // Main activities of the establishment (fill in code)
	gen occup_code					= c35 // What was the main job you did in the past 7 days? (fill in code)
	gen social_security				= c44c // With the above job, are you entitled to social insurance? (Y/N)
	gen type_social_security		= .
	gen digital						= .
	
	* Earnings
	gen earning 					= c48 // With the above job, how much salary/wage did you receive last month?
	gen bonus						= c50
	gen wage_no_compen				= c48+c50 // salary + bonus/overtime pay/other benefits
	gen Earning_manner				= c43 //
	gen previous_indus				= c34
	gen Tax_registration			= c39a
	gen Employer_social_cont		= c39b
	gen Accounting_sys				= c39c
	gen Firm_size					= c40
	gen Empl_type 					= c41
	gen Work_space 					= c45

	label data "mydata"

recode Secondary_job(1=1) (2=1) (3=0)
	
label define education1 0 "Never Attended" 1 "Some Primary" 2 "Primary" 3 "Lower Secondary" 4 "Short-term Training" 5 "Higher Education" 6 "Trade Vocational School" 7 "Traditional Services" 8 "Trade/Voc. College" 9 "College" 10 "University and Above"	,replace 
label values Education education1

label define Employmet_status1 1 "Yes" 2 "No"
label values Employmet_status Employmet_status1


label define Social_security1 1 "Yes" 2 "No", replace 
label values Social_security Social_security1


label define Gender1 1 "Male" 2 "Female"
label values Gender Gender1


label define  Maritial_status1 1 "Never Married" 2 "Married" 3 "Widowed" 4 "Divorced/Separated"
label values Maritial_status Maritial_status1

label define  Firm_size1 1 "0-20" 2 "21-99" 3 "100-299" 4 "300 and above"
label values Firm_size Firm_size1

label define  Type_contract1 1 "Contract without term" 2 "Contract with 1-3 years" 3 "Contract with less than 1 year" 4 "Oral Contract" 5 "No contract"
label values Type_contract Type_contract1

label define  Empl_type1 1 "Employer" 2 "self-employment" 3 "Family labor " 4 "Oral Contract" 5 "Corporate"
label values Empl_type Empl_type1

label define Tax_registration1 1 "Yes" 2 "No"
label values Tax_registration Tax_registration1

label define Employer_social_cont1 1 "Yes" 2 "No"
label values Employer_social_cont Employer_social_cont1

label define Accounting_sys1 1 "Yes" 2 "No"
label values Accounting_sys Accounting_sys1

label define Work_space1 1 "Fixed office" 2 "My home/Custumer's home'" 3 "Commerical center" 4 "Mobile fixed point"
label values Work_space Work_space1

label define  Earning_manner1 1 "Fixed" 2 "By Working day/hour" 3 "By product" 4 "Commission" 5 "Profit"
label values Earning_manner Earning_manner1

label define  Experience1 1 "Less than 1 year" 2 "Between 1 and 5 years" 3 "Between 5 and 10 years" 4 "Above 10 years" 
label values Experience Experience1

label define  Secondary_job1 1 "YES" 0 "NO"
label values Secondary_job Secondary_job1






la var  province			"Province"	
la var  district				"Districts"
la var  Industry_code		    "Industry codes"
la var  Occucaption_code		"Occupation codes"
la var  Social_security			"Do you have social security?"
la var  Type_social_security	"Is your social security mandatory or voluntary"
la var  Gender				    "What is your gender?"
la var  Education 				"What is the highest education achieved?"
la var  Education_field		    "What is your major?"
la var  Employmet_status		"Are you currently employed?"
la var  Secondary_job			"Do you have secondary jobs?"
la var  Type_contract			"What is the type of your work contract?"
la var  Experience				"How long have you worked this job?"
la var  Digital						""
la var  Age						"How old are you?"
la var  Maritial_status			"What is your current marital status?"
la var  birthyear				"Year of Birth"
la var  Earning 				"How much did you earn in the past ....?"
la var  Earning_manner			"How do you get paid/frequency and type"
la var  Previous_industry        "What is your previous working industry?"
la var  Bonus					"How much money did you get via Bonus?"
la var  Tax_registration		"Is your employer legally registered?"
la var  Employer_social_cont	"Does your employer contributes to social security?"
la var  Accounting_sys			"Does your organization follow accounting systems?"
la var  Firm_size				"Firm size"
la var  Empl_type 				"What is your type of employment self/wage/unpiad?"
la var  Work_space 				"Where do you work - office, mobile, etc"	






*save "$LFS2020final/LFS_2011_VNM_Harmonized.dta", replace

ta Empl_type
count if Empl_type==2
gen Self_employment = (Empl_type==2)
gen Employee = (Empl_type==4)
gen Informal = (Empl_type==2 | Empl_type==3)

ta Type_contract
count if Type_contract==5
gen No_contract=( Type_contract==5)

gen occup_code=Occucaption_code
gen Indus_code=Industry_code

ta Maritial_status
count if Maritial_status==2
gen Married=(Maritial_status==2)

ta Gender
count if Gender==1
gen Male=(Gender==1)


gen Higher_educ=(Education>=5 & Education<12)
gen Socialsecurity=(Social_security==1)
gen Exper=.

gen Active=(Employmet_status==1)

ren w_p_11 weight 

gen year=2011

keep province district year Age Male Higher_educ  Socialsecurity Married Exper Active Self_employment No_contract occup_code Indus_code Earning Bonus  weight Employee Informal 

save "$LFS2020final/LFS_2011_VNM_Harmonized_Limited.dta", replace


********************************************************************************
********************************************************************************

* 2012

use "$LFS2020raw/LFS_2012.dta", clear


gen province					= tinh
gen district					=.
gen Industry_code				=c40
gen Occucaption_code			=c37
gen Social_security				=c46c
gen Type_social_security		=""
gen Gender						=c3
gen Education 					=c13
gen Education_field				=""
gen Employmet_status			=c15
gen Secondary_job				=c57
gen Type_contract				=c44
gen Experience					=c48
gen Digital						=""
gen Age							=c5
gen Maritial_status				=c14
gen birthyear					=c4n
gen Earning 					=c50
gen Earning_manner				=c45
gen Previous_industry           =c36
gen Previous_occupation    	    =c32

gen Bonus						=c52
gen Tax_registration			=c41a
gen Employer_social_cont		=c41c
gen Accounting_sys				=c41d
gen Firm_size					=c42
gen Empl_type 					=c43
gen Work_space 					=c47

label data "mydata"

recode Secondary_job(1=1) (2=1) (3=0)
	
label define education1 0 "Never Attended" 1 "Some Primary" 2 "Primary" 3 "Lower Secondary" 4 "Short-term Training" 5 "Higher Education" 6 "Trade Vocational School" 7 "Traditional Services" 8 "Trade/Voc. College" 9 "College" 10 "University and Above"	,replace 
label values Education education1

label define Employmet_status1 1 "Yes" 2 "No"
label values Employmet_status Employmet_status1


label define Social_security1 1 "Yes" 2 "No", replace 
label values Social_security Social_security1


label define Gender1 1 "Male" 2 "Female"
label values Gender Gender1


label define  Maritial_status1 1 "Never Married" 2 "Married" 3 "Widowed" 4 "Divorced/Separated"
label values Maritial_status Maritial_status1

label define  Firm_size1 1 "0-20" 2 "21-99" 3 "100-299" 4 "300 and above"
label values Firm_size Firm_size1

label define  Type_contract1 1 "Contract without term" 2 "Contract with 1-3 years" 3 "Contract with less than 1 year" 4 "Oral Contract" 5 "No contract"
label values Type_contract Type_contract1

label define  Empl_type1 1 "Employer" 2 "self-employment" 3 "Family labor " 4 "Oral Contract" 5 "Corporate"
label values Empl_type Empl_type1

label define Tax_registration1 1 "Yes" 2 "No"
label values Tax_registration Tax_registration1

label define Employer_social_cont1 1 "Yes" 2 "No"
label values Employer_social_cont Employer_social_cont1

label define Accounting_sys1 1 "Yes" 2 "No"
label values Accounting_sys Accounting_sys1

label define Work_space1 1 "Fixed office" 2 "My home/Custumer's home'" 3 "Commerical center" 4 "Outdoor fixed point" 5 "mobile" /*different*/
label values Work_space Work_space1

label define  Earning_manner1 1 "Fixed" 2 "By Working day/hour" 3 "By product" 4 "Commission" 5 "Profit" 6 "kind" 7 "no payment"
label values Earning_manner Earning_manner1

label define  Experience1 1 "Less than 1 year" 2 "Between 1 and 5 years" 3 "Between 5 and 10 years" 4 "Above 10 years" 
label values Experience Experience1

label define  Secondary_job1 1 "YES"  0 "No" 
label values Secondary_job Secondary_job1






la var  province			"Province"	
la var  district				"Districts"
la var  Industry_code		    "Industry codes"
la var  Occucaption_code		"Occupation codes"
la var  Social_security			"Do you have social security?"
la var  Type_social_security	"Is your social security mandatory or voluntary"
la var  Gender				    "What is your gender?"
la var  Education 				"What is the highest education achieved?"
la var  Education_field		    "What is your major?"
la var  Employmet_status		"Are you currently employed?"
la var  Secondary_job			"Do you have secondary jobs?"
la var  Type_contract			"What is the type of your work contract?"
la var  Experience				"How long have you worked this job?"
la var  Digital						""
la var  Age						"How old are you?"
la var  Maritial_status			"What is your current marital status?"
la var  birthyear				"Year of Birth"
la var  Earning 				"How much did you earn in the past ....?"
la var  Earning_manner			"How do you get paid/frequency and type"
la var  Previous_industry        "What is your previous working industry?"
la var  Bonus					"How much money did you get via Bonus?"
la var  Tax_registration		"Is your employer legally registered?"
la var  Employer_social_cont	"Does your employer contributes to social security?"
la var  Accounting_sys			"Does your organization follow accounting systems?"
la var  Firm_size				"Firm size"
la var  Empl_type 				"What is your type of employment self/wage/unpiad?"
la var  Work_space 				"Where do you work - office, mobile, etc"	




*keep province-Work_space


*save "$LFS2020final/LFS_2012_VNM_Harmonized.dta", replace

ta Empl_type
count if Empl_type==2
gen Self_employment = (Empl_type==2)
gen Employee = (Empl_type==4)
gen Informal = (Empl_type==2 | Empl_type==3)

ta Type_contract
count if Type_contract==5
gen No_contract=( Type_contract==5)

gen occup_code=Occucaption_code
gen Indus_code=Industry_code

ta Maritial_status
count if Maritial_status==2
gen Married=(Maritial_status==2)

ta Gender
count if Gender==1
gen Male=(Gender==1)

ta Education 
gen Higher_educ=(Education>=5 & Education<12)
gen Socialsecurity=(Social_security==1)

gen Active=(Employmet_status==1)

ren w_p_12 weight 

gen year=2012
keep province district year Age Male Higher_educ  Socialsecurity Married Experience Active Self_employment No_contract occup_code Indus_code Earning Bonus  weight  Employee Informal 

save "$LFS2020final/LFS_2012_VNM_Harmonized_Limited.dta", replace


********************************************************************************
********************************************************************************

* 2013
*import spss using "/Users/atsi/Desktop/S4YE/Data/VNM/Raw/LFS_2013.sav", clear

use "$LFS2020raw/LFS_2013.dta", clear


gen province					=TINH
gen district					=.
gen Industry_code				=C25
gen Occucaption_code			=C22
gen Social_security				=C32C
gen Type_social_security		=""
gen Gender						=C3
gen Education 					=C15
gen Education_field				=""
gen Employmet_status			=C16
gen Secondary_job				=C43
gen Type_contract				=C29
gen Experience					=C33
gen Digital						=""
gen Age							=C5
gen Maritial_status				=C8
gen birthyear					=C4N
gen Earning 					=C36
gen Earning_manner				=C31
gen Previous_industry           =.
gen Previous_occupation    	    =.

gen Bonus						=C38
gen Tax_registration			=C27A
gen Employer_social_cont		=C27C
gen Accounting_sys				=.
gen Firm_size					=.
gen Empl_type 					=C28
gen Work_space 					=C26

label data "mydata"

recode Secondary_job(1=1) (2=1) (3=0)
	
label define education1 0 "Never Attended" 1 "Some Primary" 2 "Primary" 3 "Lower Secondary" 4 "Short-term Training" 5 "Higher Education" 6 "Trade Vocational School" 7 "Traditional Services" 8 "Trade/Voc. College" 9 "College" 10 "University and Above"	,replace 
label values Education education1

label define Employmet_status1 1 "Yes" 2 "No"
label values Employmet_status Employmet_status1


label define Social_security1 1 "Yes" 2 "No", replace 
label values Social_security Social_security1


label define Gender1 1 "Male" 2 "Female"
label values Gender Gender1


label define  Maritial_status1 1 "Never Married" 2 "Married" 3 "Widowed" 4 "Divorced/Separated"
label values Maritial_status Maritial_status1

label define  Firm_size1 1 "0-20" 2 "21-99" 3 "100-299" 4 "300 and above"
label values Firm_size Firm_size1

label define  Type_contract1 1 "Contract without term" 2 "Contract with 1-3 years" 3 "Contract with less than 1 year" 4 "Oral Contract" 5 "No contract"
label values Type_contract Type_contract1

label define  Empl_type1 1 "Employer" 2 "self-employment" 3 "Family labor " 4 "Oral Contract" 5 "Corporate"
label values Empl_type Empl_type1

label define Tax_registration1 1 "Yes" 2 "No"
label values Tax_registration Tax_registration1

label define Employer_social_cont1 1 "Yes" 2 "No"
label values Employer_social_cont Employer_social_cont1

label define Accounting_sys1 1 "Yes" 2 "No"
label values Accounting_sys Accounting_sys1

label define Work_space1 1 "Fixed office" 2 "My home/Custumer's home'" 3 "Commerical center" 4 "Outdoor fixed point" 5 "mobile" /*different*/
label values Work_space Work_space1

label define  Earning_manner1 1 "Fixed" 2 "By Working day/hour" 3 "By product" 4 "Commission" 5 "Profit" 6 "kind" 7 "no payment"
label values Earning_manner Earning_manner1

label define  Experience1 1 "Less than 1 year" 2 "Between 1 and 5 years" 3 "Between 5 and 10 years" 4 "Above 10 years" 
label values Experience Experience1

label define  Secondary_job1 1 "YES" 0 "No" 
label values Secondary_job Secondary_job1






la var  province			"Province"	
la var  district				"Districts"
la var  Industry_code		    "Industry codes"
la var  Occucaption_code		"Occupation codes"
la var  Social_security			"Do you have social security?"
la var  Type_social_security	"Is your social security mandatory or voluntary"
la var  Gender				    "What is your gender?"
la var  Education 				"What is the highest education achieved?"
la var  Education_field		    "What is your major?"
la var  Employmet_status		"Are you currently employed?"
la var  Secondary_job			"Do you have secondary jobs?"
la var  Type_contract			"What is the type of your work contract?"
la var  Experience				"How long have you worked this job?"
la var  Digital						""
la var  Age						"How old are you?"
la var  Maritial_status			"What is your current marital status?"
la var  birthyear				"Year of Birth"
la var  Earning 				"How much did you earn in the past ....?"
la var  Earning_manner			"How do you get paid/frequency and type"
la var  Previous_industry        "What is your previous working industry?"
la var  Bonus					"How much money did you get via Bonus?"
la var  Tax_registration		"Is your employer legally registered?"
la var  Employer_social_cont	"Does your employer contributes to social security?"
la var  Accounting_sys			"Does your organization follow accounting systems?"
la var  Firm_size				"Firm size"
la var  Empl_type 				"What is your type of employment self/wage/unpiad?"
la var  Work_space 				"Where do you work - office, mobile, etc"	




*keep province-Work_space


*save "$LFS2020final/LFS_2013_VNM_Harmonized.dta", replace

ta Empl_type
count if Empl_type==2
gen Self_employment = (Empl_type==2)
gen Employee = (Empl_type==4)
gen Informal = (Empl_type==2 | Empl_type==3)

ta Type_contract
count if Type_contract==5
gen No_contract=( Type_contract==5)

gen occup_code=Occucaption_code
gen Indus_code=Industry_code

ta Maritial_status
count if Maritial_status==2
gen Married=(Maritial_status==2)

ta Gender
count if Gender==1
gen Male=(Gender==1)

ta Education 
gen Higher_educ=(Education>=5 & Education<12)
gen Socialsecurity=(Social_security==1)

ren WIEGH_DCTDT weight

gen Active=(Employmet_status==1)

gen year=2013

keep province district year Age Male Higher_educ  Socialsecurity Married Experience Active Self_employment No_contract occup_code Indus_code Earning Bonus   weight  Employee Informal 

save "$LFS2020final/LFS_2013_VNM_Harmonized_Limited.dta", replace



********************************************************************************
********************************************************************************

* 2014
*import spss using "/Users/atsi/Desktop/S4YE/Data/VNM/Raw/LFS_2014.sav", clear
use "$LFS2020raw/LFS_2014.dta", clear


gen province					= TINH
gen district					=.
gen Industry_code				=C25
gen Occucaption_code			=C22
gen Social_security				=C32C
gen Socail_security_voluntary   =C32D
gen Type_social_security		=C33
gen Gender						=C3
gen Education 					=C15
gen Education_field				=""
gen Employmet_status			=C16
gen Secondary_job				=C45
gen Type_contract1				=C29
gen Exp							=C34
gen Digital						=""
gen Age							=C5
gen Maritial_status				=C8
gen birthyear					=C4N
gen Earning 					=C38
gen Earning_manner				=C31
gen Previous_industry           =.
gen Previous_occupation    	    =.

gen Bonus						=C40
gen Tax_registration			=C27A
gen Employer_social_cont		=C27C
gen Accounting_sys				=C27D
gen Firm_size					=.
gen Empl_type 					=C28
gen Work_space 					=C26

label data "mydata"
recode Secondary_job(1=1) (2=1) (3=0)


recode Exp (1/3 = 1 "Less than 1 year") (5=2 "Between 1 and 5 years") (6 = 3 "Between 5 and 10 years") (7 = 4 "Between 5 and 10 years") , gen (Experience)

recode Type_contract1 (1=1 "Indefinite term") (2=1 "One to three yearrs") (3/4 =3  "Less than one year") (5=4 "Verbal Contract") (6=5 "No Contract") , gen (Type_contract) 


	
label define education1 0 "Never Attended" 1 "Some Primary" 2 "Primary" 3 "Lower Secondary" 4 "Short-term Training" 5 "Higher Education" 6 "Trade Vocational School" 7 "Traditional Services" 8 "Trade/Voc. College" 9 "College" 10 "University and Above"	,replace 
label values Education education1

label define Employmet_status1 1 "Yes" 2 "No"
label values Employmet_status Employmet_status1


label define Social_security1 1 "Yes" 2 "No", replace 
label values Social_security Social_security1


label define Gender1 1 "Male" 2 "Female"
label values Gender Gender1


label define  Maritial_status1 1 "Never Married" 2 "Married" 3 "Widowed" 4 "Divorced/Separated"
label values Maritial_status Maritial_status1

label define  Firm_size1 1 "0-20" 2 "21-99" 3 "100-299" 4 "300 and above"
label values Firm_size Firm_size1

label define  Type_contract1 1 "Contract without term" 2 "Contract with 1-3 years" 3 "Contract with less than 1 year" 4 "Oral Contract" 5 "No contract"
label values Type_contract Type_contract1

label define  Empl_type1 1 "Employer" 2 "self-employment" 3 "Family labor " 4 "Oral Contract" 5 "Corporate"
label values Empl_type Empl_type1

label define Tax_registration1 1 "Yes" 2 "No"
label values Tax_registration Tax_registration1

label define Employer_social_cont1 1 "Yes" 2 "No"
label values Employer_social_cont Employer_social_cont1

label define Accounting_sys1 1 "Yes" 2 "No"
label values Accounting_sys Accounting_sys1

label define Work_space1 1 "Fixed office" 2 "My home/Custumer's home'" 3 "Commerical center" 4 "Outdoor fixed point" 5 "mobile" /*different*/
label values Work_space Work_space1

label define  Earning_manner1 1 "Fixed" 2 "By Working day/hour" 3 "By product" 4 "Commission" 5 "Profit" 6 "kind" 7 "no payment"
label values Earning_manner Earning_manner1

*label define  Experience1 1 "Less than 1 year" 2 "Between 1 and 5 years" 3 "Between 5 and 10 years" 4 "Above 10 years" 
*label values Experience Experience1


label define  Secondary_job1 1 "YES" 0 "No" 
label values Secondary_job Secondary_job1






la var  province			"Province"	
la var  district				"Districts"
la var  Industry_code		    "Industry codes"
la var  Occucaption_code		"Occupation codes"
la var  Social_security			"Do you have social security?"
la var  Type_social_security	"Is your social security mandatory or voluntary"
la var  Gender				    "What is your gender?"
la var  Education 				"What is the highest education achieved?"
la var  Education_field		    "What is your major?"
la var  Employmet_status		"Are you currently employed?"
la var  Secondary_job			"Do you have secondary jobs?"
la var  Type_contract			"What is the type of your work contract?"
la var  Experience				"How long have you worked this job?"
la var  Digital						""
la var  Age						"How old are you?"
la var  Maritial_status			"What is your current marital status?"
la var  birthyear				"Year of Birth"
la var  Earning 				"How much did you earn in the past ....?"
la var  Earning_manner			"How do you get paid/frequency and type"
la var  Previous_industry        "What is your previous working industry?"
la var  Bonus					"How much money did you get via Bonus?"
la var  Tax_registration		"Is your employer legally registered?"
la var  Employer_social_cont	"Does your employer contributes to social security?"
la var  Accounting_sys			"Does your organization follow accounting systems?"
la var  Firm_size				"Firm size"
la var  Empl_type 				"What is your type of employment self/wage/unpiad?"
la var  Work_space 				"Where do you work - office, mobile, etc"	




*keep province-Experience
*save "$LFS2020final/LFS_2014_VNM_Harmonized.dta", replace


ta Empl_type
count if Empl_type==2
gen Self_employment = (Empl_type==2)
gen Employee = (Empl_type==4)
gen Informal = (Empl_type==2 | Empl_type==3)

ta Type_contract
count if Type_contract==5
gen No_contract=( Type_contract==5)

gen occup_code=Occucaption_code
gen Indus_code=Industry_code

ta Maritial_status
count if Maritial_status==2
gen Married=(Maritial_status==2)

ta Gender
count if Gender==1
gen Male=(Gender==1)

ta Education 
gen Higher_educ=(Education>=5 & Education<12)
gen Socialsecurity=(Social_security==1)

ren WIEGH_DCTDT weight 

gen Active=(Employmet_status==1)

gen year=2014

keep province district year Age Male Higher_educ  Socialsecurity Married Experience Active Self_employment No_contract occup_code Indus_code Earning Bonus   weight  Employee Informal 
 


save "$LFS2020final/LFS_2014_VNM_Harmonized_Limited.dta", replace


********************************************************************************
********************************************************************************

* 2015
*import spss using "/Users/atsi/Desktop/S4YE/Data/VNM/Raw/LFS_2014.sav", clear
use "$LFS2020raw/LFS_2015.dta", clear


gen province					= TINH
gen district					=.
gen Industry_code				=C23
gen Occucaption_code			=C22
gen Social_security				=C32
gen Socail_security_voluntary   =.
gen Type_social_security		=C33
gen Gender						=C3
gen Education 					=C12
gen Education_field				=""
gen Employmet_status			=C14
gen Secondary_job				=C43 /*not numbers, but dummy*/
clonevar Type_contract1			=C29
gen Exp							=C37
gen Digital						=""
gen Age							=C5
gen Maritial_status				=C7
gen birthyear					=C4N
gen Earning 					=C40A
gen Earning_manner				=C31
gen Previous_industry           =.
gen Previous_occupation    	    =.

gen Bonus						=C40B
gen Tax_registration			=C26
gen Employer_social_cont		=.
gen Accounting_sys				=.
gen Firm_size					=.
gen Empl_type 					=C28
gen Work_space 					=C27

label data "mydata"

recode Exp (1/3 = 1 "Less than 1 year") (5=2 "Between 1 and 5 years") (6 = 3 "Between 5 and 10 years") (7 = 4 "Between 5 and 10 years") , gen (Experience)

recode Type_contract1 (1=1 "Indefinite term") (2=1 "One to three yearrs") (3/4 =3  "Less than one year") (5=4 "Verbal Contract") (6=5 "No Contract") , gen (Type_contract) 


recode Secondary_job(1=1) (2=0)


	
*label define education1 0 "Never Attended" 1 "Some Primary" 2 "Primary" 3 "Lower Secondary" 4 "Short-term Training" 5 "Higher Education" 6 "Trade Vocational School" 7 "Traditional Services" 8 "Trade/Voc. College" 9 "College" 10 "University and Above"	,replace 

label define education1 1 "Never Attended School" 2 "Not Completed Pr. School" 3 "Primary School" 4 "Lower Secondary School" 5 "Upper Secondary School" 6 "Mid-term Professional School" 7 "Professional College" 8 "University" 9 "Above University"

label values Education education1

label define Employmet_status1 1 "Yes" 2 "No"
label values Employmet_status Employmet_status1


label define Social_security1 1 "Yes" 2 "No", replace 
label values Social_security Social_security1


label define Gender1 1 "Male" 2 "Female"
label values Gender Gender1


label define  Maritial_status1 1 "Never Married" 2 "Married" 3 "Widowed" 4 "Divorced/Separated"
label values Maritial_status Maritial_status1

label define  Firm_size1 1 "0-20" 2 "21-99" 3 "100-299" 4 "300 and above"
label values Firm_size Firm_size1

label define  Type_contract1 1 "Contract without term" 2 "Contract with 1-3 years" 3 "Contract with less than 1 year" 4 "Oral Contract" 5 "No contract"
label values Type_contract Type_contract1

label define  Empl_type1 1 "Employer" 2 "self-employment" 3 "Family labor " 4 "Oral Contract" 5 "Corporate"
label values Empl_type Empl_type1

label define Tax_registration1 1 "Yes" 2 "No"
label values Tax_registration Tax_registration1

label define Employer_social_cont1 1 "Yes" 2 "No"
label values Employer_social_cont Employer_social_cont1

label define Accounting_sys1 1 "Yes" 2 "No"
label values Accounting_sys Accounting_sys1

label define Work_space1 1 "Fixed office" 2 "My home/Custumer's home'" 3 "Commerical center" 4 "Outdoor fixed point" 5 "mobile" /*different*/
label values Work_space Work_space1

label define  Earning_manner1 1 "Fixed" 2 "By Working day/hour" 3 "By product" 4 "Commission" 5 "Profit" 6 "kind" 7 "no payment"
label values Earning_manner Earning_manner1

*label define  Experience1 1 "Less than 1 year" 2 "Between 1 and 5 years" 3 "Between 5 and 10 years" 4 "Above 10 years" 
*label values Experience Experience1


label define  Secondary_job1 1 "YES" 0 "No" 
label values Secondary_job Secondary_job1






la var  province			"Province"	
la var  district				"Districts"
la var  Industry_code		    "Industry codes"
la var  Occucaption_code		"Occupation codes"
la var  Social_security			"Do you have social security?"
la var  Type_social_security	"Is your social security mandatory or voluntary"
la var  Gender				    "What is your gender?"
la var  Education 				"What is the highest education achieved?"
la var  Education_field		    "What is your major?"
la var  Employmet_status		"Are you currently employed?"
la var  Secondary_job			"Do you have secondary jobs?"
la var  Type_contract			"What is the type of your work contract?"
la var  Experience				"How long have you worked this job?"
la var  Digital						""
la var  Age						"How old are you?"
la var  Maritial_status			"What is your current marital status?"
la var  birthyear				"Year of Birth"
la var  Earning 				"How much did you earn in the past ....?"
la var  Earning_manner			"How do you get paid/frequency and type"
la var  Previous_industry        "What is your previous working industry?"
la var  Bonus					"How much money did you get via Bonus?"
la var  Tax_registration		"Is your employer legally registered?"
la var  Employer_social_cont	"Does your employer contributes to social security?"
la var  Accounting_sys			"Does your organization follow accounting systems?"
la var  Firm_size				"Firm size"
la var  Empl_type 				"What is your type of employment self/wage/unpiad?"
la var  Work_space 				"Where do you work - office, mobile, etc"	




*keep province-Experience
*save "$LFS2020final/LFS_2015_VNM_Harmonized.dta", replace

ta Empl_type
count if Empl_type==2
gen Self_employment = (Empl_type==2)
gen Employee = (Empl_type==4)
gen Informal = (Empl_type==2 | Empl_type==3)

ta Type_contract
count if Type_contract==5
gen No_contract=( Type_contract==5)

gen occup_code=Occucaption_code
gen Indus_code=Industry_code

ta Maritial_status
count if Maritial_status==2
gen Married=(Maritial_status==2)

ta Gender
count if Gender==1
gen Male=(Gender==1)

ta Education 
gen Higher_educ=(Education>=5 & Education<12)
gen Socialsecurity=(Social_security==1)

ren Weigh weight

gen Active=(Employmet_status==1)
gen year=2015


keep province district year Age Male Higher_educ  Socialsecurity Married Experience Active Self_employment No_contract occup_code Indus_code Earning Bonus   weight  Employee Informal 


save "$LFS2020final/LFS_2015_VNM_Harmonized_Limited.dta", replace





********************************************************************************
********************************************************************************

* 2016
*import spss using "/Users/atsi/Desktop/S4YE/Data/VNM/Raw/LFS_2014.sav", clear
use "$LFS2020raw/LFS_2016.dta", clear


gen province					= Matinh
gen district					=Mahuyen
gen Industry_code				=c23
gen Occucaption_code			=c22
gen Social_security				=c32
gen Socail_security_voluntary   =.
gen Type_social_security		=c33
gen Gender						=c3
gen Education 					=c12
gen Education_field				=""
gen Employmet_status			=c14
gen Secondary_job				= c43
clonevar Type_contract1			=c29 /*why no contract available"*/
gen Exp							=c37
gen Digital						=""
gen Age							=c5
gen Maritial_status				=c7
gen birthyear					=c4N
gen Earning 					=c40
gen Earning_manner				=c31
gen Previous_industry           =.
gen Previous_occupation    	    =.

gen Bonus						=c40A
gen Tax_registration			=c26
gen Employer_social_cont		=.
gen Accounting_sys				=.
gen Firm_size					=.
gen Empl_type 					=c28
gen Work_space 					=c27

label data "mydata"


recode Exp (1/3 = 1 "Less than 1 year") (5=2 "Between 1 and 5 years") (6 = 3 "Between 5 and 10 years") (7 = 4 "Between 5 and 10 years") , gen (Experience)

recode Type_contract1 (1=1 "Indefinite term") (2=1 "One to three yearrs") (3/4 =3  "Less than one year") (5=4 "Verbal Contract") (6=5 "No Contract") , gen (Type_contract) 


recode Secondary_job(1=1) (2=0)


	
*label define education1 0 "Never Attended" 1 "Some Primary" 2 "Primary" 3 "Lower Secondary" 4 "Short-term Training" 5 "Higher Education" 6 "Trade Vocational School" 7 "Traditional Services" 8 "Trade/Voc. College" 9 "College" 10 "University and Above"	,replace 

label define education1 1 "Never Attended School" 2 "Not Completed Pr. School" 3 "Primary School" 4 "Lower Secondary School" 5 "Upper Secondary School" 6 "Mid-term Professional School" 7 "Professional College" 8 "University" 9 "Above University"

label values Education education1

label define Employmet_status1 1 "Yes" 2 "No"
label values Employmet_status Employmet_status1


label define Social_security1 1 "Yes" 2 "No", replace 
label values Social_security Social_security1


label define Gender1 1 "Male" 2 "Female"
label values Gender Gender1


label define  Maritial_status1 1 "Never Married" 2 "Married" 3 "Widowed" 4 "Divorced/Separated"
label values Maritial_status Maritial_status1

label define  Firm_size1 1 "0-20" 2 "21-99" 3 "100-299" 4 "300 and above"
label values Firm_size Firm_size1

label define  Type_contract1 1 "Contract without term" 2 "Contract with 1-3 years" 3 "Contract with less than 1 year" 4 "Oral Contract" 5 "No contract"
label values Type_contract Type_contract1

label define  Empl_type1 1 "Employer" 2 "self-employment" 3 "Family labor " 4 "Oral Contract" 5 "Corporate"
label values Empl_type Empl_type1

label define Tax_registration1 1 "Yes" 2 "No"
label values Tax_registration Tax_registration1

label define Employer_social_cont1 1 "Yes" 2 "No"
label values Employer_social_cont Employer_social_cont1

label define Accounting_sys1 1 "Yes" 2 "No"
label values Accounting_sys Accounting_sys1

label define Work_space1 1 "Fixed office" 2 "My home/Custumer's home'" 3 "Commerical center" 4 "Outdoor fixed point" 5 "mobile" /*different*/
label values Work_space Work_space1

label define  Earning_manner1 1 "Fixed" 2 "By Working day/hour" 3 "By product" 4 "Commission" 5 "Profit" 6 "kind" 7 "no payment"
label values Earning_manner Earning_manner1

*label define  Experience1 1 "Less than 1 year" 2 "Between 1 and 5 years" 3 "Between 5 and 10 years" 4 "Above 10 years" 
*label values Experience Experience1


label define  Secondary_job1 1 "YES" 0 "No" 
label values Secondary_job Secondary_job1






la var  province			"Province"	
la var  district				"Districts"
la var  Industry_code		    "Industry codes"
la var  Occucaption_code		"Occupation codes"
la var  Social_security			"Do you have social security?"
la var  Type_social_security	"Is your social security mandatory or voluntary"
la var  Gender				    "What is your gender?"
la var  Education 				"What is the highest education achieved?"
la var  Education_field		    "What is your major?"
la var  Employmet_status		"Are you currently employed?"
la var  Secondary_job			"Do you have secondary jobs?"
la var  Type_contract			"What is the type of your work contract?"
la var  Experience				"How long have you worked this job?"
la var  Digital						""
la var  Age						"How old are you?"
la var  Maritial_status			"What is your current marital status?"
la var  birthyear				"Year of Birth"
la var  Earning 				"How much did you earn in the past ....?"
la var  Earning_manner			"How do you get paid/frequency and type"
la var  Previous_industry        "What is your previous working industry?"
la var  Bonus					"How much money did you get via Bonus?"
la var  Tax_registration		"Is your employer legally registered?"
la var  Employer_social_cont	"Does your employer contributes to social security?"
la var  Accounting_sys			"Does your organization follow accounting systems?"
la var  Firm_size				"Firm size"
la var  Empl_type 				"What is your type of employment self/wage/unpiad?"
la var  Work_space 				"Where do you work - office, mobile, etc"	




*keep province-Experience
*save "$LFS2020final/LFS_2016_VNM_Harmonized.dta", replace

ta Empl_type
count if Empl_type==2
gen Self_employment = (Empl_type==2)
gen Employee = (Empl_type==4)
gen Informal = (Empl_type==2 | Empl_type==3)

ta Type_contract
count if Type_contract==5
gen No_contract=( Type_contract==5)

gen occup_code=Occucaption_code
gen Indus_code=Industry_code

ta Maritial_status
count if Maritial_status==2
gen Married=(Maritial_status==2)

ta Gender
count if Gender==1
gen Male=(Gender==1)

ta Education 
gen Higher_educ=(Education>=5 & Education<12)
gen Socialsecurity=(Social_security==1)

ren weigh_final weight

gen Active=(Employmet_status==1)
gen year=2016

keep province district year Age Male Higher_educ  Socialsecurity Married Experience Active Self_employment No_contract occup_code Indus_code Earning Bonus   weight  Employee Informal 


save "$LFS2020final/LFS_2016_VNM_Harmonized_Limited.dta", replace


********************************************************************************
********************************************************************************

* 2017
*import spss using "/Users/atsi/Desktop/S4YE/Data/VNM/Raw/LFS_2017.sav", clear
*save "$LFS2020raw/LFS_2017.dta", replace 
use "$LFS2020raw/LFS_2017.dta", clear


gen province					= TINH
gen district					=HUYEN
gen Industry_code				=C25
gen Occucaption_code			=C24
gen Social_security				=C34
gen Socail_security_voluntary   =.
gen Type_social_security		=C35
gen Gender						=C3
gen Education 					=C14
gen Education_field				=""
gen Employmet_status			=C16
gen Secondary_job1				= C40B
clonevar Type_contract1			= C31/*why no contract available"*/
gen Exp							= C36
gen Digital						=""
gen Age							=C5
gen Maritial_status				=C9
gen birthyear					=C4N
gen Earning 					=C39A
gen Earning_manner				=C33
gen Previous_industry           =.
gen Previous_occupation    	    =.

gen Bonus						=C39B
gen Tax_registration			=C28
gen Employer_social_cont		=.
gen Accounting_sys				=.
gen Firm_size					=.
gen Empl_type 					=C30
gen Work_space 					=.

label data "mydata"


recode Exp (1/3 = 1 "Less than 1 year") (5=2 "Between 1 and 5 years") (6 = 3 "Between 5 and 10 years") (7 = 4 "Between 5 and 10 years") , gen (Experience)

recode Type_contract1 (1=1 "Indefinite term") (2=1 "One to three yearrs") (3/5 =3  "Less than one year") (6=4 "Verbal Contract") (7=5 "No Contract") , gen (Type_contract) 


gen Secondary_job=(Secondary_job1>0 & Secondary_job1!=.)
drop Secondary_job1
recode Maritial_status(5=4)

	
*label define education1 0 "Never Attended" 1 "Some Primary" 2 "Primary" 3 "Lower Secondary" 4 "Short-term Training" 5 "Higher Education" 6 "Trade Vocational School" 7 "Traditional Services" 8 "Trade/Voc. College" 9 "College" 10 "University and Above"	,replace 

label define education1 1 "Never Attended School" 2 "Not Completed Pr. School" 3 "Primary School" 4 "Lower Secondary School" 5 "Upper Secondary School" 6 "Mid-term Professional School" 7 "Professional College" 8 "University" 9 "Above University"

label values Education education1

label define Employmet_status1 1 "Yes" 2 "No"
label values Employmet_status Employmet_status1


label define Social_security1 1 "Yes" 2 "No", replace 
label values Social_security Social_security1


label define Gender1 1 "Male" 2 "Female"
label values Gender Gender1


label define  Maritial_status1 1 "Never Married" 2 "Married" 3 "Widowed" 4 "Divorced/Separated"
label values Maritial_status Maritial_status1

label define  Firm_size1 1 "0-20" 2 "21-99" 3 "100-299" 4 "300 and above"
label values Firm_size Firm_size1

label define  Type_contract1 1 "Contract without term" 2 "Contract with 1-3 years" 3 "Contract with less than 1 year" 4 "Oral Contract" 5 "No contract"
label values Type_contract Type_contract1

label define  Empl_type1 1 "Employer" 2 "self-employment" 3 "Family labor " 4 "Oral Contract" 5 "Corporate"
label values Empl_type Empl_type1

label define Tax_registration1 1 "Yes" 2 "No"
label values Tax_registration Tax_registration1

label define Employer_social_cont1 1 "Yes" 2 "No"
label values Employer_social_cont Employer_social_cont1

label define Accounting_sys1 1 "Yes" 2 "No"
label values Accounting_sys Accounting_sys1

label define Work_space1 1 "Fixed office" 2 "My home/Custumer's home'" 3 "Commerical center" 4 "Outdoor fixed point" 5 "mobile" /*different*/
label values Work_space Work_space1

label define  Earning_manner1 1 "Fixed" 2 "By Working day/hour" 3 "By product" 4 "Commission" 5 "Profit" 6 "kind" 7 "no payment"
label values Earning_manner Earning_manner1

*label define  Experience1 1 "Less than 1 year" 2 "Between 1 and 5 years" 3 "Between 5 and 10 years" 4 "Above 10 years" 
*label values Experience Experience1


label define  Secondary_job1 1 "YES" 0 "No" 
label values Secondary_job Secondary_job1






la var  province			"Province"	
la var  district				"Districts"
la var  Industry_code		    "Industry codes"
la var  Occucaption_code		"Occupation codes"
la var  Social_security			"Do you have social security?"
la var  Type_social_security	"Is your social security mandatory or voluntary"
la var  Gender				    "What is your gender?"
la var  Education 				"What is the highest education achieved?"
la var  Education_field		    "What is your major?"
la var  Employmet_status		"Are you currently employed?"
la var  Secondary_job			"Do you have secondary jobs?"
la var  Type_contract			"What is the type of your work contract?"
la var  Experience				"How long have you worked this job?"
la var  Digital						""
la var  Age						"How old are you?"
la var  Maritial_status			"What is your current marital status?"
la var  birthyear				"Year of Birth"
la var  Earning 				"How much did you earn in the past ....?"
la var  Earning_manner			"How do you get paid/frequency and type"
la var  Previous_industry        "What is your previous working industry?"
la var  Bonus					"How much money did you get via Bonus?"
la var  Tax_registration		"Is your employer legally registered?"
la var  Employer_social_cont	"Does your employer contributes to social security?"
la var  Accounting_sys			"Does your organization follow accounting systems?"
la var  Firm_size				"Firm size"
la var  Empl_type 				"What is your type of employment self/wage/unpiad?"
la var  Work_space 				"Where do you work - office, mobile, etc"	




*keep province-Experience
*save "$LFS2020final/LFS_2017_VNM_Harmonized.dta", replace

ta Empl_type
count if Empl_type==2
gen Self_employment = (Empl_type==2)
gen Employee = (Empl_type==4)
gen Informal = (Empl_type==2 | Empl_type==3)

ta Type_contract
count if Type_contract==5
gen No_contract=( Type_contract==5)

gen occup_code=Occucaption_code
gen Indus_code=Industry_code

ta Maritial_status
count if Maritial_status==2
gen Married=(Maritial_status==2)

ta Gender
count if Gender==1
gen Male=(Gender==1)

ta Education 
gen Higher_educ=(Education>=5 & Education<12)
gen Socialsecurity=(Social_security==1)

ren weigh_dc_final_danso weight

gen Active=(Employmet_status==1)
gen year=2017

keep province district year Age Male Higher_educ  Socialsecurity Married Experience Active Self_employment No_contract occup_code Indus_code Earning Bonus   weight  Employee Informal 

save "$LFS2020final/LFS_2017_VNM_Harmonized_Limited.dta", replace





********************************************************************************
********************************************************************************

* 2018
*import spss using "/Users/atsi/Desktop/S4YE/Data/VNM/Raw/LFS_2018.sav", clear
*save "$LFS2020raw/LFS_2018.dta", replace 
use "$LFS2020raw/LFS_2018.dta", clear


gen province					= TINH
gen district					=HUYEN
gen Industry_code				=C30C
gen Occucaption_code			=C29C
gen Social_security				=C39
gen Socail_security_voluntary   =.
gen Type_social_security		=C40
gen Gender						=C3
gen Education 					=C17
gen Education_field				=C18B
gen Employmet_status			=C21
gen Secondary_job1				= C45B
clonevar Type_contract1			= C36/*why no contract available"*/
gen Exp							= C41
gen Digital						=""
gen Age							=C5
gen Maritial_status				=C9
gen birthyear					=C4N
gen Earning 					=C44A
gen Earning_manner				=C38
gen Previous_industry           =.
gen Previous_occupation    	    =.

gen Bonus						=C44B
gen Tax_registration			=C33
gen Employer_social_cont		=.
gen Accounting_sys				=.
gen Firm_size					=.
gen Empl_type 					=C35
gen Work_space 					=.

label data "mydata"


recode Exp (1/2 = 1 "Less than 1 year") (3=2 "Between 1 and 5 years") (4 = 3 "Between 5 and 10 years") (5 = 4 "Between 5 and 10 years") , gen (Experience)

recode Type_contract1 (1=1 "Indefinite term") (2=1 "One to three yearrs") (3/5 =3  "Less than one year") (6=4 "Verbal Contract") (7=5 "No Contract") , gen (Type_contract) 


gen Secondary_job=(Secondary_job1>0 & Secondary_job1!=.)
drop Secondary_job1
recode Maritial_status(5=4)

	
*label define education1 0 "Never Attended" 1 "Some Primary" 2 "Primary" 3 "Lower Secondary" 4 "Short-term Training" 5 "Higher Education" 6 "Trade Vocational School" 7 "Traditional Services" 8 "Trade/Voc. College" 9 "College" 10 "University and Above"	,replace 

label define education1 1 "Never Attended School" 2 "Not Completed Pr. School" 3 "Primary School" 4 "Lower Secondary School" 5 "Upper Secondary School" 6 "Mid-term Professional School" 7 "Professional College" 8 "University" 9 "Above University"

label values Education education1

label define Employmet_status1 1 "Yes" 2 "No"
label values Employmet_status Employmet_status1


label define Social_security1 1 "Yes" 2 "No", replace 
label values Social_security Social_security1


label define Gender1 1 "Male" 2 "Female"
label values Gender Gender1


label define  Maritial_status1 1 "Never Married" 2 "Married" 3 "Widowed" 4 "Divorced/Separated"
label values Maritial_status Maritial_status1

label define  Firm_size1 1 "0-20" 2 "21-99" 3 "100-299" 4 "300 and above"
label values Firm_size Firm_size1

label define  Type_contract1 1 "Contract without term" 2 "Contract with 1-3 years" 3 "Contract with less than 1 year" 4 "Oral Contract" 5 "No contract"
label values Type_contract Type_contract1

label define  Empl_type1 1 "Employer" 2 "self-employment" 3 "Family labor " 4 "Oral Contract" 5 "Corporate"
label values Empl_type Empl_type1

label define Tax_registration1 1 "Yes" 2 "No"
label values Tax_registration Tax_registration1

label define Employer_social_cont1 1 "Yes" 2 "No"
label values Employer_social_cont Employer_social_cont1

label define Accounting_sys1 1 "Yes" 2 "No"
label values Accounting_sys Accounting_sys1

label define Work_space1 1 "Fixed office" 2 "My home/Custumer's home'" 3 "Commerical center" 4 "Outdoor fixed point" 5 "mobile" /*different*/
label values Work_space Work_space1

label define  Earning_manner1 1 "Fixed" 2 "By Working day/hour" 3 "By product" 4 "Commission" 5 "Profit" 6 "kind" 7 "no payment"
label values Earning_manner Earning_manner1

*label define  Experience1 1 "Less than 1 year" 2 "Between 1 and 5 years" 3 "Between 5 and 10 years" 4 "Above 10 years" 
*label values Experience Experience1


label define  Secondary_job1 1 "YES" 0 "No" 
label values Secondary_job Secondary_job1






la var  province			"Province"	
la var  district				"Districts"
la var  Industry_code		    "Industry codes"
la var  Occucaption_code		"Occupation codes"
la var  Social_security			"Do you have social security?"
la var  Type_social_security	"Is your social security mandatory or voluntary"
la var  Gender				    "What is your gender?"
la var  Education 				"What is the highest education achieved?"
la var  Education_field		    "What is your major?"
la var  Employmet_status		"Are you currently employed?"
la var  Secondary_job			"Do you have secondary jobs?"
la var  Type_contract			"What is the type of your work contract?"
la var  Experience				"How long have you worked this job?"
la var  Digital						""
la var  Age						"How old are you?"
la var  Maritial_status			"What is your current marital status?"
la var  birthyear				"Year of Birth"
la var  Earning 				"How much did you earn in the past ....?"
la var  Earning_manner			"How do you get paid/frequency and type"
la var  Previous_industry        "What is your previous working industry?"
la var  Bonus					"How much money did you get via Bonus?"
la var  Tax_registration		"Is your employer legally registered?"
la var  Employer_social_cont	"Does your employer contributes to social security?"
la var  Accounting_sys			"Does your organization follow accounting systems?"
la var  Firm_size				"Firm size"
la var  Empl_type 				"What is your type of employment self/wage/unpiad?"
la var  Work_space 				"Where do you work - office, mobile, etc"	




*keep province-Experience


*save "$LFS2020final/LFS_2018_VNM_Harmonized.dta", replace

ta Empl_type
count if Empl_type==2
gen Self_employment = (Empl_type==2)
gen Employee = (Empl_type==4)
gen Informal = (Empl_type==2 | Empl_type==3)

ta Type_contract
count if Type_contract==5
gen No_contract=( Type_contract==5)

gen occup_code=Occucaption_code
gen Indus_code=Industry_code

ta Maritial_status
count if Maritial_status==2
gen Married=(Maritial_status==2)

ta Gender
count if Gender==1
gen Male=(Gender==1)

ta Education 
gen Higher_educ=(Education>=5 & Education<12)
gen Socialsecurity=(Social_security==1)

ren CAL_WEIGH_FINAL weight

gen Active=(Employmet_status==1)
gen year=2018

keep province district year Age Male Higher_educ  Socialsecurity Married Experience Active Self_employment No_contract occup_code Indus_code Earning Bonus   weight  Employee Informal 

save "$LFS2020final/LFS_2018_VNM_Harmonized_Limited.dta", replace



********************************************************************************
********************************************************************************

* 2019
*import spss using "/Users/atsi/Desktop/S4YE/Data/VNM/Raw/LFS_2019.sav", clear
*save "$LFS2020raw/LFS_2019.dta", replace 
use "$LFS2020raw/LFS_2019.dta", clear


gen province					= MATINH
gen district					=MAHUYEN
gen Industry_code				=C44C
gen Occucaption_code			=C43C
gen Social_security				=C51A
gen Socail_security_voluntary   =.
gen Type_social_security		=C51B
gen Gender						=C03
gen Education 					=C17B
gen Education_field				=C18B
gen Employmet_status			=C19
gen Secondary_job1				= C42
clonevar Type_contract1			=C50A 
gen Exp							= C52
gen Digital						=""
gen Age							=C05
gen Maritial_status				=C09A
gen birthyear					=C04B
gen Earning 					=C70A
gen Earning_manner				=.
gen Previous_industry           =.
gen Previous_occupation    	    =.

gen Bonus						=C70B
gen Tax_registration			=C46
gen Employer_social_cont		=.
gen Accounting_sys				=.
gen Firm_size					=C55
gen Empl_type 					=C47
gen Work_space 					=.

label data "mydata"


recode Exp (1/3 = 1 "Less than 1 year") (3=2 "Between 1 and 3 years") (4 = 3 "Between 5 and 10 years") (5 = 4 "Between 5 and 10 years") , gen (Experience)

recode Type_contract1 (1=1 "Indefinite term") (2=1 "One to three yearrs") (3/5 =3  "Less than one year") (6=4 "Verbal Contract") (7=5 "No Contract") , gen (Type_contract) 


gen Secondary_job=(Secondary_job1>0 & Secondary_job1!=.)
drop Secondary_job1
recode Maritial_status(5=4)

recode Education(10=9) (11=9) (8=9 )

	
*label define education1 0 "Never Attended" 1 "Some Primary" 2 "Primary" 3 "Lower Secondary" 4 "Short-term Training" 5 "Higher Education" 6 "Trade Vocational School" 7 "Traditional Services" 8 "Trade/Voc. College" 9 "College" 10 "University and Above"	,replace 

label define education1 1 "Never Attended School" 2 "Not Completed Pr. School" 3 "Primary School" 4 "Lower Secondary School" 5 "Upper Secondary School" 6 "Mid-term Professional School" 7 "Professional College" 8 "University" 9 "Above University" 

label values Education education1

label define Employmet_status1 1 "Yes" 2 "No"
label values Employmet_status Employmet_status1


label define Social_security1 1 "Yes" 2 "No", replace 
label values Social_security Social_security1


label define Gender1 1 "Male" 2 "Female"
label values Gender Gender1


label define  Maritial_status1 1 "Never Married" 2 "Married" 3 "Widowed" 4 "Divorced/Separated"
label values Maritial_status Maritial_status1

label define  Firm_size1 1 "1" 2 "2-4" 3 "5-9" 4 "10 a-20" 5 "20-49" 6 "50+"
label values Firm_size Firm_size1

label define  Type_contract1 1 "Contract without term" 2 "Contract with 1-3 years" 3 "Contract with less than 1 year" 4 "Oral Contract" 5 "No contract"
label values Type_contract Type_contract1

label define  Empl_type1 1 "Employer" 2 "self-employment" 3 "Family labor " 4 "Oral Contract" 5 "Corporate"
label values Empl_type Empl_type1

label define Tax_registration1 1 "Yes" 2 "No"
label values Tax_registration Tax_registration1

label define Employer_social_cont1 1 "Yes" 2 "No"
label values Employer_social_cont Employer_social_cont1

label define Accounting_sys1 1 "Yes" 2 "No"
label values Accounting_sys Accounting_sys1

label define Work_space1 1 "Fixed office" 2 "My home/Custumer's home'" 3 "Commerical center" 4 "Outdoor fixed point" 5 "mobile" /*different*/
label values Work_space Work_space1

label define  Earning_manner1 1 "Fixed" 2 "By Working day/hour" 3 "By product" 4 "Commission" 5 "Profit" 6 "kind" 7 "no payment"
label values Earning_manner Earning_manner1

*label define  Experience1 1 "Less than 1 year" 2 "Between 1 and 5 years" 3 "Between 5 and 10 years" 4 "Above 10 years" 
*label values Experience Experience1


label define  Secondary_job1 1 "YES" 0 "No" 
label values Secondary_job Secondary_job1






la var  province			"Province"	
la var  district				"Districts"
la var  Industry_code		    "Industry codes"
la var  Occucaption_code		"Occupation codes"
la var  Social_security			"Do you have social security?"
la var  Type_social_security	"Is your social security mandatory or voluntary"
la var  Gender				    "What is your gender?"
la var  Education 				"What is the highest education achieved?"
la var  Education_field		    "What is your major?"
la var  Employmet_status		"Are you currently employed?"
la var  Secondary_job			"Do you have secondary jobs?"
la var  Type_contract			"What is the type of your work contract?"
la var  Experience				"How long have you worked this job?"
la var  Digital						""
la var  Age						"How old are you?"
la var  Maritial_status			"What is your current marital status?"
la var  birthyear				"Year of Birth"
la var  Earning 				"How much did you earn in the past ....?"
la var  Earning_manner			"How do you get paid/frequency and type"
la var  Previous_industry        "What is your previous working industry?"
la var  Bonus					"How much money did you get via Bonus?"
la var  Tax_registration		"Is your employer legally registered?"
la var  Employer_social_cont	"Does your employer contributes to social security?"
la var  Accounting_sys			"Does your organization follow accounting systems?"
la var  Firm_size				"Firm size"
la var  Empl_type 				"What is your type of employment self/wage/unpiad?"
la var  Work_space 				"Where do you work - office, mobile, etc"	




*keep province-Experience


*save "$LFS2020final/LFS_2019_VNM_Harmonized.dta", replace

ta Empl_type
count if Empl_type==2
gen Self_employment = (Empl_type==2)
gen Employee = (Empl_type==4)
gen Informal = (Empl_type==2 | Empl_type==3)

ta Type_contract
count if Type_contract==5
gen No_contract=( Type_contract==5)

gen occup_code=Occucaption_code
gen Indus_code=Industry_code

ta Maritial_status
count if Maritial_status==2
gen Married=(Maritial_status==2)

ta Gender
count if Gender==1
gen Male=(Gender==1)

ta Education 
gen Higher_educ=(Education>=5 & Education<12)
gen Socialsecurity=(Social_security==1)

ren weigh_final_4 weight

gen Active=(Employmet_status==1)
gen year=2019

keep province district year Age Male Higher_educ  Socialsecurity Married Experience Active Self_employment No_contract occup_code Indus_code Earning Bonus   weight  Employee Informal 

save "$LFS2020final/LFS_2019_VNM_Harmonized_Limited.dta", replace




********************************************************************************
********************************************************************************

* 2020
*import spss using "/Users/atsi/Desktop/S4YE/Data/VNM/Raw/LFS_2019.sav", clear
*save "$LFS2020raw/LFS_2019.dta", replace 
use "$LFS2020raw/LFS_2020.dta", clear

replace MATINH= MaTinh if MATINH==.
replace MADIABAN = MaDiaBan if MADIABAN ==.

gen province					= MATINH
gen district					=MAHUYEN
gen Industry_code				=C45B
gen Occucaption_code			=C43B
gen Social_security				=C52
gen Socail_security_voluntary   =.
gen Type_social_security		=C53
gen Gender						=C03
gen Education 					=C17B
gen Education_field				=C18B
gen Employmet_status			=C20
*gen Secondary_job1				= C42
clonevar Type_contract1			=C50
gen Exp							= C52
gen Digital						=""
gen Age							=C05
gen Maritial_status				=C08
gen birthyear					=C04B
gen Earning 					=C72
gen Earning_manner				=.
gen Previous_industry           =.
gen Previous_occupation    	    =.

gen Bonus						=.
gen Tax_registration			=C46
gen Employer_social_cont		=.
gen Accounting_sys				=.
gen Firm_size					=C55
gen Empl_type 					=C47
gen Work_space 					=.

label data "mydata"


recode Exp (1/3 = 1 "Less than 1 year") (3=2 "Between 1 and 3 years") (4 = 3 "Between 5 and 10 years") (5 = 4 "Between 5 and 10 years") , gen (Experience)

recode Type_contract1 (1=1 "Indefinite term") (2=1 "One to three yearrs") (3/4 =3  "Less than one year") (5/6=4 "Verbal Contract") (7=5 "No Contract") , gen (Type_contract) 


gen Secondary_job=(C72B>0 & C72B!=.)
*drop Secondary_job1
recode Maritial_status(5=4)

recode Education(10=9) (11=9) (8=9 )

	
*label define education1 0 "Never Attended" 1 "Some Primary" 2 "Primary" 3 "Lower Secondary" 4 "Short-term Training" 5 "Higher Education" 6 "Trade Vocational School" 7 "Traditional Services" 8 "Trade/Voc. College" 9 "College" 10 "University and Above"	,replace 

label define education1 1 "Never Attended School" 2 "Not Completed Pr. School" 3 "Primary School" 4 "Lower Secondary School" 5 "Upper Secondary School" 6 "Mid-term Professional School" 7 "Professional College" 8 "University" 9 "Above University" 

label values Education education1

label define Employmet_status1 1 "Yes" 2 "No"
label values Employmet_status Employmet_status1


label define Social_security1 1 "Yes" 2 "No", replace 
label values Social_security Social_security1


label define Gender1 1 "Male" 2 "Female"
label values Gender Gender1


label define  Maritial_status1 1 "Never Married" 2 "Married" 3 "Widowed" 4 "Divorced/Separated"
label values Maritial_status Maritial_status1

label define  Firm_size1 1 "1" 2 "2-4" 3 "5-9" 4 "10 a-20" 5 "20-49" 6 "50+"
label values Firm_size Firm_size1

label define  Type_contract1 1 "Contract without term" 2 "Contract with 1-3 years" 3 "Contract with less than 1 year" 4 "Oral Contract" 5 "No contract"
label values Type_contract Type_contract1

label define  Empl_type1 1 "Employer" 2 "self-employment" 3 "Family labor " 4 "Oral Contract" 5 "Corporate"
label values Empl_type Empl_type1

label define Tax_registration1 1 "Yes" 2 "No"
label values Tax_registration Tax_registration1

label define Employer_social_cont1 1 "Yes" 2 "No"
label values Employer_social_cont Employer_social_cont1

label define Accounting_sys1 1 "Yes" 2 "No"
label values Accounting_sys Accounting_sys1

label define Work_space1 1 "Fixed office" 2 "My home/Custumer's home'" 3 "Commerical center" 4 "Outdoor fixed point" 5 "mobile" /*different*/
label values Work_space Work_space1

label define  Earning_manner1 1 "Fixed" 2 "By Working day/hour" 3 "By product" 4 "Commission" 5 "Profit" 6 "kind" 7 "no payment"
label values Earning_manner Earning_manner1

*label define  Experience1 1 "Less than 1 year" 2 "Between 1 and 5 years" 3 "Between 5 and 10 years" 4 "Above 10 years" 
*label values Experience Experience1


label define  Secondary_job1 1 "YES" 0 "No" 
label values Secondary_job Secondary_job1






la var  province			"Province"	
la var  district				"Districts"
la var  Industry_code		    "Industry codes"
la var  Occucaption_code		"Occupation codes"
la var  Social_security			"Do you have social security?"
la var  Type_social_security	"Is your social security mandatory or voluntary"
la var  Gender				    "What is your gender?"
la var  Education 				"What is the highest education achieved?"
la var  Education_field		    "What is your major?"
la var  Employmet_status		"Are you currently employed?"
la var  Secondary_job			"Do you have secondary jobs?"
la var  Type_contract			"What is the type of your work contract?"
la var  Experience				"How long have you worked this job?"
la var  Digital						""
la var  Age						"How old are you?"
la var  Maritial_status			"What is your current marital status?"
la var  birthyear				"Year of Birth"
la var  Earning 				"How much did you earn in the past ....?"
la var  Earning_manner			"How do you get paid/frequency and type"
la var  Previous_industry        "What is your previous working industry?"
la var  Bonus					"How much money did you get via Bonus?"
la var  Tax_registration		"Is your employer legally registered?"
la var  Employer_social_cont	"Does your employer contributes to social security?"
la var  Accounting_sys			"Does your organization follow accounting systems?"
la var  Firm_size				"Firm size"
la var  Empl_type 				"What is your type of employment self/wage/unpiad?"
la var  Work_space 				"Where do you work - office, mobile, etc"	




*keep province-Experience


*save "$LFS2020final/LFS_2019_VNM_Harmonized.dta", replace

ta Empl_type
count if Empl_type==2
gen Self_employment = (Empl_type==2)
gen Employee = (Empl_type==4)
gen Informal = (Empl_type==2 | Empl_type==3)

ta Type_contract
count if Type_contract==5
gen No_contract=( Type_contract==5)

gen occup_code=Occucaption_code
gen Indus_code=Industry_code

ta Maritial_status
count if Maritial_status==2
gen Married=(Maritial_status==2)

ta Gender
count if Gender==1
gen Male=(Gender==1)

ta Education 
gen Higher_educ=(C17C|C17D==1 | C17E==1 | C17F==1)
gen Socialsecurity=(Social_security==1)

replace cal_weigh_quy =0  if cal_weigh_quy==.
replace Weight_final_quy=0     if Weight_final_quy==.
replace Weight_final=0 if Weight_final==.
replace cal_weigh_final=0    if cal_weigh_final==.
egen totalw_q1 = total(cal_weigh_quy)
egen totalw_q2 = total(Weight_final_quy)
egen totalw_q3 = total(Weight_final)
egen totalw_q4 = total(cal_weigh_final)
gen total_q1_4 = totalw_q1+totalw_q2+totalw_q3+totalw_q4

gen weight=cal_weigh_final*totalw_q1/total_q1_4+ Weight_final*totalw_q2/total_q1_4 +Weight_final_quy*totalw_q3/total_q1_4+ cal_weigh_quy*totalw_q4/total_q1_4


gen Active=(Employmet_status==1)
gen year=2020

keep province district year Age Male Higher_educ  Socialsecurity Married Experience Active Self_employment No_contract occup_code Indus_code Earning Bonus   weight  Employee Informal 

save "$LFS2020final/LFS_2020_VNM_Harmonized_Limited.dta", replace







********************************************************************************
********************************************************************************

* 2021
*import spss using "/Users/atsi/Desktop/S4YE/Data/VNM/Raw/LFS_2019.sav", clear
*save "$LFS2020raw/LFS_2019.dta", replace 
use "$LFS2020raw/LFS_2021.dta", clear


gen province					= MaTinh
gen district					=MaHuyen
gen Industry_code				=C37B
gen Occucaption_code			=C35B
gen Social_security				=C45
gen Socail_security_voluntary   =.
gen Type_social_security		=C46
gen Gender						=C02
gen Education 					=C13
gen Education_field				=C15B
gen Employmet_status			=C17
gen Secondary_job1				=C48
clonevar Type_contract1			= C44
gen Exp							= C47
gen Digital						=C47A
gen Digital_covid               =C47B
gen Digital_covid2				=C47C
gen Age							=C04
gen Maritial_status				=C07
gen birthyear					=C03B
gen Earning 					=C42
gen Earning_manner				=.
gen Previous_industry           =.
gen Previous_occupation    	    =.

gen Bonus						=C55
gen Tax_registration			=C39
gen Employer_social_cont		=.
gen Accounting_sys				=.
gen Firm_size					=.
gen Empl_type 					=C43
gen Work_space 					=.

label data "mydata"


recode Exp (1/3 = 1 "Less than 1 year") (3=2 "Between 1 and 3 years") (4 = 3 "Between 5 and 10 years") (5 = 4 "Between 5 and 10 years") , gen (Experience)

recode Type_contract1 (1=1 "Indefinite term") (2=1 "One to three yearrs") (3/5 =3  "Less than one year") (6=4 "Verbal Contract") (7=5 "No Contract") , gen (Type_contract) 


gen Secondary_job=(Secondary_job1>0 & Secondary_job1!=.)
drop Secondary_job1
recode Maritial_status(5=4)

recode Education(10=9) (11=9) (8=9 )

	
*label define education1 0 "Never Attended" 1 "Some Primary" 2 "Primary" 3 "Lower Secondary" 4 "Short-term Training" 5 "Higher Education" 6 "Trade Vocational School" 7 "Traditional Services" 8 "Trade/Voc. College" 9 "College" 10 "University and Above"	,replace 

label define education1 1 "Never Attended School" 2 "Not Completed Pr. School" 3 "Primary School" 4 "Lower Secondary School" 5 "Upper Secondary School" 6 "Mid-term Professional School" 7 "Professional College" 8 "University" 9 "Above University" 

label values Education education1

label define Employmet_status1 1 "Yes" 2 "No"
label values Employmet_status Employmet_status1


label define Social_security1 1 "Yes" 2 "No", replace 
label values Social_security Social_security1


label define Gender1 1 "Male" 2 "Female"
label values Gender Gender1


label define  Maritial_status1 1 "Never Married" 2 "Married" 3 "Widowed" 4 "Divorced/Separated"
label values Maritial_status Maritial_status1

label define  Firm_size1 1 "1" 2 "2-4" 3 "5-9" 4 "10 a-20" 5 "20-49" 6 "50+"
label values Firm_size Firm_size1

label define  Type_contract1 1 "Contract without term" 2 "Contract with 1-3 years" 3 "Contract with less than 1 year" 4 "Oral Contract" 5 "No contract"
label values Type_contract Type_contract1

label define  Empl_type1 1 "Employer" 2 "self-employment" 3 "Family labor " 4 "Oral Contract" 5 "Corporate"
label values Empl_type Empl_type1

label define Tax_registration1 1 "Yes" 2 "No"
label values Tax_registration Tax_registration1

label define Employer_social_cont1 1 "Yes" 2 "No"
label values Employer_social_cont Employer_social_cont1

label define Accounting_sys1 1 "Yes" 2 "No"
label values Accounting_sys Accounting_sys1

label define Work_space1 1 "Fixed office" 2 "My home/Custumer's home'" 3 "Commerical center" 4 "Outdoor fixed point" 5 "mobile" /*different*/
label values Work_space Work_space1

label define  Earning_manner1 1 "Fixed" 2 "By Working day/hour" 3 "By product" 4 "Commission" 5 "Profit" 6 "kind" 7 "no payment"
label values Earning_manner Earning_manner1

*label define  Experience1 1 "Less than 1 year" 2 "Between 1 and 5 years" 3 "Between 5 and 10 years" 4 "Above 10 years" 
*label values Experience Experience1


label define  Secondary_job1 1 "YES" 0 "No" 
label values Secondary_job Secondary_job1






la var  province			"Province"	
la var  district				"Districts"
la var  Industry_code		    "Industry codes"
la var  Occucaption_code		"Occupation codes"
la var  Social_security			"Do you have social security?"
la var  Type_social_security	"Is your social security mandatory or voluntary"
la var  Gender				    "What is your gender?"
la var  Education 				"What is the highest education achieved?"
la var  Education_field		    "What is your major?"
la var  Employmet_status		"Are you currently employed?"
la var  Secondary_job			"Do you have secondary jobs?"
la var  Type_contract			"What is the type of your work contract?"
la var  Experience				"How long have you worked this job?"
la var  Digital						""
la var  Age						"How old are you?"
la var  Maritial_status			"What is your current marital status?"
la var  birthyear				"Year of Birth"
la var  Earning 				"How much did you earn in the past ....?"
la var  Earning_manner			"How do you get paid/frequency and type"
la var  Previous_industry        "What is your previous working industry?"
la var  Bonus					"How much money did you get via Bonus?"
la var  Tax_registration		"Is your employer legally registered?"
la var  Employer_social_cont	"Does your employer contributes to social security?"
la var  Accounting_sys			"Does your organization follow accounting systems?"
la var  Firm_size				"Firm size"
la var  Empl_type 				"What is your type of employment self/wage/unpiad?"
la var  Work_space 				"Where do you work - office, mobile, etc"	




*keep province-Experience C14C C14D C14E C14F


*save "$LFS2020final/LFS_2021_VNM_Harmonized.dta", replace



ta Empl_type
count if Empl_type==2
gen Self_employment = (Empl_type==2)
gen Employee = (Empl_type==4)
gen Informal = (Empl_type==2 | Empl_type==3)

ta Type_contract
count if Type_contract==5
gen No_contract=( Type_contract==5)

gen occup_code=Occucaption_code
gen Indus_code=Industry_code

ta Maritial_status
count if Maritial_status==2
gen Married=(Maritial_status==2)

ta Gender
count if Gender==1
gen Male=(Gender==1)

ta Education 
gen Higher_educ=(C14C==1|C14D==1 | C14E==1 | C14F==1)
gen Socialsecurity=(Social_security==1)

ren Final_Weight weight

gen Active=(Employmet_status==1)
gen year=2021

keep province district year Age Married Male Higher_educ  Socialsecurity Experience Active Self_employment No_contract occup_code Indus_code Earning Bonus   weight Digital Employee Informal 

save "$LFS2020final/LFS_2021_VNM_Harmonized_Limited.dta", replace

********************************************************************************

*Appending 
********************************************************************************

use "$LFS2020final/LFS_2011_VNM_Harmonized_Limited.dta", clear

forvalues x=2012/2021{
	
append using "$LFS2020final/LFS_`x'_VNM_Harmonized_Limited.dta", force 

	
}
gen country="VNM"
*Huyen missing until 20`6
*Xa available sisnce 2017
*Diaban is avaiable for almost all years. But I am not sure if the definition is consistent across time (DIABAN means enumeration area)

*CORRECTING FEW OCCUPATION CODES MANUALLLY will take place after appening 



save "$LFS2020final/LFS_VNM_Harmonized_Limited.dta", replace 
