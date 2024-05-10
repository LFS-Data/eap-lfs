*==============================================================================*
* 
* 
*==============================================================================*

qui {

  *-----------------------------------------------------------------------------
  * Check that project profile was loaded, otherwise stops code
  *-----------------------------------------------------------------------------
  cap assert ${stata_profile_is_loaded} == 1
  if _rc != 0 {
  	noi disp as error "Please execute the profile_eap-ceo initialization do in the root of this project and try again."
  	exit
  }



*-------------------------------------------------------------------------------
* Tasks in this project
*-------------------------------------------------------------------------------

* TASK 01_HARMONIZATION: Harmonizes GLD data and creates descriptive statistics (in datalibweb or input path)
	do "${clone}/01_harmonization/01_run.do"
 
* TASK 02_ONET: Creates digital score using ONET data and harmonizes SOC to ISCO code

*-------------------------------------------------------------------------------

}
*exit
