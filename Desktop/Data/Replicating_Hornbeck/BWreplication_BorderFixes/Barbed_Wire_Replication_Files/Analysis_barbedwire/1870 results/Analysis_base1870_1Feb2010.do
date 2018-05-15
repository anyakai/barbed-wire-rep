/*
Date:  Feb 1, 2010
Author:  Richard Hornbeck
Compatibility:  Stata 11

This do file replicates analysis from "Barbed Wire:  Property Rights and Agricultural Development" by Richard Hornbeck, May 2010 Quarterly Journal of Economics.

The analysis originally used a web extract from the Great Plains Project (see data file notes) and earlier versions of Stata.  Documentation and future replication is more straightforward with the ICPSR analog to the Great Plains Data, and Stata is now at version 11.  This creates small rounding differences from the published version in some of the replication results.

This file analyzes the sample of counties based on a base year of 1870.
*/

set mem 500m
set matsize 800
set more off
set graphics off
use Base1870.dta, clear
capture log close
log using Analysis_base1870_1Feb2010.log, replace

tempfile preanalysis conley pre_rranalysis rr_base1870 herd_law fence_price pre_woodland pre_conley nsew_1870 region_1870 subregion_1870 soil_1870 pre_initial 1870_rr 1880_rr 1890_rr 1900_rr 1910_rr 1920_rr rr_base1870 

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
sort unfips year
by unfips: egen timber = mean(timber1880)
gen stimber = timber^2
gen ctimber = timber^3
gen qtimber = timber^4

*land value data
egen value_1900 = rsum(farmval farmbui) if year==1900
replace prp_xx_v = value_1900 if year==1900&farmval!=.&farmbui!=.
egen value_1910 = rsum(farmval farmbui) if year==1910
replace prp_xx_v = value_1910 if year==1910&farmval!=.&farmbui!=.
gen lnprp_xx_vA = ln(prp_xx_v/are_xx_a)
gen lnvalue1870 = lnprp_xx_vA if year == 1870
sort unfips
by unfips: egen valueln = mean(lnvalue1870)
gen svalueln = valueln^2
gen cvalueln = valueln^3
gen qvalueln = valueln^4

*generate area fraction variables, note some are > 1
gen fml_xx_aA = fml_xx_a/are_xx_a
gen iml_xx_aA = iml_xx_a/are_xx_a
gen ctl_xx_qA = ctl_xx_q/are_xx_a

*generate land fraction variables
gen iml_xx_aF = iml_xx_a/fml_xx_a
gen ctl_xx_qF = ctl_xx_q/fml_xx_a

*add up all cropland, but it is a noisy measure
egen cropland = rsum(bar_xh_a bea_xh_a bet_xh_a cot_xh_a crn_gh_a flx_xh_a hay_xh_a oat_xh_a pea_xh_a pnt_xh_a pot_xh_a rye_xh_a wht_xh_a)

*Difference the data
tsset unfips year
by unfips: gen diml_xx_aA = iml_xx_aA - iml_xx_aA[_n-1]
by unfips: gen diml_xx_aF = iml_xx_aF - iml_xx_aF[_n-1]
by unfips: gen dfml_xx_aA = fml_xx_aA - fml_xx_aA[_n-1]
by unfips: gen dlnprp_xx_vA = lnprp_xx_vA - lnprp_xx_vA[_n-1]

sort unfips year
by unfips: egen balance2 = count(fml_xx_aA)
by unfips: egen balance3 = count(iml_xx_aA)
by unfips: egen balance4 = count(iml_xx_aF)
by unfips: egen balance5 = count(lnprp_xx_vA)

gen improvedf1870 = iml_xx_aF if year == 1870
sort unfips year
by unfips: egen improvedf = mean(improvedf1870)
gen simprovedf = improvedf^2
gen cimprovedf = improvedf^3
gen qimprovedf = improvedf^4

gen settled1870 = fml_xx_aA if year == 1870
sort unfips year
by unfips: egen settled = mean(settled1870)
gen ssettled = settled^2
gen csettled = settled^3
gen qsettled = settled^4

gen improveda1870 = iml_xx_aA if year == 1870
sort unfips year
by unfips: egen improveda = mean(improveda1870)
gen simproveda = improveda^2
gen cimproveda = improveda^3
gen qimproveda = improveda^4

by unfips: egen check = sd(are_xx_a)
centile check if timber!=.&balance2==7, centile(0(1)100)
centile check if timber!=.&balance3==6, centile(0(1)100)
centile check if timber!=.&balance4==6, centile(0(1)100)
drop if check>50000

gen group=1 if timber<.04
replace group=2 if timber>.04&timber<.08
replace group=3 if timber>.08&timber<.12

gen col5 = (group==1|group==2)
gen col6 = (group==2|group==3)
gen group1 = (group==1)
gen group2 = (group==2)
gen group3 = (group==3)

keep if balance4==6
gen double year_state = state*10000+year
char year[omit]1870
xi: reg diml_xx_aF i.year*timber i.year*stimber i.year*ctimber i.year*qtimber if balance4==6

sort unfips year
save `preanalysis', replace
clear


***
*Table 2, Summary statistics
***
clear
use `preanalysis'

sum iml_xx_aF if year==1880
sum iml_xx_aF if group==1&year==1880
sum iml_xx_aF if group==2&year==1880
sum iml_xx_aF if group==3&year==1880
reg iml_xx_aF group2 if year==1880&col5==1,  robust
reg iml_xx_aF group3 if year==1880&col6==1,  robust

sum fml_xx_aA if year==1880
sum fml_xx_aA if group==1&year==1880
sum fml_xx_aA if group==2&year==1880
sum fml_xx_aA if group==3&year==1880
reg fml_xx_aA group2 if year==1880&col5==1, robust
reg fml_xx_aA group3 if year==1880&col6==1, robust

sum iml_xx_aA if year==1880
sum iml_xx_aA if group==1&year==1880
sum iml_xx_aA if group==2&year==1880
sum iml_xx_aA if group==3&year==1880
reg iml_xx_aA group2 if year==1880&col5==1,  robust
reg iml_xx_aA group3 if year==1880&col6==1,  robust

sum are_xx_a if year==1880
sum are_xx_a if group==1&year==1880
sum are_xx_a if group==2&year==1880
sum are_xx_a if group==3&year==1880
reg are_xx_a group2 if year==1880&col5==1,  robust
reg are_xx_a group3 if year==1880&col6==1,  robust

sum fml_xx_a if year==1880
sum fml_xx_a if group==1&year==1880
sum fml_xx_a if group==2&year==1880
sum fml_xx_a if group==3&year==1880
reg fml_xx_a group2 if year==1880&col5==1,  robust
reg fml_xx_a group3 if year==1880&col6==1,  robust

sum prp_xx_v if year==1880
sum prp_xx_v if group==1&year==1880
sum prp_xx_v if group==2&year==1880
sum prp_xx_v if group==3&year==1880
reg prp_xx_v group2 if year==1880&col5==1,  robust
reg prp_xx_v group3 if year==1880&col6==1,  robust

sum afp_xx_v if year==1880
sum afp_xx_v if group==1&year==1880
sum afp_xx_v if group==2&year==1880
sum afp_xx_v if group==3&year==1880
reg afp_xx_v group2 if year==1880&col5==1,  robust
reg afp_xx_v group3 if year==1880&col6==1,  robust

sum fen_xx_v if year==1880
sum fen_xx_v if group==1&year==1880
sum fen_xx_v if group==2&year==1880
sum fen_xx_v if group==3&year==1880
reg fen_xx_v group2 if year==1880&col5==1,  robust
reg fen_xx_v group3 if year==1880&col6==1,  robust
clear


