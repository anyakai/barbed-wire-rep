/*
Date:  Feb 1, 2010
Author:  Richard Hornbeck
Compatibility:  Stata 11

This do file replicates analysis from "Barbed Wire:  Property Rights and Agricultural Development" by Richard Hornbeck, May 2010 Quarterly Journal of Economics.

The analysis originally used a web extract from the Great Plains Project (see data file notes) and earlier versions of Stata.  Documentation and future replication is more straightforward with the ICPSR analog to the Great Plains Data, and Stata is now at version 11.  This creates small rounding differences from the published version in some of the replication results.

This file analyzes the sample of counties based on a base year of 1880.
*/

set mem 500m
set matsize 800
set more off
set graphics off
use Base1880.dta, clear
capture log close
log using Analysis_base1880_1Feb2010.log, replace

tempfile preanalysis_1880 nsew_1880 region_1880 subregion_1880 soil_1880 pre_initial_18880 1880_rr 1890_rr 1900_rr 1910_rr 1920_rr rr_base1880 

***
*Prepare the data for analysis
***

*Create State Variable
gen state = 0
replace state = 8 if unfips > 8000 & unfips < 9000
replace state = 19 if unfips > 19000 & unfips < 20000
replace state = 20 if unfips > 20000 & unfips < 21000
replace state = 27 if unfips > 27000 & unfips < 28000
replace state = 30 if unfips > 30000 & unfips < 31000
replace state = 31 if unfips > 31000 & unfips < 32000
replace state = 35 if unfips > 35000 & unfips < 36000
replace state = 38 if unfips > 38000 & unfips < 39000
replace state = 40 if unfips > 40000 & unfips < 41000
replace state = 46 if unfips > 46000 & unfips < 47000
replace state = 48 if unfips > 48000 & unfips < 49000
replace state = 56 if unfips > 56000 & unfips < 57000
label var state "State"
*8 - Colorado
*19 - Iowa
*20 - Kansas
*27 - Minnesota
*30 - Montana
*31 - Nebraska
*35 - New Mexico
*38 - North Dakota
*40 - Oklahoma
*46 - South Dakota
*48 - Texas
*56 - Wyoming
keep if state==8|state==19|state==20|state==27|state==31|state==48

sort unfips year
replace are_xx_a = are_xx_a[_n+1] if are_xx_a==.

*generate timber fraction variable
gen timber_percent =  wod_xx_a/ are_xx_a
gen timber1880 = timber_percent if year == 1880
sort unfips
by unfips: egen timber = mean(timber1880)
label var timber "Woodland percent" 
gen stimber = timber^2
gen ctimber = timber^3
gen qtimber = timber^4

*add up all cropland
egen cropland = rsum(bar_xh_a bea_xh_a bet_xh_a cot_xh_a crn_gh_a flx_xh_a hay_xh_a oat_xh_a pea_xh_a pnt_xh_a pot_xh_a rye_xh_a wht_xh_a)
*add up all cropland for all original crops
egen cropland_original = rsum(bar_xh_a cot_xh_a crn_gh_a hay_xh_a oat_xh_a rye_xh_a wht_xh_a)

*generate percentage variables, note some are > 1
gen ctl_xx_qA = 5*ctl_xx_q/are_xx_a
gen crop_percent = cropland/fml_xx_a
*gen crop_percent = cropland_original/fml_xx_a
drop if crop_percent>1

gen croplandF = cropland/fml_xx_a
egen risk = rsum(bar_xh_a crn_gh_a oat_xh_a rye_xh_a wht_xh_a)
gen percent_risk = risk/cropland_original
egen cotton = rsum(cot_xh_a)
gen percent_cotton = cotton/cropland_original
egen hay = rsum(hay_xh_a)
gen percent_hay = hay/cropland_original
egen barley = rsum(bar_xh_a)
gen percent_barley = barley/cropland_original
egen corn = rsum(crn_gh_a)
gen percent_corn = corn/cropland_original
egen oat = rsum(oat_xh_a)
gen percent_oat = oat/cropland_original
egen rye = rsum(rye_xh_a)
gen percent_rye = rye/cropland_original
egen wheat = rsum(wht_xh_a)
gen percent_wheat = wheat/cropland_original


gen year_state = year*100+state
sort year_state
by year_state: egen meancrop = mean(crop_percent)
gen varcrop = (crop_percent - meancrop)^2

