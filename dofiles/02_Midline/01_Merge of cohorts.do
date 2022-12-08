
/*******************************************************************************
* Author: Thomas Eekhout
* Date: December 2022
* Project: P20204i Uganda
* Topic: Cleaning and preparation of midline data

*******************************************************************************/

*Select dataset
use "$MIDLINE_RAW", clear



********************************************************************************
*						TREATMENT CHARACTERISTICS  							*
********************************************************************************





/********************************************************************************
						Background characteristics
********************************************************************************/
*Cleaning and labelling
*Age at midline
label var id2 "Age (based on midline questionnaire)"
rename id2 age_qx

encode age, gen(age_num)
drop age
rename age_num age_birth
label var age_birth "Age (based on birth date)"  // some errors probably due to entry errors in year of birth



*Gender
label var id3 "Gender"
rename id3 gender



*Nationality
rename a3 nationality
label var nationality "Nationality"

gen nationality2=.
replace nationality2=1 if nationality==1
replace nationality2=2 if nationality!=1 & !missing(nationality)
label define nation_lbl 1"Ugandan" 2"Non Ugandan"
label values nationality2 nation_lbl

*Residence
rename a4 residence

*Religion
rename a5 religion
replace religion=1 if religion==-96
label var religion "Religion"

*Education
rename a1a educ
replace educ=1 if educ==-96
label var educ "Level of education at baseline"

rename a1b educ_post
replace educ_post=1 if educ==-96
label var educ_post "Level of education at midline" //will not use this varialbe for causal analysis
order educ_post, after(educ)


*Marital status
label var a2 "Marital status"
rename a2 marital_status

gen marital_status2=0
replace marital_status2=1 if marital_status==1 | marital_status==2
replace marital_status2=. if !missing(marital_status2)
label define marital2_lbl 0"Not married" 1"Married"
label values marital_status2 marital2_lbl
label var marital_status2 "Marital status"
order marital_status2, after(marital_status)


*Members of household
rename a14 nb_hh
label var nb_hh "# of persons in household (including respondent)"

rename a9 nb_hh_inc
label var nb_hh_inc "# of persons in household that depend on respondent's income"
replace nb_hh_inc="0" if nb_hh_inc=="NONE"
replace nb_hh_inc="0" if nb_hh_inc=="O"
destring nb_hh_inc, replace

rename a25 nb_hh_15
label var nb_hh "# of persons in household above 15 years old"

*Household head
rename a15 hh_head
**# Bookmark #3
label var hh_head "Head of household" // Many missing obs!

*relation to head of household
**# Bookmark #4
rename a16 hh_head_relation 
label var hh_head_relation "Relation to head of household" // No obs!


*Professional experience
rename a10 pro_exp
label var pro_exp "Has professional experience (worked in exhcange of cash or in-kind)"




********************************************************************************
*                         		 EMPLOYABILITY								   *			
********************************************************************************

*JOB SEARCH

gen search_emp1=.
replace search_emp1=0 if d1==0
replace search_emp1=1 if d1==1 | d1==2 | d1==3
label var search_emp1 "Searched for employment in last 4 weeks"

gen search_emp2=.
replace search_emp2=0 if d1==0 | d1==2
replace search_emp2=1 if d1==1 | d1==3
label var search_emp2 "Searched for employment (non-self-employed) in last 4 weeks"

gen search_emp3=.
replace search_emp3=0 if d1==0 | d1==1
replace search_emp3=1 if d1==2 | d1==3
label var search_emp3 "Seeked to start a business in last 4 weeks"

label define bin_lbl 0 "No" 1"Yes"
label values search_emp? bin_lbl


