
/*******************************************************************************
* Author: Thomas Eekhout (based on JG LORTA Guatemala)
* Date: June 2022
* Project: P20204i Uganda
* Topic: power calculations

*******************************************************************************/

*Select dataset
use "$BASELINE_DATA_COMPLETE", clear

* DIRECTORY TO SAVE TABLES
cd "$tablesRR22\Power calculations"



*We have baseline data and can estimate MDEs on stable employment
local x emp_stable
label var `x' "Stable employment"

/*
Based on monitoring data: 42% of the treatment group received the DIT
We estimate the MDES with the current sample (cohort 1 and cohort 2)
	Estimate the MDES for T1+T2
	Estimate the MDES for T1 or T2
We estimate the MDES with with a 3rd cohort (an increase of 30% of the sample)
	Estimate the MDES for T1+T2
	Estimate the MDES for T1 or T2

*/
tabulate gender, generate(gender) 
labvarch gender*, after(==)

global rate_fem= 0.61
global rate_ref=0.43



*T1+T2
global n_t = round(1086+1157)
disp $n_t

*T1 or T2 cohorts 1 and 2
global n_t1 = round(1157)
disp $n_t1

*T1+T2 female
global n_t_fem = round($n_t*$rate_fem)
disp $n_t_fem

*T1 or T2 female
global n_t1_fem = round($n_t1*$rate_fem)
disp $n_t1_fem

*T1+T2 Refugee
global n_t_ref = round($n_t*$rate_ref)
disp $n_t_ref

*T1 or T2 Refugee
global n_t1_ref = round($n_t1*$rate_ref)
disp $n_t1_ref


global n_c=1087


	foreach n_t in $n_t $n_t1 $n_t_fem $n_t1_fem $n_t_ref $n_t1_ref  {

		
if `n_t'==$n_t | `n_t'==$n_t1 {
	global n_c=1087
}

if `n_t'==$n_t_fem | `n_t'==$n_t1_fem {
	global n_c=610
}

if `n_t'==$n_t_fem | `n_t'==$n_t1_fem {
	global n_c=455
}

local rho 
		
preserve
mat drop _all

**Size of C at baseline. We want to double the size of the control group to ensure we have enough relevant matches
 	global n_c=`n_t'

**Total sample size needed at baseline
    global n = `n_t'+$n_c
	
	global attr1=0.00   // attrition between baseline and endline
	global attr2=0.0   // attrition of comparison obs due to matching


 *Sample size at endline