tsset unfips year
sort unfips
by unfips: gen dctl_xx_qA = ctl_xx_qA - ctl_xx_qA[_n-1]
by unfips: gen dvarcrop = varcrop - varcrop[_n-1]
by unfips: gen dpercent_risk = percent_risk - percent_risk[_n-1]

by unfips: gen dcroplandF = croplandF - croplandF[_n-1]
sort unfips
by unfips: egen balance6 = count(ctl_xx_qA)
by unfips: egen balance7 = count(varcrop)
by unfips: egen balance_risk = count(percent_risk)
by unfips: egen balance_cf = count(croplandF)

by unfips: egen check = sd(are_xx_a)
drop if check>50000

gen group=1 if timber<.04
replace group=2 if timber>.04&timber<.08
replace group=3 if timber>.08&timber<.12

gen col5 = (group==1|group==2)
gen col6 = (group==2|group==3)
gen group1 = (group==1)
gen group2 = (group==2)
gen group3 = (group==3)

keep if balance_risk==5
*tab balance_cf
*tab balance_risk
*tab balance6
*tab balance7
char year[omit]1880
xi: reg dcroplandF i.year*timber i.year*stimber i.year*ctimber i.year*qtimber

gen double unyear = unfips*10000+year
sort unfips year
save `preanalysis_1880', replace
clear


***
*Table 2, Summary Statistics
***
clear
use `preanalysis_1880'

sum croplandF if year==1880
sum croplandF if group==1&year==1880
sum croplandF if group==2&year==1880
sum croplandF if group==3&year==1880
reg croplandF group2 if year==1880&col5==1, robust
reg croplandF group3 if year==1880&col6==1, robust

sum percent_corn if year==1880
sum percent_corn if group==1&year==1880
sum percent_corn if group==2&year==1880
sum percent_corn if group==3&year==1880
reg percent_corn group2 if year==1880&col5==1, robust
reg percent_corn group3 if year==1880&col6==1, robust

sum percent_wheat if year==1880
sum percent_wheat if group==1&year==1880
sum percent_wheat if group==2&year==1880
sum percent_wheat if group==3&year==1880
reg percent_wheat group2 if year==1880&col5==1, robust
reg percent_wheat group3 if year==1880&col6==1, robust

sum percent_hay if year==1880
sum percent_hay if group==1&year==1880
sum percent_hay if group==2&year==1880
sum percent_hay if group==3&year==1880
reg percent_hay group2 if year==1880&col5==1, robust
reg percent_hay group3 if year==1880&col6==1, robust

sum percent_oat if year==1880
sum percent_oat if group==1&year==1880
sum percent_oat if group==2&year==1880
sum percent_oat if group==3&year==1880
reg percent_oat group2 if year==1880&col5==1, robust
reg percent_oat group3 if year==1880&col6==1, robust

sum percent_barley if year==1880
sum percent_barley if group==1&year==1880
sum percent_barley if group==2&year==1880
sum percent_barley if group==3&year==1880
reg percent_barley group2 if year==1880&col5==1, robust
reg percent_barley group3 if year==1880&col6==1, robust

sum percent_rye if year==1880
sum percent_rye if group==1&year==1880
sum percent_rye if group==2&year==1880
sum percent_rye if group==3&year==1880
reg percent_rye group2 if year==1880&col5==1, robust
reg percent_rye group3 if year==1880&col6==1, robust

***
*Table 5, Crop switching analysis (columns 3 and 4, columns 7 and 8)
***
clear
use `preanalysis_1880'
areg dcroplandF _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

areg dpercent_risk _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

***
*Table 7, Cattle and Specialization
***
clear
use `preanalysis_1880'
sum ctl_xx_qA if year==1880, detail
areg dctl_xx_qA _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

sum varcrop if year==1880, detail
areg dvarcrop _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

