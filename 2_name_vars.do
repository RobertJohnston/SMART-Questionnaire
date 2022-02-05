/* ACO Urban SMART  DB PREPARATION               	*/
/* Robert Johnston                                 	*/
/* 2022                        						*/
/* stata v16                                       	*/

cd C:\Analysis\
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




* Open HOUSEHOLD LISTING data
di "`datapath'`filename_noext'_1.dta"

use "`datapath'`filename_noext'_1.dta", clear

* use ACO_SMART_Survey_2022_2022-01-24-05-30-30_1.dta, clear
* ACO_SMART_Survey_2022_-_all_versions_-_English_-_2022-01-24-14-17-57_1

rename Province province
rename District district
rename Clusternumber cluster
rename Householdnumber hh_num
rename Teamnumber team_num
rename HellomynameisNAMEIam consent
drop CONSENTREFUSEDPleaseensuret CURRENTHOUSEHOLDMEMBERSPleas

rename Justtoconfirmyouhavementio confirm_famnum
rename Whatisthetotalnumberofcurr numfamily_2
drop children
drop women
rename PleasetakeaGPSreading gps
rename Youhavecompletedthequestionn qst_complete
rename V qst_refused
rename W qst_absent
drop Ifhouseholdoreligiblechilda
rename Pleaseaddanyrelevantcomments comment
rename time date

* Data calculated in questionnaire
* Number of children 
tab total_eligible
tab  total_measured
tab total_malnourished
 tab total_referred
tab percent_childmeasured

drop _version_ _version__001 _version__002 _version__003 _version__004 _version__005 __version
drop HHmembersnumfamilywomen
drop startstarttimetime


des start end deviceid team_num cluster hh_num gps  ///
	team_num consent numfamily confirm_famnum numfamily_2 ///
	numchildren numwomen gps qst_complete qst_refused /// 
	qst_absent comment province_abr date total_eligible ///
	total_measured total_malnourished total_referred percent_childmeasured

* In SMART surveys, use team_leader_num as team number
* gen team_num = team_leader_num
la var team_num "team number"
 
* Survey Date
gen temp = substr(start,1,10) 
gen surveydate = date(temp, "YMD") 
format surveydate %td
drop temp
la var surveydate "survey date"
tab surveydate

* Convert starttime from string to timestamp containing only time.
* do not strip date out of end and submission times because we need to know how much time between start and endtime.  There could be more than 24 hours. 

* how to convert string to time
* In STATA, all times are stored in reference to ZERO set to 1st Jan 1960. 
* to work with only times, in timestamps, use only the time variable with the date 1st Jan 1960. 

* In Afghanistan, is time correct. Or do we need to subtract 4:30?

* STARTTIME
gen starttime_raw = start 
gen temp = subinstr(start, "T", " ",.) 
replace temp = subinstr(temp, "+04:30", "",.) 
// cap drop starttime
gen double starttime = clock(temp,"YMDhms", 2100) 

replace temp = substr(starttime_raw ,12, 12)
gen starttime_str = "1960/01/01 " + temp
gen double startHMS = clock(starttime_str,"YMDhms", 2000) 
format starttime %tc
format startHMS %tc_HH:MM
drop starttime_str temp
cap drop starttime_raw

* ENDTIME
cap drop endtime_raw
cap drop temp
cap drop endtime
cap drop endtime_str
cap drop endHMS
gen endtime_raw = end
gen temp = subinstr(end, "T", " ",.) 
replace temp = subinstr(temp, "+04:30", "",.) 
// cap drop endtime
generate double endtime = clock(temp, "YMDhms", 2100) 

replace temp = substr(endtime_raw ,12, 12)
gen endtime_str = "1960/01/01 " + temp
gen double endHMS = clock(endtime_str,"YMDhms", 2000) 
format endtime %tc
format endHMS %tc_HH:MM:SS
drop endtime_str temp
cap drop endtime_raw



* Starttime of data collection
* Display only time (not date) in starttime
* startHMS

* Display 24 hour clock
* format timevariable %tc_HH:MM:SS

* When analyzing time of data collection (min, mean, max) use only time variables and
* not date/time variables - Cannot analyse time (HH:MM:SS) in stata as date/time

* Duration of daily fieldwork
* Calculate the first starttime and last endtime per day per team

* here used team_num instead of team_leader_num
destring team_num, replace
bysort surveydate team_num: egen daily_start = min(startHMS)
gen dur_individual_qst = hours(endtime - starttime)

bysort surveydate team_num: egen daily_end = max(endHMS)

* Sunrise in country 7:00 AM
* Sunset in country 17:10 - no surveys should completed after 19:00
* if daily_end is later than 19:00 then set to missing
*replace daily_start=. if daily_start <tc(06:30:00)
*replace daily_end=. if daily_end > tc(19:00:00)

gen dur_fieldwork = daily_end - daily_start
la var dur_fieldwork "Hours spent in the field daily"
format daily_start endHMS daily_end dur_fieldwork %tc_HH:MM


* Name of first administrative regions
gen first_admin = province
tab first_admin	


* In some surveys, the strata does not correspond to the first admin level
// la val strata province
// 1	Badakhshan
// 2	Badghis
// 3	Baghlan
// 4	Balkh
// 5	Bamyan
// 6	Daikundi
// 7	Farah
// 8	Faryab
// 9	Ghazni
// 10	Ghor
// 11	Helmand
// 12	Hirat
// 13	Jawzjan
// 14	Kabul
// 15	Kandahar
// 16	Kapisa
// 17	Khost
// 18	Kunar
// 19	Kunduz
// 20	Laghman
// 21	Logar
// 22	Nangarhar
// 23	Nimroz
// 24	Nooristan
// 25	Paktia
// 26	Paktika
// 27	Panjshir
// 28	Parwan
// 29	Samangan
// 30	Sar-e-Pul
// 31	Takhar
// 32	Urozgan
// 33	Wardak
// 34	Zabul