***
*Figure 2, Kansas fence price data
***
clear
insheet using fence_price.txt, tab
sort unfips
save `fence_price', replace
clear
use `preanalysis'
sort unfips year
merge unfips using `fence_price'

foreach var of varlist rail_p_79_80 barbed_p_79_80 {
reg `var' timber if year==1870&_merge==3
reg `var' timber stimber ctimber qtimber if year==1870&_merge==3
nlcom (low_med:-.06*_b[timber] - .0036*_b[stimber] - .000216*_b[ctimber] - .00001296*_b[qtimber]) (med_high:-.06*_b[timber] - .0108*_b[stimber] - .001512*_b[ctimber] - .0001944*_b[qtimber]) (diff: .0072*_b[stimber] + .001296*_b[ctimber] + .00018144*_b[qtimber])
}

twoway (scatter rail_p_79_80 timber if year==1870&_merge==3, clpattern(solid) scheme(s2mono) ysize(4) ytitle("Wooden Rail Fencing Cost (per-100), 1879-1880") xsize(6) xsc(r(0 .18)) xlabel(0 .03 .06 .09 .12 .15 .18) xtitle("Woodland Fraction") graphregion(fcolor(white) lstyle(solid))), saving(Figure2_a, replace)
twoway (scatter barbed_p_79_80 timber if year==1870&_merge==3, clpattern(solid) scheme(s2mono) ysize(4) ytitle("Barbed Wire Fencing Cost (per-rod), 1879-1880") xsize(6) xsc(r(0 .18)) xlabel(0 .03 .06 .09 .12 .15 .18) xtitle("Woodland Fraction") graphregion(fcolor(white) lstyle(solid))), saving(Figure2_b, replace)
clear

***
*Figure 4, Timber-Year Trends
***
clear
use `preanalysis'
gen group_year = group*10000 + year
sort group_year
by group_year: egen ifmean = mean(iml_xx_aF)
by group_year: gen g1 = 1 if [_n]==1
twoway (line ifmean year if group==1&g1==1, clpattern(solid)) (line ifmean year if group==2&g1==1, clpattern(longdash)) (line ifmean year if group==3&g1==1, clpattern(shortdash)), scheme(s2mono) ysize(4) ysc(r(.2 .8)) ytitle("") ylabel(.2 .4 .6 .8, nogrid) xsize(6) xtitle("") xlabel(1870 1880 1890 1900 1910 1920, nogrid) graphregion(fcolor(white) lstyle(solid)) xline(1880, lpattern(dot)) xline(1900, lpattern(dot)) legend(order(1 2 3) symplacement(left) rows(1) label(1 "0% to 4%") label(2 "4% to 8%") label(3 "8% to 12%"))
graph save Figure4, replace
clear

***
*Table 3, baseline land-use results
***
clear
use `preanalysis'

*Improved land, per farm acre
areg diml_xx_aF _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1880:-.06*_b[_IyeaXtim_1880] - .0036*_b[_IyeaXsti_1880] - .000216*_b[_IyeaXcti_1880] - .00001296*_b[_IyeaXqti_1880]) (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1880:-.06*_b[_IyeaXtim_1880] - .0108*_b[_IyeaXsti_1880] - .001512*_b[_IyeaXcti_1880] - .0001944*_b[_IyeaXqti_1880]) (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1880: .0072*_b[_IyeaXsti_1880] + .001296*_b[_IyeaXcti_1880] + .00018144*_b[_IyeaXqti_1880]) (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

*Farmland, per county acre
areg dfml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1880:-.06*_b[_IyeaXtim_1880] - .0036*_b[_IyeaXsti_1880] - .000216*_b[_IyeaXcti_1880] - .00001296*_b[_IyeaXqti_1880]) (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1880:-.06*_b[_IyeaXtim_1880] - .0108*_b[_IyeaXsti_1880] - .001512*_b[_IyeaXcti_1880] - .0001944*_b[_IyeaXqti_1880]) (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1880: .0072*_b[_IyeaXsti_1880] + .001296*_b[_IyeaXcti_1880] + .00018144*_b[_IyeaXqti_1880]) (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

*Improved land, per county acre
areg diml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1880:-.06*_b[_IyeaXtim_1880] - .0036*_b[_IyeaXsti_1880] - .000216*_b[_IyeaXcti_1880] - .00001296*_b[_IyeaXqti_1880]) (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1880:-.06*_b[_IyeaXtim_1880] - .0108*_b[_IyeaXsti_1880] - .001512*_b[_IyeaXcti_1880] - .0001944*_b[_IyeaXqti_1880]) (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1880: .0072*_b[_IyeaXsti_1880] + .001296*_b[_IyeaXcti_1880] + .00018144*_b[_IyeaXqti_1880]) (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])
clear

***
*Figure 5, Graphed polynomial changes
***
*Create numbers, take log file, run separate program
clear
use `preanalysis'