***
*Table 5, Productivity analysis (columns 1 and 2, columns 5 and 6)
***
clear
use `preanalysis_1880'

*production variables
gen bar_xh_aA = bar_xh_a/are_xx_a
gen hay_xh_aA = hay_xh_a/are_xx_a
gen oat_xh_aA = oat_xh_a/are_xx_a
gen rye_xh_aA = rye_xh_a/are_xx_a
gen wht_xh_aA = wht_xh_a/are_xx_a
gen crn_gh_aA = crn_gh_a/are_xx_a

gen p_barley = bar_xh_b/bar_xh_a
gen p_hay = hay_xh_t/hay_xh_a
gen p_oat = oat_xh_b/oat_xh_a
gen p_rye = rye_xh_b/rye_xh_a
gen p_wheat = wht_xh_b/wht_xh_a
gen p_corn = crn_gh_b/crn_gh_a

gen p_barley1880 = p_barley if year ==1880
gen p_hay1880 = p_hay if year ==1880
gen p_oat1880 = p_oat if year ==1880
gen p_rye1880 = p_rye if year ==1880
gen p_wheat1880 = p_wheat if year ==1880
gen p_corn1880 = p_corn if year ==1880

sort unfips
by unfips: egen p_haybase = mean(p_hay1880)
by unfips: egen p_barleybase = mean(p_barley1880)
by unfips: egen p_oatbase = mean(p_oat1880)
by unfips: egen p_ryebase = mean(p_rye1880)
by unfips: egen p_wheatbase = mean(p_wheat1880)
by unfips: egen p_cornbase = mean(p_corn1880)

gen prbarley = p_barley/p_barleybase
gen prhay = p_hay/p_haybase
gen proat = p_oat/p_oatbase
gen prrye = p_rye/p_ryebase
gen prwheat = p_wheat/p_wheatbase
gen prcorn = p_corn/p_cornbase

reshape long pr, i(unyear) j(crop barley hay oat rye wheat corn)

gen id=1 if crop=="barley"
replace id=2 if crop=="hay"
replace id=3 if crop=="oat"
replace id=4 if crop=="rye"
replace id=5 if crop=="wheat"
replace id=7 if crop=="corn"

gen double unfips_crop = unfips*10 + id

gen double state_crop = state*10 + id
gen double state_crop_year = state_crop*10000+year

*centile pr, c(0(1)100)

drop if pr<.36
drop if pr>6.4

sort unfips_crop
by unfips_crop: egen balance5 = count(pr)
keep if balance5==5

*crop weights
gen weight = bar_xh_a if id==1&year==1880
replace weight = hay_xh_a if id==2&year==1880
replace weight = oat_xh_a if id==3&year==1880
replace weight = rye_xh_a if id==4&year==1880
replace weight = wht_xh_a if id==5&year==1880
replace weight = crn_gh_a if id==7&year==1880
sort unfips_crop
by unfips_crop: egen cropweight = max(weight)

tsset unfips_crop year
sort unfips_crop
by unfips_crop: gen dpr = pr - pr[_n-1]
char year[omit]1880
xi: reg dpr i.year*timber i.year*stimber i.year*ctimber i.year*qtimber

areg dpr _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920, absorb(state_crop_year) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

gen crop_group=1 if id==1|id==3|id==4|id==5|id==7
replace crop_group=2 if id==2

areg dpr _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 if crop_group==1, absorb(state_crop_year) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

areg dpr _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 if crop_group==2, absorb(state_crop_year) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

*Use crop weights

areg dpr _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 [aweight=cropweight], absorb(state_crop_year) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

areg dpr _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 [aweight=cropweight] if crop_group==1, absorb(state_crop_year) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

areg dpr _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 [aweight=cropweight] if crop_group==2, absorb(state_crop_year) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])


***
*Robustness checks
***

*Distance analysis

clear
insheet using 1880_nsew.txt, tab
rename id unfips
gen statefips=floor(unfips/1000)
keep if statefips==8|statefips==19|statefips==20|statefips==27|statefips==31|statefips==48
keep unfips yaxis xaxis
sort unfips
save `nsew_1880', replace
clear

use `preanalysis_1880'
merge unfips using `nsew_1880'
keep if _merge==3
drop _merge

foreach year of numlist 1890(10)1920 { 
gen double west_`year' = xaxis if year==`year'
replace west_`year' = 0 if west_`year'==.
}

gen louis = ((xaxis-1911)^2 + (yaxis-1112)^2)^.5
foreach year of numlist 1890(10)1920 { 
gen double louis_`year' = louis if year==`year'
replace louis_`year' = 0 if louis_`year'==.
}

*Crop switching analysis

*Distance West
areg dcroplandF _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 west_*, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

areg dpercent_risk _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 west_*, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

*Distance West and from St. Louis

areg dcroplandF _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 west_* louis_*, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

areg dpercent_risk _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 west_* louis_*, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])


*Cattle and Specialization

*Distance West

areg dctl_xx_qA _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 west_*, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

areg dvarcrop _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 west_*, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

*Distance West and from St. Louis

areg dctl_xx_qA _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 west_* louis_*, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

areg dvarcrop _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 west_* louis_*, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

*Productivity analysis

