/*
EUTF RISE Evaluation
Thomas Eekhout
September 2022

*/
*upload data

cd "$dofiles"

*POWER CALCULATIONS
do "2.1_Power calculations_WIP.do"
cd "$dofiles"

{ /* DESCRIPTIVE STATISTICS */

* DIRECTORY TO SAVE TABLES
cd "$tablesRR22\Balance checks"
				
********************************************************************************
*** 						DO NOT TOUCH 									 ***
********************************************************************************
{
* Automatic numbering of tables
global tablenum = 0
}
********************************************************************************
********************************************************************************

********************************************************************************
*** 							BUILD TABLES								 ***
********************************************************************************

forvalues t = 0/2 {
use "$DATA_PREPARED", clear
keep if cohort==1 | cohort==2
drop *_TSTT *_FLES // For some reason monitoring data does not allow to use the maketable command and reports a mismatch...

	if `t'==0 {
use "$DATA_PREPARED", clear
keep if cohort==1 | cohort==2
drop *_TSTT *_FLES // For some reason monitoring data does not allow to use the maketable command and reports a mismatch...
keep if treatment!=99
replace treatment=1 if treatment==2
label define t_lbl 0"Control" 1"Treatment (T1 & T2)"
label values treatment t_lbl

}

	if `t'==1 {
use "$DATA_PREPARED", clear
keep if cohort==1 | cohort==2
drop *_TSTT *_FLES // For some reason monitoring data does not allow to use the maketable command and reports a mismatch...
keep if treatment!=99
drop if treatment==2
}

	if `t'==2 {
use "$DATA_PREPARED", clear
keep if cohort==1 | cohort==2
drop *_TSTT *_FLES // For some reason monitoring data does not allow to use the maketable command and reports a mismatch...
keep if treatment!=99
drop if treatment==1
replace treatment=1 if treatment==2
label define t_lbl 0"Control" 1"Treatment 2"
label values treatment t_lbl
}

{ /*TABLE - Principal sociodemographics */


*** prepare variables
label var age "Age (in April 2022)"

tabulate gender, generate(gender) 
labvarch gender*, after(==)

tabulate refugee_status, generate(refugee_status) 
labvarch refugee_status*, after(==)

tabulate married, generate(married) 
labvarch married*, after(==)

tabulate educ, generate(educ) 
labvarch educ*, after(==)


*** Setup options for 'maketable' command

* Variables to summarize
local vars 		age gender2 refugee_status1 married2 educ1 educ2 educ3 educ4

sum `vars'

* Short table title also used for RTF file name (cannot contain characters not accepted in Windows OS file names)
local title			"Sociodemographics T`t' vs C"

* Specify treatment variable --> argument to option 'ttest'; must be binary dummy variable coded 1 = Treatment and 0 = Control
local treatvar		treatment

* Specify cluster variable --> argument to option 'cluster'; can only be specified with 'ttest'. Adjust t-test for clustering.
local clustervar  //cluster

* Specify grouping variable --> argument to option 'groupvar', option used when need group statistics but no t-test; can be numeric or string 
local groupvar		

* Variables for which left indent is desired for labels in table
local indent_vars `vars'

* Specify type of respondents at bottom of table on row that shows no. of obs. It will read "Number of `respondents'". Default is "Observations".
local respondents 

* Positive integer. Sets format for values between 
local format 		2


*** Other options --> 'maketable' accepts all options accepted by 'estout'

* For categories in estout's 'refcat()' option
local categories	age "{\b Principal sociodemographic characteristics}" educ1 "{\b Education}"


* Specify local 'note' to override default note. 		
local note 	"Note: Columns (1), (2) and (3) present the sample means (proportions when % is shown in the variable name or in the table) of selected variables for the full sample, the treatment group and the control group, respectively. Standard deviations in parentheses. Column (4) presents the mean difference between the treatment and control groups. P-value of the corresponding t-test in parentheses. T-test adjusted for clustering at the vti-trade-gender cluster level. Significance level: p \u8804? 0.1, ** p \u8804? 0.05, *** p \u8804? 0.01. \line Source: C4ED elaboration"


*** Produce and export table to RTF document
/*
maketable `vars', title(`title') font(Times New Roman) rmvtitle backcolors(topfill(c4ed) nbtoprows(2) toptextbold) ttest(`treatvar') cluster(`clustervar') refcat(`categories', nolabel) indentvars(`indent_vars') notesize(16) wrapnote
*/
maketable `vars', title(`title') font(Times New Roman) backcolors(topfill(c4ed) nbtoprows(2) toptextbold) ttest(`treatvar') cluster(`clustervar') refcat(`categories', nolabel) indentvars(`indent_vars') note(`note') notesize(16) wrapnote rmvtitle


	}

{ /*TABLE - Employment  */


*** prepare variables
label var emp_stable "Has a stable job"

tabulate emp_status, generate(emp_status) 
labvarch emp_status*, after(==)
label var emp_status1 "Other"
label var emp_status2 "Employee"
label var emp_status3 "Family worker"
label var emp_status4 "Self employed"
label var emp_status5 "Apprentice"
label var emp_status6 "Casual worker"


*** Setup options for 'maketable' command

* Variables to summarize
local vars 		emp_stable emp_status2 emp_status3 emp_status4 emp_status5 emp_status6 emp_status1

sum `vars'

* Short table title also used for RTF file name (cannot contain characters not accepted in Windows OS file names)
local title			"Employment characteristics T`t' vs C"

* Specify treatment variable --> argument to option 'ttest'; must be binary dummy variable coded 1 = Treatment and 0 = Control
local treatvar		treatment

* Specify cluster variable --> argument to option 'cluster'; can only be specified with 'ttest'. Adjust t-test for clustering.
local clustervar  cluster

* Specify grouping variable --> argument to option 'groupvar', option used when need group statistics but no t-test; can be numeric or string 
local groupvar		

* Variables for which left indent is desired for labels in table
local indent_vars  emp_status2 emp_status3 emp_status4 emp_status5 emp_status6 emp_status1

* Specify type of respondents at bottom of table on row that shows no. of obs. It will read "Number of `respondents'". Default is "Observations".
local respondents 

* Positive integer. Sets format for values between 
local format 		2


*** Other options --> 'maketable' accepts all options accepted by 'estout'

* For categories in estout's 'refcat()' option
local categories


* Specify local 'note' to override default note. 		
local note 		`note'


*** Produce and export table to RTF document
/*
maketable `vars', title(`title') font(Times New Roman) rmvtitle backcolors(topfill(c4ed) nbtoprows(2) toptextbold) ttest(`treatvar') cluster(`clustervar') refcat(`categories', nolabel) indentvars(`indent_vars') notesize(16) wrapnote
*/
maketable `vars', title(`title') font(Times New Roman) backcolors(topfill(c4ed) nbtoprows(2) toptextbold) ttest(`treatvar') cluster(`clustervar') refcat(`categories', nolabel) indentvars(`indent_vars') note(`note') notesize(16) wrapnote rmvtitle


	}
	

