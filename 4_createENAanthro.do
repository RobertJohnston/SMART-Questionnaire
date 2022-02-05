/* ACO Urban SMART  DB PREPARATION               	*/
/* Robert Johnston                                 	*/
/* 2022                        						*/
/* stata v16                                       	*/
* create ENA anthro

set more off
cd "C:\Analysis\"
capture log close


* COPY PASTE ALL LOCALS FROM 1st do file 
* Change this filename to identify the desired data to export in the quotations below. 
local filename "ACO_SMART_Survey_2022_-_all_versions_-_English_-_2022-02-02-01-18-39.xlsx"

* set output data path - where you will find the excel and stata produced data from do file
cd C:\Analysis\

* set throwaway data path - where you store data for merging or transposing (not analysis)- data to be deleted after running do file.
local workdatapath "C:\Temp\Working/"

* Change the local variable 'dofilepath' to the filepath where you store the do files.
local dofilepath "C:\Users\Rojohnston\OneDrive - UNICEF\1 UNICEF Work\1 Afghanistan\Surveys\2022 UrbanSMART\Analysis/"

* Change the local variable 'datapath' to the filepath to the location where the raw survey data is stored on your computer.
local datapath "C:\Analysis\Data/"

* Remove extension
local filename_noext = subinstr("`filename'", ".xlsx", "", .)



*******************
* Child Anthro Data
*******************
*use surveydate cluster  team_number hh_num first_admin _index strata rand uniq_clust int_result starttime endtime startHMS using 
use "`datapath'`filename_noext'_1.dta", clear

// drop _uuid _submission_time 

gen id = _index
sort id
save "`workdatapath'merge_temp", replace

* merge in cluster, team_num, hh_num
use "`datapath'`filename_noext'_3.dta", clear

* Always ensure privacy
drop child_name 


* cannot run syntax if saved previously because of line below. 
gen id = _parent_index
sort id
merge m:1 id using "`workdatapath'merge_temp"
* merge 2 are the household with no children
drop if _merge == 2

// foreach var of varlist _all {
// local newname = subinstr("`var'", "consentchild", "", .)
// rename `var' `newname'
// }

* Prepare dataset

* relabel variables

* 1st Measure
drop Nowenteringdataforchildc
rename Doyouhaveanofficialagedocu 	dob_known
rename child_namesdateofbirth 		birthdate
rename Ageofchild_nameincomplete 	xmonths 
* rename xmonths_test xmonths_test 				 				 
* rename MONTHS MONTHS 				 
rename child_namesageisunknown 		age_noconfirm
rename child_nameisMONTHSmon 		age_confirm
rename WeightinKGofchild_name 		weight
rename Waschild_namedressedinclo 	clothed
rename HeightinCMofchild_name 		height
rename RecordmeasurementtakenLengt 	measure
drop PLEASEMEASURELENGTHChildren 
drop PLEASEMEASUREHEIGHTChildren
// rename Q muac_cm
rename MUACinMMofchild_name 		muac
rename Doeschild_namehavebilatera 	edema
rename Pleaseconfirmwiththeteamlea 	edema_confirm

* Second Measure
drop REMEASUREenteringdataforch
rename REMEASUREDoyouhaveanoffic  	dob_known_2
rename REMEASUREchild_namesdate		birthdate_2
rename REMEASUREAgeofchild_name 	xmonths_2 
* rename xmonths_test_2 xmonths_test_2 				 				 
* rename MONTHS_2 MONTHS_2 				 
rename REMEASUREchild_namesage      age_noconfirm_2
rename REMEASUREchild_nameis        age_confirm_2
rename REMEASUREWeightinKGofch		weight_2
rename REMEASUREWaschild_namedre 	clothed_2
rename REMEASUREHeightinCMofch     	height_2
rename REMEASURERecordmeasurementt  measure_2
drop BF BE
rename REMEASUREMUACinMMofchil 		muac_2
* no 2nd or 3rd assessment of bilateral edema