*production variables
gen bar_xh_aA = bar_xh_a/are_xx_a
gen hay_xh_aA = hay_xh_a/are_xx_a
gen oat_xh_aA = oat_xh_a/are_xx_a
gen rye_xh_aA = rye_xh_a/are_xx_a
gen wht_xh_aA = wht_xh_a/are_xx_a
gen crn_gh_aA = crn_gh_a/are_xx_a

gen p_barley = bar_xh_b/bar_xh_a
gen p_hay = hay_xh_t/hay_xh_a
gen p_oat = oat_xh_b/oat_xh_a
gen p_rye = rye_xh_b/rye_xh_a
gen p_wheat = wht_xh_b/wht_xh_a
gen p_corn = crn_gh_b/crn_gh_a

gen p_barley1880 = p_barley if year ==1880
gen p_hay1880 = p_hay if year ==1880
gen p_oat1880 = p_oat if year ==1880
gen p_rye1880 = p_rye if year ==1880
gen p_wheat1880 = p_wheat if year ==1880
gen p_corn1880 = p_corn if year ==1880

sort unfips
by unfips: egen p_haybase = mean(p_hay1880)
by unfips: egen p_barleybase = mean(p_barley1880)
by unfips: egen p_oatbase = mean(p_oat1880)
by unfips: egen p_ryebase = mean(p_rye1880)
by unfips: egen p_wheatbase = mean(p_wheat1880)
by unfips: egen p_cornbase = mean(p_corn1880)

gen prbarley = p_barley/p_barleybase
gen prhay = p_hay/p_haybase
gen proat = p_oat/p_oatbase
gen prrye = p_rye/p_ryebase
gen prwheat = p_wheat/p_wheatbase
gen prcorn = p_corn/p_cornbase

reshape long pr, i(unyear) j(crop barley hay oat rye wheat corn)

gen id=1 if crop=="barley"
replace id=2 if crop=="hay"
replace id=3 if crop=="oat"
replace id=4 if crop=="rye"
replace id=5 if crop=="wheat"
replace id=7 if crop=="corn"


gen double unfips_crop = unfips*10 + id

gen double state_crop = state*10 + id
gen double state_crop_year = state_crop*10000+year

*centile pr, c(0(1)100)

drop if pr<.36
drop if pr>6.4

sort unfips_crop
by unfips_crop: egen balance5 = count(pr)
keep if balance5==5

*crop weights
gen weight = bar_xh_a if id==1&year==1880
replace weight = hay_xh_a if id==2&year==1880
replace weight = oat_xh_a if id==3&year==1880
replace weight = rye_xh_a if id==4&year==1880
replace weight = wht_xh_a if id==5&year==1880
replace weight = crn_gh_a if id==7&year==1880
sort unfips_crop
by unfips_crop: egen cropweight = max(weight)

qui{
tsset unfips_crop year
sort unfips_crop
by unfips_crop: gen dpr = pr - pr[_n-1]
char year[omit]1880
xi: reg dpr i.year*timber i.year*stimber i.year*ctimber i.year*qtimber
}
gen crop_group=1 if id==1|id==3|id==4|id==5|id==7
replace crop_group=2 if id==2

