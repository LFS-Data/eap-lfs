*==============================================================================*
*!  PROGRAM 0191 label_values: Label Values of harmonized variables
*==============================================================================*

/* The use case of this program is:
    Label harmonized variables 
	This ensure consistency in how labesl are defined across assessments
	
	Please use this as a source file if any labels need to be modified

*/

cap program drop lab_vals
program  define  lab_vals, rclass

  version 18

  local syntaxerror 2222

  quietly {
  	label var code "Country code"
	label var year "Year of survey"
	
	* Male / Female
	cap label define lbl_male 0 "Female" 1 "Male"
	label values male lbl_male
	
	* Occupation Skill (occup_skill)
	cap label define lbl_occup_skill 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill lbl_occup_skill
	label var occup_skill "Skill based on ISCO08 standard"
	
	* Employment Status
	cap label define lbl_empstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by stat"
	label values empstat lbl_empstat
	
	* Industry category (10)
	cap la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10 lblindustrycat10

	* Industry Category (4)
	cap la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
	label var industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
	
	* Unit Wage
	cap label define lbl_unitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwag* lbl_unitwage
	
	* Education (4 levels)
	cap la de lbleducat4 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values educat4 lbleducat4

  }
   
end