{ /*TABLE - Motivation */


*** prepare variables

tabulate motivation, generate(motivation) 
labvarch motivation*, after(==)


*** Setup options for 'maketable' command

* Variables to summarize
local vars 		motivation2 motivation3 motivation4 motivation1

sum `vars'

* Short table title also used for RTF file name (cannot contain characters not accepted in Windows OS file names)
local title			"Motivation T`t' vs C"

* Specify treatment variable --> argument to option 'ttest'; must be binary dummy variable coded 1 = Treatment and 0 = Control
local treatvar		treatment

* Specify cluster variable --> argument to option 'cluster'; can only be specified with 'ttest'. Adjust t-test for clustering.
local clustervar  cluster

* Specify grouping variable --> argument to option 'groupvar', option used when need group statistics but no t-test; can be numeric or string 
local groupvar		

* Variables for which left indent is desired for labels in table
local indent_vars

* Specify type of respondents at bottom of table on row that shows no. of obs. It will read "Number of `respondents'". Default is "Observations".
local respondents 

* Positive integer. Sets format for values between 
local format 		2


*** Other options --> 'maketable' accepts all options accepted by 'estout'

* For categories in estout's 'refcat()' option
local categories


* Specify local 'note' to override default note. 		
local note 		`note'


*** Produce and export table to RTF document
/*
maketable `vars', title(`title') font(Times New Roman) rmvtitle backcolors(topfill(c4ed) nbtoprows(2) toptextbold) ttest(`treatvar') cluster(`clustervar') refcat(`categories', nolabel) indentvars(`indent_vars') notesize(16) wrapnote
*/
maketable `vars', title(`title') font(Times New Roman) backcolors(topfill(c4ed) nbtoprows(2) toptextbold) ttest(`treatvar') cluster(`clustervar') refcat(`categories', nolabel) indentvars(`indent_vars') note(`note') notesize(16) wrapnote rmvtitle


	}
	


{ /*TABLE - Vulnerabilities */


*** prepare variables


*** Setup options for 'maketable' command

* Variables to summarize
local vars 		vul_hh vul_mh vul_ph vul_cd vul

sum `vars'

* Short table title also used for RTF file name (cannot contain characters not accepted in Windows OS file names)
local title			"Vulnerabilities T`t' vs C"

* Specify treatment variable --> argument to option 'ttest'; must be binary dummy variable coded 1 = Treatment and 0 = Control
local treatvar		treatment

* Specify cluster variable --> argument to option 'cluster'; can only be specified with 'ttest'. Adjust t-test for clustering.
local clustervar  cluster

* Specify grouping variable --> argument to option 'groupvar', option used when need group statistics but no t-test; can be numeric or string 
local groupvar		

* Variables for which left indent is desired for labels in table
local indent_vars

* Specify type of respondents at bottom of table on row that shows no. of obs. It will read "Number of `respondents'". Default is "Observations".
local respondents 

* Positive integer. Sets format for values between 
local format 		2


*** Other options --> 'maketable' accepts all options accepted by 'estout'

* For categories in estout's 'refcat()' option
local categories


* Specify local 'note' to override default note. 		
local note 		`note'


*** Produce and export table to RTF document
/*
maketable `vars', title(`title') font(Times New Roman) rmvtitle backcolors(topfill(c4ed) nbtoprows(2) toptextbold) ttest(`treatvar') cluster(`clustervar') refcat(`categories', nolabel) indentvars(`indent_vars') notesize(16) wrapnote
*/
maketable `vars', title(`title') font(Times New Roman) backcolors(topfill(c4ed) nbtoprows(2) toptextbold) ttest(`treatvar') cluster(`clustervar') refcat(`categories', nolabel) indentvars(`indent_vars') notesize(16) wrapnote rmvtitle


	}
	
}

}