foreach year of numlist 1890(10)1920 { 
foreach c of numlist 1 2 3 4 5 7 {
gen double crop_west_`year'_`c' = west_`year' if year==`year'&id==`c'
replace crop_west_`year'_`c' = 0 if crop_west_`year'_`c' ==.
}
}

areg dpr _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 crop_west_*, absorb(state_crop_year) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

areg dpr _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 crop_west_* if crop_group==1, absorb(state_crop_year) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])


foreach year of numlist 1890(10)1920 { 
foreach c of numlist 1 2 3 4 5 7 {
gen double crop_louis_`year'_`c' = louis_`year' if year==`year'&id==`c'
replace crop_louis_`year'_`c' = 0 if crop_louis_`year'_`c' ==.
}
}

areg dpr _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 crop_west_* crop_louis_*, absorb(state_crop_year) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])


areg dpr _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 crop_west_* crop_louis_* if crop_group==1, absorb(state_crop_year) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])







*Controlling for Regional Quadratic Trends (by crop)

clear
insheet using Exportmerged_Tracedmap2_us1880.txt, tab
gen region = 1 if letter=="D"
replace region = 2 if letter=="E"
replace region = 3 if letter=="F"
replace region = 4 if letter=="G"
replace region = 4 if letter=="G G"
replace region = 5 if letter=="H"
replace region = 6 if letter=="I"
replace region = 7 if letter=="J"
replace region = 8 if letter=="K"
replace region = 9 if letter=="L"
replace region = 10 if letter=="M"
replace region = 11 if letter=="N"
replace region = 12 if letter=="P"
replace region = 13 if letter=="T"

sort id_1
gen double unique = (id_1*100+region)
tostring unique, replace
collapse (sum) new_area, by(unique)

tostring unique, replace
gen region = substr(unique,-2,2)
destring region, replace
destring unique, replace
gen fips = floor(unique/100)
drop unique
reshape wide new_area, i(fips) j(region)

foreach i of numlist 1(1)13 {
replace new_area`i'=0 if new_area`i'==.
}

gen all_region = new_area1+new_area2+new_area3+new_area4+new_area5+new_area6+new_area7+new_area8+new_area9+new_area10+new_area11+new_area12+new_area13
foreach i of numlist 1(1)13 {
rename new_area`i' region_`i'
}
foreach i of numlist 1(1)13 {
replace region_`i' = region_`i'/all_region
}

gen state=floor(fips/1000)
keep if state==8|state==19|state==20|state==27|state==31|state==48
drop state
rename fips unfips
sort unfips
save `region_1880', replace
clear

use `preanalysis_1880'
merge unfips using `region_1880'
keep if _merge==3
drop _merge

drop region_1 region_11

qui{
foreach i of numlist 2(1)10 12 13 {
gen q_region_`i' = region_`i' * 5 if year==1890
replace q_region_`i' = region_`i' * 7 if year==1900
replace q_region_`i' = region_`i' * 9 if year==1910
replace q_region_`i' = region_`i' * 11 if year==1920
}
}

*Crop switching analysis

areg dcroplandF _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 q_region_* region_*, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

areg dpercent_risk _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 q_region_* region_*, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])


*Cattle and Specialization

areg dctl_xx_qA _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 q_region_* region_*, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

areg dvarcrop _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 q_region_* region_*, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])


*Productivity analysis
qui{
*production variables
gen bar_xh_aA = bar_xh_a/are_xx_a
gen hay_xh_aA = hay_xh_a/are_xx_a
gen oat_xh_aA = oat_xh_a/are_xx_a
gen rye_xh_aA = rye_xh_a/are_xx_a
gen wht_xh_aA = wht_xh_a/are_xx_a
gen crn_gh_aA = crn_gh_a/are_xx_a

gen p_barley = bar_xh_b/bar_xh_a
gen p_hay = hay_xh_t/hay_xh_a
gen p_oat = oat_xh_b/oat_xh_a
gen p_rye = rye_xh_b/rye_xh_a
gen p_wheat = wht_xh_b/wht_xh_a
gen p_corn = crn_gh_b/crn_gh_a

gen p_barley1880 = p_barley if year ==1880
gen p_hay1880 = p_hay if year ==1880
gen p_oat1880 = p_oat if year ==1880
gen p_rye1880 = p_rye if year ==1880
gen p_wheat1880 = p_wheat if year ==1880
gen p_corn1880 = p_corn if year ==1880

sort unfips
by unfips: egen p_haybase = mean(p_hay1880)
by unfips: egen p_barleybase = mean(p_barley1880)
by unfips: egen p_oatbase = mean(p_oat1880)
by unfips: egen p_ryebase = mean(p_rye1880)
by unfips: egen p_wheatbase = mean(p_wheat1880)
by unfips: egen p_cornbase = mean(p_corn1880)

gen prbarley = p_barley/p_barleybase
gen prhay = p_hay/p_haybase
gen proat = p_oat/p_oatbase
gen prrye = p_rye/p_ryebase
gen prwheat = p_wheat/p_wheatbase
gen prcorn = p_corn/p_cornbase

reshape long pr, i(unyear) j(crop barley hay oat rye wheat corn)

gen id=1 if crop=="barley"
replace id=2 if crop=="hay"
replace id=3 if crop=="oat"
replace id=4 if crop=="rye"
replace id=5 if crop=="wheat"
replace id=7 if crop=="corn"

gen unfips_crop double = unfips*10 + id

gen state_crop = state*10 + id
gen state_crop_year = state_crop*10000+year

*centile pr, c(0(1)100)

drop if pr<.36
drop if pr>6.4

sort unfips_crop
by unfips_crop: egen balance5 = count(pr)
keep if balance5==5

tsset unfips_crop year
sort unfips_crop
by unfips_crop: gen dpr = pr - pr[_n-1]
char year[omit]1880
xi: reg dpr i.year*timber i.year*stimber i.year*ctimber i.year*qtimber
}
gen crop_group=1 if id==1|id==3|id==4|id==5|id==7
replace crop_group=2 if id==2

