/* ACO Urban SMART DB PREPARATION               	*/
/* Robert Johnston                                 	*/
/* 2022                        						*/
/* stata v16                                       	*/


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



* add all necessary data cleaning below

* data_1 is the consent & GPS data
use "`datapath'`filename_noext'_1.dta", clear

// use ACO_SMART_Survey_2022_2022-01-24-05-30-30_1.dta, clear

* Assign country name
gen country ="Afghanistan"

* check if there are errors in cluster number
tab cluster, m 

*Create ID of Team Leader and Cluster number
gen uniq_clust = strata*100 + cluster
tab uniq_clust, m

destring hh_num, replace
gen uniq_hh = uniq_clust*100 + hh_num

* If any Errors in cluster number
* Make corrections to data below. 





* Team numbers
sort first_admin cluster hh_num deviceid
sort surveydate deviceid
order starttime deviceid first_admin cluster hh_num

tab team_num, m

* Errors in team number
* Make corrections to data below. 
// list surveydate team_num first_admin cluster hh_number comment if team_num ==22
* replace team_number =  if team_number ==

* Review Comments
order surveydate strata uniq_clust cluster team_num hh_num uniq_hh comment
* Drop clusters that are marked as "A Suprimer or to delete"
tab comment, m 

gsort -strata
gsort -cluster

* Recreate ID of Team Leader and Cluster number
replace uniq_clust = strata*100 + cluster

replace uniq_hh = uniq_clust*100 + hh_num

save "`datapath'`filename_noext'_1.dta" , replace

do "`dofilepath'4_createENAanthro"