*How searched for a job (non-self-employed)
foreach var of varlist  d3a-d3e{
clonevar `var'_clone=`var'
replace `var'_clone=0 if d1==0 | d1==2
}

label var d3a_clone "Read ads in newspapers/journals/magazines"
label var d3b_clone "Prepare/revise your CV"
label var d3d_clone "Talk to friends/relatives about possible job leads"
label var d3e_clone "Talk to previous employers/business acquaintances"
label var d3f_clone "Use Internet/radio/Social media"

rename d3a_clone search_newspaper
rename d3b_clone search_prepcv
rename d3d_clone search_friends
rename d3e_clone search_employer
rename d3f_clone search_internet


********************************************************************************
*                         		 EMPLOYMENT									   *			
********************************************************************************



*** there is a non-missing repeat section after b1 is no, this should not happen

* remove section for inconsistent b1 is the prefer
foreach var of varlist  job_name_1-b30_other_3{
cap replace `var'=. if b1==0
cap replace `var'="" if b1==0
}



/* vars generated


self_employed
reg_employee
fam_work
apprentice
casual_worker
other_worker

self_employed_sm
reg_employee_sm
fam_work_sm
apprentice_sm
casual_worker_sm
other_worker_sm

informal_sect_1? // ?=a,b,c
informal_sect_2? // ?=a,b,c
informal_sect_3? // ?=a,b,c
formal_sect

informal_employ_1
informal_employ_2
informal_employ_3
formal_employ

isic_simple

employed

*/
********************************************************************************
* EMPLOYMENT


*stable employment (excludes small jobs)
clonevar stable_job=b1
label var stable_job "Has a stable job"

*# of stable jobs
clonevar nb_stable_job=b2
replace  nb_stable_job=0 if stable_job==0
label var nb_stable_job "Number of stable jobs"

*Has more than one stable job
cap gen several_jobs= .
replace several_jobs=0 if stable_job==0
replace several_jobs=0 if stable_job==1
replace several_jobs=1 if nb_stable_job>1 & stable_job==1 
label var several_jobs ">1 stable job"


* Employment (Based on ILO definition)
gen employed=emp_ilo
label var employed "Has a job (last 7 days)"

/*
is considered as employed if respondent is:
b1a_1	A paid employee of someone who is not a member of your household
b1a_2	A paid worker on household farm or non-farm business enterprise
b1a_3	An employer
b1a_4	A worker non-agricultural own account worker, without employees
or
b1b has a permanent job but was absent in the past 7 days

b1a_5	Unpaid workers (e.g. Homemaker, working in non-farm family business)
b1a_6	Unpaid farmers
b1a_7	None of the above
*/

********************************************************************************


* EMPLOYMENT STATUS

{ // employment status of stable and small jobs

* In stable jobs

*Self-employed
cap gen self_employed= .
replace self_employed=0 if !missing(b1) 
replace self_employed=1 if b6_1==3 | b6_2==3 | b6_3==3
label values self_employed bin_lbl
label var self_employed "Self-employed in stable job"

*Employer
cap drop employer
gen employer= .
replace employer=0 if !missing(b1) 
replace employer=1 if b6_1==3 & b21_1>0 | b6_2==3 & b21_2>0 | b6_3==3 & b21_3>0
label values employer bin_lbl
label var employer "Employer in stable job"

*Own account worker
cap gen own_account= .
replace own_account=0 if !missing(b1) 
replace own_account=1 if employer==0 & b21_1==0 | employer==0 & b21_2==0 | employer==0 & b21_3==0
label values own_account bin_lbl
label var own_account "Own account in stable job"


*Regular employee
cap gen reg_employee= .
replace reg_employee=0 if !missing(b1) 
replace reg_employee=1 if b6_1==1 | b6_2==1 | b6_3==1
label values reg_employee bin_lbl
label var reg_employee "Regular employee in stable job"

*Regular family worker
gen fam_work= .
replace fam_work=0 if !missing(b1) 
replace fam_work=1 if b6_1==2 | b6_2==2 | b6_3==2
label values fam_work bin_lbl
label var fam_work "Regular family worker in stable job"

*apprentice (includes volunteers and interns)
gen apprentice= .
replace apprentice=0 if !missing(b1) 
replace apprentice=1 if (b6_1==4 | b6_2==4 | b6_3==4) | (b6_1==6 | b6_2==6 | b6_3==6)
label values apprentice bin_lbl
label var apprentice "Apprentice in stable job"

*Casual worker
gen casual_worker= .
replace casual_worker=0 if !missing(b1) 
replace casual_worker=1 if b6_1==5 | b6_2==5 | b6_3==5
label values casual_worker bin_lbl
label var casual_worker "Casual worker in stable job"

*Other type of worker
gen other_worker= .
replace other_worker=0 if !missing(b1) 
replace other_worker=1 if self_employed==0 & reg_employee==0 & fam_work==0 & apprentice==0 & casual_worker==0  & stable_job==1
label values other_worker bin_lbl
label var other_worker "Other employment in stable job"

*Other type of worker
gen other_emp_self= .
replace other_emp_self=0 if !missing(b1) 
replace other_emp_self=1 if fam_work==1 | apprentice==1 |casual_worker==1
label values other_emp_self bin_lbl
label var other_emp_self "Other employment status"

}

{
* VULNERABLE EMPLOYMENT

*ILO defines vulnerable employment as being contributing faimily worker ot being own account worker
*It remains debatable whether apprencie and casual workers can be considered as "non-vulnerable workers"...		   

*Vulnerable employment:

cap gen vul_emp= .
replace vul_emp=0 if !missing(b1)
replace vul_emp=1 if own_account==1 | fam_work==1
replace vul_emp=0 if employer==1 | reg_employee==1 | apprentice==1 | casual_worker | other_worker // we insert this line after as if at least job is considered "non vulenrable, the obs is considered "non-vulnerable".
replace vul_emp= . if b21_1==-98 & (b21_2==-98 | b21_2==.) & (b21_3==-98 | b21_3==.) //We do not know if these self-employed employ someone
label var vul_emp "Vulnerable employment in stable job"

}



********************************************************************************
* FORMALITY (only for those with "stable" job)								   

{
	 // FORMAL EMPLOYMENT
/* 2 concepts: informal sector and informal employment are distinct concepts, they are also complementary. 
// The informal economy encompasses both perspectives and is defined as all economic activities by workers and economic units that are - in law or in practice - not covered or insufficiently covered by formal arrangements. ---> https://www.ilo.org/global/topics/wages/minimum-wages/beneficiaries/WCMS_436492/lang--en/index.htm


**INFORMAL SECTOR
//ILO recommends using the following criteria to identify the informal sector:
*	size: less than 5 workers --> used for self-employed but we do not have the info for subordinated workers.
*	legal: is not registered --> used 
*	organizational: keeps standardized records --> Do not have question at the job level so cannot be used.
*	production: at least part of the production is oreinted to the market --> implicitly assumed

* In practice, there is isually a great overlap when using the different criteria. there wouldn't be significant changes

*Current definition: works in unregistered firm or is self-employed in a unregistered firm and has less than 5 workers (including respondent)
*/


*** INFORMAL SECTOR

foreach i of num 1/3{
    
*** no default
cap drop informal_sect_`i'a
gen informal_sect_`i'a= .
label var informal_sect_`i'a "Job `i' is in the informal sector [no default]"

// Identify jobs in in/formal sector based on registration
cap replace informal_sect_`i'a=0 if b12_1==1 & !missing(b3_`i')  //What does b3_i mean?
cap replace informal_sect_`i'a=0 if b20_1==1 & !missing(b3_`i')

// Identify jobs in in/formal sector based on number of workers
replace informal_sect_`i'a=0 if b6_`i'==3 & b21_`i'>=4 & !missing(b21_`i') & missing(informal_sect_`i'a) & !missing(b3_`i') // before it was set to informal for <4 and default was missing. But comment said default is informal, this does not change. This way we incorporate number of workers in the definition of formality, maybe threshold should change. 4 workers because with the respondent, number of workers=5

replace informal_sect_`i'a=1 if b6_`i'==3 & b21_`i'<4 & !missing(b21_`i')  & missing(informal_sect_`i'a) & !missing(b3_`i') //  4 workers because with the respondent, number of workers=5

// weaker info

cap replace informal_sect_`i'a=1 if b20_`i'==1 & missing(informal_sect_`i'a) & !missing(b3_`i')

**# Bookmark #2: What does .c and -b mean again?			 if .c=informal_sect_1==1 if .b=.
cap replace informal_sect_`i'a=1 if b12_`i'==.c & missing(informal_sect_`i'a) & !missing(b3_`i') // if you don't know if you're registered you are likely not


*** informal default
cap drop informal_sect_`i'b
clonevar informal_sect_`i'b= informal_sect_`i'a
label var informal_sect_`i'b "Job `i' is in the informal sector [informal default]"

//By default set as formal when has a job
replace informal_sect_`i'b=1 if !missing(b3_`i') & missing(informal_sect_`i'b)

*** formal default
cap drop informal_sect_`i'c
clonevar informal_sect_`i'c= informal_sect_`i'a
label var informal_sect_`i'c "Job `i' is in the informal sector [formal default]"

//By default set as formal when has a job
replace informal_sect_`i'c=0 if !missing(b3_`i') & missing(informal_sect_`i'c)

}