qui{
foreach c of numlist 1 2 3 4 5 7 {
foreach i of numlist 2(1)10 12 13 {
gen double c_r_`c'_`i' = region_`i' if id==`c'
replace c_r_`c'_`i' = 0 if c_r_`c'_`i'==.
}
}

foreach c of numlist 1 2 3 4 5 7 {
foreach i of numlist 2(1)10 12 13 {
gen q_c_r_`c'_`i' = c_r_`c'_`i' * 5 if year==1890
replace q_c_r_`c'_`i' = c_r_`c'_`i' * 7 if year==1900
replace q_c_r_`c'_`i' = c_r_`c'_`i' * 9 if year==1910
replace q_c_r_`c'_`i' = c_r_`c'_`i' * 11 if year==1920
}
}
}

areg dpr _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 q_c_r_* c_r_* , absorb(state_crop_year) 
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

areg dpr _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 q_c_r_* c_r_*  if crop_group==1, absorb(state_crop_year)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])





*Controlling for Subregion quadratic trend (by crop)

qui{
clear
insheet using Exportmerged_Tracedmap2_us1880.txt, tab
sort id_1
gen double unique = (id_1*1000+id)
tostring unique, replace

collapse (sum) new_area, by(unique)

tostring unique, replace
gen subregion = substr(unique,-3,3)
destring subregion, replace
destring unique, replace
gen fips = floor(unique/1000)
drop unique
reshape wide new_area, i(fips) j(subregion)

foreach i of numlist 32(1)37 39 41(1)46 48(1)92 102(1)109 112 116(1)119 133 150 151 {
replace new_area`i'=0 if new_area`i'==.
}

egen all_subregion = rowtotal(new_area*)

foreach i of numlist 32(1)37 39 41(1)46 48(1)92 102(1)109 112 116(1)119 133 150 151 {
rename new_area`i' subregion_`i'
}
foreach i of numlist 32(1)37 39 41(1)46 48(1)92 102(1)109 112 116(1)119 133 150 151 {
replace subregion_`i' = subregion_`i'/all_subregion
}

gen state=floor(fips/1000)
keep if state==8|state==19|state==20|state==27|state==31|state==48
drop state
rename fips unfips
sort unfips
save `subregion_1880', replace
clear

use `preanalysis_1880'
merge unfips using `subregion_1880'
keep if _merge==3
drop _merge

drop subregion_36 subregion_77 subregion_70

foreach i of numlist 34 35 37 45 48 49 50 51 56 57 65 67 68 69 71(1)76 78(1)88 90 91 92 102(1)109 112 133 150 151 {
gen q_subregion_`i' = subregion_`i' * 5 if year==1890
replace q_subregion_`i' = subregion_`i' * 7 if year==1900
replace q_subregion_`i' = subregion_`i' * 9 if year==1910
replace q_subregion_`i' = subregion_`i' * 11 if year==1920
}
}

*Crop switching analysis

areg dcroplandF _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 q_subregion_* subregion_*, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

areg dpercent_risk _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 q_subregion_* subregion_*, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])


*Cattle and Specialization
areg dctl_xx_qA _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 q_subregion_* subregion_*, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

areg dvarcrop _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 q_subregion_* subregion_*, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])