areg diml_xx_aF _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920, absorb(year_state) cluster(unfips)
foreach i of numlist 0(0.001)0.12 {
nlcom (yy1880: (`i'-0)*_b[_IyeaXtim_1880] + (`i'^2-0^2)*_b[_IyeaXsti_1880] + (`i'^3-0^3)*_b[_IyeaXcti_1880] + (`i'^4-0^4)*_b[_IyeaXqti_1880])
}
foreach i of numlist 0(0.001)0.12 {
nlcom (yy1890: (`i'-0)*_b[_IyeaXtim_1890] + (`i'^2-0^2)*_b[_IyeaXsti_1890] + (`i'^3-0^3)*_b[_IyeaXcti_1890] + (`i'^4-0^4)*_b[_IyeaXqti_1890])
}
foreach i of numlist 0(0.001)0.12 {
nlcom (yy1900: (`i'-0)*_b[_IyeaXtim_1900] + (`i'^2-0^2)*_b[_IyeaXsti_1900] + (`i'^3-0^3)*_b[_IyeaXcti_1900] + (`i'^4-0^4)*_b[_IyeaXqti_1900])
}
foreach i of numlist 0(0.001)0.12 {
nlcom (yy1910: (`i'-0)*_b[_IyeaXtim_1910] + (`i'^2-0^2)*_b[_IyeaXsti_1910] + (`i'^3-0^3)*_b[_IyeaXcti_1910] + (`i'^4-0^4)*_b[_IyeaXqti_1910])
}
foreach i of numlist 0(0.001)0.12 {
nlcom (yy1920: (`i'-0)*_b[_IyeaXtim_1920] + (`i'^2-0^2)*_b[_IyeaXsti_1920] + (`i'^3-0^3)*_b[_IyeaXcti_1920] + (`i'^4-0^4)*_b[_IyeaXqti_1920])
}


***
*Table 4, Robustness
***
clear
use `preanalysis'

*First, test adjusted code to run conley standard errors (mynlcom)

areg diml_xx_aF _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920, absorb(year_state) cluster(unfips)
nlcom (yy1880:.06*_b[_IyeaXtim_1880] + .0036*_b[_IyeaXsti_1880] + .000216*_b[_IyeaXcti_1880] + .00001296*_b[_IyeaXqti_1880]) (yy1890:.06*_b[_IyeaXtim_1890] + .0036*_b[_IyeaXsti_1890] + .000216*_b[_IyeaXcti_1890] + .00001296*_b[_IyeaXqti_1890]) (yy1900:.06*_b[_IyeaXtim_1900] + .0036*_b[_IyeaXsti_1900] + .000216*_b[_IyeaXcti_1900] + .00001296*_b[_IyeaXqti_1900]) (yy1910:.06*_b[_IyeaXtim_1910] + .0036*_b[_IyeaXsti_1910] + .000216*_b[_IyeaXcti_1910] + .00001296*_b[_IyeaXqti_1910]) (yy1920:.06*_b[_IyeaXtim_1920] + .0036*_b[_IyeaXsti_1920] + .000216*_b[_IyeaXcti_1920] + .00001296*_b[_IyeaXqti_1920])
mat cov_dep = e(V)
mat y1880 = ((.06^2)*cov_dep[1,1] + (.0036^2)*cov_dep[6,6] + (.000216^2)*cov_dep[11,11] + (.00001296^2)*cov_dep[16,16] + 2*.06*.0036*cov_dep[1,6] + 2*.06*.000216*cov_dep[1,11] + 2*.06*.00001296*cov_dep[1,16] + 2*.0036*.000216*cov_dep[6,11] + 2*.0036*.00001296*cov_dep[6,16] + 2*.000216*.00001296*cov_dep[11,16])^.5
mat y1890 = ((.06^2)*cov_dep[2,2] + (.0036^2)*cov_dep[7,7] + (.000216^2)*cov_dep[12,12] + (.00001296^2)*cov_dep[17,17] + 2*.06*.0036*cov_dep[2,7] + 2*.06*.000216*cov_dep[2,12] + 2*.06*.00001296*cov_dep[2,17] + 2*.0036*.000216*cov_dep[7,12] + 2*.0036*.00001296*cov_dep[7,17] + 2*.000216*.00001296*cov_dep[12,17])^.5
mat y1900 = ((.06^2)*cov_dep[3,3] + (.0036^2)*cov_dep[8,8] + (.000216^2)*cov_dep[13,13] + (.00001296^2)*cov_dep[18,18] + 2*.06*.0036*cov_dep[3,8] + 2*.06*.000216*cov_dep[3,13] + 2*.06*.00001296*cov_dep[3,18] + 2*.0036*.000216*cov_dep[8,13] + 2*.0036*.00001296*cov_dep[8,18] + 2*.000216*.00001296*cov_dep[13,18])^.5
mat y1910 = ((.06^2)*cov_dep[4,4] + (.0036^2)*cov_dep[9,9] + (.000216^2)*cov_dep[14,14] + (.00001296^2)*cov_dep[19,19] + 2*.06*.0036*cov_dep[4,9] + 2*.06*.000216*cov_dep[4,14] + 2*.06*.00001296*cov_dep[4,19] + 2*.0036*.000216*cov_dep[9,14] + 2*.0036*.00001296*cov_dep[9,19] + 2*.000216*.00001296*cov_dep[14,19])^.5
mat y1920 = ((.06^2)*cov_dep[5,5] + (.0036^2)*cov_dep[10,10] + (.000216^2)*cov_dep[15,15] + (.00001296^2)*cov_dep[20,20] + 2*.06*.0036*cov_dep[5,10] + 2*.06*.000216*cov_dep[5,15] + 2*.06*.00001296*cov_dep[5,20] + 2*.0036*.000216*cov_dep[10,15] + 2*.0036*.00001296*cov_dep[10,20] + 2*.000216*.00001296*cov_dep[15,20])^.5
mat list y1880
mat list y1890
mat list y1900
mat list y1910
mat list y1920
mat drop cov_dep
mat drop y1880
mat drop y1890
mat drop y1900
mat drop y1910
mat drop y1920

save `pre_conley', replace
clear
insheet using 1870_nsew.txt, tab
rename id unfips
gen statefips=floor(unfips/1000)
keep if statefips==8|statefips==19|statefips==20|statefips==27|statefips==31|statefips==48
keep unfips yaxis xaxis
sort unfips
save `nsew_1870', replace
clear

use `pre_conley'
sort unfips year
merge unfips using `nsew_1870'
keep if _merge==3
drop _merge

drop if year==1870

tab year_state, gen(d_year_state)

gen cutoff1=100
gen cutoff2=100
sort unfips year
save `conley', replace

reg diml_xx_aF _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 d_year_state*, noc
reg diml_xx_aF _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 d_year_state*, noc robust
reg diml_xx_aF _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 d_year_state*, noc cluster(unfips)

x_ols xaxis yaxis cutoff1 cutoff2 diml_xx_aF _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 d_year_state*, xreg(50) coord(2)

mat y1880 = ((.06^2)*cov_dep[1,1] + (.0036^2)*cov_dep[6,6] + (.000216^2)*cov_dep[11,11] + (.00001296^2)*cov_dep[16,16] + 2*.06*.0036*cov_dep[1,6] + 2*.06*.000216*cov_dep[1,11] + 2*.06*.00001296*cov_dep[1,16] + 2*.0036*.000216*cov_dep[6,11] + 2*.0036*.00001296*cov_dep[6,16] + 2*.000216*.00001296*cov_dep[11,16])^.5
mat y1890 = ((.06^2)*cov_dep[2,2] + (.0036^2)*cov_dep[7,7] + (.000216^2)*cov_dep[12,12] + (.00001296^2)*cov_dep[17,17] + 2*.06*.0036*cov_dep[2,7] + 2*.06*.000216*cov_dep[2,12] + 2*.06*.00001296*cov_dep[2,17] + 2*.0036*.000216*cov_dep[7,12] + 2*.0036*.00001296*cov_dep[7,17] + 2*.000216*.00001296*cov_dep[12,17])^.5
mat y1900 = ((.06^2)*cov_dep[3,3] + (.0036^2)*cov_dep[8,8] + (.000216^2)*cov_dep[13,13] + (.00001296^2)*cov_dep[18,18] + 2*.06*.0036*cov_dep[3,8] + 2*.06*.000216*cov_dep[3,13] + 2*.06*.00001296*cov_dep[3,18] + 2*.0036*.000216*cov_dep[8,13] + 2*.0036*.00001296*cov_dep[8,18] + 2*.000216*.00001296*cov_dep[13,18])^.5
mat y1910 = ((.06^2)*cov_dep[4,4] + (.0036^2)*cov_dep[9,9] + (.000216^2)*cov_dep[14,14] + (.00001296^2)*cov_dep[19,19] + 2*.06*.0036*cov_dep[4,9] + 2*.06*.000216*cov_dep[4,14] + 2*.06*.00001296*cov_dep[4,19] + 2*.0036*.000216*cov_dep[9,14] + 2*.0036*.00001296*cov_dep[9,19] + 2*.000216*.00001296*cov_dep[14,19])^.5
mat y1920 = ((.06^2)*cov_dep[5,5] + (.0036^2)*cov_dep[10,10] + (.000216^2)*cov_dep[15,15] + (.00001296^2)*cov_dep[20,20] + 2*.06*.0036*cov_dep[5,10] + 2*.06*.000216*cov_dep[5,15] + 2*.06*.00001296*cov_dep[5,20] + 2*.0036*.000216*cov_dep[10,15] + 2*.0036*.00001296*cov_dep[10,20] + 2*.000216*.00001296*cov_dep[15,20])^.5
mat list y1880
mat list y1890
mat list y1900
mat list y1910
mat list y1920

nlcom (yy1880:.06*_b[__000005] + .0036*_b[__00000A] + .000216*_b[__00000F] + .00001296*_b[__00000K]) (yy1890:.06*_b[__000006] + .0036*_b[__00000B] + .000216*_b[__00000G] + .00001296*_b[__00000L]) (yy1900:.06*_b[__000007] + .0036*_b[__00000C] + .000216*_b[__00000H] + .00001296*_b[__00000M]) (yy1910:.06*_b[__000008] + .0036*_b[__00000D] + .000216*_b[__00000I] + .00001296*_b[__00000N]) (yy1920:.06*_b[__000009] + .0036*_b[__00000E] + .000216*_b[__00000J] + .00001296*_b[__00000O])
mynlcom (yy1880:.06*_b[__000005] + .0036*_b[__00000A] + .000216*_b[__00000F] + .00001296*_b[__00000K]) (yy1890:.06*_b[__000006] + .0036*_b[__00000B] + .000216*_b[__00000G] + .00001296*_b[__00000L]) (yy1900:.06*_b[__000007] + .0036*_b[__00000C] + .000216*_b[__00000H] + .00001296*_b[__00000M]) (yy1910:.06*_b[__000008] + .0036*_b[__00000D] + .000216*_b[__00000I] + .00001296*_b[__00000N]) (yy1920:.06*_b[__000009] + .0036*_b[__00000E] + .000216*_b[__00000J] + .00001296*_b[__00000O])
mynlcom (yy1880:-.06*_b[__000005] - .0036*_b[__00000A] - .000216*_b[__00000F] - .00001296*_b[__00000K]) (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L]) (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M]) (yy1910:-.06*_b[__000008] - .0036*_b[__00000D] - .000216*_b[__00000I] - .00001296*_b[__00000N]) (yy1920:-.06*_b[__000009] - .0036*_b[__00000E] - .000216*_b[__00000J] - .00001296*_b[__00000O])
clear

*Column 1, Baseline with conley standard errors
clear
use `conley'

x_ols xaxis yaxis cutoff1 cutoff2 diml_xx_aF _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 d_year_state*, xreg(50) coord(2)
mynlcom (yy1880:-.06*_b[__000005] - .0036*_b[__00000A] - .000216*_b[__00000F] - .00001296*_b[__00000K]) (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L]) (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M]) (yy1910:-.06*_b[__000008] - .0036*_b[__00000D] - .000216*_b[__00000I] - .00001296*_b[__00000N]) (yy1920:-.06*_b[__000009] - .0036*_b[__00000E] - .000216*_b[__00000J] - .00001296*_b[__00000O])
mynlcom (d1880: .0072*_b[__00000A] + .001296*_b[__00000F] + .00018144*_b[__00000K]) (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L]) (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M]) (d1910: .0072*_b[__00000D] + .001296*_b[__00000I] + .00018144*_b[__00000N]) (d1920: .0072*_b[__00000E] + .001296*_b[__00000J] + .00018144*_b[__00000O])
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])

drop epsilon window dis1 dis2
x_ols xaxis yaxis cutoff1 cutoff2 dfml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 d_year_state*, xreg(50) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])

