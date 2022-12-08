
use "$BASELINE_DATA_COMPLETE", clear

* DIRECTORY TO SAVE TABLES
cd "$tablesRR22\Monitoring"


//Keep obs who where enrolled
keep if enrolled_TSTT==1

encode vti, gen(vti_coded)
label define vti_coded_lbl 1"Ayilo" 2"Inde" 3"Nyumanzi" 4"Ocea" 5"Omugo"
rename vti vti_name
rename vti_coded vti
sort vti


global vti_name "Ayilo"
global vti_name "Inde"
*global vti_name "Nyumanzi"
*global vti_name "Ocea"
*global vti_name "Omugo"

if "$vti_name"=="Ayilo" {
global vti_num 1
}
if "$vti_name"=="Inde" {
global vti_num 2
}
if "$vti_name"=="Nyumanzi" {
global vti_num 3
}
if "$vti_name"=="Ocea" {
global vti_num 4
}
if "$vti_name"=="Omugo" {
global vti_num 5
}


keep if vti==$vti_num

local i = 0
foreach x of varlist day1_dec_2021-day105_mai_2022 {
local i = `i' + 1
egen attendance_rate_day`i'=mean(`x')
replace attendance_rate_day`i'=attendance_rate_day`i'*100

}

*order vti, after(attendance_rate_day105)
drop id_number-attendance_rate_obs

xpose, clear varname

keep v1
drop if v1== $vti_num | v1==0 | v1==. | v1==100
rename v1 attendance_rate_$vti_name
label var attendance_rate_$vti_name "Attendance rate $vti_name"
keep if attendance_rate_$vti_name !=.

generate training_day = _n
label var training_day "Day of training"

twoway (line attendance_rate_`vti' training_day, sort), ytitle(Attendance (in % of enrolled)) ylabel(0(20)100) xlabel(0(10)80)
*graph export "$tables\Monitoring\Attendance_rates_$vti_name.jpg", as(jpg) name("Graph") quality(100) replace


save "$ATTENDANCE_RATES\Attendance_rate_$vti_name.dta", replace



use "$ATTENDANCE_RATES\Attendance_rate_Ayilo", clear
merge 1:1 training_day using "$ATTENDANCE_RATES\Attendance_rate_Inde", gen (merge)
drop merge
merge 1:1 training_day using "$ATTENDANCE_RATES\Attendance_rate_Nyumanzi", gen (merge)
drop merge
merge 1:1 training_day using "$ATTENDANCE_RATES\Attendance_rate_Omugo", gen (merge)
drop merge
merge 1:1 training_day using "$ATTENDANCE_RATES\Attendance_rate_Ocea", gen (merge)
drop merge

rename attendance_rate_Ayilo Ayilo
label var Ayilo "Ayilo"
rename attendance_rate_Inde Inde
label var Inde "Inde"
rename attendance_rate_Nyumanzi Nyumanzi
label var Nyumanzi "Nyumanzi"
rename attendance_rate_Omugo Omugo
label var Omugo "Omugo"
rename attendance_rate_Ocea Ocea
label var Ocea "Ocea"

twoway (line Ayilo training_day, sort) (line Inde training_day) (line Nyumanzi training_day) (line Omugo training_day) (line Ocea training_day), ytitle(Attendance (in % of enrolled)) ylabel(10(10)100) xlabel(0(10)80)

*graph save "Graph" "$tables\Monitoring\Attendance_rates_all_VTIs.jpg", replace
graph export "Attendance_rates_all_VTIs.jpg", as(jpg) name("Graph") quality(100) replace