*Productivity analysis
qui{
*production variables
gen bar_xh_aA = bar_xh_a/are_xx_a
gen hay_xh_aA = hay_xh_a/are_xx_a
gen oat_xh_aA = oat_xh_a/are_xx_a
gen rye_xh_aA = rye_xh_a/are_xx_a
gen wht_xh_aA = wht_xh_a/are_xx_a
gen crn_gh_aA = crn_gh_a/are_xx_a

gen p_barley = bar_xh_b/bar_xh_a
gen p_hay = hay_xh_t/hay_xh_a
gen p_oat = oat_xh_b/oat_xh_a
gen p_rye = rye_xh_b/rye_xh_a
gen p_wheat = wht_xh_b/wht_xh_a
gen p_corn = crn_gh_b/crn_gh_a

gen p_barley1880 = p_barley if year ==1880
gen p_hay1880 = p_hay if year ==1880
gen p_oat1880 = p_oat if year ==1880
gen p_rye1880 = p_rye if year ==1880
gen p_wheat1880 = p_wheat if year ==1880
gen p_corn1880 = p_corn if year ==1880

sort unfips
by unfips: egen p_haybase = mean(p_hay1880)
by unfips: egen p_barleybase = mean(p_barley1880)
by unfips: egen p_oatbase = mean(p_oat1880)
by unfips: egen p_ryebase = mean(p_rye1880)
by unfips: egen p_wheatbase = mean(p_wheat1880)
by unfips: egen p_cornbase = mean(p_corn1880)

gen prbarley = p_barley/p_barleybase
gen prhay = p_hay/p_haybase
gen proat = p_oat/p_oatbase
gen prrye = p_rye/p_ryebase
gen prwheat = p_wheat/p_wheatbase
gen prcorn = p_corn/p_cornbase

reshape long pr, i(unyear) j(crop barley hay oat rye wheat corn)

gen id=1 if crop=="barley"
replace id=2 if crop=="hay"
replace id=3 if crop=="oat"
replace id=4 if crop=="rye"
replace id=5 if crop=="wheat"
replace id=7 if crop=="corn"

gen unfips_crop double = unfips*10 + id

gen state_crop = state*10 + id
gen state_crop_year = state_crop*10000+year

*centile pr, c(0(1)100)

drop if pr<.36
drop if pr>6.4

sort unfips_crop
by unfips_crop: egen balance5 = count(pr)
keep if balance5==5

tsset unfips_crop year
sort unfips_crop
by unfips_crop: gen dpr = pr - pr[_n-1]
char year[omit]1880
xi: reg dpr i.year*timber i.year*stimber i.year*ctimber i.year*qtimber

gen crop_group=1 if id==1|id==3|id==4|id==5|id==7
replace crop_group=2 if id==2

foreach c of numlist 1 2 3 4 5 7 {
foreach i of numlist 34 35 37 45 48 49 50 51 56 57 65 67 68 69 71(1)76 78(1)88 90 91 92 102(1)109 112 133 150 151 {
gen double c_sr_`c'_`i' = subregion_`i' if id==`c'
replace c_sr_`c'_`i' = 0 if c_sr_`c'_`i'==.
}
}

foreach c of numlist 1 2 3 4 5 7 {
foreach i of numlist 34 35 37 45 48 49 50 51 56 57 65 67 68 69 71(1)76 78(1)88 90 91 92 102(1)109 112 133 150 151 {
gen q_c_sr_`c'_`i' = c_sr_`c'_`i' * 5 if year==1890
replace q_c_sr_`c'_`i' = c_sr_`c'_`i' * 7 if year==1900
replace q_c_sr_`c'_`i' = c_sr_`c'_`i' * 9 if year==1910
replace q_c_sr_`c'_`i' = c_sr_`c'_`i' * 11 if year==1920
}
}
}

areg dpr _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 q_c_sr_* c_sr_* , absorb(state_crop_year) 
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

areg dpr _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 q_c_sr_* c_sr_*  if crop_group==1, absorb(state_crop_year)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])




*Controlling for Soil Quadratic Trends (by crop)

clear
insheet using Exportmerged_Tracedmap1_us1880.txt, tab
sort id_1
gen double unique = id_1*100+id
collapse (sum) new_area, by(unique)

tostring unique, replace
gen soil = substr(unique,-2,2)
destring soil, replace
destring unique, replace
gen fips = floor(unique/100)
drop unique
reshape wide new_area, i(fips) j(soil)

foreach i of numlist 0 2(1)22 {
replace new_area`i'=0 if new_area`i'==.
}

gen all_soil = new_area0+new_area2+new_area3+new_area4+new_area5+new_area6+new_area7+new_area8+new_area9+new_area10+new_area11+new_area12+new_area13+new_area14+new_area15+new_area16+new_area17+new_area18+new_area19+new_area20+new_area21+new_area22
foreach i of numlist 0 2(1)22 {
rename new_area`i' soil_`i'
}

foreach i of numlist 0 2(1)22 {
replace soil_`i' = soil_`i'/all_soil
}

gen state=floor(fips/1000)
keep if state==8|state==19|state==20|state==27|state==31|state==48
drop state
rename fips unfips
sort unfips
save `soil_1880', replace
clear

use `preanalysis_1880'
merge unfips using `soil_1880'
keep if _merge==3
drop _merge
drop soil_11 soil_13 soil_16

foreach i of numlist 0 2(1)10 12 14 15 17(1)22 {
gen q_soil_`i' = soil_`i' * 5 if year==1890
replace q_soil_`i' = soil_`i' * 7 if year==1900
replace q_soil_`i' = soil_`i' * 9 if year==1910
replace q_soil_`i' = soil_`i' * 11 if year==1920
}


