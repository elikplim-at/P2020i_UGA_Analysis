*Select dataset
use "$DATA_PREPARED", clear

* DIRECTORY TO SAVE TABLES --> Adjust if needed
cd "$tablesRR22"


tabulate gender, generate(gender) 
labvarch gender*, after(==)

tabulate refugee_status, generate(refugee_status) 
labvarch refugee_status*, after(==)

label var emp_stable "Has a stable job"

label var age "Age"

label var educ "Level of education"
tabulate educ, generate(educ) 
labvarch educ*, after(==)

/*
cap gen self_employed=0
replace self_employed=1 if q14==3
label var self_employed "Self-employed"

cap gen reg_emp=0
replace reg_emp=1 if q14==1
label var reg_emp "Regular employee"

cap label var q15_1 "Find a job in a business"
cap label var q15_2 "Start/develop a business"
cap label var q15_3 "Develop skills"

cap label var q16_a "Household"
cap label var q16_b "Mental health"
cap label var q16_c "Physical health"
cap label var q16_d "Chronic desease"

*/
keep if treatment!=99


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

*** TABLE - Balance checks
{
*** prepare variables
**generate dummies


*** Setup options for 'maketable' command

* Variables to summarize
*local vars 		gender2 refugee_status2 age q116 q112 q113 q114 q14 self_employed reg_emp q17_1 q17_2 q17_3 q18_a q18_b q18_c q18_d
local vars 		gender2 refugee_status2 age educ1 educ2 educ3 educ4 educ5 educ6
* Short table title also used for RTF file name (cannot contain characters not accepted in Windows OS file names)
local title			"balance checks-All groups-full sample"

* Specify treatment variable --> argument to option 'ttest'; must be binary dummy variable coded 1 = Treatment and 0 = Control
local treatvar		

* Specify cluster variable --> argument to option 'cluster'; can only be specified with 'ttest'. Adjust t-test for clustering.
local clustervar  

* Specify grouping variable --> argument to option 'groupvar', option used when need group statistics but no t-test; can be numeric or string 
local groupvar		treatment

* Variables for which left indent is desired for labels in table
local indent_vars `vars'

* Specify type of respondents at bottom of table on row that shows no. of obs. It will read "Number of `respondents'". Default is "Observations".
local respondents 	individuals

* Positive integer. Sets format for values between 
local format 		2


*** Other options --> 'maketable' accepts all options accepted by 'estout'

* For categories in estout's 'refcat()' option
local categories gender2 "{\b Sociodemographic characteristics}" educ1 "{\b Education}"

* Specify local 'note' to override default note. 		
local note 		


*** Produce and export table to RTF document

maketable `vars', title(`title') backcolors(topfill(c4ed) nbtoprows(2) toptextbold) ttest() cluster() groupvar(`groupvar') refcat(`categories', nolabel) indentvars(`indent_vars') notesize(16) wrapnote
}


********************************************************************************

*** TABLE - Balance checks T1 vs C

*Select dataset
use "$DATA_PREPARED.dta", clear

quietly{
tabulate gender, generate(gender) 
labvarch gender*, after(==)

tabulate refugee_status, generate(refugee_status) 
labvarch refugee_status*, after(==)

label var q14 "Has a stable job"

label var age "Age"

label var q11 "Level of education"
tabulate q11, generate(q11) 
labvarch q11*, after(==)

cap gen self_employed=0
replace self_employed=1 if q14==3
label var self_employed "Self-employed"

cap gen reg_emp=0
replace reg_emp=1 if q14==1
label var reg_emp "Regular employee"

cap label var q15_1 "Find a job in a business"
cap label var q15_2 "Start/develop a business"
cap label var q15_3 "Develop skills"

cap label var q16_a "Household"
cap label var q16_b "Mental health"
cap label var q16_c "Physical health"
cap label var q16_d "Chronic desease"
}

keep if treatment==0 | treatment==1 

