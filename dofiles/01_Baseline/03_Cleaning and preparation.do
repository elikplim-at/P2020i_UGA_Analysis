
/*******************************************************************************
* Author: Thomas Eekhout
* Date: September 2022
* Project: P20204i Uganda
* Topic: Cleaning and preparation

*******************************************************************************/

*Select dataset
use "$BASELINE_DATA_COMPLETE", clear

*Treatment
rename treatment1 treatment


*Trades
replace trade_assigned=9 if trade_assigned==14

cap drop strata
bysort vti trade_assigned gender: generate strata = _N
cap drop cluster
egen cluster = group(strata)
label var cluster "Clusters (vti-trade-gender)"



*Education
rename educ_level educ
replace educ=0 if educ==-96
replace educ=3 if educ==4
replace educ=0 if educ==5
label define educ_lbl 0"No formal education" 1"Primary" 2"Secondary" 3"Tertiary"
label values educ educ_lbl

*School dropout
replace sch_dropout=. if sch_dropout==-555 | sch_dropout==96

*Age
drop age
rename current_age age
label var age "Age (as of april 7th 2022)"
*We have observation below 18 in cohort 2 - for the moment we remove the info and will check at midline
replace age=. if age<18


*Marital status
gen married=marital_status
replace married=0 if marital_status==2 | marital_status==3 | marital_status==4 | marital_status==-96
replace married=1 if marital_status==1
label define married_lbl 0"Not married" 1"Married"
label values married married_lbl

*Stable employment
label var emp_stable "Has a stable job (worked for >1 month in the last 6 months)"


*Employmnet status
label var emp_status "Employment status"
*Many report having an emploment status without having a stable job. We assume this is because they misread the condition in the form and consider that if no stable employment, emp_status ==.
replace emp_status=. if missing(emp_stable) //we still have 13 missing...


*Motivation
rename reason_course motivation
replace motivation=0 if motivation==-555
replace motivation=0 if motivation==.
label define motivation_lbl 0"No response" 1"Find a job in a business" 2"Start or develop a business" 3"Develop skills without concrete ambitions" 
label values motivation motivation_lbl

*Vulnerabilities
rename vulnerabilities_hh vul_hh
rename vulnerabilities_mhv vul_mh 
rename vulnerabilities_phv vul_ph 
rename vulnerabilities_cdc vul_cd

cap label var vul_hh "Household"
cap label var vul_mh "Mental health"
cap label var vul_ph "Physical health"
cap label var vul_cd "Chronic desease"

gen vul=0
replace vul=1 if vul_hh==1 | vul_mh==1 |vul_ph==1 | vul_cd==1
label define bin_lbl 0"No" 1"Yes"
label values vul bin_lbl
label var vul "Has at least 1 vulnerability"

egen num_vul=rowtotal(vul_hh vul_mh vul_ph vul_cd)
label var num_vul "# of vulnerabilities"



save "$DATA_PREPARED", replace