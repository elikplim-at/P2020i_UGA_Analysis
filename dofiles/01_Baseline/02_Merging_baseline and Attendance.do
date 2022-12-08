
clear 

/*******************************************************************************
						CLEANING OF TSTT ATTENDANCE DATA COHORT 1
*******************************************************************************/
/*
import excel "$ATTENDANCE_TSTT_RAW_EXCEL_C1", sheet("Clean NRC Data") cellrange(A1:FY612) firstrow clear
save "$ATTENDANCE_RAW_TSTT_DTA_C1", replace
*/

use "$ATTENDANCE_DTA_C1", clear


rename RISEID id_number

duplicates tag id_number, gen(dup) // 6 duplicates. Seems like there are real duplicates but report they have followed different trainings and have different attendance data. Did they participate to difference trades?
drop if dup==1  // I just drop them for the moment
drop dup

*Drop variables with only missing data 
dropmiss, force

order DL, after (Notes)

local i = 0
foreach x of varlist thDec2021Day1-rdDec2021Day1 {
local i = `i' + 1
rename `x' day`i'_dec_2021
}

foreach x of varlist thJan2022Day1-BR {
local i = `i' + 1
rename `x' day`i'_jan_2022
}

foreach x of varlist stFeb2022Day1-CL {
local i = `i' + 1
rename `x' day`i'_feb_2022
}

foreach x of varlist stMarch2022Day1-stMarch2022 {
local i = `i' + 1
rename `x' day`i'_mar_2022
}

foreach x of varlist stApril2022-EK {
local i = `i' + 1
rename `x' day`i'_apr_2022
}

foreach x of varlist FB-FX {
local i = `i' + 1
rename `x' day`i'_mai_2022
}

label define attend_lbl 0 "Absent" 1 "Present"
foreach x of varlist day1_dec_2021-day106_mai_2022 {
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
foreach x of varlist Enrolled TrainingProgrammeAttendance ReceivedDIT Replaced EnrolledFLES CompletedTraining {
replace `x' = subinstr(`x', " ", "", .)  // remove spaces
replace `x' = upper(`x')
replace `x'="1" if `x'=="YES"
replace `x'="0" if `x'=="NO"
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

rename DITResult DIT_res
label var DIT_res "Received DIT"
encode DIT_res, gen(DIT_res_num)
drop DIT_res
rename DIT_res_num DIT_res
order DIT_res, after(DIT)

rename Replaced replaced
label var replaced "Was replaced"

rename CompletedTraining completed_FLES
label var completed_FLES "Completed FLES training"

rename TradeEnrolled trade_enrolled
label var trade_enrolled "Trade enrolled"

rename Totaldaysattended attendance_days



drop Name-SelectedforFLES Gender-VillageBlock
drop if id_number==""

gen cohort=1

tempfile attendance_c1
save `attendance_c1'

/****************
COHORT 2
****************/

/*
import excel "$ATTENDANCE_EXCEL_C2", sheet("Cleaned_DIT_FLES") cellrange(A1:FY612) firstrow clear
save "$ATTENDANCE_DTA_C2", replace
*/

use "$ATTENDANCE_DTA_C2", clear


rename RISEID id_number

duplicates tag id_number, gen(dup) 
drop dup

*Drop variables with only missing data 
dropmiss, force

drop Selected_FLES

label define binary_lbl 0 "No" 1 "Yes"
foreach x of varlist Enrolled Reg_DIT ReceivedDIT Attended_FLES CompletedFLES {
replace `x' = subinstr(`x', " ", "", .)  // remove spaces
replace `x' = upper(`x')
replace `x'="1" if `x'=="YES"
replace `x'="0" if `x'=="NO"


encode `x', gen(`x'_num)
drop `x'
rename `x'_num `x'
label values `x' binary_lbl
}

foreach x of varlist Attended_FLES CompletedFLES {
replace `x'=`x'-1 //WHY DO I NEED TO DO THIS???!?!?!
}

rename Enrolled enrolled_TSTT
label var enrolled_TSTT "Enrolled in TSTT"