{
*** Setup options for 'maketable' command

* Variables to summarize
local vars 		gender2 refugee_status2 age q112 q13 self_employed reg_emp q15_1 q15_2 q15_3 q16_a q16_b q16_c q16_d

* Short table title also used for RTF file name (cannot contain characters not accepted in Windows OS file names)
local title			"balance checks T1 vs C-full sample"

* Specify treatment variable --> argument to option 'ttest'; must be binary dummy variable coded 1 = Treatment and 0 = Control
local treatvar		treatment

* Specify cluster variable --> argument to option 'cluster'; can only be specified with 'ttest'. Adjust t-test for clustering.
local clustervar  cluster

* Specify grouping variable --> argument to option 'groupvar', option used when need group statistics but no t-test; can be numeric or string 
local groupvar		

* Variables for which left indent is desired for labels in table
local indent_vars `vars'

* Specify type of respondents at bottom of table on row that shows no. of obs. It will read "Number of `respondents'". Default is "Observations".
local respondents 	individuals

* Positive integer. Sets format for values between 
local format 		2


*** Other options --> 'maketable' accepts all options accepted by 'estout'

* For categories in estout's 'refcat()' option
local categories gender2 "{\b Sociodemographics}" q112 "{\b Education}" q13 "{\b Employment}" q15_1 "{\b Motivations}" q16_a "{\b Vulnerabilities}"

* Specify local 'note' to override default note. 		
local note 		


*** Produce and export table to RTF document

maketable `vars', title(`title') backcolors(topfill(c4ed) nbtoprows(2) toptextbold) ttest(treatment) cluster(`clustervar') groupvar(`groupvar') refcat(`categories', nolabel) indentvars(`indent_vars') notesize(16) wrapnote
}


*** TABLE - Balance checks T2 vs C

*Select dataset
use "$DATA_PREPARED", clear

quietly{
tabulate gender, generate(gender) 
labvarch gender*, after(==)

tabulate refugee_status, generate(refugee_status) 
labvarch refugee_status*, after(==)

label var q14 "Has a stable job"

label var age "Age"

label var q11 "Level of education"
tabulate q11, generate(q11) 
labvarch q11*, after(==)

cap gen self_employed=0
replace self_employed=1 if q14==3
label var self_employed "Self-employed"

cap gen reg_emp=0
replace reg_emp=1 if q14==1
label var reg_emp "Regular employee"

cap label var q15_1 "Find a job in a business"
cap label var q15_2 "Start/develop a business"
cap label var q15_3 "Develop skills"

cap label var q16_a "Household"
cap label var q16_b "Mental health"
cap label var q16_c "Physical health"
cap label var q16_d "Chronic desease"
}

keep if treatment==0 | treatment==2 
replace treatment=1 if treatment==2
label define treatment2_lbl 0"Control" 1"Treatment2"
label values treatment treatment2_lbl


{
*** prepare variables
**generate dummies

*** Setup options for 'maketable' command

* Variables to summarize
local vars 		gender2 refugee_status2 age q112 q13 self_employed reg_emp q15_1 q15_2 q15_3 q16_a q16_b q16_c q16_d

* Short table title also used for RTF file name (cannot contain characters not accepted in Windows OS file names)
local title			"balance checks T2 vs C-full sample"

* Specify treatment variable --> argument to option 'ttest'; must be binary dummy variable coded 1 = Treatment and 0 = Control
local treatvar		treatment

* Specify cluster variable --> argument to option 'cluster'; can only be specified with 'ttest'. Adjust t-test for clustering.
local clustervar  cluster

* Specify grouping variable --> argument to option 'groupvar', option used when need group statistics but no t-test; can be numeric or string 
local groupvar		

* Variables for which left indent is desired for labels in table
local indent_vars `vars'

* Specify type of respondents at bottom of table on row that shows no. of obs. It will read "Number of `respondents'". Default is "Observations".
local respondents 	individuals

* Positive integer. Sets format for values between 
local format 		2


*** Other options --> 'maketable' accepts all options accepted by 'estout'

* For categories in estout's 'refcat()' option
local categories gender2 "{\b Sociodemographics}" q112 "{\b Education}" q13 "{\b Employment}" q15_1 "{\b Motivations}" q16_a "{\b Vulnerabilities}"

* Specify local 'note' to override default note. 		
local note 		


*** Produce and export table to RTF document

maketable `vars', title(`title') backcolors(topfill(c4ed) nbtoprows(2) toptextbold) ttest(treatment) cluster(`clustervar') groupvar(`groupvar') refcat(`categories', nolabel) indentvars(`indent_vars') notesize(16) wrapnote french
}

