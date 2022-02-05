/* ACO Urban SMART  DB PREPARATION               	*/
/* Robert Johnston                                 	*/
/* 2022                        						*/
/* stata v16                                       	*/
* create ENA anthro

cd "C:\Analysis\"
local data_export_name "ACO_SMART_child"

* Child Data
use `data_export_name'.dta, clear



destring consent_yn, gen(int_result)
* 36 cases of refusals
la var int_result "Résultat de l'Entretien"
la define result 1 "Rempli"
la define result 2 "Pas de membre du ménage à la maison ou pas d’enquêté compétent au moment de la visite", add 
la define result 3 "Ménage totalement absent pour une longue période", add 
la define result 4 "Différé", add 
la define result 5 "Refusé", add 
la define result 6 "Logement vide ou pas de logement à l’adresse", add 
la define result 7 "Logement détruit", add 
la define result 8 "Logement non trouvé", add 
la define result 9 "Autre", add

* replace int_result=1 if int_result==3
drop if SURVDATE==. & CLUSTER==. & TEAM==. & HH==.


la val int_result result 
tab int_result, m 

* Review the comments for other surveys to delete. 
// replace comment ="" if comment=="Ras"


gen blank =1 if comment==""
capture log close
log using "C:\Analysis\Comments.log", replace
*already reviewed consent is No and consent missing. 
* list _index comment if blank!=1 
log close


* Interview Result 
* Consent_yn was 1 or 0 , not missing
                                                            
* all cases of refusal
// replace int_result =  3  if _index==6333 

* Missing Consent
// replace int_result = 3  if _index== 2192

// replace int_result = 3  if _index== 6401

format int_result %18.0g
tab int_result, m 
format int_result %8.0g

tab strata int_result, m 

* Breastfeeding and other variables
rename curr_bf curr_bf_str
encode curr_bf_str, gen(curr_bf)
tab curr_bf curr_bf_str
la def SEX 1 male 2 female
la val SEX SEX
tab SEX, m 

tab curr_bf, m 
tab STRATA_NAME curr_bf, row 
// tab STRATA_NAME curr_bf, row format(%3.1f)  
// table STRATA_NAME curr_bf, perc format(%3.1f)  
tab SEX curr_bf, row 

cap drop curr_bf_100
gen curr_bf_100 = curr_bf
recode curr_bf_100 (2=100)(1=0)
tab curr_bf_str curr_bf_100
gen curr_bf_girl = curr_bf_100 if SEX==2
gen curr_bf_boy = curr_bf_100 if SEX==1

sort MONTHS
twoway (lpoly curr_bf_girl MONTHS) (lpoly curr_bf_boy MONTHS) if MONTHS<24, ///
   ytitle("% currently breastfeeding") xtitle("Age in Months") title("Current breastfeeding by age in months & sex") 

* vita ari fever diarrhea measles   
tab SEX measles, row  
tab SEX vita, row  

tab SEX ari, row  
tab SEX fever, row  
tab SEX diarrhea, row  


* Difference between 1st and final measures
gen wgt_final = .
replace wgt_final = weight_2 if weight_2 !=.
replace wgt_final = weight_3 if weight_3 !=.
tab wgt_final, m 
gen wgt_diff = wgt_final- weight
sum wgt_diff
tab wgt_diff, m 
scatter wgt_diff weight

gen hgt_final = .
replace hgt_final = height_2 if height_2 !=.
replace hgt_final = height_3 if height_3 !=.
tab hgt_final, m 
gen hgt_diff = hgt_final- height
sum hgt_diff
tab hgt_diff, m 
scatter hgt_diff height


* Weight measures by clothed / unclothed
cap drop clothed_wgt
cap drop unclothed_wgt
cap drop weighed_clothed
destring WEIGHT, replace

encode CLOTHES, gen(weighed_clothed)
tab weighed_clothed, m 
gen clothed_wgt = WEIGHT if weighed_clothed==1
gen unclothed_wgt = WEIGHT if weighed_clothed==2
tab CLOTHES weighed_clothed, m 

tab STRATA_NAME weighed_clothed, row
table STRATA_NAME, c(mean clothed_wgt mean unclothed_wgt n weighed_clothed) col row


sort MONTHS
twoway (lpolyci clothed_wgt MONTHS) (lpolyci unclothed_wgt MONTHS) if MONTHS<60, ///
   ytitle("Wgt in KG") xtitle("Age in Months") title("Weight by age in months by clothed/unclothed") 

destring WEIGHT, replace
table TEAM SEX, c(mean WEIGHT min WEIGHT max WEIGHT n WEIGHT) col row cellwidth(16) format(%3.1f) 

gen girlwgt = WEIGHT if SEX==2
gen boywgt = WEIGHT if SEX==1

sort MONTHS
twoway (lpolyci girlwgt MONTHS) (lpolyci boywgt MONTHS) if MONTHS<60, ///
   ytitle("count") title("Weight by sex and age in months ") 
   
// twoway (scatter girlwgt MONTHS) (scatter boywgt MONTHS) if MONTHS<60 

// graph twoway (line girlwgt MONTHS) (line boywgt MONTHS), label(labsize(1) angle(45) alternate) ///
//    ytitle("count") title("Weight by sex and age in months ") 

table STRATA_NAME SEX, c(mean WEIGHT min WEIGHT max WEIGHT n WEIGHT) col row cellwidth(16) format(%3.1f) 

destring HEIGHT, replace
table STRATA_NAME SEX, c(mean HEIGHT min HEIGHT max HEIGHT n HEIGHT) col row cellwidth(16) format(%3.1f) 

gen girlhgt = HEIGHT if SEX==2
gen boyhgt = HEIGHT if SEX==1

twoway (lpolyci girlhgt MONTHS) (lpolyci boyhgt MONTHS) if MONTHS<60, ///
   ytitle("count") title("Height by sex and age in months ") 
   
table STRATA_NAME SEX, c(mean MUAC min MUAC max MUAC n MUAC) col row cellwidth(16) format(%3.1f) 

gen girlmuac = MUAC if SEX==2
gen boymuac = MUAC if SEX==1

twoway (lpolyci girlmuac MONTHS) (lpolyci boymuac MONTHS) if MONTHS<60, ///
   ytitle("count") title("MUAC by sex and age in months ") 
   
* Age in months by sex
gen one = 1
* this graph does not work if there are not data for each unit on x axis. 
graph bar (count) one if MONTHS>=0, over(MONTHS, label(labsize(1) angle(45) alternate)) ///
   ytitle("count") title("Counts of anthropometric measures of age in months ") 

gen girl = 1 if SEX==2
gen boy = 1 if SEX==1

graph bar (count) girl boy, over(MONTHS, label(labsize(1) angle(45) alternate)) ///
   ytitle("count") title("Counts of anthropometric measures of age in months ") 


















* DIFFERENCES IN FIRST AND FINAL MEASURES
* initial values such as 
* birthdate_init, weight_init, height_init were not collected in Liberia
* comment out section below

* set all vars to zero
*gen diff_birthdate =0 if age>=0 & age<=59 | age==98
*gen diff_months =0    if age>=0 & age<=59 | age==98
*gen diff_wgt =0       if age>=0 & age<=59 | age==98
*gen diff_hgt =0       if age>=0 & age<=59 | age==98 
*gen diff_meas =0      if age>=0 & age<=59 | age==98
*gen diff_muac =0      if age>=0 & age<=59 | age==98

* BIRTHDATE
* here the default value (survey date) recorded is often stored as the initial value. 
*replace diff_birthdate = 100 if birthdate != birthdate_init
*replace birthdate_init =.  if birthdate_init >= surveydate
*replace birthdate_init =.  if birthdate_init < date("1 Jan 2009","DMY")
*la var birthdate "Birth Date"
*la var birthdate_init "First Entry of Birth Date"

*table team_number, c(mean diff_birthdate count diff_birthdate) col row cellwidth(16) format(%3.1f) 

*replace diff_months = 100 if months != months_init
*replace months_init = 99 if months_init >99
* warning: changed keying errors / unacceptable values set to 99
* scatter months months_init

* ANTHROPOMETRY
*replace diff_wgt = 100 if weight != weight_init
*replace weight_init =99 if weight_init>99
*replace diff_hgt = 100 if height != height_init   
*replace diff_meas = 100 if measure != measure_init   
*replace diff_muac = 100 if muac != muac_init

* Was child remeasured after WHO flag
* if flag for second measure then set var to zero to indicate this is a valid case. 
gen re_age = 0 if flag==1 
gen re_wgt = 0 if flag==1 
gen re_hgt = 0 if flag==1 
gen re_meas = 0 if flag==1  
gen re_muac = 0 if flag==1 
gen re_edema = 0 if flag==1 
* Remeasure after flag - global
gen re_global = 0 if flag==1

replace re_age = 100 if flag==1 & MONTHS_2 !=. 
replace re_wgt = 100 if flag==1 & weight_2 !=. 
replace re_hgt = 100 if flag==1 & height_2 !=. 
// replace re_meas = 100 if flag==1 & measure_2 !=. 
sum muac_2
replace re_muac = 100 if flag==1 & muac_2 !=. 
replace re_edema = 100 if flag==1 & edema_2 !=. 
replace re_global = (re_age + re_wgt + re_hgt + re_meas + re_muac + re_edema)/6 if flag==1
table team_number, c(mean re_global count re_global) col row cellwidth(16) format(%3.1f) 



* Was child remeasured after random
destring rand age_3 edema_3, replace
replace random = rand
recode random (0/0.04999999 = 1)(0.05/1 = 0)
tab team_number random

gen rand_age   = 0 if random==1 
gen rand_wgt   = 0 if random==1 
gen rand_hgt   = 0 if random==1 
gen rand_meas  = 0 if random==1  
gen rand_muac  = 0 if random==1 
gen rand_edema = 0 if random==1 
gen rand_global = 0 if random==1 

replace rand_age   = 100 if random==1 & age_3     !=. 
replace rand_wgt   = 100 if random==1 & weight_3  !=. 
replace rand_hgt   = 100 if random==1 & height_3  !=. 
replace rand_meas  = 100 if random==1 & measure_3 !=. 
replace rand_muac  = 100 if random==1 & muac_3    !=. 
replace rand_edema = 100 if random==1 & edema_3   !=. 
* average of all rand_meas
replace rand_global = (rand_age + rand_wgt + rand_hgt + rand_meas + rand_muac + rand_edema)/6 if random==1 
table team_number, c(mean rand_global n rand_global) col row cellwidth(16) format(%3.1f) 


*error in measure - Mason's analysis of Ethiopia DHS data
* measure - 1 = standing height, 2 = recumbent length
gen age2 = age
replace age2 =. if age>59
gen hgt = height
replace hgt =. if height> 120

egen meanlgt = mean(hgt) if measure==2, by(age2) 
egen meanhgt = mean(hgt) if measure==1, by(age2) 
sort age2
line meanlgt age2 || line meanhgt age2  
* difficult to interpret because have not eliminated means based on too few cases. 


gen lgt_err = 0
replace lgt_err =100 if measure==2 & height>=87
gen hgt_err = 0
replace hgt_err =100 if measure==1 & height<87
tab lgt_err hgt_err, m

*list height measure if  hgt_err ==100
table team_number, c(mean lgt_err n lgt_err mean hgt_err n hgt_err) col row cellwidth(16) format(%3.1f) 

table team_number , c(mean lgt_err n lgt_err mean hgt_err n hgt_err) col row cellwidth(16) format(%3.1f) 