* Third Measure
drop BP
rename BQ     						dob_known_3
rename BR     						birthdate_3
rename BS     						xmonths_3
* rename xmonths_test_3 xmonths_test_3 				 				 
* rename MONTHS_3 MONTHS_3 			
rename BV           				age_noconfirm_3
rename BW           				age_confirm_3
rename BX     						weight_3
rename REMEASUREWaschild_namedr 	clothed_3
rename BZ     						height_3
rename CA    						measure_3
drop CB CC
rename CF 							muac_3

* Currently breastfeeding
rename Isthechildchild_namecur curr_bf
* Vitamin A
rename Hasthechildchild_namere vita
rename CO measles
rename Hasthechildchild_nameha diarrhea
rename CQ ari
rename CR fever

drop child_namehasSEVEREACUTE 
rename Haveyoureferredchild_name sam_ref
drop child_namehasMODERATEACU 
rename CX mam_ref

destring team_num, replace
tab team_num, m 
destring hh_num, replace
tab hh_num, m
destring first_admin, replace
tab first_admin, m

* Interview Result
* 1 Completed
* 2 No household member at home or competent respondent
* 3 Entire household absent for extended period of time
* 4 Postponed 
* 5 Refused
* 6 Dwelling vacant or address not a dwelling
* 7 Dwelling destroyed
* 8 Dwelling not found
* 9 Other

* Destring variables

* This variable is from initial data collection - not copy of initial data
tab dob_known, m 
destring dob_known, replace

tab CHSEX, m 
* don't use encode - use recode
gen child_sex = CHSEX
replace child_sex = "1" if CHSEX == "m"
replace child_sex = "2" if CHSEX == "f"
destring child_sex, replace
*Sex is coded 1=Male 2=Female
tab CHSEX child_sex
// la list child_sex

recode child_sex (1=1) (2=0), gen(child_sex_ratio)
* Child sex ratio (boys/girls)
table team_num, c(mean child_sex_ratio) col row cellwidth(16) format(%3.2f) 

* Set missing_sex = 1 if missing
recode child_sex (nonmiss = 0) (miss = 100), gen(missing_sex)
table team_num, c(mean missing_sex) col row cellwidth(16) format(%3.1f) 

destring MONTHS, replace
la var MONTHS "age months"
recode MONTHS (0/59.99=1)(60/97=0)(98=1)(99/997=0), gen(must_measure)
*tab age must_measure
la var must_measure "0-59 months of age or missing age"

gen dob=date(birthdate,"YMD###")
format dob %td
destring xmonths, replace

* Date of birth or age in months
cap drop dob_or_months
gen dob_or_months = 1 if dob !=.

replace dob_or_months = 2 if xmonths !=.
replace dob_or_months = 3 if MONTHS ==98
la define dob_or_months 1 "DOB" 2 "age months" 3 "missing"
la val dob_or_months dob_or_months 
tab dob_or_months, m

recode MONTHS (0/97=0)(98=100)(99/200=0)(.=100), gen(missing_age)
tab MONTHS missing_age, m


* Missing data on child age 
* table team_number dob_or_months, c(freq) col row cellwidth(20) format(%3.0f) 

* Missing data on weight, height, measure, MUAC, oedema
destring weight, replace
recode weight (nonmiss = 0) (miss = 100), gen(missing_wgt)
replace missing_wgt =. if must_measure!=1
*tab weight missing_wgt, m
*tab must_measure missing_wgt, m

destring height, replace
recode height (nonmiss = 0) (miss = 100), gen(missing_hgt)
replace missing_hgt =. if must_measure!=1
*tab must_measure missing_hgt, m

* gen missing_meas = 100 if measure==. & must_measure==1
tab measure
encode measure, gen(meas_x)
recode meas_x (nonmiss = 0) (miss = 100), gen(missing_meas)
replace missing_meas =. if must_measure!=1
*tab must_measure missing_meas, m

destring muac, replace
sum muac
* Children without muac could be < 6m or >59m. 
* gen missing_muac = 100 if muac==. & must_measure==1
recode muac (nonmiss = 0) (miss = 100), gen(missing_muac)
replace missing_muac =. if must_measure!=1
*tab must_measure missing_muac, m