*	global m=$n*(1-$attr1)
	global m_t=round(`n_t'*(1-$attr1))
	global m_c=round($n_c*(1-$attr1)*(1-$attr2))
	global m=$m_t+$m_c

 * % of the study population is assigned to treatment and x% to control.
    global P = $m_t/$m

 *number of clusters
 *  global j =  80
	
 * number of obs per cluster at endline
 *	global nC=$m/$j
 

*** General Settings for power calculations ***
global alpha=0.05 // 
global power=0.8
global testtype  //leave blank for two-sided
cap drop x


* With data, we would use:
    sum `x' if treatment==1 | treatment==2
    global sd_t = round(`r(sd)',0.01)
    sum `x' if treatment==0
    global sd_c= round(`r(sd)',0.01)
	
    global m_control = round(`r(mean)',0.01) // mean of control group
	global lagvar=0 /// set 1 if there are controls 

disp $sd
disp $control

 *First, let's calculate the intra-cluster correlation (ICC) which measures how correlated the error terms of individuals in the same cluster are: in thsi case, it is not a cluster design so ICC=0
*  global rho
*  Let's assume 95% confidence intervals and 80% power...
* for MDE with simple design

	power twomeans $m_control, alpha($alpha) power($power) n($m) n1($m_t) sd1($sd_t) sd2($sd_c)

    global mde =r(delta)
    global mean_t =r(m2)

	global percent_change=$mde/$m_control

	
	matrix `x' = ($m_control, $sd_c, $n, `n_t', $n_c, $m, $m_t, $m_c,$attr1*100, $mde, $percent_change*100, $mean_t)
	//				1		   2	 3	   4	  5	   6	7	 8	    9		  10	  	 11		       	12		


		// output new matrix to excel
		svmat  `x', name(`x')
/*
		local lab: variable label `x' 
        	gen `x'_L=  "`lab'"
			gen `x'_N= "`x'"
			gen `x'_E="`x'"
*/
			local lab: variable label `x' 
			if "`n_t'"== "$n_t" {  // for each condition
        	gen `x'_L=  "Overall treatment"
			}
			
			if "`n_t'"== "$n_t1" {  // for each condition
        	gen `x'_L=  "T1 or T2"
			}
			
			if "`n_t'"== "$n_t_fem" {  // for each condition
        	gen `x'_L=  "Overall treatment (female)"
			}

			if "`n_t'"== "$n_t1_fem" {  // for each condition
        	gen `x'_L=  "T1 or T2 (female)"
			}
			
			if "`n_t'"== "$n_t_ref" {  // for each condition
        	gen `x'_L=  "Overall treatment (refugee)"
			}

			if "`n_t'"== "$n_t1_ref" {  // for each condition
        	gen `x'_L=  "T1 or T2 (refugee)"
			}
			
			gen `x'_N= "`x'"
			gen `x'_E="`x'"
		
		
		keep `x'*
		*cap drop `x' // added Kathi
		cap drop `x'_O // added Kathi
		keep in 1
		rename `x'1 Baseline_Mean
		rename `x'2 Baseline_SD
		rename `x'3 base_n
		rename `x'4 base_t
		rename `x'5 base_c
		rename `x'6 end_n
		rename `x'7 end_t
		rename `x'8 end_c 
		rename `x'9 attrition
		rename `x'10 MDE
		rename `x'11 percent_change
		rename `x'12 mean_endline
		rename `x'_L Scenario
		rename `x'_N Variable_baseline
		rename `x'_E Variable // in order to merge easily with tables in Appendix
		drop `x'
		
		replace Variable=subinstr("`x'","_DB","_DE",.)
		replace Variable=subinstr(Variable,"_B","_E",.)
		replace Variable=subinstr(Variable,"_SB","_SE",.)
		
		cap label var Baseline_Mean "Mean at baseline"
		cap label var Baseline_SD "SD at baseline"
		
		cap label var base_n "Sample size"
		cap label var base_t "Treatment group"
		cap label var base_c "Comparison group"
		
		cap label var end_n "Sample size"
		cap label var end_t "Treatment group"
		cap label var end_c "Comparison group"
		
		cap label var MDE "MDE (in units)"
		cap label var percent_change "% change"
		cap label var attrition "Attrition (in %)"
		
		cap label var mean_endline "Mean at endline for treatment group"
		
		
	
		if "`n_t'"== "$n_t" {  // for each condition
		tempfile `x'_1_1
		save "``x'_1_1'", replace
		}
		
		if "`n_t'"== "$n_t1" {
		tempfile `x'_1_2
		save "``x'_1_2'", replace
		}
		
		if "`n_t'"== "$n_t_fem" { 
		tempfile `x'_2_1
		save "``x'_2_1'", replace
		}
		
		if "`n_t'"== "$n_t1_fem" { 
		tempfile `x'_2_2
		save "``x'_2_2'", replace
		}
		
				if "`n_t'"== "$n_t_ref" { 
		tempfile `x'_3_1
		save "``x'_3_1'", replace
		}
		
				if "`n_t'"== "$n_t1_ref" { 
		tempfile `x'_3_2
		save "``x'_3_2'", replace
		}
				
		restore
	}

preserve
**** append the data-files
use "`emp_stable_1_1'", clear
append using `emp_stable_1_2'
append using `emp_stable_2_1'
append using `emp_stable_2_2'
append using `emp_stable_3_1'
append using `emp_stable_3_2'

 
order Scenario Baseline_Mean Baseline_SD base_n base_t base_c attrition end_n end_t end_c MDE percent_change mean_endline // MDE percent_change


drop  Variable_baseline Variable

cd "$tablesRR22\Power calculations"
export excel using "MDES_RR22.xls", sheet("Stata Output") firstrow(varlabels) keepcellfmt cell(A2) sheetmodify

restore