drop epsilon window dis1 dis2
x_ols xaxis yaxis cutoff1 cutoff2 diml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 d_year_state*, xreg(50) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])


*Column 2, Distance West
clear
use `conley'
foreach year of numlist 1880(10)1920 { 
gen double west_`year' = xaxis if year==`year'
replace west_`year' = 0 if west_`year'==.
}
x_ols xaxis yaxis cutoff1 cutoff2 diml_xx_aF _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 d_year_state* west_*, xreg(55) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])

drop epsilon window dis1 dis2
x_ols xaxis yaxis cutoff1 cutoff2 dfml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 d_year_state* west_*, xreg(55) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])

drop epsilon window dis1 dis2
x_ols xaxis yaxis cutoff1 cutoff2 diml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 d_year_state* west_*, xreg(55) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])


*Column 3, Distance to St. Louis and West
gen louis = ((xaxis-1911)^2 + (yaxis-1112)^2)^.5
foreach year of numlist 1880(10)1920 { 
gen double louis_`year' = louis if year==`year'
replace louis_`year' = 0 if louis_`year'==.
}
drop epsilon window dis1 dis2
x_ols xaxis yaxis cutoff1 cutoff2 diml_xx_aF _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 d_year_state* west_* louis_*, xreg(60) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])

drop epsilon window dis1 dis2
x_ols xaxis yaxis cutoff1 cutoff2 dfml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 d_year_state* west_* louis_*, xreg(60) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])

drop epsilon window dis1 dis2
x_ols xaxis yaxis cutoff1 cutoff2 diml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 d_year_state* west_* louis_*, xreg(60) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])
drop epsilon window dis1 dis2


*Column 4, Region quadratic trends
clear
insheet using Exportmerged_Tracedmap2_us1870.txt, tab
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
save `region_1870', replace
clear

use `conley'
merge unfips using `region_1870'
keep if _merge==3
drop _merge
drop region_1 region_11

foreach i of numlist 2(1)10 12 13 {
gen q_region_`i' = region_`i' * 3 if year==1880
replace q_region_`i' = region_`i' * 5 if year==1890
replace q_region_`i' = region_`i' * 7 if year==1900
replace q_region_`i' = region_`i' * 9 if year==1910
replace q_region_`i' = region_`i' * 11 if year==1920
}

*Improved land, per farm acre
x_ols xaxis yaxis cutoff1 cutoff2 diml_xx_aF _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 d_year_state* region_* q_region_*, xreg(72) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])

*Farmland, per county acre
drop epsilon window dis1 dis2
x_ols xaxis yaxis cutoff1 cutoff2 dfml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 d_year_state* region_* q_region_*, xreg(72) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])

*Improved land, per county acre
drop epsilon window dis1 dis2
x_ols xaxis yaxis cutoff1 cutoff2 diml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 d_year_state* region_* q_region_*, xreg(72) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])
drop epsilon window dis1 dis2


*Column 5, Subregion quadratic trends
clear
insheet using Exportmerged_Tracedmap2_us1870.txt, tab
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
save `subregion_1870', replace
clear

use `conley'
merge unfips using `subregion_1870'
keep if _merge==3
drop _merge
drop subregion_36 subregion_77 subregion_70

foreach i of numlist 33 37 45 48 49 50 51 56 57 67 68 69 71(1)76 78(1)88 90 91 102(1)109 112 133 150 151 {
gen q_subregion_`i' = subregion_`i' * 3 if year==1880
replace q_subregion_`i' = subregion_`i' * 5 if year==1890
replace q_subregion_`i' = subregion_`i' * 7 if year==1900
replace q_subregion_`i' = subregion_`i' * 9 if year==1910
replace q_subregion_`i' = subregion_`i' * 11 if year==1920
}
drop subregion_32 subregion_34 subregion_35 subregion_39 subregion_41 subregion_42 subregion_43 subregion_44 subregion_46 subregion_52 subregion_53 subregion_54 subregion_55 subregion_58 subregion_59 subregion_60 subregion_61 subregion_62 subregion_63 subregion_64 subregion_65 subregion_66 subregion_89 subregion_92 subregion_116 subregion_117 subregion_118 subregion_119

drop subregion_79 d_year_state5

*Improved land, per farm acre
x_ols xaxis yaxis cutoff1 cutoff2 diml_xx_aF _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 d_year_state* subregion_* q_subregion_*, xreg(132) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])

*Farmland, per county acre
drop epsilon window dis1 dis2
x_ols xaxis yaxis cutoff1 cutoff2 dfml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 d_year_state* subregion_* q_subregion_*, xreg(132) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])

*Improved land, per county acre
drop epsilon window dis1 dis2
x_ols xaxis yaxis cutoff1 cutoff2 diml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 d_year_state* subregion_* q_subregion_*, xreg(132) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])
drop epsilon window dis1 dis2


*Column 6, Soil quadratic trend
clear
insheet using Exportmerged_Tracedmap1_us1870.txt, tab
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
save `soil_1870', replace
clear

use `conley'
merge unfips using `soil_1870'
keep if _merge==3
drop _merge
drop soil_11 soil_13 soil_16

foreach i of numlist 0 2(1)10 12 14 15 17(1)22 {
gen q_soil_`i' = soil_`i' * 3 if year==1880
replace q_soil_`i' = soil_`i' * 5 if year==1890
replace q_soil_`i' = soil_`i' * 7 if year==1900
replace q_soil_`i' = soil_`i' * 9 if year==1910
replace q_soil_`i' = soil_`i' * 11 if year==1920
}
drop soil_12 d_year_state20