encode edema, gen(edema_x)
* recode yes=1 no=0
recode edema_x (1=0)(2=1)
recode edema_x (nonmiss = 0) (miss = 100), gen(missing_edema)
replace missing_edema =. if must_measure!=1
replace missing_edema =. if MONTHS<6 
*tab must_measure missing_edema, m

encode edema_confirm, gen(edema_confirm_x)
* recode yes=1 no=0
recode edema_confirm_x (1=0)(2=1)
recode edema_confirm_x (nonmiss = 0) (miss = 100), gen(edema_confirm_missing)
replace edema_confirm_missing =. if must_measure!=1 
replace edema_confirm_missing =. if edema_x!=1


* destring vita deworm measles, replace

*gen missing_vita = 100 if vita==. & must_measure==1 & age>5 (months)
*recode vita (nonmiss = 0) (miss = 100), gen(missing_vita)
*replace missing_vita =. if must_measure!=1 
*replace missing_vita =. if age<6
*tab must_measure missing_vita, m

*gen missing_worm = 100 if deworm==. & must_measure==1 & age>12 (months)
*recode deworm (nonmiss = 0) (miss = 100), gen(missing_worm)
*replace missing_worm =. if must_measure!=1 
*replace missing_worm =. if age<12
*tab must_measure missing_worm, m

*gen missing_measle = 100 if deworm==. & must_measure==1 & age>12 (months)
*recode measles (nonmiss = 0) (miss = 100), gen(missing_measle)
*replace missing_measle =. if must_measure!=1 
*replace missing_measle =. if age<12
*tab must_measure missing_measle, m

* WHZ flag first measure
destring whz_neg3 flag, replace
la var whz_neg3 "SAM alert"
la var flag "Anthro Remeasure"

* Interview Result
// qst_complete qst_refused qst_absent
// destring int_result, replace
// tab int_result, m 

*tab team_number whz_neg3 ,m
*tab team_number sam_muac ,m
*tab team_number mam_muac,m
*tab team_number flag

* do analysis for duplicates
duplicates report

* Survey Weights
gen child_survey_weights =.

* ENA uses standardized weights
* N	ENAWgts
*replace child_survey_weight =	8.214 if strata==1
*Etc...
                                
* SPSS  frequency wgt   
gen child_freq_weight = .         
* N	FreqWgts	                
*replace child_freq_weight =	2062.37	if strata==1	
*Etc...

* Children over 5 years of age. 
recode MONTHS (0/59=0)  (60/97=100) (98=.) (100/998=0), gen(age_5yrs) 
la var age_5yrs "% of children over five / all children"
tab MONTHS age_5yrs, m

* Create ENA acceptable cluster variable. 
destring cluster, replace
tab cluster, m 

// gen uniq_clust = cluster
// tab uniq_clust, m
// sort uniq_clust
// egen ena_cluster = group(uniq_clust)
// sort uniq_clust
* scatter uniq_clust ena_cluster


* Field Test Data on 22nd January
* Drop everything from and prior to 22nd January Date. 
gen sdatetemp = surveydate
order surveydate sdatetemp, last
drop if sdatetemp<=22667

tab surveydate


*Export ENA data format.
gen SURVDATE = surveydate
format SURVDATE %td
gen CLUSTER = cluster
* check with code above for ENA cluster var
gen TEAM = team_num
tab child_hh_position
cap drop ID
destring child_hh_position, gen(ID) 
// tab ID child_hh_position, m 
gen HH = hh_num
gen SEX = child_sex
tab SEX CHSEX
*Sex is coded 1=Male 2=Female

gen BIRTHDAT= dob



* RANDOM
* rand variable from HH questionnaire 
destring rand, replace
gen random = 1 if rand<0.05
la var random "Random selected for remeasure"
tab random, m 
* list BIRTHDAT birthdate_3 if random ==1


* Replace 1st pass data with remeasures if taken. 
gen dob_2=date(birthdate_2,"YMD###")
cap gen dob_3=date(birthdate_3,"YMD###")
replace BIRTHDAT = dob_2 if flag ==1
cap replace BIRTHDAT = dob_3 if random ==1
format BIRTHDAT %td

