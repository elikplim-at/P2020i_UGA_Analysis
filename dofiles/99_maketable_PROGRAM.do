version 16

* Marc Gillaizeau, 4 August 2021
* v5


********************************************************************************
***								maketable								     ***
********************************************************************************


*** PROGRAM to produce tables

cap prog drop maketable
prog define maketable, eclass

	version 16

	syntax varlist [if] [in], title(string asis) [filename(string) single obslabel(string asis) indentvars(varlist) font(string asis) fontsize(numlist max=1 >=2 integer) notesize(numlist max=1 >=2 integer) groupvar(varlist max=1) ttest(varlist max=1) cluster(varlist max=1) percent(string asis) fullsample(string asis) format(numlist min=1 >=0 integer) smartformat(numlist min=1 max=5 >=0 integer) backcolors(string asis) ci se meansonly addobs rmvtitle french wrapnote whiteborders *]

** Syntax of 'backcolors()' option (see HELP file):

* backcolors(topfill(color) toptextcolor(color) tablefill(RGB_color) nbtoprows(integer) toptextcolortext)


********************************************************************************
	
						*** ERROR MESSAGES ***			

{
	
	* ERROR --> 'filename' must be specified with 'single'
	if (`"`single'"'!="" & `"`filename'"'=="") {
		di as error "WRONG OPTIONS IN 'maketable': Must specify 'filename()' with option 'single'."
		error 197
		}
	
			
	* ERROR --> need one of 'ci' or 'se'. Not both at same time.
	if (`"`ci'"'!="" & `"`se'"'!="") {
		di as error "CONFLICTING OPTIONS IN 'maketable': Cannot specify both 'ci' and 'se' at the same time."
		error 197
		}
	
	
	* ERROR --> cannot specify 'meansonly' with 'ttest'
	if (`"`meansonly'"'!="" & `"`ttest'"'!="") {
		di as error "CONFLICTING OPTIONS IN 'maketable': Cannot specify 'meansonly' and 'ttest' at teh same time."
		error 197
		}
	
	
	* ERROR --> cannot specify 'ttest' if 'groupvar' is specified.
	if (`"`ttest'"'!="" & `"`groupvar'"'!="") {
		di as error "WRONG OPTIONS IN 'maketable': Cannot specify 'ttest' with 'groupvar'."
		error 197
		}
		

	* ERROR --> cannot specify 'cluster' if 'ttest' is not specified.
	if (`"`ttest'"'=="" & `"`cluster'"'!="") {
		di as error "WRONG OPTIONS IN 'maketable': Cannot specify 'cluster' without 'ttest'."
		error 197
		}

		
	* ERROR --> check grouping variable
	if (`"`groupvar'"'!="") {
		* Check if grouping variable  not empty
		qui count if missing(`groupvar')
		if `=scalar(r(N))' == `c(N)' {
			di as error "ERROR IN 'groupvar' OPTION: grouping variable `groupvar' is empty."
			error 197
			}
			
		else {		
			* Check if grouping variable is numeric and has value label
			if strpos("`: type `groupvar''", "str")>0 {
				di as error "NOTE: grouping variable `groupvar' is a string variable."
				}
			else {
				local haslab: value label `groupvar'
				if "`haslab'"=="" {
					di as error "WARNING: grouping variable `groupvar' has no value labels. Columns will be named Group 1, Group 2, etc. To change the column names, assign value labels to `groupvar'."
					}
				}
			}
		}

		
	* ERROR --> check that treatment variable is coded 0/1
	if (`"`ttest'"'!="") {
		* Check if treatment variable  not empty
		qui count if missing(`ttest')
		if `=scalar(r(N))' == `c(N)' {
			di as error "ERROR IN 'ttest' OPTION: treatment variable `ttest' is empty."
			error 197
			}
			
		else {
		
			* Check if really dummy variable
			qui unique `ttest' if !missing(`ttest')
			local unique = r(unique)
			if `unique'>2 {
				di as error "ERROR IN 'ttest' OPTION: treatment variable `ttest' has more than 2 categories."
				error 197
				}
			else {
				qui sum `ttest'
				if (`unique'==2 & (r(min)!=0 | r(max)!=1)) {
					di as error "ERROR IN 'ttest' OPTION: treatment variable `ttest' must be coded as 0/1."
					error 197
					}
				else if `unique'==1 {
					di as error "ERROR IN 'ttest' OPTION: treatment variable `ttest' has only 1 group."
					error 197
					}
				}
			}
		}
		
		
	* ERROR --> if option 'percent' is specified, must specifiy argument 'sign' or 'nosign'.
	if (`"`percent'"'!="sign" & `"`percent'"'!="nosign" & `"`percent'"'!="") {
		di as error "WRONG ARGUMENT IN OPTION 'percent': Must specifiy 'percent(sign)' or 'percent(nosign)'"
		error 197
		}
	
	
	* ERROR --> if option 'fullsample' is specified, must specifiy argument 'none', 'first' or 'last'.
	if (`"`fullsample'"'!="none" & `"`fullsample'"'!="first" & `"`fullsample'"'!="last" & `"`fullsample'"'!="") {
		di as error "WRONG ARGUMENT IN OPTION 'fullsample': Must specifiy 'fullsample(none)' or 'fullsample(first)' or 'fullsample(last)'."
		error 197
		}
	if (`"`fullsample'"'=="last" & `"`ttest'"'!="") {
		di as error "WARNING in OPTION 'fullsample': Cannot specifiy 'fullsample(last)' with 'ttest'. Option ignored."
		}
	if (`"`fullsample'"'=="none" & `"`ttest'"'=="" & `"`groupvar'"'=="") {
		di as error "WARNING in OPTION 'fullsample': Need one of 'ttest' or 'groupvar' to specify 'fullsample(none)'. Option ignored."
		}
	
	
	* ERROR --> formatting options
	if (`"`format'"'!="" & `"`smartformat'"'!="") {
		di as error "WRONG 'format' OPTIONS: Cannot specifiy 'format' and 'smartformat' at the same time."
		error 197
		}

	
	* ERROR --> backcolors: can be either 'c4ed', 'lorta' or new color specified as R G B, e.g. backcolors(4 123 119).
	if (`"`backcolors'"'!="") {
		parse_backcolors_option, `backcolors'
		
		* Background color --> top row(s)
		if `"`s(topfill)'"'!="" {
			tokenize `"`s(topfill)'"'
			if "`4'"!="" {
				di as error "WRONG 'backcolors' OPTION: Too many arguments in topfill()."
				error 197
				}
			else if ("`3'"=="" & "`2'"!="") | ("`2'"=="" & "`1'"!="" & `"`1'"'!="c4ed" & `"`1'"'!="lorta") {	
				di as error "WRONG 'backcolors' OPTION: Wrong arguments in topfill(). Must specify 1 string argument (c4ed or lorta) or 3 numeric arguments (new color)."
				error 197
				}
			else if "`3'"!="" {
				if (real("`1'")==. | real("`2'")==. | real("`3'")==.) {
					di as error "WRONG 'backcolors' OPTION: New color in topfill() must be specified by numbers as Red Green Blue, each number must be between 0 and 255."
					error 197
					}
				else {	
					if (`1'<0 | `1'>255) | (`2'<0 | `2'>255) | (`3'<0 | `3'>255) {
						di as error "WRONG 'backcolors' OPTION: New color in topfill() specified as Red Green Blue, each number must be between 0 and 255."
						error 197
						}
					if (`1' - floor(`1') != 0 | `2' - floor(`2') != 0 | `3' - floor(`3') != 0) {
						di as error "WRONG 'backcolors' OPTION: Numbers to specify new color in topfill() must be integer."
						error 197
						}
					}
				}
			}
			
		* Background color --> rest of table row(s)
		if `"`tablefill'"'!="" {
			tokenize `"`s(tablefill)'"'
			if "`4'"!="" {
				di as error "WRONG 'backcolors' OPTION: Too many arguments in tablefill()."
				error 197
				}
				
			else if ("`3'"=="") {	
				di as error "WRONG 'backcolors' OPTION: Missing arguments in tablefill(). Must specify 3 numeric arguments. i.e. color as RGB."
				error 197
				}
			else if "`3'"!="" {
				if (real("`1'")==. | real("`2'")==. | real("`3'")==.) {
					di as error "WRONG 'backcolors' OPTION: New color in tablefill() must be specified by numbers as Red Green Blue, each number must be between 0 and 255."
					error 197
					}
				else {	
					if (`1'<0 | `1'>255) | (`2'<0 | `2'>255) | (`3'<0 | `3'>255) {
						di as error "WRONG 'backcolors' OPTION: New color in tablefill() specified as Red Green Blue, each number must be between 0 and 255."
						error 197
						}
					if (`1' - floor(`1') != 0 | `2' - floor(`2') != 0 | `3' - floor(`3') != 0) {
						di as error "WRONG 'backcolors' OPTION: In tablefill(), numbers to specify new color must be integer."
						error 197
						}
					}
				}
			}
		
		* Text color
		if `"`s(toptextcolor)'"'!="" {
			tokenize `"`s(toptextcolor)'"'
			if "`4'"!="" {
				di as error "WRONG 'backcolors' OPTION: Too many arguments in toptextcolor()."
				error 197
				}
			else if ("`3'"=="" & "`2'"!="") | ("`2'"=="" & "`1'"!="" & `"`1'"'!="black" & `"`1'"'!="white") {	
				di as error "WRONG 'backcolors' OPTION: Wrong arguments in toptextcolor(). Must specify 1 string argument (black or white) or 3 numeric arguments (new color)."
				error 197
				}
			else if "`3'"!="" {
				if (real("`1'")==. | real("`2'")==. | real("`3'")==.) {
					di as error "WRONG 'backcolors' OPTION: New color in toptextcolor() must be specified by numbers as Red Green Blue, each number must be between 0 and 255."
					error 197
					}
				else {	
					if (`1'<0 | `1'>255) | (`2'<0 | `2'>255) | (`3'<0 | `3'>255) {
						di as error "WRONG 'backcolors' OPTION: New color in toptextcolor() specified as Red Green Blue, each number must be between 0 and 255."
						error 197
						}
					if (`1' - floor(`1') != 0 | `2' - floor(`2') != 0 | `3' - floor(`3') != 0) {
						di as error "WRONG 'backcolors' OPTION: Numbers to specify new color in toptextcolor() must be integer."
						error 197
						}
					}
				}
			}
			
		* Number of rows
		if `"`s(nbtoprows)'"'!="" & {
		    if `s(nbtoprows)' < 0 {
				di as error "WRONG 'backcolors' OPTION: Cannot specify negative number of rows in nbtoprows()."
				error 197
				}
			}
			
		}
	
}	
********************************************************************************

quietly {
	
**********************

	
	* Clear estimates in memory	
	eststo clear
	
	* Increment counter for automatic table numbering
	global tablenum = $tablenum + 1

	
**********************

	
* OPTION 'indentvars': add indent (i.e. 2 blank spaces) to specified variables through varlabels(, blist()) option in esttab
	if `"`indentvars'"'!="" {
		local varlabels `"varlabels(, blist(`=subinstr(`"`indentvars'"', " ", `" "  " "', .)' "  "))"'
		}
	else local varlabels


* OPTIONS 'font' and 'fontsize': set defaults values if not specified
	if `"`font'"'=="" {
		local font "Cambria"
		}
	if `"`fontsize'"'=="" {
		local fontsize 20
		}
	

	* OPTION 'backcolors': backgound color for top row. Argument can be 'c4ed', 'lorta' or 3 numbers separated by a space to specify other color as Red Green Blue.
	* CAREFUL --> take into account background color of table
	* Parse option
	if `"`backcolors'"'!="" {
		parse_backcolors_option, `backcolors'
		
		local topfill `s(topfill)'
		local toptextcolor `s(toptextcolor)'
		local boldtext `s(boldtext)'
		local nbtoprows `s(nbtoprows)'
		local tablefill `s(tablefill)'
		
		* Process TOP ROW background color
		* if 1 argument
		if `"`topfill'"'!="" {
			if `"`topfill'"'=="c4ed" local cftopfill 2
			else if `"`topfill'"'=="lorta" local cftopfill 3
			* If new color
			else {
				tokenize `"`topfill'"'
				local newcolor "\red`1'\green`2'\blue`3';"
				local cftopfill 4
				}
			}
		
		* Process TABLE background color
		if `"`tablefill'"'!="" {	
			tokenize `"`tablefill'"'
			local newcolor "`newcolor'\red`1'\green`2'\blue`3';"
			if "`cftopfill'"=="4" local cftablefill 5
			else local cftablefill 4
			}
		
		
		* Process text color
		* if 1 argument
		if `"`toptextcolor'"'!="" {
			if `"`toptextcolor'"'=="black" local cftext 0
			else if `"`toptextcolor'"'=="white" local cftext 1
			* If new color
			else {
				tokenize `"`toptextcolor'"'
				local newcolor "`newcolor'\red`1'\green`2'\blue`3';"
				* Depends whether new color for background or not
				if "`cftablefill'"=="5" local cftext 6
				else if ("`cftablefill'"=="4" | "`cftopfill'"=="4") local cftext 5 
				else local cftext 4
				}
			}
		* If textcolor() is missing but toprow() not missing --> default = white if backcolor specified
		else {
			if `"`topfill'"'=="c4ed" | `"`topfill'"'=="lorta" local cftext 1
			else local cftext 0
			}
		
		* Bold text
		if "`toptextbold'"!="" local boldtext "\b"
		else local boldtext

		* Number of rows
		if "`nbtoprows'"!="" local nbtoprows "`nbtoprows'"
		else local nbtoprows 1
		}
	
	* If backcolors() is missing --> default text color = black + not bold
	else {
		local cftext 0
		local boldtext
		}
		

* OPTION 'single': create output file on first iteration add new page after table, so that next table in same document is on next page
	if `"`single'"'!="" {
		
		* First iteration
		if ${tablenum}==1 {
			* Declare file handle ---> used to refer to file when using RTF commands
			local handle tables
			* Create blank RTF file.
			* Declare colors: C4ED green 4 123 119; LORTA 161 52 80; White 0 0 0
			capture rtfclose `handle'
			rtfopen `handle' using "`filename'.rtf", paper(a4) replace
				file write `handle' "\ansi\deff0{\fonttbl{\f0 `font';}" ///
									"{\colortbl;\red255\green255\blue255;\red4\green123\blue119;\red161\green52\blue80;`newcolor'}}" ///
									"\fs`fontsize'"
			rtfclose `handle'
			}
			
		local newpage `""\page""'
		}
	
	* If 'single' not specified --> create new output file for each table
	else {
		local handle indiv_tables
	* Make file name if missing	
		if `"`filename'"'=="" local filename "Table_${tablenum}_`title'"
		
		capture rtfclose `handle'
		rtfopen `handle' using "`filename'.rtf", paper(a4) replace
			file write `handle' "\ansi\deff0{\fonttbl{\f0 `font';}" ///
								"{\colortbl;\red255\green255\blue255;\red4\green123\blue119;\red161\green52\blue80;`newcolor'}}" ///
								"\fs`fontsize'"
		rtfclose `handle'
		
		local newpage
		}

		
	
* OPTION 'rmvtitle': remove table title if specified
	if `"`rmvtitle'"'!="" {
		local tabletitle 	
		}
	else {
		local tabletitle `"title("{\b Table ${tablenum} `title'}")"'
*		local tabletitle `"title("Table {\field{\*\fldinst { SEQ Table \\* ARABIC }}} `title'")"'
		}		
		

* OPTION 'obslabel': if specified, show "`obslabel'" at bottom of table; otherwise show "Observations"
	if `"`obslabel'"'=="" local obslabel "Observations"
	

* OPTION 'french' --> number formatting: in French, decimals are separated by comma		
	if `"`french'"'!="" set dp comma	

	
*** Flexible NUMBER FORMATTING
* OPTION 'smartformat' --> first num specifies decimals for abs(values)<1; 2nd num <10; 3rd num <100; 4th num <1000; 5th num <10000
	* Make smartformat the default
	if `"`smartformat'"'=="" & `"`format'"'=="" {
		local smartformat 2 1 1
		}
		
	if `"`smartformat'"'!="" {
		local format1: word 1 of `smartformat'
		local format10: word 2 of `smartformat'
		local format100: word 3 of `smartformat'
		local format1000: word 4 of `smartformat'
		local format10000: word 5 of `smartformat'
		
		foreach f in format10 format100 format1000 format10000 {
			if "``f''"=="" local `f' 0
			}
		}
	
	
*** FULL SAMPLE DISPLAY	
* OPTION 'fullsample': show in first column (default), in last column, or do not show 
	if `"`fullsample'"'=="" | (`"`fullsample'"'=="none" & `"`ttest'"'=="" & `"`groupvar'"'=="") | (`"`fullsample'"'=="last" & `"`ttest'"'!="") local fullsample first
		
		
*** TABLE NOTE
* OPTION 'note': make the note() for esttab --> also depends on 'ttest' and 'cluster' options! + Depends on 'fullsample' option
	if `"`cluster'"'!="" {
		if "`: variable label `cluster''"!="" local clusternote " T-test adjusted for clustering at the `: variable label `cluster'' level."
		else local clusternote " T-test adjusted for clustering at the `cluster' level."
		}
	else local clusternote
	
	* Showing means only
	if `"`meansonly'"'=="" local sdnote " Standard deviations in parentheses."
	else local sdnote

	* Default note if t-test required --> note() is put in `options'
	if (strpos(`"`options'"', " note(")==0 | strpos(`"`options'"', " note() ")>0) & `"`ttest'"'!="" {	
		
		if `"`wrapnote'"'!="" local nextline "\line"
		else local nextline "\par"
		
		if `"`fullsample'"'=="first" local printnote `"note("\qj Note: Columns (1), (2) and (3) present the sample means (proportions when % is shown in the variable name or in the table) of selected variables for the full sample, the treatment group and the control group, respectively. Standard deviations in parentheses. Column (4) presents the mean difference between the treatment and control groups. P-value of the corresponding t-test in parentheses.`clusternote'`nextline' Significance stars: * p \u8804? 0.1, ** p \u8804? 0.05, *** p \u8804? 0.01."`newpage')"'
		
		else if `"`fullsample'"'=="none" local printnote `"note("\qj Note: Columns (1) and (2) present the sample means (proportions when % is shown in the variable name or in the table) of selected variables for the treatment group and the control group, respectively. Standard deviations in parentheses. Column (3) presents the mean difference between the treatment and control groups. P-value of the corresponding t-test in parentheses.`clusternote'`nextline' Significance stars: * p \u8804? 0.1, ** p \u8804? 0.05, *** p \u8804? 0.01."`newpage')"'

		local options = subinstr(`"`options'"', "note()", "", 1)
		}
		
	* Default note if groups and no t-test	
	else if (strpos(`"`options'"', " note(")==0 | strpos(`"`options'"', " note() ")>0) & `"`ttest'"'=="" & `"`groupvar'"'!="" {
				
		if `"`fullsample'"'=="first" local printnote `"note("\qj Note: Sample means (proportions when % is shown in the variable name or in the table) of selected variables for the full sample (first column) and by group.`sdnote'"`newpage')"'
		
		else if `"`fullsample'"'=="last" local printnote `"note("\qj Note: Sample means (proportions when % is shown in the variable name or in the table) of selected variables by group and for the full sample.`sdnote'"`newpage')"'
		
		else if `"`fullsample'"'=="none" local printnote `"note("\qj Note: Sample means (proportions when % is shown in the variable name or in the table) of selected variables by group.`sdnote'"`newpage')"'
		
		local options = subinstr(`"`options'"', "note()", "", 1)
		}

	* Default note if no groups and no t-test	
	else if (strpos(`"`options'"', " note(")==0 | strpos(`"`options'"', " note() ")>0) & `"`ttest'"'=="" & `"`groupvar'"'=="" {
		local printnote `"note("\qj Note: Sample means (proportions when % is shown in the variable name or in the table) of selected variables for the full sample.`sdnote'"`newpage')"'
		
		local options = subinstr(`"`options'"', "note()", "", 1)
		}
	
	else local printnote

	
	