*Improved land, per farm acre
x_ols xaxis yaxis cutoff1 cutoff2 diml_xx_aF _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 d_year_state* soil_* q_soil_*, xreg(86) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])

*Farmland, per county acre
drop epsilon window dis1 dis2
x_ols xaxis yaxis cutoff1 cutoff2 dfml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 d_year_state* soil_* q_soil_*, xreg(86) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])

*Improved land, per county acre
drop epsilon window dis1 dis2
x_ols xaxis yaxis cutoff1 cutoff2 diml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 d_year_state* soil_* q_soil_*, xreg(86) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])
drop epsilon window dis1 dis2


*Column 7, Controlling for Initial Levels
clear
insheet using 1870_nsew.txt, tab
rename id unfips
gen statefips=floor(unfips/1000)
keep if statefips==8|statefips==19|statefips==20|statefips==27|statefips==31|statefips==48
keep unfips yaxis xaxis
sort unfips
save `nsew_1870', replace
clear

use `preanalysis'
sort unfips year
merge unfips using `nsew_1870'
keep if _merge==3
drop _merge

tab year_state if year!=1870, gen(d_year_state)

gen cutoff1=100
gen cutoff2=100

*Improved land, per farm acre
qui{
char year[omit]1870
xi: reg dfml_xx_aA i.year*timber i.year*stimber i.year*ctimber i.year*qtimber i.year*improvedf i.year*simprovedf i.year*cimprovedf i.year*qimprovedf
save `pre_initial'
drop if year==1870
}
x_ols xaxis yaxis cutoff1 cutoff2 diml_xx_aF _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 _IyeaXimp_1880-_IyeaXimp_1920 _IyeaXsim_1880-_IyeaXsim_1920 _IyeaXcim_1880-_IyeaXcim_1920 _IyeaXqim_1880-_IyeaXqim_1920 d_year_state*, xreg(70) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])

*Farmland, per county acre
qui{
clear
use `pre_initial'
char year[omit]1870
xi: reg dfml_xx_aA i.year*timber i.year*stimber i.year*ctimber i.year*qtimber i.year*settled i.year*ssettled i.year*csettled i.year*qsettled
drop if year==1870
}
x_ols xaxis yaxis cutoff1 cutoff2 dfml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 _IyeaXset_1880-_IyeaXset_1920 _IyeaXsse_1880-_IyeaXsse_1920 _IyeaXcse_1880-_IyeaXcse_1920 _IyeaXqse_1880-_IyeaXqse_1920 d_year_state*, xreg(70) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])

*Improved land, per county acre
qui{
clear
use `pre_initial'
char year[omit]1870
xi: reg diml_xx_aA i.year*timber i.year*stimber i.year*ctimber i.year*qtimber i.year*improveda i.year*simproveda i.year*cimproveda i.year*qimproveda
drop if year==1870
}
x_ols xaxis yaxis cutoff1 cutoff2 diml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 _IyeaXimp_1880-_IyeaXimp_1920 _IyeaXsim_1880-_IyeaXsim_1920 _IyeaXcim_1880-_IyeaXcim_1920 _IyeaXqim_1880-_IyeaXqim_1920 d_year_state*, xreg(70) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])


*Column 8, Control for Railroads
clear
foreach i of numlist 870(10)920 {
insheet using 1`i'rr_length1870.txt, tab
sort id
collapse (sum) length, by(id)
gen year = 1`i'
sort id
save `1`i'_rr', replace
clear
}
use `1870_rr'
append using `1880_rr'
append using `1890_rr'
append using `1900_rr'
append using `1910_rr'
append using `1920_rr'
sort id year
rename id unfips
keep unfips year length
sort unfips year
save `rr_base1870', replace

clear
use `preanalysis'
sort unfips year
merge unfips year using `rr_base1870'
gen sample = (_merge==1|_merge==3)
replace length = 0 if _merge==1
drop _merge
sort unfips year
keep year unfips length sample
gen state = 0
replace state = 8 if unfips > 8000 & unfips < 9000
replace state = 19 if unfips > 19000 & unfips < 20000
replace state = 20 if unfips > 20000 & unfips < 21000
replace state = 27 if unfips > 27000 & unfips < 28000
replace state = 31 if unfips > 31000 & unfips < 32000
replace state = 48 if unfips > 48000 & unfips < 49000
keep if state==8|state==19|state==20|state==27|state==31|state==48
*8 - Colorado
*19 - Iowa
*20 - Kansas
*27 - Minnesota
*31 - Nebraska
*48 - Texas
gen any = (length>0)

save `pre_rranalysis', replace

/*
set graphics on
*Check against Poor's railroad data
collapse (sum) length (mean) any, by(state year)
replace length = length/1000

twoway (connected length year if state==8, clpattern(solid) msymbol(circle) mlcolor(black) mfcolor(black) scheme(s2mono) ysize(10) ytitle("") ylabel(0 2 4 6 8 10 12 14 16) xsize(15) xtitle("") xlabel(1870 1880 1890 1900 1910 1920, nogrid) graphregion(fcolor(white) lstyle(solid)) legend(order(1 2 3 4 5 6) symplacement(left) rows(1) label(1 "Colorado") label(2 "Iowa") label(3 "Kansas") label(4 "Minnesota") label(5 "Nebraska") label(6 "Texas"))) (connected length year if state==19, clpattern(longdash) msymbol(triangle) mfcolor(black) mlcolor(black)) (connected length year if state==20, clpattern(shortdash) msymbol(square) mfcolor(black) mlcolor(black)) (connected length year if state==27, clpattern(longdash_dot) msymbol(circle_hollow) mlcolor(black)) (connected length year if state==31, clpattern(shortdash_dot) msymbol(triangle_hollow) mlcolor(black)) (connected length year if state==48, clpattern(dot) msymbol(square_hollow) mlcolor(black))
twoway (connected any year if state==8, clpattern(solid) msymbol(circle) mlcolor(black) mfcolor(black) scheme(s2mono) ysize(10) ytitle("") ylabel(0 0.2 0.4 0.6 0.8 1) xsize(15) xtitle("") xlabel(1870 1880 1890 1900 1910 1920, nogrid) graphregion(fcolor(white) lstyle(solid)) legend(order(1 2 3 4 5 6) symplacement(left) rows(1) label(1 "Colorado") label(2 "Iowa") label(3 "Kansas") label(4 "Minnesota") label(5 "Nebraska") label(6 "Texas"))) (connected any year if state==19, clpattern(longdash) msymbol(triangle) mfcolor(black) mlcolor(black)) (connected any year if state==20, clpattern(shortdash) msymbol(square) mfcolor(black) mlcolor(black)) (connected any year if state==27, clpattern(longdash_dot) msymbol(circle_hollow) mlcolor(black)) (connected any year if state==31, clpattern(shortdash_dot) msymbol(triangle_hollow) mlcolor(black)) (connected any year if state==48, clpattern(dot) msymbol(square_hollow) mlcolor(black))

clear
use `pre_rranalysis'
keep if sample==1

collapse (sum) length (mean) any, by(state year)
replace length = length/1000

twoway (connected length year if state==8, clpattern(solid) msymbol(circle) mlcolor(black) mfcolor(black) scheme(s2mono) ysize(10) ytitle("") ylabel(0 2 4 6 8 10 12 14 16) xsize(15) xtitle("") xlabel(1870 1880 1890 1900 1910 1920, nogrid) graphregion(fcolor(white) lstyle(solid)) legend(order(1 2 3 4 5 6) symplacement(left) rows(1) label(1 "Colorado") label(2 "Iowa") label(3 "Kansas") label(4 "Minnesota") label(5 "Nebraska") label(6 "Texas"))) (connected length year if state==19, clpattern(longdash) msymbol(triangle) mfcolor(black) mlcolor(black)) (connected length year if state==20, clpattern(shortdash) msymbol(square) mfcolor(black) mlcolor(black)) (connected length year if state==27, clpattern(longdash_dot) msymbol(circle_hollow) mlcolor(black)) (connected length year if state==31, clpattern(shortdash_dot) msymbol(triangle_hollow) mlcolor(black)) (connected length year if state==48, clpattern(dot) msymbol(square_hollow) mlcolor(black))
twoway (connected any year if state==8, clpattern(solid) msymbol(circle) mlcolor(black) mfcolor(black) scheme(s2mono) ysize(10) ytitle("") ylabel(0 0.2 0.4 0.6 0.8 1) xsize(15) xtitle("") xlabel(1870 1880 1890 1900 1910 1920, nogrid) graphregion(fcolor(white) lstyle(solid)) legend(order(1 2 3 4 5 6) symplacement(left) rows(1) label(1 "Colorado") label(2 "Iowa") label(3 "Kansas") label(4 "Minnesota") label(5 "Nebraska") label(6 "Texas"))) (connected any year if state==19, clpattern(longdash) msymbol(triangle) mfcolor(black) mlcolor(black)) (connected any year if state==20, clpattern(shortdash) msymbol(square) mfcolor(black) mlcolor(black)) (connected any year if state==27, clpattern(longdash_dot) msymbol(circle_hollow) mlcolor(black)) (connected any year if state==31, clpattern(shortdash_dot) msymbol(triangle_hollow) mlcolor(black)) (connected any year if state==48, clpattern(dot) msymbol(square_hollow) mlcolor(black))
set graphics off
*/

