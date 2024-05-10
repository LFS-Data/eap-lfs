*==============================================================================*
*! Harmonized LFS and HH Survey Database for EAP CEO
*! Adapted from GLAD (github.com/worldbank/GLAD) written by Diana Goldemberg, Joao Pedro Azevedo, and Kristoff Bjarkfur
*! 

*! PROFILE: Required step before running any do-files in this project
*==============================================================================*

qui {

  /*
  Steps in this do-file:
  1) General program setup
  2) Define user-dependant path for local clone repo
  3) Check if can access WB network path and WB datalibweb
  4) Download and install required user written ado's
  5) Make time-saving offers to user, requesting confirmation
  6) Flag that profile was successfully loaded
  */

  *-----------------------------------------------------------------------------
  * 1) General program setup
  *-----------------------------------------------------------------------------
  clear              all
  capture log        close _all
  set more           off
  set varabbrev      off, permanently
  set emptycells     drop
  set maxvar         12000
  set linesize       255
  set rmsg 			 on
  version            17
  *-----------------------------------------------------------------------------

  *-----------------------------------------------------------------------------
  * 2) Define user-dependant path for local clone repo
  *-----------------------------------------------------------------------------
  * Change here only if this repo is renamed
  local this_repo     "eap-lfs"
  * Change here only if this master run do-file is renamed
  local this_run_do   "run_eap-lfs.do"
  
  * msteams global 
  * For now it will check 2 defaults 
  * (please add a new path if the path is different)
  mata : st_numscalar("exists", direxists("C:/Users/`c(username)'/OneDrive - WBG/Data from Poverty team/Labor Force Survey"))
	* Possible path 1
		if scalar(exists) == 0 {
			global msteams "C:/Users/`c(username)'/WBG/Duong Trung Le - Data from Poverty team/Labor Force Survey"
			global flagship "C:/Users/`c(username)'/WBG/Duong Trung Le - Technology and Labor Market flagship"
		}
	* Possible Path 2
		else {
			  global msteams "C:/Users/`c(username)'/OneDrive - WBG/Data from Poverty team/Labor Force Survey"
			  	global flagship "C:/Users/`c(username)'/OneDrive - WBG/Technology and Labor Market flagship"

		}


  * The remaining of this section is standard in EduAnalytics repos

  * One of two options can be used to "know" the clone path for a given user
  * A. the user had previously saved their GitHub location with -whereis-,
  *    so the clone is a subfolder with this Project Name in that location
  * B. through a window dialog box where the user manually selects a file

  * Method A - Github location stored in -whereis-
  *---------------------------------------------
  capture whereis github
  if _rc == 0 global clone "`r(github)'/`this_repo'"

  * Method B - clone selected manually
  *---------------------------------------------
  else {
    * Display an explanation plus warning to force the user to look at the dialog box
    noi disp as txt `"{phang}Your GitHub clone local could not be automatically identified by the command {it: whereis}, so you will be prompted to do it manually. To save time, you could install -whereis- with {it: ssc install whereis}, then store your GitHub location, for example {it: whereis github "C:/Users/AdaLovelace/GitHub"}.{p_end}"'
    noi disp as error _n `"{phang}Please use the dialog box to manually select the file `this_run_do' in your machine.{p_end}"'

    * Dialog box to select file manually
    capture window fopen path_and_run_do "Select the master do-file for this project (`this_run_do'), expected to be inside any path/`this_repo'/" "Do Files (*.do)|*.do|All Files (*.*)|*.*" do

    * If user clicked cancel without selecting a file or chose a file that is not a do, will run into error later
    if _rc == 0 {

      * Pretend user chose what was expected in terms of string lenght to parse
      local user_chosen_do   = substr("$path_and_run_do",   - strlen("`this_run_do'"),     strlen("`this_run_do'") )
      local user_chosen_path = substr("$path_and_run_do", 1 , strlen("$path_and_run_do") - strlen("`this_run_do'") - 1 )

      * Replace backward slash with forward slash to avoid possible troubles
      local user_chosen_path = subinstr("`user_chosen_path'", "\", "/", .)

      * Check if master do-file chosen by the user is master_run_do as expected
      * If yes, attributes the path chosen by user to the clone, if not, exit
      if "`user_chosen_do'" == "`this_run_do'"  global clone "`user_chosen_path'"
      else {
        noi disp as error _newline "{phang}You selected $path_and_run_do as the master do file. This does not match what was expected (any path/`this_repo'/`this_run_do'). Code aborted.{p_end}"
        error 2222
      }
    }
  }

  * Regardless of the method above, check clone
  *---------------------------------------------
  * Confirm that clone is indeed accessible by testing that master run is there
  cap confirm file "${clone}/`this_run_do'"
  if _rc != 0 {
    noi disp as error _n `"{phang}Having issues accessing your local clone of the `this_repo' repo. Please double check the clone location specified in the run do-file and try again.{p_end}"'
    error 2222
  }
  *-----------------------------------------------------------------------------


  *-----------------------------------------------------------------------------
  * 3) Download and install required user written ado's
  *-----------------------------------------------------------------------------
  * Fill this list will all user-written commands this project requires
  local user_commands fs pv seq mdesc alphawgt touch labmv fre egenmore unique missings wbopendata labutil iscogen

  * Loop over all the commands to test if they are already installed, if not, then install
  foreach command of local user_commands {
    cap which `command'
    ssc install `command'
    
  }


  *-----------------------------------------------------------------------------
  * 6) Flag that profile was successfully loaded
  *-----------------------------------------------------------------------------
  noi disp as result _n `"{phang}`this_repo' clone sucessfully set up (${clone}).{p_end}"'
  global stata_profile_is_loaded = 1
  *-----------------------------------------------------------------------------

}