rename Attended_FLES enrolled_FLES
label var enrolled_FLES "Enrolled in FLES"

gen attendance_80= .
replace attendance_80=1 if Percentage>=0.8 & !missing(Percentage)
replace attendance_80=0 if Percentage<0.8 & !missing(Percentage)
label var attendance_80 "Attended to >80% of TSTT training days"
label values attendance_80 binary_lbl


rename Percentage attendance_rate
replace attendance_rate=attendance_rate*100
label var attendance_rate "% of days present of the training days"

rename TrainingProgrammeAttendance attendance_days
label var attendance_days "# of days present of the training days"

gen training_days=attendance_days*100/attendance_rate

rename ReceivedDIT DIT
label var DIT "Participated to the DIT assessment"

/* INFORMATION NOT YET AVAILABLE
rename DITResult DIT_res
label var DIT_res "Received DIT"
encode DIT_res, gen(DIT_res_num)
drop DIT_res
rename DIT_res_num DIT_res
*/

/* No info
rename Replaced replaced
label var replaced "Was replaced"
*/

rename CompletedFLES completed_FLES
label var completed_FLES "Completed FLES training"

rename TradeEnrolled trade_enrolled
label var trade_enrolled "Trade enrolled"

drop Name-SelectedforFLES Gender-VillageBlock


gen cohort=2

tempfile attendance_c2
save `attendance_c2'

/****************
COHORT 3
****************/




/****************
Appending attendance datasets
****************/

use "`attendance_c1'", clear
append using `attendance_c2'

tempfile attendance
save `attendance'

/*******************************************************************************
						CLEANING OF FLES ATTENDANCE DATA
*******************************************************************************/

/****************
COHORT 1
****************/

/*
import excel "$ATTENDANCE_FLES_RAW_EXCEL_C1", sheet("Intense FLES database") firstrow clear
save "$ATTENDANCE_RAW_FLES_DTA_C1", replace


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

*/

/*******************************************************************************
						ATTEANDANCE CLEANING
*******************************************************************************/
use "`attendance'", clear


*Get number of training days
	*We use training days from cohort 2 and insert the same number of days for cohort 1
encode VTI, gen(vti_num)
xfill training_days, i(vti_num)
drop vti_num
	*No info on OMUGO as no obs from Cohort 2 in OMUGO. From attendance info, seems like there was 72 days
replace training_days=72 if VTI=="OMUGO"


*Get days rates of attendance in cohort 1
replace attendance_rate=attendance_days/training_days*100 if cohort==1

	
foreach var of varlist day1_dec_2021-day106_mai_2022 {
	clonevar `var'_bis=`var'
	replace `var'_bis=1 if `var'_bis==0
}
	egen attendance_days_bis= rowtotal(day1_dec_2021_bis-day106_mai_2022_bis)

*4 obs that attended to the TSTT but are considered as not enrolled_FLES
replace enrolled_TSTT=1 if attendance_rate>0 & !missing(attendance_rate) & enrolled_TSTT==0
	
	

drop VTI TradeAssigned trade_enrolled Replacement cohort

save "$ATTENDANCE_CLEAN", replace



/*******************************************************************************
						MERGE OF BASELINE WITH CLEANED ATTENDANCE DATA
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

replace enrolled_TSTT=0 if enrolled_TSTT==. & treatment==1
replace enrolled_TSTT=0 if enrolled_TSTT==. & treatment==2
replace enrolled_TSTT=0 if enrolled_TSTT==. & treatment==99


replace enrolled_FLES=0 if enrolled_FLES==. & treatment==2
replace enrolled_FLES=0 if enrolled_FLES==. & treatment==2
replace enrolled_FLES=0 if enrolled_TSTT==. & treatment==99


replace enrolled_TSTT=. if cohort=="2"
encode cohort, gen(cohort_num) label(Cohort)
drop cohort
rename cohort_num cohort

// Attendance rate for each person enrolled
egen attendance_rate_obs=rmean(day1_dec_2021-day105_mai_2022)  


save "$BASELINE_DATA_COMPLETE", replace
