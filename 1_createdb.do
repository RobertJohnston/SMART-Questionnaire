/* ACO Urban SMART  DB PREPARATION               	*/
/* Robert Johnston                                 	*/
/* 2022                        				*/
/* stata v16                                    	*/

* code to add to Stata
* ssc install xls2dta

* Make a daily list below of raw data downloaded from day 1 of data collection to final cleaned dataset. 
* Each file will be labelled with the date and time of creation, for example: 

* ACO_SMART_Survey_2022_-_all_versions_-_English_-_2022-01-22-06-06-01
* ACO_SMART_Survey_2022_-_all_versions_-_English_-_2022-01-24-05-30-30
* ACO_SMART_Survey_2022_-_all_versions_-_English_-_2022-01-24-14-17-57
* ACO_SMART_Survey_2022_-_all_versions_-_English_-_2022-01-26-01-32-47
* ACO_SMART_Survey_2022_-_all_versions_-_English_-_2022-01-28-01-21-42
* ACO_SMART_Survey_2022_-_all_versions_-_English_-_2022-01-30-03-15-41
* ACO_SMART_Survey_2022_-_all_versions_-_English_-_2022-01-30-17-42-45
* ACO_SMART_Survey_2022_-_all_versions_-_English_-_2022-02-01-01-04-12
* ACO_SMART_Survey_2022_-_all_versions_-_English_-_2022-02-02-01-18-39

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
display "`filename_noext'"

* Remove filler text
* local temp = subinstr("`temp'", "_Survey_2022_-_all_versions_-_English_-", "", .)



* Analysis flow 
* when you run the first do file 1_createdb.do, it will continue automatically to run the 2nd, and following do files. 
* 1_createdb.do - Prepare databases 
* 2_name_var.do - Rename variables - destring and name variables and values
* 3_cleaning.do - Prepare variables and remove errors with IDs
* 4_createENAanthro.do
* 5_createENAmortality.do
* 6_analysis.do - Produce analysis on DQ

clear all
set more off 

* xls2dta using "`datapath'/`filename'", allsheets firstrow 
* Use a forward slash in front of the local macro, and do not use quotes in between:
* The backslash acts as escape character in Stata. 
* EXAMPLE  "c:\union_pop\orig/`file'"
* if xls2dta is not available in your version of Stata, install it by typing "findit xls2dta" in command window.

* Check if this can be changes to import excel command. 
// xls2dta, save(C:\Analysis\) allsheets :import excel using "`datapath'`filename'", firstrow 
cd `datapath'
xls2dta, save(, replace) allsheets :import excel using "`datapath'`filename'", firstrow 
display "`filename'"


* there are four tabs with data converted to STATA
* consent
* household listing
* child
* pregnant lactating woman

* the code below describes the process of creation of data for full SMART with anthropometry and mortality

* Either 5 or 6 databases are exported
* 1st database
* Household identification, cluster, GPS, date, consent, number of hh members, women, children
* use `filename_noext'_1.dta", clear

* 2nd database - Household composition, age, sex, joined, born
* Population pyramid
* use `filename_noext'_2.dta", clear

* 3rd database
* Child Anthro Data
* use `filename_noext'_5.dta", clear

* 4th database
* Woman Anthro Data
* use `filename_noext'_6.dta", clear

* Change path to /analysis
* do "`datapath'SEN_SMART_2015_2_name_var"

* Continue with cleaning household database. 

* Return to output datapath
cd C:\Analysis\

* Change to generic dofilepath 

* Change the local variable 'dofilepath' to the filepath where you store the do files.
local dofilepath "C:\Users\Rojohnston\OneDrive - UNICEF\1 UNICEF Work\1 Afghanistan\Surveys\2022 UrbanSMART\Analysis/"
di "`dofilepath'2_name_vars.do"

do "`dofilepath'2_name_vars.do"

* END OF FILE
