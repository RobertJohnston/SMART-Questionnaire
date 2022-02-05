/* Senegal SMART 2015 Create Woman's Database       */
/* Robert Johnston                                 	*/
/* 29 Oct 2015                        				*/
/* C:/data/                                        	*/
/* stata v12                                    	*/

* Merge db1 household data  with db6 woman's anthro data
* Order data
* Save

clear
set more off 
cd C:\Analysis\

* Woman Anthro Data
use "${filename_noext}_6.dta", clear
 
* Remove consent bla from variable names
foreach var of varlist _all {
local newname = subinstr("`var'", "consentwoman", "", .)
rename `var' `newname'
}
foreach var of varlist _all {
local newname = subinstr("`var'", "woman", "", .)
rename `var' `newname'
}
drop _name _cluster _team_num _hh_num _name_note note_8 _id _uuid _submission_time _tags _notes

destring _selected_posi, gen(eligible_wom_number)
la var eligible_wom_number "Count of eligible women in hh- Start at 0"
destring _hh_position, gen(hh_listing_number)
la var eligible_wom_number "Household listing number"

destring _age_years, gen (wom_age)
destring preg, replace
destring union, gen (breastfeed)
drop _selected_posi _hh_position _age_years union
replace wom_age=. if wom_age<12 | wom_age>49
*BMI (weight in kg / height in meters squared)
gen wom_bmi = wom_wgt/(wom_hgt/100)^2

duplicates report eligible_wom_number hh_listing_number wom_age wom_wgt wom_hgt wom_muac preg breastfeed _index, gen(dup)

sort _index

* End of woman preparation
save, replace

* Replace country in list below. 

* use country surveydate cluster dr_number team_number strata hh_num _index nom_chef_equipe using "${filename_noext}_1.dta", clear
use surveydate cluster dr_number team_number strata hh_num _index nom_chef_equipe int_result uniq_clust using "${filename_noext}_1.dta", clear
gen id = _index
sort id
save merge_temp, replace

* merge in cluster, team_num, hh_num
use "${filename_noext}_6.dta", clear

* cannot run syntax if saved previously because of line below. 
gen id = _parent_index
sort id
merge m:1 id using merge_temp
* merge 2 are the households with no women
drop if _merge == 2

* two women from households not found - no anthro data. 
drop if int_result !=1

* Add survey weights
gen woman_freq_wgt =. 
replace woman_freq_wgt=	1154.1 if strata==1
replace woman_freq_wgt=	181.63 if strata==2
replace woman_freq_wgt=	225.73 if strata==3
replace woman_freq_wgt=	35.17  if strata==4
replace woman_freq_wgt=	41.67  if strata==5
replace woman_freq_wgt=	54.41  if strata==6
replace woman_freq_wgt=	77.85  if strata==7
replace woman_freq_wgt=	161.28 if strata==8
replace woman_freq_wgt=	226.13 if strata==9
replace woman_freq_wgt=	126.58 if strata==10
replace woman_freq_wgt=	153.86 if strata==11
replace woman_freq_wgt=	172.29 if strata==12
replace woman_freq_wgt=	44.13  if strata==13
replace woman_freq_wgt=	86.33  if strata==14
replace woman_freq_wgt=	47.06  if strata==15
replace woman_freq_wgt=	81.98  if strata==16

* Add country to list below
order strata surveydate cluster hh_num hh_listing_number wom_age wom_wgt wom_hgt wom_bmi wom_muac preg breastfeed

*save final women's data
save "C:\Analysis\SMART2015_Sen_Femme.dta", replace
export excel using "SMART2015_Sen_Femme.xls", firstrow(variables) nolabel replace

END

* analysis of mean weight, height, muac
scatter wom_wgt wom_age
scatter wom_hgt wom_age
scatter wom_muac wom_age
scatter wom_hgt wom_muac 
scatter wom_bmi wom_muac 

egen meanmuac = mean(wom_muac) if preg!=1 & breastfeed!=1 , by(wom_age) 
egen meanmuac_b = mean(wom_muac) if breastfeed==1 , by(wom_age) 
egen meanmuac_p = mean(wom_muac) if preg==1  , by(wom_age) 

sort wom_age
line meanmuac wom_age 
line meanmuac wom_age || line meanmuac_b wom_age 
line meanmuac wom_age || line meanmuac_b wom_age || line meanmuac_p wom_age 