* Age in Months
// gen MONTHS 
destring MONTHS_2 MONTHS_3, replace
replace MONTHS = MONTHS_2 if flag ==1
replace MONTHS = MONTHS_3 if random ==1
* replace MONTHS = round(MONTHS,1)

* Replace MONTH in whole number with calculated months if birthdate is available. 
* days in year 365.24
* days in month 30.44
replace MONTHS = (SURVDATE-BIRTHDAT)/30.436667 if BIRTHDAT !=.
tab MONTHS, m 

* Weight
cap drop wgttemp
gen wgttemp = weight
destring weight_2 weight_3, replace
replace wgttemp = weight_2 if flag ==1
replace wgttemp = weight_3 if random ==1
replace wgttemp = round(wgttemp,.1)
cap drop digit_wgt
gen digit_wgt = wgttemp-floor(wgttemp) 
replace digit_wgt = round(digit_wgt,.1)
tab digit_wgt

*format WEIGHT %4.1f 
*tostring wgttemp, gen(WEIGHT)force
*replace WEIGHT = substr(WEIGHT,1,3) if wgttemp <10
*replace WEIGHT = substr(WEIGHT,1,4) if wgttemp >=10

replace wgttemp = trunc(round(wgttemp*10))
tostring wgttemp, gen(WEIGHT)force
replace WEIGHT=substr(WEIGHT,1,1)+"."+substr(WEIGHT,2,1) if wgttemp <100
replace WEIGHT=substr(WEIGHT,1,2)+"."+substr(WEIGHT,3,1) if wgttemp >=100
replace WEIGHT= "" if wgttemp ==.
// tab WEIGHT

* Height
cap drop hgttemp
gen hgttemp = height
destring height_2 height_3, replace
// tab height
// tab height_2
// tab height_3
replace hgttemp = height_2 if flag ==1
replace hgttemp = height_3 if random ==1
replace hgttemp = round(hgttemp,.1)
tab hgttemp
cap drop digit_hgt
gen digit_hgt = hgttemp-floor(hgttemp) 
replace digit_hgt = round(digit_hgt,.1)
tab digit_hgt

*format HEIGHT %4.1f 
replace hgttemp = trunc(round(hgttemp*10))
tostring hgttemp, gen(HEIGHT)force
replace HEIGHT=substr(HEIGHT,1,2)+"."+substr(HEIGHT,3,1) if hgttemp <1000
replace HEIGHT=substr(HEIGHT,1,3)+"."+substr(HEIGHT,4,1) if hgttemp >=1000
replace HEIGHT= "" if hgttemp ==.
// tab HEIGHT

* Bilateral Edema
gen EDEMA =  edema 
replace EDEMA = "No" if edema_confirm =="No"
replace EDEMA = "Yes" if edema_confirm =="Yes" 
tab EDEMA, m 

* MUAC
gen MUAC = muac
destring muac_2 muac_3, replace
replace MUAC = muac_2 if flag ==1
replace MUAC = muac_3 if random ==1

gen WAZ = .
gen HAZ = .
gen WHZ = .

* Measure
cap drop MEASURE
gen MEASURE = measure
replace MEASURE = measure_2 if flag ==1
replace MEASURE = measure_3 if random ==1
replace MEASURE = "l" if MEASURE =="Length (lying horizontal on board)"
replace MEASURE = "h" if MEASURE =="Standing height"
tab MEASURE, m 


destring clothed clothed_2 clothed_3, replace
gen CLOTHES = clothed
replace CLOTHES = clothed_2 if flag ==1
replace CLOTHES = clothed_3 if random ==1

gen STRATA = strata
// decode strata, gen(STRATA_NAME)
gen STRATA_NAME = province
gen WTFACTOR = child_survey_weights 
gen REGION = first_admin
// decode first_admin, gen(REGION_NAME)
gen REGION_NAME = province





*Drop cases of children older than 5 years
drop if MONTHS > 59 & MONTHS != 98

gen strata_num = strata

* Save child database 6 with all variables included
label var WEIGHT ""
label var HEIGHT ""