*Any formal sector
cap drop formal_sect
gen formal_sect= .
replace formal_sect=0 if !missing(b1)
replace formal_sect=1 if informal_sect_1a==0 | informal_sect_2a==0 | informal_sect_3a==0
label var formal_sect "Has a stable job in the formal sector"


*** INFORMAL EMPLOYMENT
//definition used in the Gambia: "Informal employment refers to those jobs that generally lack basic social or legal protections or employment benefits and may be found in informal sector, formal sector enterprises or households." 2018 Gambia LFS.  
* Curent definition: has an informal IGA or does not have a written contract in a registered firm.

*informal employment by job
foreach i of num 1/3{
cap drop informal_employ_`i'
gen informal_employ_`i'= .

* self employed
replace informal_employ_`i'=1 if b6_`i'==3 & informal_sect_`i'a==1
replace informal_employ_`i'=0 if b6_`i'==3 & informal_sect_`i'a==0 

* not self employed
replace informal_employ_`i'=1 if b6_`i'!=3 & b13_`i'==0 | b13_`i'==2 // informal if no or oral contract
replace informal_employ_`i'=0 if b6_`i'!=3 & b13_`i'==1 & informal_sect_`i'c==0 // note I use default formal for firm, as written contract already a burden

* if no contract info then base on sector
replace informal_employ_`i'=1 if b6_`i'!=3 & missing(informal_employ_`i') & informal_sect_`i'a==1  //if in informal sector and no info on contract, then assume he is in informal employment
* replace informal_employ_`i'=0 if b6_`i'!=3 & missing(informal_employ_`i') & informal_sect_`i'a==0 //if in formal sector and no info on contract, then assume he is in formal employment  --> I cancelled out this option as the assumption doesn't seem realistic to me. This said, for Tthis sample, it does not provoke any change.


* default informal 
replace informal_employ_`i'=1 if !missing(b6_`i') & missing(informal_employ_`i')
label var informal_employ_`i' "Job `i' is informal employment"
}


*Formal employment
cap drop formal_employ
gen formal_employ= .
replace formal_employ=0 if !missing(b1)
replace formal_employ=1 if informal_employ_1==0 | informal_employ_2==0 | informal_employ_3==0
label var formal_employ "Has a formal stable job"
}

//Wrap up:
*order variables created
order self_employed reg_employee fam_work apprentice casual_worker other_worker informal_sect_1? informal_sect_2? informal_sect_3? formal_sect informal_employ_1 informal_employ_2 informal_employ_3 formal_employ,  after (nb_stable_job)


********************************************************************************

/*
*Add  suffix to all variables
rename * *

save "$MIDLINE_PREPARED", replace