clear
use `pre_rranalysis'
keep if sample==1

collapse (sum) length (mean) any, by(year)

sum length if year==1870
sum length if year==1880
sum length if year==1890
sum length if year==1900
sum length if year==1910
sum length if year==1920

sum any if year==1870
sum any if year==1880
sum any if year==1890
sum any if year==1900
sum any if year==1910
sum any if year==1920

clear
insheet using 1870_nsew.txt, tab
rename id unfips
gen statefips=floor(unfips/1000)
keep if statefips==8|statefips==19|statefips==20|statefips==27|statefips==31|statefips==48
keep unfips yaxis xaxis
sort unfips
save `nsew_1870', replace

clear
use `preanalysis'
merge unfips year using `rr_base1870'
drop if _merge==2
replace length = 0 if _merge==1
drop _merge

sort unfips year

merge unfips using `nsew_1870'
keep if _merge==3
drop _merge
tab year_state if year!=1870, gen(d_year_state)
gen cutoff1=100
gen cutoff2=100

gen any = (length>0)
gen sl = length^2
gen cl = length^3
gen ql = length^4

tsset unfips year
by unfips: gen dlength = length - length[_n-1]
by unfips: gen dsl = sl - sl[_n-1]
by unfips: gen dcl = cl - cl[_n-1]
by unfips: gen dql = ql - ql[_n-1]
by unfips: gen dany = any - any[_n-1]

areg dlength _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920, absorb(year_state) cluster(unfips)
*Evaluate 0.06 vs. 0
nlcom (yy1880:.06*_b[_IyeaXtim_1880] + .0036*_b[_IyeaXsti_1880] + .000216*_b[_IyeaXcti_1880] + .00001296*_b[_IyeaXqti_1880]) (yy1890:.06*_b[_IyeaXtim_1890] + .0036*_b[_IyeaXsti_1890] + .000216*_b[_IyeaXcti_1890] + .00001296*_b[_IyeaXqti_1890]) (yy1900:.06*_b[_IyeaXtim_1900] + .0036*_b[_IyeaXsti_1900] + .000216*_b[_IyeaXcti_1900] + .00001296*_b[_IyeaXqti_1900]) (yy1910:.06*_b[_IyeaXtim_1910] + .0036*_b[_IyeaXsti_1910] + .000216*_b[_IyeaXcti_1910] + .00001296*_b[_IyeaXqti_1910]) (yy1920:.06*_b[_IyeaXtim_1920] + .0036*_b[_IyeaXsti_1920] + .000216*_b[_IyeaXcti_1920] + .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1880:.06*_b[_IyeaXtim_1880] + .0108*_b[_IyeaXsti_1880] + .001512*_b[_IyeaXcti_1880] + .0001944*_b[_IyeaXqti_1880]) (yyy1890:.06*_b[_IyeaXtim_1890] + .0108*_b[_IyeaXsti_1890] + .001512*_b[_IyeaXcti_1890] + .0001944*_b[_IyeaXqti_1890]) (yyy1900:.06*_b[_IyeaXtim_1900] + .0108*_b[_IyeaXsti_1900] + .001512*_b[_IyeaXcti_1900] + .0001944*_b[_IyeaXqti_1900]) (yyy1910:.06*_b[_IyeaXtim_1910] + .0108*_b[_IyeaXsti_1910] + .001512*_b[_IyeaXcti_1910] + .0001944*_b[_IyeaXqti_1910]) (yyy1920:.06*_b[_IyeaXtim_1920] + .0108*_b[_IyeaXsti_1920] + .001512*_b[_IyeaXcti_1920] + .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1880: .0072*_b[_IyeaXsti_1880] + .001296*_b[_IyeaXcti_1880] + .00018144*_b[_IyeaXqti_1880]) (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

drop if year==1870

x_ols xaxis yaxis cutoff1 cutoff2 diml_xx_aF _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 dlength d_year_state*, xreg(51) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])

drop epsilon window dis1 dis2
x_ols xaxis yaxis cutoff1 cutoff2 dfml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 dlength d_year_state*, xreg(51) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])

drop epsilon window dis1 dis2
x_ols xaxis yaxis cutoff1 cutoff2 diml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 dlength d_year_state*, xreg(51) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])

/*
*Polynomial in railroad
drop epsilon window dis1 dis2
x_ols xaxis yaxis cutoff1 cutoff2 diml_xx_aF _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 dlength dsl dcl dql d_year_state*, xreg(54) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])

drop epsilon window dis1 dis2
x_ols xaxis yaxis cutoff1 cutoff2 dfml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 dlength dsl dcl dql d_year_state*, xreg(54) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])

drop epsilon window dis1 dis2
x_ols xaxis yaxis cutoff1 cutoff2 diml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 dlength dsl dcl dql d_year_state*, xreg(54) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])

*Any railroad
drop epsilon window dis1 dis2
x_ols xaxis yaxis cutoff1 cutoff2 diml_xx_aF _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 dany d_year_state*, xreg(51) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])

drop epsilon window dis1 dis2
x_ols xaxis yaxis cutoff1 cutoff2 dfml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 dany d_year_state*, xreg(51) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])

drop epsilon window dis1 dis2
x_ols xaxis yaxis cutoff1 cutoff2 diml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 dany d_year_state*, xreg(51) coord(2)
mynlcom (yy1890:-.06*_b[__000006] - .0036*_b[__00000B] - .000216*_b[__00000G] - .00001296*_b[__00000L])
mynlcom (d1890: .0072*_b[__00000B] + .001296*_b[__00000G] + .00018144*_b[__00000L])
mynlcom (yy1900:-.06*_b[__000007] - .0036*_b[__00000C] - .000216*_b[__00000H] - .00001296*_b[__00000M])
mynlcom (d1900: .0072*_b[__00000C] + .001296*_b[__00000H] + .00018144*_b[__00000M])
*/


***
*Table 6, Land value analysis
***
clear
use `preanalysis'
qui{
keep if balance5==6
char year[omit]1870
xi: reg dlnprp_xx_vA i.year*i.state i.year*timber i.year*stimber i.year*ctimber i.year*qtimber i.year*valueln i.year*svalueln i.year*cvalueln i.year*qvalueln
}
areg dlnprp_xx_vA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 _IyeaXval_1880-_IyeaXval_1920 _IyeaXsva_1880-_IyeaXsva_1920 _IyeaXcva_1880-_IyeaXcva_1920 _IyeaXqva_1880-_IyeaXqva_1920 , absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1880:-.06*_b[_IyeaXtim_1880] - .0036*_b[_IyeaXsti_1880] - .000216*_b[_IyeaXcti_1880] - .00001296*_b[_IyeaXqti_1880]) (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1880:-.06*_b[_IyeaXtim_1880] - .0108*_b[_IyeaXsti_1880] - .001512*_b[_IyeaXcti_1880] - .0001944*_b[_IyeaXqti_1880]) (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1880: .0072*_b[_IyeaXsti_1880] + .001296*_b[_IyeaXcti_1880] + .00018144*_b[_IyeaXqti_1880]) (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

gen percent = farmbui/(farmbui+farmval)
sum percent if year==1900
sum percent if timber<.04 & year==1900
sum percent if timber>.04&timber<.08 & year==1900
sum percent if timber>.08&timber<.12 & year==1900

sum percent if year==1910
sum percent if timber<.04 & year==1910
sum percent if timber>.04&timber<.08 & year==1910
sum percent if timber>.08&timber<.12 & year==1910

sum timber if timber<.01&year==1880
sum prp_xx_v if timber<.01&year==1880
sum timber if timber>.01&timber<.02&year==1880
sum prp_xx_v if timber>.01&timber<.02&year==1880
sum timber if timber>.02&timber<.03&year==1880
sum prp_xx_v if timber>.02&timber<.03&year==1880
sum timber if timber>.03&timber<.04&year==1880
sum prp_xx_v if timber>.03&timber<.04&year==1880
sum timber if timber>.04&timber<.05&year==1880
sum prp_xx_v if timber>.04&timber<.05&year==1880
sum timber if timber>.05&timber<.06&year==1880
sum prp_xx_v if timber>.05&timber<.06&year==1880

areg dlnprp_xx_vA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 _IyeaXval_1880-_IyeaXval_1920 _IyeaXsva_1880-_IyeaXsva_1920 _IyeaXcva_1880-_IyeaXcva_1920 _IyeaXqva_1880-_IyeaXqva_1920 , absorb(year_state) cluster(unfips)
nlcom (g1:.0041492*_b[_IyeaXtim_1890] + (.0041492^2)*_b[_IyeaXsti_1890] + (.0041492^3)*_b[_IyeaXcti_1890] + (.0041492^4)*_b[_IyeaXqti_1890] - .06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (g2:0.0145476*_b[_IyeaXtim_1890] + 0.00021163266576*_b[_IyeaXsti_1890] + 0.00000307874736841018*_b[_IyeaXcti_1890] + 0.0000000447883852166839*_b[_IyeaXqti_1890] - .06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (g3:0.0248836*_b[_IyeaXtim_1890] + 0.00061919354896*_b[_IyeaXsti_1890] + 0.0000154077645949011*_b[_IyeaXcti_1890] + 0.00000038340065107368*_b[_IyeaXqti_1890] - .06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (g4:0.0347741*_b[_IyeaXtim_1890] + 0.00120923803081*_b[_IyeaXsti_1890] + 0.00004205016420719*_b[_IyeaXcti_1890] + 0.00000146225661515725*_b[_IyeaXqti_1890] - .06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (g5:0.0457764*_b[_IyeaXtim_1890] + 0.00209547879696*_b[_IyeaXsti_1890] + 0.0000959234756011598*_b[_IyeaXcti_1890] + 0.00000439103138850893*_b[_IyeaXqti_1890] - .06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (g6:0.0556349*_b[_IyeaXtim_1890] + 0.00309524209801*_b[_IyeaXsti_1890] + 0.000172203484598577*_b[_IyeaXcti_1890] + 0.00000958052364529335*_b[_IyeaXqti_1890] - .06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]), post
nlcom (h1: 2.71828182845904523536^_b[g1]-1) (h2: 2.71828182845904523536^_b[g2]-1) (h3: 2.71828182845904523536^_b[g3]-1) (h4: 2.71828182845904523536^_b[g4]-1) (h5: 2.71828182845904523536^_b[g5]-1) (h6: 2.71828182845904523536^_b[g6]-1), post
nlcom (value: 64*1716474*_b[h1] + 39*2716805*_b[h2] + 20*2289618*_b[h3] + 23*3284712*_b[h4] + 18*4686421*_b[h5] + 18*4848579*_b[h6]), post




***
*In text, correlation between measured woodland and Atlas woodland
***
clear
insheet using woodland_area1870.txt, tab
gen woodland = (id==2|id==7|id==8|id==10|id==12|id==13|id==14|id==15|id==16)
sort id_1 woodland
collapse (sum) new_area, by(id_1 woodland)
by id_1: gen add = sum(new_area)
by id_1: egen total = max(add) 
by id_1: gen frac_woodland = new_area/total if woodland==1
by id_1: egen woodland_percent = max(frac_woodland)
replace woodland_percent = 0 if woodland_percent==.
by id_1: keep if [_n]==1
keep id_1 woodland_percent
rename id_1 unfips
sort unfips
save `pre_woodland', replace

clear
use `preanalysis'
sort unfips year
merge unfips using `pre_woodland'
drop if _merge==2
drop _merge

pwcorr woodland_percent timber if year==1870, sig
pwcorr woodland_percent timber if state==8&year==1870, sig
pwcorr woodland_percent timber if state==19&year==1870, sig
pwcorr woodland_percent timber if state==20&year==1870, sig
pwcorr woodland_percent timber if state==27&year==1870, sig
pwcorr woodland_percent timber if state==31&year==1870, sig
pwcorr woodland_percent timber if state==48&year==1870, sig
/*
set graphics on
twoway (scatter woodland_percent timber if year==1870, title("All Counties"))
twoway (scatter woodland_percent timber if state==8&year==1870, title("Colorado"))
twoway (scatter woodland_percent timber if state==19&year==1870, title("Iowa"))
twoway (scatter woodland_percent timber if state==20&year==1870, title("Kansas"))
twoway (scatter woodland_percent timber if state==27&year==1870, title("Minnesota"))
twoway (scatter woodland_percent timber if state==31&year==1870, title("Nebraska"))
twoway (scatter woodland_percent timber if state==48&year==1870, title("Texas"))
set graphics off
*/
clear




***
*In text, Herd law analysis
***
clear
insheet using herd_law.txt, tab
replace herd = 0 if herd==1
replace herd=1 if herd==2
sort unfips
save `herd_law', replace
clear
use `preanalysis'
sort unfips
merge unfips using `herd_law'

*Kansas herd law analysis
scatter herd timber if year==1880&state==20&_merge==3
foreach year of numlist 1880(10)1920 {
gen h_`year' = _Iyear_`year'*herd
}
reg diml_xx_aF _Iyear_1880-_Iyear_1920 h_1880-h_1920 if state==20, noc cluster(unfips)
reg dfml_xx_aA _Iyear_1880-_Iyear_1920 h_1880-h_1920 if state==20, noc cluster(unfips)
reg diml_xx_aA _Iyear_1880-_Iyear_1920 h_1880-h_1920 if state==20, noc cluster(unfips)


*Nebraska state-wide analysis

*Improved land, per farm acre
areg diml_xx_aF _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 if state==31, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1880:-.06*_b[_IyeaXtim_1880] - .0036*_b[_IyeaXsti_1880] - .000216*_b[_IyeaXcti_1880] - .00001296*_b[_IyeaXqti_1880]) (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1880:-.06*_b[_IyeaXtim_1880] - .0108*_b[_IyeaXsti_1880] - .001512*_b[_IyeaXcti_1880] - .0001944*_b[_IyeaXqti_1880]) (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1880: .0072*_b[_IyeaXsti_1880] + .001296*_b[_IyeaXcti_1880] + .00018144*_b[_IyeaXqti_1880]) (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

*Farmland, per county acre
areg dfml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 if state==31, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1880:-.06*_b[_IyeaXtim_1880] - .0036*_b[_IyeaXsti_1880] - .000216*_b[_IyeaXcti_1880] - .00001296*_b[_IyeaXqti_1880]) (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1880:-.06*_b[_IyeaXtim_1880] - .0108*_b[_IyeaXsti_1880] - .001512*_b[_IyeaXcti_1880] - .0001944*_b[_IyeaXqti_1880]) (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1880: .0072*_b[_IyeaXsti_1880] + .001296*_b[_IyeaXcti_1880] + .00018144*_b[_IyeaXqti_1880]) (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

*Improved land, per county acre
areg diml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 if state==31, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1880:-.06*_b[_IyeaXtim_1880] - .0036*_b[_IyeaXsti_1880] - .000216*_b[_IyeaXcti_1880] - .00001296*_b[_IyeaXqti_1880]) (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1880:-.06*_b[_IyeaXtim_1880] - .0108*_b[_IyeaXsti_1880] - .001512*_b[_IyeaXcti_1880] - .0001944*_b[_IyeaXqti_1880]) (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1880: .0072*_b[_IyeaXsti_1880] + .001296*_b[_IyeaXcti_1880] + .00018144*_b[_IyeaXqti_1880]) (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])


*Kansas state-wide analysis

*Improved land, per farm acre
areg diml_xx_aF _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 if state==20, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1880:-.06*_b[_IyeaXtim_1880] - .0036*_b[_IyeaXsti_1880] - .000216*_b[_IyeaXcti_1880] - .00001296*_b[_IyeaXqti_1880]) (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1880:-.06*_b[_IyeaXtim_1880] - .0108*_b[_IyeaXsti_1880] - .001512*_b[_IyeaXcti_1880] - .0001944*_b[_IyeaXqti_1880]) (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1880: .0072*_b[_IyeaXsti_1880] + .001296*_b[_IyeaXcti_1880] + .00018144*_b[_IyeaXqti_1880]) (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

*Farmland, per county acre
areg dfml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 if state==20, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1880:-.06*_b[_IyeaXtim_1880] - .0036*_b[_IyeaXsti_1880] - .000216*_b[_IyeaXcti_1880] - .00001296*_b[_IyeaXqti_1880]) (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1880:-.06*_b[_IyeaXtim_1880] - .0108*_b[_IyeaXsti_1880] - .001512*_b[_IyeaXcti_1880] - .0001944*_b[_IyeaXqti_1880]) (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1880: .0072*_b[_IyeaXsti_1880] + .001296*_b[_IyeaXcti_1880] + .00018144*_b[_IyeaXqti_1880]) (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])

*Improved land, per county acre
areg diml_xx_aA _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920 if state==20, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1880:-.06*_b[_IyeaXtim_1880] - .0036*_b[_IyeaXsti_1880] - .000216*_b[_IyeaXcti_1880] - .00001296*_b[_IyeaXqti_1880]) (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1880:-.06*_b[_IyeaXtim_1880] - .0108*_b[_IyeaXsti_1880] - .001512*_b[_IyeaXcti_1880] - .0001944*_b[_IyeaXqti_1880]) (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1880: .0072*_b[_IyeaXsti_1880] + .001296*_b[_IyeaXcti_1880] + .00018144*_b[_IyeaXqti_1880]) (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])