* drop if missing date & IDs
drop if SURVDATE==. & CLUSTER==. & TEAM==. & HH==.





* 1st measures only

// replace BIRTHDAT = dob
// replace MONTHS = xmonths
// destring WEIGHT HEIGHT, replace
// replace WEIGHT = weight
// replace CLOTHES = clothed
// replace HEIGHT = height
// replace MEASURE = measure
// replace MEASURE = "l" if MEASURE =="Length (lying horizontal on board)"
// replace MEASURE = "h" if MEASURE =="Standing height"
// replace MUAC = muac
//
// order SURVDATE CLUSTER TEAM ID HH SEX BIRTHDAT MONTHS WEIGHT HEIGHT EDEMA MUAC WAZ HAZ WHZ MEASURE CLOTHES ///
//      STRATA WTFACTOR STRATA_NAME child_freq_weight , first
// * int_result
// keep SURVDATE CLUSTER TEAM ID HH SEX BIRTHDAT MONTHS WEIGHT HEIGHT EDEMA MUAC WAZ HAZ WHZ MEASURE CLOTHES ///
//      STRATA WTFACTOR STRATA_NAME child_freq_weight   ///
// 	 sam_case uniq_clust first_admin ///
// 	 child_survey_weights REGION REGION_NAME 
// *int_result
//
// local data_export_name = substr("$filename_noext",1, 9) + "_child_1st"
//
// *Save National or Global level data
// save "`data_export_name'", replace
// export excel using "`data_export_name'", firstrow(variables) nolabel replace

* 1st measures only END 


order SURVDATE CLUSTER TEAM ID HH SEX BIRTHDAT MONTHS WEIGHT HEIGHT EDEMA MUAC WAZ HAZ WHZ MEASURE CLOTHES ///
     STRATA WTFACTOR STRATA_NAME child_freq_weight, first
*int_result

// keep SURVDATE CLUSTER TEAM ID HH SEX BIRTHDAT MONTHS WEIGHT HEIGHT EDEMA MUAC WAZ HAZ WHZ MEASURE CLOTHES ///
//      STRATA WTFACTOR STRATA_NAME child_freq_weight   ///
// 	 sam_case uniq_clust first_admin ///
// 	 child_survey_weights REGION REGION_NAME 
*int_result

tab STRATA, m 
	 
* Data export name
local data_export_name = substr("$filename_noext",1, 9) + "_child"

*Save National or Global level data
save "`data_export_name'", replace
export excel using "`data_export_name'", firstrow(variables) nolabel replace

*Save National or Global level data
save "`data_export_name'", replace
export excel using "`data_export_name'", firstrow(variables) nolabel replace


*ENA format
keep SURVDATE CLUSTER TEAM ID HH SEX BIRTHDAT MONTHS WEIGHT HEIGHT EDEMA MUAC WAZ HAZ WHZ MEASURE CLOTHES ///
     STRATA WTFACTOR STRATA_NAME child_freq_weight 
* int_result

order SURVDATE CLUSTER TEAM ID HH SEX BIRTHDAT MONTHS WEIGHT HEIGHT EDEMA MUAC WAZ HAZ WHZ MEASURE CLOTHES ///
     STRATA WTFACTOR STRATA_NAME child_freq_weight , last
* int_result

*Export as separate file for each STRATA
local x_dataname "X_" + "`data_export_name'"

levelsof STRATA
foreach i in `r(levels)' {
	local name = subinstr("`x_dataname'","X","`i'", .)
	export excel using `name' if STRATA==`i', firstrow(variables) nolabel replace 
}

	 

use "`data_export_name'", clear



* If woman's data is included in the data collection - create woman's database. 
do path\SURVEYNAME_X_createdb_woman.do"




* Create Mortality Database
* do `dofilepath'5_createENAmortality"

gen SURVDATE 

order SURVDATE CLUSTER TEAM ID HH SEX BIRTHDAT MONTHS WEIGHT HEIGHT EDEMA MUAC WAZ HAZ WHZ MEASURE CLOTHES ///
     STRATA WTFACTOR STRATA_NAME child_freq_weight , last
	 

* int_result