*** DATA-DEPENDENT OPTIONS ***

*** Process data-related options "if", "in" and "weight"

	* Weights --> problem: "sum" does not allow pweight, must transform into aweight form "summarize"
	if `"`weight'"'!="" {
		if `"`weight'"'=="aweight" {
			local weights "[`weight' `exp']"
			local sumweights "[`weight' `exp']"
			}
		else if `"`weight'"'=="pweight" {
			local weights "[`weight' `exp']"
			local sumweights "[aweight `exp']"
			}
		}	
	
	else {
		local weights
		local sumweights
		}
		
		
	* if/in conditions
	* Recover name of current frame
	frame pwf
	local baseframe "`r(currentframe)'"
	
	* Send restricted sample to other frame and change to that frame
	if `"`if'"'!="" | `"`in'"'!="" {
		tempname ifindata
		cap frame drop `ifindata'
		*frame create ifindata
		
		frame put * `if' `in', into(`ifindata')

		frame change `ifindata'
		}

	
*** COLUMN WITH OBSERVATIONS
* OPTION 'addobs': Show in a column with number of observations per category
* Need to generate estimation results.
* Depends on variable type: if binary --> show N for variable==1 / if continuous --> show N of non-missing values
	if `"`addobs'"'!="" {
		local count = 0
		foreach var in `varlist' {
			local ++count
			qui distinct `var'
			local distinct = r(ndistinct)
			qui sum `var'
		* Identify binary var
			if `distinct'==2 & ((r(min)==0 & r(max)==1) | (r(min)==0 & r(max)==0) | (r(min)==1 & r(max)==1)) {
				count if `var'==1
				}
			else {
				count if !missing(`var')
				}				
			if `count'==1 mat nbobs = r(N)
			else mat nbobs = nbobs, r(N)		
			}
	*** No. of obs. per category (matrix nbobs --> see loop above)
		estpost sum `varlist'
		matrix colnames nbobs = `:colnames e(mean)'
		*ereturn matrix mean = nbobs, copy
		ereturn post nbobs
		eststo nbobs, title("N")
		local nbobs nbobs
		}
	else local nbobs


*** NUMBER FORMATTING	
* OPTION 'percent': Show binary variables as percentage (preserve and restore because modify variables)
					* That's also where all number formats are set
					
	if `"`percent'"'!="" {
		preserve
		local restore restore
		
		local allformat
		local space
		local percentvars
		local count 0
		foreach var in `varlist' {
			local ++count
			
			qui distinct `var'
			local distinct = r(ndistinct)
			qui sum `var' `sumweights'
		* Identify binary var --> if yes: multiply by 100 + format with 1 decimal
			if `distinct'==2 & (r(min)==0 & r(max)==1) | (r(min)==0 & r(max)==0) | (r(min)==1 & r(max)==1) {
				local allformat "`allformat'`space'1"
				qui replace `var'=`var'*100
				
				* LABELLING: if percent(nosign) specified, add (%) in variable label.
				if `"`percent'"'=="nosign" lab var `var' "`: variable label `var'' (%)"
				* Otherwise, add % sign in table directly --> tag binary variables with mention in label to be removed afterwards
				else if `"`percent'"'=="sign" lab var `var' "`: variable label `var'' (ADD%SIGN)"
				}
				
		* If not --> use smartformat
			else if `"`smartformat'"'!="" {
				if abs(r(mean))<1 local allformat "`allformat'`space'`format1'"
				else if abs(r(mean))<10 local allformat "`allformat'`space'`format10'"
				else if abs(r(mean))<100 local allformat "`allformat'`space'`format100'"
				else if abs(r(mean))<1000 local allformat "`allformat'`space'%15.`format1000'fc"
				else local allformat "`allformat'`space'%15.`format10000'fc"
				}
				
		* If no smartformat --> use format
			else {
				local thisvarfmt: word `count' of `format'
				* If empty --> last format
				if "`thisvarfmt'"=="" local thisvarfmt: word `: word count `format'' of `format'
				local allformat "`allformat'`space'`thisvarfmt'"
				}
			
			local space " "
			}
		}

	else {
		local allformat
		local space
		local count 0
		foreach var in `varlist' {
			local ++count
			qui sum `var' `sumweights'
			
			if `"`smartformat'"'!="" {
				if abs(r(mean))<1 local allformat "`allformat'`space'`format1'"
				else if abs(r(mean))<10 local allformat "`allformat'`space'`format10'"
				else if abs(r(mean))<100 local allformat "`allformat'`space'`format100'"
				else if abs(r(mean))<1000 local allformat "`allformat'`space'%15.`format1000'fc"
				else local allformat "`allformat'`space'%15.`format10000'fc"
				}
			
			else {
				local thisvarfmt: word `count' of `format'
				* If empty --> last format
				if "`thisvarfmt'"=="" local thisvarfmt: word `: word count `format'' of `format'
				local allformat "`allformat'`space'`thisvarfmt'"
				}
			
			local space " "
			}	
		}
	

*** TABLE CONTENTS
*** SD, CI or SE
* OPTION 'ci': Show 95% CI instead of SD (technically SE as it's a fake regression estimate) + modify table note
* OPTION 'se': Show SE instead of SD + modify table note
* Default is SD, cannot specify both 'ci' and 'se'
	
	if `"`ttest'"'!="" {
		if `"`fullsample'"'=="none" {
			local pattern1 "sd(fmt(2) par pattern(0 0 1 0)) &"
			local pattern2 "pattern(1 1 0 0)"
			}
		else {
			local pattern1 "sd(fmt(2) par pattern(0 0 0 1 0)) &"
			local pattern2 "pattern(1 1 1 0 0)"
			}
		}
	else {
		local pattern1
		local pattern2
		}
	
	* CI
	if `"`ci'"'!="" & `"`se'"'=="" {
	    local sd_ci_se "`pattern1' ci(fmt(`allformat') par([  ;  ]) `pattern2')"
		* Modify table note
		* Recover CI level from `options'
		local cilevel = substr(`"`options'"', strpos(`"`options'"', "level("), .)
		if `"`cilevel'"'!="" {
			local cilevel = substr("`cilevel'", strpos("`cilevel'", "(") + 1, strpos("`cilevel'", ")") - strpos("`cilevel'", "(") - 1)
			}			
		else local cilevel 95
		local printnote = subinstr(`"`printnote'"', "Standard deviations in parentheses", "`cilevel'% confidence intervals in square brackets", .)
		}
	
	* SE
	else if `"`se'"'!="" & `"`ci'"'=="" {
	    local sd_ci_se "`pattern1' se(fmt(`allformat') par([ ]) `pattern2')"
		* Modify table note
		local printnote = subinstr(`"`printnote'"', "Standard deviations in parentheses", "Standard errors in square brackets", .)
		}
	
	* SD
	else if `"`meansonly'"'=="" local sd_ci_se "`pattern1' sd(fmt(`allformat') par `pattern2')"
	
	
* OPTION 'meansonly'
	
	* Means only, no SD, no SE, no CI
	local printcells "b(fmt(`allformat') star pvalue(pvalue)) & `sd_ci_se'"
	if `"`meansonly'"'!="" local printcells "b(fmt(`allformat'))"	
	
	
*** T-test
* OPTION 'ttest': run t-test for mean comparison across groups + add column with test results
	if `"`ttest'"'!="" {
		* RUN 'testresults' program to produce desc stats + t-test and store in estimates results
		if `"`cluster'"'!="" testresults `varlist' `weights', groupvar(`ttest') ttest cluster(`cluster')
		else testresults `varlist' `weights', groupvar(`ttest') ttest
		
		if `"`fullsample'"'=="first" local resultset full treat control difftest
		else if `"`fullsample'"'=="none" local resultset treat control difftest
		
		* Column title in case t-test 
*		local labfour "(2)-(3) (p-value)"
		}

	* If by group but no t-test	
	else {
		* RUN 'testresults' program for full sample and for each group separately
		* Full sample
		cap drop groupvar
		g groupvar = 1
		testresults `varlist' `weights', groupvar(groupvar)
		
		* Copy results with default name
		qui est restore groupresult
		est store full, title("Full sample")
				
		* For each group separately, if 'groupvar' exists
		if `"`groupvar'"'!="" {
			
			levelsof `groupvar', local(groups)
			local groupcount = 0
			
			* Count number of groups to adjust column width
			qui distinct `groupvar' if !missing(`groupvar')
			local nbgroup = r(ndistinct)
			* 2 groups + Full --> 8
			if `nbgroup'==2 local colwidth 8
			* 3 groups + Full --> 7
			else if `nbgroup'==3 local colwidth 7
			* 4 groups + Full --> 6
			else if `nbgroup'==4 local colwidth 6
			else local colwidth 5
			
			* Account for "full sample" column
			local widthcols "`colwidth'"
			
			foreach g of local groups {
				local ++groupcount
				cap drop groupvar
			* CAREFUL: groupvar can be string
				if strpos("`: type `groupvar''", "str")>0 g groupvar = 1 if `groupvar'=="`g'"
				else g groupvar = 1 if `groupvar'==`g'
				testresults `varlist' `weights', groupvar(groupvar)

				* Copy results with default name
				qui est restore groupresult
				* If string
				if strpos("`: type `groupvar''", "str")>0 est store group`groupcount', title("`g'")
				* If numeric
				else{
					if "`: label (`groupvar') `g''"!="" est store group`groupcount', title("`: label (`groupvar') `g''")
					else est store group`groupcount', title("Group `groupcount'")
					}
				
				local resultset "`resultset' group`groupcount'"
				
				local widthcols "`widthcols' `colwidth'"
				}
			}
		cap drop groupvar
		
		* Results to print
		if `"`fullsample'"'=="first" local resultset full `resultset'
		else if `"`fullsample'"'=="last" local resultset `resultset' full
		else if `"`fullsample'"'=="none" local resultset `resultset'
		
		}




* 'esttab' to export table to previously prepared RTF document

*** Default esttab options
	local collabels "collabels(none)"
	local stats `"stats(obs, fmt(%15.0fc) labels("`obslabel'"))"'
	local starlevels "starlevels(* 0.1 ** 0.05 *** 0.01)"
	local varwidth "varwidth(18)"
	
	if `"`ttest'"'!="" local modelwidth "modelwidth(8 8 8 5 3)"
	else if `"`addobs'"'!="" local modelwidth "modelwidth(`widthcols' 3)"
	else local modelwidth "modelwidth(`widthcols')"
	
	local mtitles "mtitles"
	local noobs "noobs"
	local label "label"
	
	foreach option in collabels stats starlevels varwidth modelwidth {
		if strpos(`"`options'"', "`option'(")>0 local `option'
		}
	
	if strpos(`"`options'"', "mtitles")>0 local mtitles
	if strpos(`"`options'"', " label ")>0 | strpos(`"`options'"', " nolabel ")>0 local label
	
	* Table note
	if strpos(`"`options'"', "nonotes")>0 local printnote
	
	* Special case for "noobs"
	if strpos(`"`options'"', "noobs")>0 {
		local noobs
		local stats
		}
	

	* Export table
	
	n: esttab `resultset' `nbobs' using "`filename'.rtf", append ///
			cells("`printcells'") incelldelimiter("\line") ///
			nonote nogaps ///
			`tabletitle' `varlabels' `printnote' `options' `collabels' `stats' `starlevels' `varwidth' `modelwidth' `mtitles' `noobs' `label'

	`restore'
	

*** Back to original frame 

frame change `baseframe'
cap frame drop `ifindata'


	
*** FORMATTING OF .RTF DOCUMENT ***
	
	cap frame drop tempframe
	frame create tempframe
	frame tempframe {
		import delimited "`filename'.rtf", clear
	
		*** Process indenting of variables --> replace double blank space at beginning of row by left indent in cell
		if `"`indentvars'"'!="" {
			g find = substr(v1, strpos(v1, "\cellx"), strrpos(v1, "\pard\intbl\ql {") + strlen("\pard\intbl\ql {") - strpos(v1, "\cellx"))
			g sub = subinstr(find, "\pard\intbl\ql {", "\pard\ltrpar\ql \li170\ri0\nowidctlpar\intbl\wrapdefault\faauto\rin0\lin170 {", 1) if strpos(v1, "  {\trowd\trgaph108")==1
			replace v1 = subinstr(v1, find, sub, 1) if !missing(sub) & strpos(v1, "  {\trowd\trgaph108")==1
			drop find sub
			}
			
		
		*** Remove extra rows in cells when displaying different statistics, e.g. SD in columns and p-value in last column
		split v1, gen(vsplit_)
		unab vars: vsplit_*
		foreach var of local vars {
			* Remove extra row in middle of cell
			cap drop sub
			g sub = subinstr(`var', "\line\line", "\line", 1) if strpos(`var', "}\cell")>0 & strpos(`var', "{")==1 & strpos(`var', "\line\line")>0
			replace v1 = subinstr(v1, `var', sub, 1) if !missing(sub)
			* Remove extra row at bottom of cell
			cap drop sub
			g sub = subinstr(`var', "\line}\cell", "}\cell", 1) if strpos(`var', "\line}\cell")>1 & strpos(`var', "{")==1
			replace v1 = subinstr(v1, `var', sub, 1) if !missing(sub)
			}
		drop vsplit_*
		
		
		*** Remove extra zeroes in column "N" (i.e. no. of observations) when added
		* ASSUMES up to 5 decimals, hopefully should never be more
		if `"`addobs'"'!="" {
			if `"`french'"'!="" local dp ","
			else local dp "."
			foreach zero in "`dp'00000" "`dp'0000" "`dp'000" "`dp'00" "`dp'0" {
				replace v1 = subinstr(v1, "`zero'\line}\cell\row}", "\line}\cell\row}",1) if strpos(v1, "`zero'\line}\cell\row}")>1
				replace v1 = subinstr(v1, "`zero'}\cell\row}", "}\cell\row}",1) if strpos(v1, "`zero'}\cell\row}")>1
				}
			}
			

		*** Add % sign directly in table if option 'percent(sign)' specified
		if `"`percent'"'=="sign" {
			* Use variable label to know where to replace --> find tag "(ADD%SIGN)" in label and remove afterwards
			* CAREFUL: replace up to 3 instances, otherwise will add % to last column too
			if `"`ttest'"'!="" & `"`fullsample'"'=="none" {
				if `"`ci'"'!="" | `"`se'"'!="" replace v1 = subinstr(v1, "\line[", "%\line[", 2) if strpos(v1, "\line[")>1 & strpos(v1, "(ADD%SIGN)")>1
				else replace v1 = subinstr(v1, "\line(", "%\line(", 2) if strpos(v1, "\line(")>1 & strpos(v1, "(ADD%SIGN)")>1
				}
			else if `"`ttest'"'!="" & `"`fullsample'"'=="first" {
				if `"`ci'"'!="" | `"`se'"'!="" replace v1 = subinstr(v1, "\line[", "%\line[", 3) if strpos(v1, "\line[")>1 & strpos(v1, "(ADD%SIGN)")>1
				else replace v1 = subinstr(v1, "\line(", "%\line(", 3) if strpos(v1, "\line(")>1 & strpos(v1, "(ADD%SIGN)")>1
				}
			else {
				replace v1 = subinstr(v1, "\line[", "%\line[", .) if strpos(v1, "\line[")>1 & strpos(v1, "(ADD%SIGN)")>1
				replace v1 = subinstr(v1, "\line(", "%\line(", .) if strpos(v1, "\line(")>1 & strpos(v1, "(ADD%SIGN)")>1
				
				if `"`meansonly'"'!="" {
					g v2 = substr(v1, strpos(v1, "(ADD%SIGN)}\cell ") + strlen("(ADD%SIGN)}\cell "),.) if strpos(v1, "(ADD%SIGN)")>0
					g v3 = subinstr(v2, "}\cell", "%}\cell", .)
					replace v1 = subinstr(v1, v2, v3, .)
					}
				}
				
			replace v1 = subinstr(v1, " (ADD%SIGN)", "", .)
			}
		
		
		
		*** OPTION 'backcolors' --> see help file for details
		if `"`backcolors'"'!="" {
			* Identify top rows --> default is first row. Otherwise 'nbrows'.
			
			*g tag = (strpos(v1, "{}\cell")==strpos(v1, "}\cell")-1)
			cap drop order
			g order = _n
			su order if strpos(v1, "\trowd")>0
			local first = r(min)
			local last = r(max)
			
			* If number of rows in nbrows() larger than in table --> default to nb of rows in table
			if `nbtoprows' > (`= `last' - `first' + 1') local nbtoprows = `last' - `first' + 1 
			local toprows = `first' + `nbtoprows' - 1
				
			* Set background color for TOP ROWS
			if `"`topfill'"'!="" {
				replace v1 = subinstr(v1, "\cellx", "\clcbpat`cftopfill'\cellx", .) if order>=`first' & order<=`toprows'
				}
				
			* Set background color for TABLE
			if `"`tablefill'"'!="" {
				replace v1 = subinstr(v1, "\cellx", "\clcbpat`cftablefill'\cellx", .) if order>`toprows' & order<=`last'
				}	
						
			* Text color and bold --> loop over cells
			split v1, gen(vsplit_) parse("{")
			unab vars: vsplit_*
			foreach var of local vars {
				* Remove extra row in middle of cell
				replace `var' = "{" + `var' if strpos(`var', "}\cell")>0 & order>=`first' & order<=`toprows'
				cap drop sub
				g sub = subinstr(`var', "{", "{`boldtext'\cf`cftext' ", 1) if strpos(`var', "}\cell")>0 & strpos(`var', "{")==1 & strpos(`var', "{}\cell")==0 & order>=`first' & order<=`toprows'
				replace v1 = subinstr(v1, `var', sub, 1) if `var'!=sub & !missing(sub) & order>=`first' & order<=`toprows'
				}
		
			drop sub
			drop order
			}
			    
		
		* OPTION 'wrapnote' and 'notesize' --> make table note to width of table + change font size of note if needed
		* Execute only if there is a note
		if `"`printnote'"'!="" | (`"`printnote'"'=="" & strpos(`"`options'"', " note(")>0) {
			* Identify first row below table
			g order = _n
			sum order if strpos(v1, "\cell")>0
			local lastrow = r(max)
			g tag = 1 if order > r(max)
			
			* Modify font size of note
			if `"`notesize'"'!="" replace v1 = subinstr(v1, "\fs20", "\fs`notesize'", .) if tag==1

			if `"`wrapnote'"'!="" {
				* Identify last row of table --> need to find table overall width
				qui levelsof v1 if order==`lastrow', local(cellx) clean
				local cellx = substr("`cellx'", strrpos("`cellx'", "\cellx"), .)
				local cellx = subinstr("`cellx'", "\cellx", "", .)
				local cellx = substr("`cellx'", 1, strpos("`cellx'", "\pard") - 1)
				
				* Remove paragraph syntax
				replace v1 = subinstr(v1, "\pard", "", 1) if tag==1
				replace v1 = subinstr(v1, "\par", "", 1) if tag==1
				* Remove left-align if present
				replace v1 = subinstr(v1, "\ql", "", .) if tag==1

				* Add table row cell syntax
				replace v1 = "{\trowd\cellx`cellx'\pard\intbl\qj\fs`notesize' " + v1 + "\cell\row}" if tag==1				
				
				}
			
			
			drop order tag
			}
		

		*** OPTION 'whiteborders' --> white table borders (esttab default is black)
		if `"`whiteborders'"'!="" replace v1 = subinstr(v1, "\brdrs", "\brdrcf1\brdrs", .)

			
		
************************* Export formatted RTF ***********		
		
		outsheet v1 using "`filename'.rtf", noquote nonames replace
		}	
		
		
	frame drop tempframe

*** END OF .RTF FORMATTING	
	
	* Reset default for decimal point
	set dp period

* End "quietly"
}	
	
	end
	

********************************************************************************
* PROGRAM to parse 'backcolors' option in 'maketable'
	
cap prog drop parse_backcolors_option
prog define parse_backcolors_option, sclass

	syntax [, topfill(string asis) toptextcolor(string asis) toptextbold nbtoprows(integer 1) tablefill(string asis)]
	
	sreturn local topfill `"`topfill'"'
	sreturn local toptextcolor `"`toptextcolor'"'
	sreturn local toptextbold `"`toptextbold'"'
	sreturn local nbtoprows `"`nbtoprows'"'
	sreturn local tablefill `"`tablefill'"'
	
end

********************************************************************************
***								testresults								     ***
********************************************************************************


*** PROGRAM TO PRODUCE DESCRIPTIVE STATS BY FULL SAMPLE, T and C GROUPS + t-test
*** PROGRAM "testresults" CREATES ESTIMATION RESULTS "full", "treat", "control" AND "difftest" TO BE EXPORTED IN THAT ORDER WITH esttab/estout
*** Desc stats by group if option 'groupvar' is specified

*** T-test column
* 1) Perform t-test for each variable + store results in matrices (difference and p-value) 
* 2) Generate "fake" estimation results
* 3) Replace by matrices generated in Step 1 --> TIP: put T-C difference in "e(mean)"; put p-value in "e(sd)" AND in new matrix "e(pvalue)" on which significance stars are based
* 4) Store estimation results in "difftest"

*** Desc stats by group
* N obs. = I don't want the number of observations for the "t-test" column, so I create an additional scalar with obs. number for other estimation results but not for t-test results.
* SD, CI and SE = to use esttab 'ci' option, you need to post point estimates (mean in our case) in e(b) and covariance matrix in e(V).
				* BUT for regression results the SE is the square root of diagonal element of Cov matrix, whereas in our case the 'summarize' command produces SD and not SE.
				* Need to put matrix with SE "squared" diagonal elements into e(V) for CI to work properly in our case, i.e. to use SE instead of sample SD.
				* Also store SD estimates in e(sd).

				
cap prog drop testresults
prog define testresults, eclass

	version 16

	syntax varlist [if] [pweight aweight] [, groupvar(varlist max=1) ttest cluster(varlist max=1)]
	
	* Weights --> problem: "sum" does not allow pweight, must transform into aweight form "summarize"
	if `"`weight'"'!="" {
		if `"`weight'"'=="aweight" {
			local weights "[`weight' `exp']"
			local sumweights "[`weight' `exp']"
			}
		else if `"`weight'"'=="pweight" {
			local weights "[`weight' `exp']"
			local sumweights "[aweight `exp']"
			}
		}	
	
	else {
		local weights
		local sumweights
		}
	
	
	* OPTION 'ttest': specified in 'maketable' command below
	if `"`ttest'"'!="" {
	* Step 1
		local count = 0
		foreach var in `varlist' {
			local ++count
			* Cluster or not
			if `"`cluster'"'=="" reg `var' `groupvar' `weights'
			else reg `var' `groupvar' `weights', vce(cluster `cluster')
									
			mat rtable = r(table)
				
			mat A = rtable["b", "`groupvar'"]
			mat B = rtable["pvalue", "`groupvar'"]

			if `count'==1 mat diff = A
			else mat diff = diff, A
			
			if `count'==1 mat pvalue = B
			else mat pvalue = pvalue, B
								
			}
			
	* Step 2 --> fake results to be replaced
		estpost sum `varlist'
	* Step 3
		* Store difference in means to be put in 'e(b)'
		matrix colnames diff = `:colnames e(mean)'
		matrix colnames pvalue = `:colnames e(mean)'
		ereturn post diff
		ereturn matrix sd = pvalue, copy
		ereturn matrix pvalue = pvalue, copy
		ereturn scalar N = .
	* Step 4
		eststo difftest, title("(2)-(3) (p-value)")
	
	* Now for full sample + each group
		* Labels for column titles
		local labone: label(`groupvar') 1
		local labzero: label(`groupvar') 0
		if "`labone'"=="1" | "`labzero'"=="0" {
			n: di as error "WARNING: missing value label in grouping variable `groupvar'." _n "Categories assumed: 1 = Treatment Group, 0= Control Group."
			local labone "Treatment Group"
			local labzero "Control Group"
			}
		
		forvalues i=1/3 {
			local sample: word `i' of "" "if `groupvar'==1" "if `groupvar'==0"
			local estname: word `i' of full treat control
			local esttitle: word `i' of "Full sample" "`labone'" "`labzero'"
			
			estpost sum `varlist' `sample' `sumweights'
			mat m = e(mean)
			mat sd = e(sd)
			scalar N = e(N)
			
			* Generate matrix with SE "squared" to be put in e(V), i.e. SE^2 = Var / N --> SE is used for CIs
			mata: st_matrix("SESQ", st_matrix("e(Var)") :/ st_matrix("e(count)"))
			mat colnames SESQ = `: colnames m'
			mat SESQ = diag(SESQ)
			
			* Post mean and SE^2 in e(b) and e(V)
			ereturn post m SESQ
			
			* Add number of observations in scalar "obs"
			estadd scalar obs = N
			
			* Add SD in matrix e(sd)
			ereturn matrix sd = sd, copy
			
			eststo `estname', title("`esttitle'")		
			}	
		}

*** Desc stats by group, no t-test --> basically generates stats for 'groupvar'==1
	else {
		estpost sum `varlist' if `groupvar'==1 `sumweights'
		mat m = e(mean)
		mat sd = e(sd)
		scalar N = e(N)
		
		* Generate matrix with SE "squared" to be put in e(V), i.e. SE^2 = Var / N --> SE is used for CIs
		mata: st_matrix("SESQ", st_matrix("e(Var)") :/ st_matrix("e(count)"))
		mat colnames SESQ = `: colnames m'
		mat SESQ = diag(SESQ)
		
		* Post mean and SE^2 in e(b) and e(V)
		ereturn post m SESQ
		
		* Add number of observations in scalar "obs"
		estadd scalar obs = N
		
		* Add SD in matrix e(sd)
		ereturn matrix sd = sd, copy
		
		eststo groupresult
		}
		
end



********************************************************************************

