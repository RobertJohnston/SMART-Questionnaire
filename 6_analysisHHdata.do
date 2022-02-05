/* SMART 2016 DB PREPARATION               	*/
/* Robert Johnston                                 	*/
/* 4 May 2016                        				*/
/* stata v12                                    	*/

* Further analysis on household database. 


cd "C:\Analysis\"

use "${filename_noext}_1.dta", clear
* This above should refer to a data file that has been cleaned with named variables. 
* Should export - raw data
* cleaned data with named variables data for export.

*for DATA CLEANING - see file #3


* check for errors in recording cluster number

* number of HH completed
* all clusters should have about 20 household surveys

log using "C:\Analysis\Daily DQ Report.log", replace

* Review cluster numbers
tab cluster, m 

* Check if clusters are  unique
* uniq_clust = strata + cluster number
* Identify errors in the table below if the SD does not = 0
table uniq_clust, c(mean team_number sd team_number) col row cellwidth(8)


* Median duration in minutes of household interview (Centile as in 50% percentile)
* centile duration

* Duration in minutes of household interview (length from start time of one household until beginning of next household)
mean duration, over(team_number)
* Min, mean and max duration in minutes of household interview
table team_number, c(min duration mean duration max duration count duration) col row cellwidth(12) format(%3.1f) 
histogram duration
scatter duration hh_members

* Timing of submission of data (in hours)
* Average time to submit the household questionnaire in hours. 
mean time_to_submit, over(team_number)
* Table of time to submit the household questionnaire in hours. 
table surveydate team_number, c(mean time_to_submit) col row cellwidth(8) format(%3.0f) 

* Duration of daily fieldwork

* Sunrise in Country ~6:30  no surveys should start before 6:30
* Sunset in Country ~18:00 - no surveys should be completed after 19:00
* Working outside these hours is dangerous for team members and should not be permitted.

* The table below presents the data by team and survey date of
* Start time 
* End time 
* Number of hours in field
table surveydate team_number, c(mean daily_start mean daily_end mean dur_fieldwork) cellwidth(20) format(%3.0f) 

* Median number of hours to submit data. 
centile time_to_submit

* Number of households completed by cluster
* this analysis is not perfect as there maybe errors in cluster ID

* Number of households completed by team by date
table surveydate team_number, c(count hh_number) col row cellwidth(8)

* Number of refusals by team and by date
* gen refusal = 1 if consent ==0
table surveydate team_number, c(count refusal) col row cellwidth(8) format(%3.1f) 
table team_number, c(count refusal) col row cellwidth(12) format(%3.1f) 
list team_number comment if refusal ==1

* Number of missing consent by team
table team_number, c(count missing_consent) col row cellwidth(12) format(%3.1f) 
list team_number comment if missing_consent ==1

* Percent of successfully completed interviews by team by date
table surveydate team_number, c(mean consent) col row cellwidth(8) format(%3.1f) 

* Number of household members by team
* Note - N = number of households
table team_number, c(mean hh_members sd hh_members min hh_members max hh_members count hh_members) col row cellwidth(16) format(%3.1f) 

* Number of women aged 12-49 years of age in household by team
* Note - N = number of households
table team_number, c(mean hh_women sd hh_women min hh_women max hh_women count hh_women) col row cellwidth(16) format(%3.1f) 

* Number of children under five years of age in household  by team
* Note - N = number of households
table team_number, c(mean hh_children sd hh_children min hh_children max hh_children count hh_children) col row cellwidth(16) format(%3.1f) 


*CHILD ANALYSES
use "${filename_noext}_5.dta", clear

* Missing data 
* Sex and age for all children under 6 years
* Percent of missing data on Weight Height Measure MUAC Edema and Edema_confirm for all children under 5 years
table team_number, c(m missing_sex m missing_age m missing_wgt m missing_hgt) col row cellwidth(16) format(%3.1f) 
table team_number, c(m missing_meas m missing_muac m missing_edema m edema_confirm_missing ) col row cellwidth(16) format(%3.1f) 

* Vita Deworming Measles for children 6-59m.
* table team_number, c(count missing_vita count missing_worm count missing_measle) col row cellwidth(16) format(%3.0f) 

* Confirm edema
list first_admin team_number age child_sex weight height muac if edema_confirm ==1
list team_number surveydate first_admin cluster hh_num if edema_confirm ==1

* Number of Flags
table surveydate team_number, c(count flag) col row cellwidth(8) format(%3.1f) 

* Changes from initial data to remaining 1st entry
* Percent of differences between initial to saved 1st entry and N of measures taken by team number
* Teams with more than 10% of difference are working too fast without sufficient concentration on entering data. 
* These variables on initial measure were removed - did not work with older version of ODK - no updates to server were made

* table team_number, c(mean diff_birthdate count diff_birthdate mean diff_months count diff_months) col row cellwidth(20) format(%3.1f) 
* table team_number, c(mean diff_wgt count diff_wgt mean diff_hgt count diff_hgt) col row cellwidth(16) format(%3.1f) 
* table team_number, c(mean diff_meas count diff_meas mean diff_muac count diff_muac) col row cellwidth(16) format(%3.1f) 

* Was child remeasured after WHO flag (mesure de contrôle)
table team_number, c(mean re_age  count re_age  mean re_wgt   count re_wgt)   col row cellwidth(16) format(%3.1f) 
table team_number, c(mean re_hgt  count re_hgt  mean re_meas  count re_meas)  col row cellwidth(16) format(%3.1f) 
table team_number, c(mean re_muac count re_muac mean re_edema count re_edema) col row cellwidth(16) format(%3.1f) 
table team_number, c(mean re_global count re_global) col row cellwidth(16) format(%3.1f) 

* Was child remeasured after random 
table team_number, c(mean rand_age count rand_age mean rand_wgt count rand_wgt) col row cellwidth(16) format(%3.1f) 
table team_number, c(mean rand_hgt count rand_hgt mean rand_meas count rand_meas) col row cellwidth(16) format(%3.1f) 
table team_number, c(mean rand_muac count rand_muac mean rand_edema count rand_edema) col row cellwidth(16) format(%3.1f) 
table team_number, c(mean rand_global count rand_global) col row cellwidth(16) format(%3.1f) 

* Date of birth or age in months by team
tab team_number dob_or_months, nofreq row 

* Percent of children 5 years of age of all children < 6 years 
* The result should be ~ 9%.  Lower % means that they are not checking ages for children at 5 years
* Higher % means that they could be increasing age of child to avoid anthropometry
table team_number, c(mean age_5yrs count age_5yrs) col row cellwidth(16) format(%3.1f) 








log close
* END OF FILE.




* Delete all globals (macros)
ma drop _all