*Crop switching analysis

areg dcroplandF _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 q_soil_* soil_*, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

areg dpercent_risk _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 q_soil_* soil_*, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])


*Cattle and Specialization
areg dctl_xx_qA _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 q_soil_* soil_*, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

areg dvarcrop _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 q_soil_* soil_*, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])


*Productivity analysis
qui{
*production variables
gen bar_xh_aA = bar_xh_a/are_xx_a
gen hay_xh_aA = hay_xh_a/are_xx_a
gen oat_xh_aA = oat_xh_a/are_xx_a
gen rye_xh_aA = rye_xh_a/are_xx_a
gen wht_xh_aA = wht_xh_a/are_xx_a
gen crn_gh_aA = crn_gh_a/are_xx_a

gen p_barley = bar_xh_b/bar_xh_a
gen p_hay = hay_xh_t/hay_xh_a
gen p_oat = oat_xh_b/oat_xh_a
gen p_rye = rye_xh_b/rye_xh_a
gen p_wheat = wht_xh_b/wht_xh_a
gen p_corn = crn_gh_b/crn_gh_a

gen p_barley1880 = p_barley if year ==1880
gen p_hay1880 = p_hay if year ==1880
gen p_oat1880 = p_oat if year ==1880
gen p_rye1880 = p_rye if year ==1880
gen p_wheat1880 = p_wheat if year ==1880
gen p_corn1880 = p_corn if year ==1880

sort unfips
by unfips: egen p_haybase = mean(p_hay1880)
by unfips: egen p_barleybase = mean(p_barley1880)
by unfips: egen p_oatbase = mean(p_oat1880)
by unfips: egen p_ryebase = mean(p_rye1880)
by unfips: egen p_wheatbase = mean(p_wheat1880)
by unfips: egen p_cornbase = mean(p_corn1880)

gen prbarley = p_barley/p_barleybase
gen prhay = p_hay/p_haybase
gen proat = p_oat/p_oatbase
gen prrye = p_rye/p_ryebase
gen prwheat = p_wheat/p_wheatbase
gen prcorn = p_corn/p_cornbase

reshape long pr, i(unyear) j(crop barley hay oat rye wheat corn)

gen id=1 if crop=="barley"
replace id=2 if crop=="hay"
replace id=3 if crop=="oat"
replace id=4 if crop=="rye"
replace id=5 if crop=="wheat"
replace id=7 if crop=="corn"

gen unfips_crop double = unfips*10 + id

gen state_crop = state*10 + id
gen state_crop_year = state_crop*10000+year

*centile pr, c(0(1)100)

drop if pr<.36
drop if pr>6.4

sort unfips_crop
by unfips_crop: egen balance5 = count(pr)
keep if balance5==5

tsset unfips_crop year
sort unfips_crop
by unfips_crop: gen dpr = pr - pr[_n-1]
char year[omit]1880
xi: reg dpr i.year*timber i.year*stimber i.year*ctimber i.year*qtimber

gen crop_group=1 if id==1|id==3|id==4|id==5|id==7
replace crop_group=2 if id==2

foreach c of numlist 1 2 3 4 5 7 {
foreach i of numlist 0 2(1)10 12 14 15 17(1)22 {
gen double c_s_`c'_`i' = soil_`i' if id==`c'
replace c_s_`c'_`i' = 0 if c_s_`c'_`i'==.
}
}

foreach c of numlist 1 2 3 4 5 7 {
foreach i of numlist 0 2(1)10 12 14 15 17(1)22 {
gen q_c_s_`c'_`i' = c_s_`c'_`i' * 5 if year==1890
replace q_c_s_`c'_`i' = c_s_`c'_`i' * 7 if year==1900
replace q_c_s_`c'_`i' = c_s_`c'_`i' * 9 if year==1910
replace q_c_s_`c'_`i' = c_s_`c'_`i' * 11 if year==1920
}
}
}

areg dpr _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 q_c_s_* c_s_* , absorb(state_crop_year) 
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

areg dpr _IyeaXtim_1890-_IyeaXtim_1920 _IyeaXsti_1890-_IyeaXsti_1920 _IyeaXcti_1890-_IyeaXcti_1920 _IyeaXqti_1890-_IyeaXqti_1920 q_c_s_* c_s_*  if crop_group==1, absorb(state_crop_year)
*Evaluate 0 vs. 0.06
nlcom (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])



log close