cap drop strata
gen strata =.
replace strata = 	1	if province =="Badakhshan"
replace strata = 	2	if province =="Badghis"
replace strata = 	3	if province =="Baghlan"
replace strata = 	4	if province =="Balkh"
replace strata = 	5	if province =="Bamyan"
replace strata = 	6	if province =="Daikundi"
replace strata = 	7	if province =="Farah"
replace strata = 	8	if province =="Faryab"
replace strata = 	9	if province =="Ghazni"
replace strata = 	10	if province =="Ghor"
replace strata = 	11	if province =="Helmand"
replace strata = 	12	if province =="Hirat"
replace strata = 	13	if province =="Jawzjan"
replace strata = 	14	if province =="Kabul"
replace strata = 	15	if province =="Kandahar"
replace strata = 	16	if province =="Kapisa"
replace strata = 	17	if province =="Khost"
replace strata = 	18	if province =="Kunar"
replace strata = 	19	if province =="Kunduz"
replace strata = 	20	if province =="Laghman"
replace strata = 	21	if province =="Logar"
replace strata = 	22	if province =="Nangarhar"
replace strata = 	23	if province =="Nimroz"
replace strata = 	24	if province =="Nooristan"
replace strata = 	25	if province =="Paktia"
replace strata = 	26	if province =="Paktika"
replace strata = 	27	if province =="Panjshir"
replace strata = 	28	if province =="Parwan"
replace strata = 	29	if province =="Samangan"
replace strata = 	30	if province =="Sar-e-Pul"
replace strata = 	31	if province =="Takhar"
replace strata = 	32	if province =="Urozgan"
replace strata = 	33	if province =="Wardak"
replace strata = 	34	if province =="Zabul"

tab strata, m	

*Add household weights after completion of data collection
gen household_freq_wgt=.
*replace household_freq_wgt=	1312.58 if strata== 1
* ETC....

* in KoboToolbox _id is a unique value for each hh survey

* count number of clusters completed per strata
* tag labels first instance of variable in data
egen clust_comp= tag(cluster)

* NOTE *******************************************
* NON UNIQUE cluster ids cause errors in the table 
table strata, c(sum clust_comp) col row cellwidth(16) format(%3.0f) 

* create composite variable of strata 
destring cluster, replace 
gen strata_cluster = strata * 1000 + cluster
// replace strata_cluster =. if cluster> 999
egen clust_comp2= tag(strata_cluster)
la var clust_comp2 "clusters completed"
table strata, c(sum clust_comp2) col row cellwidth(8) format(%3.0f) 

* Time between interviews in minutes (duration in minutes)
sort team_num starttime
* Subtract hh1 starttime from hh2 starttime
gen duration = hours(starttime[_n+1] - starttime) * 60
replace duration =. if surveydate[_n+1] != surveydate
replace duration =. if team_num[_n+1] != team_num

* set duration to missing if duration of interview was longer than 3 hours
replace duration =. if duration > 180
* hist duration

gen consent_yn = consent
drop consent
encode consent_yn , gen(consent)
recode consent (1/2=0)(3=100)
gen refusal =0 
replace refusal = 1 if consent == 0

* Number of consent by team by date
table team_num surveydate , c(mean consent) col row cellwidth(8) format(%3.0f) 

* Number of refusals of consent by team by date
table team_num surveydate , c(sum refusal) col row cellwidth(8) format(%3.0f) 

* Missing consent

// mdesc _yn gps
* bysort team_num: mdesc gps

* HOUSEHOLD MEMBERS
destring numfamily, replace
destring numfamily_2, replace
gen hh_members = numfamily
* If interviewer made a mistake with number of hh_members, they were asked to record the correct number of hh_members
replace hh_members = numfamily_2 if numfamily_2 !=. 

* NUMBER OF WOMEN
destring numwomen, gen(hh_women)
* hist hh_women, discrete

* NUMBER OF CHILDREN
destring numchildren, gen(hh_children)
* hist hh_children, discrete

* duration
table team_num surveydate,   c(mean duration min duration max duration) col row cellwidth(8) format(%3.1f) 

* start and end time of data collection 
table team_num surveydate,   c(min daily_start max daily_end) col row cellwidth(8) format(%3.1f) 

* duration of fieldwork 
table team_num surveydate,   c(mean dur_fieldwork) col row cellwidth(8) format(%3.1f) 

format startHMS %tc_HH:MM
format endHMS %tc_HH:MM

* table hh_num surveydate if team_num==19, c(mean startHMS mean endHMS)   cellwidth(8) format(%3.1f) 


* Timing of submission of data
replace _submission_time = subinstr(_submission_time, "T", " ",.) 
replace _submission_time = subinstr(_submission_time, "Z", "",.) 

generate double submission = clock(_submission_time, "YMDhms") 
format submission %tc
* drop time_to_submit
gen time_to_submit = hours(submission - starttime)
la var time_to_submit "Hours between data collection and data submission"
table team_num surveydate,   c(mean time_to_submit min time_to_submit max time_to_submit) col row cellwidth(8) format(%3.1f) 

* Strange negative time to submit times - I don't know why. 


order starttime  startHMS  endtime endHMS, last


save "`datapath'`filename_noext'_1.dta", replace


* NExt\Analysis\cleaning.do"
* Using generic dofilepath
do `dofilepath'3_cleaning"


