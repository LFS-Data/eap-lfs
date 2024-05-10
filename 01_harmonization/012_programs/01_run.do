*==============================================================================*
* 01 RUN: Run the tasks that come from this routine
*  The final output includes harmonized datasets and summary statistics
*==============================================================================*

* TASK 01_HARMONIZATION: Harmonizes GLD data and creates descriptive statistics (in datalibweb or input path)	
	* Subtask 011: Harmonize any problematic variables from EAP LFS (WIP)
	* This will come for new incoming data 
	do "${clone}/01_harmonization/012_programs/011_raw_to_eapce.do"
	
	* Subtask 012: Harmonize EAP-CE data to GLD
	do "${clone}/01_harmonization/012_programs/012_eapce_to_gld.do"	
	
	* Subtask 013: Further harmonize GLD-formatted datasets by adding additional variables of interest
	do "${clone}/01_harmonization/012_programs/013_final_harmonizations.do"	
	
	* Subtask 014: Calculate interested outcomes by interested breakdowns
	do "${clone}/01_harmonization/012_programs/014_create_means.do"
