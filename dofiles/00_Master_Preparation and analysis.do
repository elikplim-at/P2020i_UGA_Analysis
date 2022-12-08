/*
Project: EUTF Uganda
Dofile: Preparation of data and analysis
Author: Thomas Eekhout
Date: July 2022
*/

clear


quietly{
clear all

// General Globals
global ONEDRIVE "C:\Users\/`c(username)'\C4ED"

if "`c(username)'"=="ThomasEekhout" | "`c(username)'"=="NathanSivewright" {
global P20204i "$ONEDRIVE\P20204i_EUTF_UGA - Documents" 
}
else{
global P20204i "$ONEDRIVE\P20204i_EUTF_UGA - Dokumente"
}

global ANALYSIS "$P20204i\02_Analysis"
global version = 1
global date = string(date("`c(current_date)'","DMY"),"%tdNNDD")
global time = string(clock("`c(current_time)'","hms"),"%tcHHMMSS")
global datetime = "$date"+"$time"
global dofiles "$ANALYSIS\01_DoFiles\Data Preparation and Analysis"
global encrypted_drive "H"
global encrypted_path "$encrypted_drive:"
global project_folder "$ONEDRIVE\$folder\02_Analysis" 
global tables "$ANALYSIS\03_Tables_Graphs"
global tablesRR22 "$tables\01_Research Report 2022"

//Datasets globals


global BASELINE_DATA "$encrypted_path\Baseline\Complete_bl\complete_bl.dta"

**Cohort 1
global ATTENDANCE_EXCEL_C1 "$encrypted_path\Monitoring\Database From GIZ\01_Attendance data_c1.xlsx"
global ATTENDANCE_DTA_C1 "$encrypted_path\Monitoring\01_Attendance data_c1.dta"

**Cohort 2
global ATTENDANCE_EXCEL_C2 "$encrypted_path\Monitoring\Database From GIZ\02_Attendance data_c2.xlsx"
global ATTENDANCE_DTA_C2 "$encrypted_path\Monitoring\Database From GIZ\02_Attendance data_c2.dta"



global ATTENDANCE_CLEAN "$encrypted_path\Monitoring\10_Attendance data_cleaned.dta"
global BASELINE_DATA_COMPLETE "$encrypted_path\Baseline\Complete_bl\Baseline_attendance_cleaned.dta"
global DATA_PREPARED "$encrypted_path\Baseline\Complete_bl\Baseline_prepared_for_analysis.dta"
global ATTENDANCE_RATES "$encrypted_path\Monitoring"


*MIDLINE DATA
global MIDLINE_RAW "$ANALYSIS\02_Data\Midline\C1\Youth\RISE_MIDLINE_1_NoPII.dta"
global MIDLINE_PREPARED "$ANALYSIS\02_Data\02_midline_prepared.dta"

//Load maketable command programme 
cd "$dofiles"
do "99_maketable_PROGRAM.do"
cd "$dofiles"
}

/********************************************************************************
							Baseline and monitoring data preparation
********************************************************************************/
do "01_Baseline\01_Decryption.do"
cd "$dofiles"
do "01_Baseline\02_Merging_baseline and Attendance.do"
cd "$dofiles"
do "01_Baseline\03_Cleaning and preparation.do" // Need to save prepared data without PIIs in "$Analysis\02_Data\01_Baseline_prepared.dta"
cd "$dofiles"

/********************************************************************************
							Midline data preparation 
********************************************************************************/

do "02_Midline\01_Cleaning and preparation"


/********************************************************************************
							Endline data preparation 
********************************************************************************/


/********************************************************************************
							Data analysis
********************************************************************************/

/*
do "1.1_Power calculations_WIP.do"
cd "$dofiles"
do "1.2_Balance_checks_WIP.do"
cd "$dofiles"
/*
do "1.3_Attendance rates.do"
*/
