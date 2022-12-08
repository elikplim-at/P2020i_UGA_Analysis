
clear 

/*******************************************************************************
						CLEANING OF TSTT ATTENDANCE DATA COHORT 1
*******************************************************************************/
/*
import excel "$ATTENDANCE_TSTT_RAW_EXCEL_C1", sheet("Clean NRC Data") cellrange(A1:FY612) firstrow clear
save "$ATTENDANCE_RAW_TSTT_DTA_C1", replace
*/

use "$ATTENDANCE_RAW_TSTT_DTA_C1", clear


rename RISEID id_number

duplicates tag id_number, gen(dup) // 6 duplicates. Seems like there are real duplicates but report they have followed different trainings and have different attendance data. Did they participate to difference trades?
drop if dup==1  // I just drop them for the moment
drop dup

drop p-BA
drop pbh CC FX CS CW CX DD DE
drop CP CQ
drop ndApril2022 rdApril2022 
drop EC ED EE EF
drop EK-EZ
drop thMay2022

order DK, after (Notes)

local i = 0
foreach x of varlist thDec2021Day1-rdDec2021Day1 {
local i = `i' + 1
rename `x' day`i'_dec_2021
}

foreach x of varlist thJan2022Day1-BQ {
local i = `i' + 1
rename `x' day`i'_jan_2022
}

foreach x of varlist stFeb2022Day1-CK {
local i = `i' + 1
rename `x' day`i'_feb_2022
}

foreach x of varlist stMarch2022Day1-stMarch2022 {
local i = `i' + 1
rename `x' day`i'_mar_2022
}

foreach x of varlist stApril2022-EJ {
local i = `i' + 1
rename `x' day`i'_apr_2022
}

foreach x of varlist FA-FW {
local i = `i' + 1
rename `x' day`i'_mai_2022
}

label define attend_lbl 0 "Absent" 1 "Present"
foreach x of varlist day1_dec_2021-day105_mai_2022 {
replace `x'="1" if `x'=="P"
replace `x'="1" if `x'=="p"
replace `x'="0" if `x'=="A"

encode `x', gen(`x'_num)
drop `x'
rename `x'_num `x'
label values `x' attend_lbl
replace `x'=`x'-1 //WHY DO I NEED TO DO THIS???!?!?!
}

label define binary_lbl 0 "No" 1 "Yes"
foreach x of varlist Enrolled TrainingProgrammeAttendance ReceivedDIT Replaced EnrolledFLES CompletedTraining  {
replace `x' = subinstr(`x', " ", "", .)  // remove spaces
replace `x' = upper(`x')
replace `x'="1" if `x'=="Yes"
replace `x'="0" if `x'=="No"
encode `x', gen(`x'_num)
drop `x'
rename `x'_num `x'
label values `x' binary_lbl
replace `x'=`x'-1 //WHY DO I NEED TO DO THIS???!?!?!

}

rename Enrolled enrolled_TSTT
label var enrolled_TSTT "Enrolled in TSTT"

rename Enrolled enrolled_FLES
label var enrolled_FLES "Enrolled in FLES"

rename TrainingProgrammeAttendance attendance_80
label var attendance_80 "Attended to >80% of TSTT training days"
 
rename ReceivedDIT DIT
label var DIT "Participated to the DIT assessment"

*gen DIT_received=


rename Replaced replaced
label var replaced "Was replaced"

rename CompletedTraining completed_training
label var completed_training "Completed the training"

rename TradeEnrolled trade_enrolled
label var trade_enrolled "Trade enrolled"

drop VTI-VillageBlock
drop Replacement // all "No"


foreach x of varlist trade_enrolled-completed_training {
rename `x' `x'_TSTT
}

tempfile tstt_attendance_c1
save `tstt_attendance_c1'

/****************
COHORT 2
****************/



/****************
COHORT 2
****************/


/****************
Appending tstt attendance data
****************/




tempfile tstt_attendance
save `tstt_attendance'

/*******************************************************************************
						CLEANING OF FLES ATTENDANCE DATA
*******************************************************************************/

/****************
COHORT 1
****************/

/*
import excel "$ATTENDANCE_FLES_RAW_EXCEL_C1", sheet("Intense FLES database") firstrow clear
save "$ATTENDANCE_RAW_FLES_DTA_C1", replace
*/

use "$ATTENDANCE_RAW_FLES_DTA_C1", clear

drop SN VTI Name TradeAssigned Gender Residence_status Ageofrespondent Maritalstatus

rename RISEID id_number

rename Identification_no identifcation_no
rename Tel1 tel1
rename Tel2 tel2
rename District district
rename SubCounty subcounty
rename Parish parish
rename VillageBlock village_block
rename villageWhichvillageorblockisyou village_block_residence
rename TradeEnrolled trade_enrolled
rename TelephoneNumber1 tel_3
rename Mothersname name_mother
rename StartofFLESdate start
rename Endofflesdate end
rename NameofFLEStrainer name_trainer
rename ContactofFLEStrainer tel_trainer
rename FLESAttendanceScore attendance_rate
rename DateofPretrainingevaluation date_pre_evaluation
rename FLESPretrainingevaluationSco score_pre_evaluation
rename FLESendoftrainingevalations score_post_evaluation
rename agechangeintrainingassessme score_evaluation_diff

foreach x of varlist identifcation_no-score_evaluation_diff {
rename `x' `x'_FLES
}

duplicates tag id_number, gen(dup)
drop if dup==3
drop dup

tempfile fles_attendance_c1
save `fles_attendance_c1'

/****************
COHORT 2
****************/



/****************
COHORT 2
****************/






/****************
Appending fles attendance data
****************/




tempfile fles_attendance
save `fles_attendance'


/*******************************************************************************
						MERGE OF TSTT ATTENDANCE WITH FLES ATTENDANCE COHORT 1
*******************************************************************************/

use "`tstt_attendance'", clear
merge 1:1 id_number using "`fles_attendance'", gen (merge_monitoring)
label define merge_monitoring_lbl  1 "In TSTT only" 2"in FLES only" 3"In both attendance datasets"
label values merge_monitoring merge_monitoring_lbl

save "$ATTENDANCE_CLEAN", replace



/*******************************************************************************
						MERGE OF BASELINE WITH CLEANED ATTENDANCE DATA COHORT 1
*******************************************************************************/


use "$BASELINE_DATA", clear
merge 1:1 id_number using "$ATTENDANCE_CLEAN", gen (merge)
label define merge_lbl  1 "In Baseline only" 2"Attendance only" 3"In baseline & attendance"
label values merge merge_lbl





/*******************************************************************************
						MERGE OF BASELINE WITH CLEANED ATTENDANCE DATA COHORT 2
*******************************************************************************/





/*******************************************************************************
						MERGE OF BASELINE WITH CLEANED ATTENDANCE DATA COHORT 3
*******************************************************************************/

replace enrolled_TSTT=0 if enrolled_TSTT==. & treatment==1 & cohort=="1"
replace enrolled_TSTT=0 if enrolled_TSTT==. & treatment==2 & cohort=="1"
replace enrolled_FLES=0 if enrolled_FLES==. & treatment==2 & cohort=="1"


replace enrolled_TSTT=. if cohort=="2"
encode cohort, gen(cohort_num) label(Cohort)
drop cohort
rename cohort_num cohort

// Attendance rate for each person enrolled
egen attendance_rate_obs=rmean(day1_dec_2021-day105_mai_2022)  


save "$BASELINE_DATA_COMPLETE", replace