***
*In text, Farm Size
***
clear
use `preanalysis'
gen lnavfsize = ln(fml_xx_a/frm_xx_q)
replace lnavfsize = . if lnavfsize<4|lnavfsize>8
tsset unfips year
by unfips: gen dlnavfsize = lnavfsize - lnavfsize[_n-1]
sort unfips year
by unfips: egen balance6 = count(lnavfsize)
keep if balance6==6
*Improved land, per farm acre
areg dlnavfsize _IyeaXtim_1880-_IyeaXtim_1920 _IyeaXsti_1880-_IyeaXsti_1920 _IyeaXcti_1880-_IyeaXcti_1920 _IyeaXqti_1880-_IyeaXqti_1920, absorb(year_state) cluster(unfips)
*Evaluate 0 vs. 0.06
nlcom (yy1880:-.06*_b[_IyeaXtim_1880] - .0036*_b[_IyeaXsti_1880] - .000216*_b[_IyeaXcti_1880] - .00001296*_b[_IyeaXqti_1880]) (yy1890:-.06*_b[_IyeaXtim_1890] - .0036*_b[_IyeaXsti_1890] - .000216*_b[_IyeaXcti_1890] - .00001296*_b[_IyeaXqti_1890]) (yy1900:-.06*_b[_IyeaXtim_1900] - .0036*_b[_IyeaXsti_1900] - .000216*_b[_IyeaXcti_1900] - .00001296*_b[_IyeaXqti_1900]) (yy1910:-.06*_b[_IyeaXtim_1910] - .0036*_b[_IyeaXsti_1910] - .000216*_b[_IyeaXcti_1910] - .00001296*_b[_IyeaXqti_1910]) (yy1920:-.06*_b[_IyeaXtim_1920] - .0036*_b[_IyeaXsti_1920] - .000216*_b[_IyeaXcti_1920] - .00001296*_b[_IyeaXqti_1920])
*Evaluate 0.12 vs. 0.06
nlcom (yyy1880:-.06*_b[_IyeaXtim_1880] - .0108*_b[_IyeaXsti_1880] - .001512*_b[_IyeaXcti_1880] - .0001944*_b[_IyeaXqti_1880]) (yyy1890:-.06*_b[_IyeaXtim_1890] - .0108*_b[_IyeaXsti_1890] - .001512*_b[_IyeaXcti_1890] - .0001944*_b[_IyeaXqti_1890]) (yyy1900:-.06*_b[_IyeaXtim_1900] - .0108*_b[_IyeaXsti_1900] - .001512*_b[_IyeaXcti_1900] - .0001944*_b[_IyeaXqti_1900]) (yyy1910:-.06*_b[_IyeaXtim_1910] - .0108*_b[_IyeaXsti_1910] - .001512*_b[_IyeaXcti_1910] - .0001944*_b[_IyeaXqti_1910]) (yyy1920:-.06*_b[_IyeaXtim_1920] - .0108*_b[_IyeaXsti_1920] - .001512*_b[_IyeaXcti_1920] - .0001944*_b[_IyeaXqti_1920])
*Calculate the difference of the two
nlcom (d1880: .0072*_b[_IyeaXsti_1880] + .001296*_b[_IyeaXcti_1880] + .00018144*_b[_IyeaXqti_1880]) (d1890: .0072*_b[_IyeaXsti_1890] + .001296*_b[_IyeaXcti_1890] + .00018144*_b[_IyeaXqti_1890]) (d1900: .0072*_b[_IyeaXsti_1900] + .001296*_b[_IyeaXcti_1900] + .00018144*_b[_IyeaXqti_1900]) (d1910: .0072*_b[_IyeaXsti_1910] + .001296*_b[_IyeaXcti_1910] + .00018144*_b[_IyeaXqti_1910]) (d1920: .0072*_b[_IyeaXsti_1920] + .001296*_b[_IyeaXcti_1920] + .00018144*_b[_IyeaXqti_1920])


log close
